defmodule FlEx.RendererFunctions do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      def json_handler(),
          do:
            unquote(opts[:otp_app])
            |> Application.get_env(FlEx.Server, [])
            |> Keyword.get(:json_handler, Jason)

      defp encode!(data), do: json_handler().encode!(data)
      defp decode!(data), do: json_handler().decode!(data)

      @spec status(Plug.Conn.t(), integer()) :: Plug.Conn.t()
      def status(conn, status) do
        Plug.Conn.assign(conn, :status, status)
      end

      @spec json(Plug.Conn.t(), map()) :: Plug.Conn.t()
      def json(conn, data) do
        status = Map.get(conn.assigns, :status, 200)
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(status, encode!(data))
      end

    end
  end
end
