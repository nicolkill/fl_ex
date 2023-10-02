defmodule FlEx.Plug.Accepts do
  def init(opts), do: opts

  def call(conn, opts) do
    IO.inspect(opts, label: "accepts")

    conn
  end
end
