defmodule FlEx.ConnTest do

  defmacro __using__(opts) do
    http_methods = [:get, :post, :put, :patch, :delete]
    methods = Enum.map(http_methods, fn method ->
      quote do
        @doc """
        Dispatches to the current endpoint.

        See `dispatch/5` for more information.
        """
        def unquote(method)(conn, path_or_action, params_or_body \\ nil) do
          FlEx.ConnTest.request(conn, unquote(opts[:endpoint]), unquote(method), path_or_action, params_or_body)
        end
      end
    end)

    quote do
      use ExUnit.Case, async: true
      use Plug.Test

      import Plug.Conn
      import FlEx.ConnTest

      setup _ do
        {:ok, conn: build_conn()}
      end

      unquote(methods)
    end
  end

  @doc """
  Creates a connection.
  """
  @spec build_conn() :: Conn.t
  def build_conn() do
    build_conn(:get, "/", nil)
  end

  @doc """
  Creates a connection with a preset method, path and body.
  """
  @spec build_conn(atom | binary, binary, binary | list | map | nil) :: Conn.t()
  def build_conn(method, path, params_or_body \\ nil) do
    Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, method, path, params_or_body)
  end

  def request(%Plug.Conn{} = conn, endpoint, method, path_or_action, params_or_body) do
    if is_binary(params_or_body) and is_nil(List.keyfind(conn.req_headers, "content-type", 0)) do
      raise ArgumentError, "a content-type header is required when setting " <>
                           "a binary body in a test connection"
    end

    conn
    |> ensure_recycled()
    |> request_endpoint(endpoint, method, path_or_action, params_or_body)
    |> Plug.Conn.put_private(:phoenix_recycled, false)
    |> send_resp()
  end

  defp request_endpoint(conn, endpoint, method, path, params_or_body) when is_binary(path) do
    conn
    |> Plug.Adapters.Test.Conn.conn(method, path, params_or_body)
    |> endpoint.call(endpoint.init([]))
  end

  defp request_endpoint(conn, endpoint, method, action, params_or_body) when is_atom(action) do
    conn
    |> Plug.Adapters.Test.Conn.conn(method, "/", params_or_body)
    |> endpoint.call(endpoint.init(action))
  end

  defp send_resp(%Plug.Conn{state: :set} = conn), do: Plug.Conn.send_resp(conn)
  defp send_resp(conn), do: conn

  @doc """
  Recycles the connection.

  Recycling receives a connection and returns a new connection,
  containing cookies and relevant information from the given one.

  This emulates behaviour performed by browsers where cookies
  returned in the response are available in following requests.

  Note `recycle/1` is automatically invoked when dispatching
  to the endpoint, unless the connection has already been
  recycled.
  """
  @spec recycle(Conn.t(), [String.t()]) :: Conn.t()
  def recycle(conn, headers \\ ~w(accept accept-language authorization)) do
    build_conn()
    |> Map.put(:host, conn.host)
    |> Plug.Test.recycle_cookies(conn)
    |> Plug.Test.put_peer_data(Plug.Conn.get_peer_data(conn))
    |> copy_headers(conn.req_headers, headers)
  end

  defp copy_headers(conn, headers, copy) do
    headers = for {k, v} <- headers, k in copy, do: {k, v}
    %{conn | req_headers: headers ++ conn.req_headers}
  end

  @doc """
  Ensures the connection is recycled ans recycles in case that wasn't.
  """
  @spec ensure_recycled(Conn.t()) :: Conn.t()
  def ensure_recycled(conn) do
    if conn.private[:phoenix_recycled] do
      conn
    else
      recycle(conn)
    end
  end

  @doc """
  Asserts the given status code and returns the response body
  if one was set or sent.

  ## Examples

      conn = get(build_conn(), "/")
      assert response(conn, 200) =~ "hello world"

  """
  @spec response(Plug.Conn.t(), status :: integer | atom) :: binary
  def response(%Plug.Conn{state: :unset}, _status) do
    raise """
    expected connection to have a response but no response was set/sent.
    Please verify that you assign to "conn" after a request:

        conn = get(conn, "/")
        assert html_response(conn) =~ "Hello"
    """
  end

  def response(%Plug.Conn{status: status, resp_body: body}, given) do
    given = Plug.Conn.Status.code(given)

    if given == status do
      body
    else
      raise "expected response with status #{given}, got: #{status}, with body:\n#{inspect(body)}"
    end
  end

  @doc """
  Returns the content type as long as it matches the given format.

  ## Examples

      # Assert we have an html response with utf-8 charset
      assert response_content_type(conn, :html) =~ "charset=utf-8"

  """
  @spec response_content_type(Plug.Conn.t(), atom) :: String.t()
  def response_content_type(conn, format) when is_atom(format) do
    case Plug.Conn.get_resp_header(conn, "content-type") do
      [] ->
        raise "no content-type was set, expected a #{format} response"
      [h] ->
        if response_content_type?(h, format) do
          h
        else
          raise "expected content-type for #{format}, got: #{inspect h}"
        end
      [_|_] ->
        raise "more than one content-type was set, expected a #{format} response"
    end
  end

  defp response_content_type?(header, format) do
    case parse_content_type(header) do
      {part, subpart} ->
        format = Atom.to_string(format)
        format in MIME.extensions(part <> "/" <> subpart) or
        format == subpart or String.ends_with?(subpart, "+" <> format)
      _  ->
        false
    end
  end

  defp parse_content_type(header) do
    case Plug.Conn.Utils.content_type(header) do
      {:ok, part, subpart, _params} ->
        {part, subpart}
      _ ->
        false
    end
  end

  @doc """
  Asserts the given status code, that we have a json response and
  returns the decoded JSON response if one was set or sent.

  ## Examples

      body = json_response(conn, 200)
      assert "can't be blank" in body["errors"]

  """
  @spec json_response(Conn.t, status :: integer | atom) :: term
  def json_response(conn, status) do
    body = response(conn, status)
    _ = response_content_type(conn, :json)

    FlEx.Renderer.json_handler().decode!(body)
  end

end
