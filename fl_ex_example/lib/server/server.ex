defmodule FlExExample.Server do
  use FlEx.Server, otp_app: :fl_ex_example

  plug Plug.Head
  plug FlEx.Plug.Logger

  define_router FlExExample.Router
end