## FlEx

FlEx it's a micro-framework for backend inspired by the simplicity of Flask and the complication to use Phoenix in very
small applications

One of the cores of this micro-framework it's be flexible, you can define your whole app in a single file or split in a 
lot of more files, basic rules, nothing to be followed

This project doesn't pretend to replace Phoenix, the opposite we LOVE Phoenix and we're taking a lot of inspiration on 
the use and implementation of Phoenix, but sometimes a lot of stuff it's too overkill for some very small servers and 
more when you want to create a very small service

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fl_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fl_ex, "~> 0.1.0"}
  ]
end
```

## Basic Usage

> IMPORTANT! this implementation comes from the point from a empty project, if you have some of the files mentioned
> just follow the line that says: `add to your file`

First you need create a module that will be your server

```elixir
defmodule MyApp.Server do
  use FlEx.Server

  plug :accepts, ["json"]
  plug MyApp.Plugs.Auth

  # define directly your route 
  get "/your_page/:param", &my_func/2

  # also you can define a function from other module
  get "/your_page/:param", MyApp.SomeOtherModule, :function_name

  # or define a scope of routes

  scope "/api/v1" do
    get "/your_page", &my_func/2
    get "/your_page", MyApp.SomeOtherModule, :function_name
  end

  def my_func(conn, %{"param" => param} = _params) do
    conn
    |> FlEx.Renderer.status(200)
    |> FlEx.Renderer.json(%{some_key: "value of param is #{param}"})
  end
end
```

Then create your Application module, this must have the previous server added to the childer list

```elixir
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
  def application do
    [
      mod: {MyApp.Application, []},
      extra_applications: [:logger]
    ]
  end
```

With this you have the basic server working now and you can start using it

## Routes

The `FlEx.Server` allows to define routes and plugs directly, but what if you want to define your routes in other places
and just merge all the routes in the server, for this you need `FlEx.Router`

```elixir
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

defmodule MyApp.Server do
  use FlEx.Server

  define_router MyApp.SomeRouter
end
```

## Configure

You can configure your server in the `config/config.exs` file

```elixir
import Config

config :fl_ex_example, FlEx.Server,
  port: System.get_env("PORT"),
  json_handler: Jason
```

| key | type | desc |
|---|---|---|
| port | :tring | server port |

## How to test

todo...
