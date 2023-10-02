defmodule FlExExample.Server do
  use FlEx.Server, otp_app: :fl_ex_example

  plug Plug.Head
  plug Plug.RequestId
  plug Plug.Logger, log: :debug

  define_router FlExExample.Router
end