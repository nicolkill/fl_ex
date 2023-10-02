defmodule FlEx.PlugHandler do
  defmacro __using__(_) do
    quote do
      import FlEx.PlugHandler

      Module.register_attribute(__MODULE__, :plugs, accumulate: true)
      @before_compile FlEx.PlugHandler
    end
  end

  defmacro __before_compile__(env) do
    plugs = Module.get_attribute(env.module, :plugs)

    quote do
      def plugs(), do: unquote(Macro.escape(plugs))
    end
  end

  defmacro plug(plug, opts \\ []) do
    quote do
      @plugs {unquote(plug), unquote(opts)}
    end
  end

end
