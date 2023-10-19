## Basic Usage

> IMPORTANT! this implementation comes from the point from a empty project, if you have some of the files mentioned
> just follow the line that says: `add to your file`

First you need create a module that will be your server, named `MyApp.Server`

```elixir
# lib/server.ex
defmodule MyApp.Server do
  use FlEx.Server, otp_app: :my_app

  plug Plug.Head
  plug Plug.RequestId
  plug Plug.Logger, log: :debug
  plug FlEx.Plug.Accepts, ["json"]
  # custom plug
  plug MyApp.Plugs.Auth

  # define directly your route 
  get "/your_page/:param", :my_func

  # also you can define a function from other module
  get "/your_page/:param", MyApp.SomeOtherModule, :function_name

  # or define a scope of routes

  scope "/api/v1" do
    # you can add your plugs that just will run on this scoped routes
    plug MyApp.Plugs.Auth

    get "/your_page", :my_func
    get "/your_page", MyApp.SomeOtherModule, :function_name

    # you can add exclusive plugs to just one route if you want
    get "/your_page", MyApp.SomeOtherModule, :function_name, Plug.ExamplePlug, {Plug.OtherExamplePlug, [opts: 1]}
  end

  def my_func(conn, %{"param" => param} = _params) do
    conn
    |> FlEx.Renderer.status(200)
    |> FlEx.Renderer.json(%{some_key: "value of param is #{param}"})
  end
end
```

Then create your Application module, this must have the previous `MyApp.Server` module added to the children list

```elixir
# lib/application.ex
defmodule MyApp.Application do
  use Application, otp_app: :my_app
  
  @impl true
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      MyApp.Server # add to your file
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

Then add your Application module to your application list to start in your `mix.exs` file, in case that this isn't done 
yet

```elixir
# add to the mix.exs
  def application do
    [
      mod: {MyApp.Application, []},
      extra_applications: [:logger]
    ]
  end
```

With this you have the basic server working now and you can start using it

## Commands

- `mix run --no-halt` to start the server
- `mix test` to run tests
