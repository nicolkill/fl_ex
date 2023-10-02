defmodule FlEx.Server.Supervisor do
  use Supervisor

  def start_link(otp_app, mod, opts \\ []) do
    with {:ok, _pid} = ok <-
           Supervisor.start_link(__MODULE__, {otp_app, mod, opts}, name: __MODULE__) do
      ok
    end
  end

  @doc false
  def init({otp_app, mod, opts}) do
    children = [
      server_children(opts, otp_app, mod)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp server_children(_opts, otp_app, mod),
    do: FlEx.Server.Cowboy.specs(otp_app, mod)
end
