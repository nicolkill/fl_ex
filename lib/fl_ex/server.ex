defmodule FlEx.Server do
  @moduledoc """
  The server module it's the main piece of the server, can be the only router or just a router forwarder, in all cases
  it's the init of all

  Example:

  ```elixir
  defmodule MyApp.Server do
    use FlEx.Server, otp_app: :my_app

    plug Plug.Head
    plug Plug.RequestId

    # define directly your route
    get "/your_page/:param", :my_func

    def my_func(conn, %{"param" => param} = _params) do
      conn
      |> FlEx.Renderer.status(200)
      |> FlEx.Renderer.json(%{some_key: "your param", param: param})
    end
  end
  ```
  """

  defmacro __using__(opts) do
    quote do
      @otp_app unquote(opts)[:otp_app] || raise("endpoint expects :otp_app to be given")

      unquote(server())
      unquote(params())
    end
  end

  defp server() do
    quote do
      use FlEx.Router

      use FlEx.Server.Request,
        otp_app: @otp_app,
        mod: __MODULE__

      import FlEx.Server

      def start_link(opts \\ []) do
        FlEx.Server.Supervisor.start_link(@otp_app, __MODULE__, opts)
      end

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :worker
        }
      end

      Module.register_attribute(__MODULE__, :external_routers, accumulate: true)
      @before_compile FlEx.Server
    end
  end

  defp params() do
    quote do
      def __params__(:app), do: @otp_app
      def __params__(:external_routers), do: @external_routers
      def __params__(:routes), do: @routes
      def __params__(:plugs), do: @plugs
    end
  end

  defmacro __before_compile__(env) do
    otp_app = Module.get_attribute(env.module, :otp_app)

    contents =
      quote do
        use FlEx.RendererFunctions, otp_app: unquote(otp_app)
      end

    Module.create(FlEx.Renderer, contents, env)

    routers =
      env.module
      |> Module.get_attribute(:external_routers)
      |> then(&([env.module] ++ &1))

    quote do
      @doc """
      returns all the defined modules in the server
      """
      @spec routers() :: [module()]
      def routers(),
        do: unquote(routers)
    end
  end

  @doc """
  Define a router module to forward all the request in case tha some request matches with the route

  Example:

  ```
  define_router MyApp.SomeRouter
  """
  defmacro define_router(mod) do
    quote do
      @external_routers unquote(mod)
    end
  end
end
