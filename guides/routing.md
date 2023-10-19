## Routing

The `FlEx.Server` allows to define routes and plugs directly, but what if you want to define your routes in other places
and just merge all the routes in the server, for this you need `FlEx.Router`

```elixir
# lib/some_router.ex
defmodule MyApp.SomeRouter do
  use FlEx.Router

  plug :accepts, ["json"]

  scope "/api/v1" do
    get "/your_page", MyApp.SomeOtherModule, :function_name
  end
end
```

and add to the server module the next line

```elixir
# lib/server.ex
defmodule MyApp.Server do
  use FlEx.Server, otp_app: :my_app

  define_router MyApp.SomeRouter
end
```
