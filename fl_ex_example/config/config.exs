import Config

config :fl_ex_example, FlExExample.Server,
  port: System.get_env("PORT")

config :logger, :console, metadata: [:request_id]
