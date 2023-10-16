defmodule FlEx.Plug.Logger do
  @moduledoc """
  Pre-configured logger with some pressets depending the env
  """

  use Plug.Builder

#  import Plug.Conn

  plug Plug.RequestId

  if Mix.env() == :dev do
    plug Plug.Logger, log: :debug
  end

  def init(opts), do: opts

  def call(conn, opts) do
    super(conn, opts)
  end

end
