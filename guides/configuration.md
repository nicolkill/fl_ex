## Configuration

You can configure your server in the `config/config.exs` file

```elixir
# config/config.exs
import Config #add in case that doesn't exist

config :fl_ex_example, FlEx.Server,
  port: System.get_env("PORT"),
  json_handler: Jason
```

| key | type | default | desc |
|---|---|---|---|
| port | :string | 4000 | server port |
| json_handler | Module | [Jason](https://github.com/michalmuskala/jason) | The module that partses string to map and viseversa |
