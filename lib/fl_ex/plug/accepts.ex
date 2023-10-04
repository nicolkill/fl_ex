defmodule FlEx.Plug.Accepts do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, [type]),
      do: put_req_header(conn, "accept", type)
  def call(conn, _),
      do: conn
end
