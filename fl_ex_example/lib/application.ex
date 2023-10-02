defmodule FlExExample.Application do
  use Application

  require Logger

  defmodule Server do
    def init(options), do: options |> IO.inspect(label: "init")

    def call(conn, _opts) do
      conn
      |> Plug.Conn.put_resp_content_type("text/plain")
      |> Plug.Conn.send_resp(200, "Hello World!\n")
    end
  end

  @impl true
  def start(_type, _args) do
    children = [
      FlExExample.Server
    ]

    Logger.info("starting application")

    opts = [strategy: :one_for_one, name: FlExExample.Supervisor]
    Supervisor.start_link(children, opts)
  end
end