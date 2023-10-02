defmodule FlEx.Server.Cowboy do
  require Logger

  def specs(otp_app, mod) do
    port =
      otp_app
      |> Application.get_env(FlEx.Server, [])
      |> Keyword.get(:port)
      |> then(&if is_nil(&1), do: "4000", else: &1)
      |> String.to_integer()

    Logger.info("Server module: #{mod}")
    Logger.info("starting server at http://localhost:#{port}")

    Plug.Cowboy.child_spec(scheme: :http, plug: mod, port: port)
  end
end
