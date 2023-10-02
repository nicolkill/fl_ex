defmodule FlEx.Server do
  defmacro __using__(opts) do
    quote do
      @otp_app unquote(opts)[:otp_app] || raise("endpoint expects :otp_app to be given")

      unquote(server())
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
      def routers(),
          do: unquote(routers)
    end
  end

  defmacro define_router(mod) do
    quote do
      @external_routers unquote(mod)
    end
  end
end
