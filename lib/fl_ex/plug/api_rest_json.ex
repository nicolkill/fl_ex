defmodule FlEx.Plug.ApiRestJson do
  @moduledoc """
  All the required to have an json api rest

  includes a body parser (json, multipart and form post), method override to use put/patch/delete and other http methods
  """

  use Plug.Builder

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(Plug.MethodOverride)

  def init(opts), do: opts

  def call(conn, opts) do
    super(conn, opts)
  end
end
