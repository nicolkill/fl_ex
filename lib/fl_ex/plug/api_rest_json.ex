defmodule FlEx.Plug.ApiRestJson do
  @moduledoc """
  All the required to have an json api rest
  """

  use Plug.Builder

#  import Plug.Conn

  plug Plug.Parsers,
       parsers: [:urlencoded, :multipart, :json],
       pass: ["*/*"],
       json_decoder: Jason
  plug Plug.MethodOverride

  def init(opts), do: opts

  def call(conn, opts) do
    super(conn, opts)
  end

end
