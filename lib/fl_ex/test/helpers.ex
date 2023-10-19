defmodule FlEx.Test.Helpers do
  @moduledoc """
  Contains the type of response handling and more helpers for all kinds of possible servers that you can create

  This module it's pre-imported in the module `FlEx.ConnTest`
  """

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
          raise "expected content-type for #{format}, got: #{inspect(h)}"
        end

      [_ | _] ->
        raise "more than one content-type was set, expected a #{format} response"
    end
  end

  defp response_content_type?(header, format) do
    case parse_content_type(header) do
      {part, subpart} ->
        format = Atom.to_string(format)

        format in MIME.extensions(part <> "/" <> subpart) or
          format == subpart or String.ends_with?(subpart, "+" <> format)

      _ ->
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
  @spec json_response(Conn.t(), status :: integer | atom) :: term
  def json_response(conn, status) do
    body = response(conn, status)
    _ = response_content_type(conn, :json)

    FlEx.Renderer.json_handler().decode!(body)
  end
end
