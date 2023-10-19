defmodule FlEx.Plug.PlugHandler do
  @moduledoc """
  This module helps to store in module all the plugs defined in routers in the same definition sorting

  > This module it's just for internal use, it's not necessary implement
  """

  defmacro __using__(_) do
    quote do
      import FlEx.Plug.PlugHandler

      Module.register_attribute(__MODULE__, :plugs, accumulate: true)
      @before_compile FlEx.Plug.PlugHandler
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
