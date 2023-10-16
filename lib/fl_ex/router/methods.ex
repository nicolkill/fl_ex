defmodule FlEx.Router.Methods do
  defmacro __using__(_) do
    quote do
      import FlEx.Router.Methods

      Module.register_attribute(__MODULE__, :routes, accumulate: true)
      @before_compile FlEx.Router.Methods
    end
  end

  defmacro __before_compile__(env) do
    routes =
      env.module
      |> Module.get_attribute(:routes)
      |> Enum.reverse()

    routes = Enum.map(routes, fn
      %{module: nil} = route ->
        Map.put(route, :module, env.module)
      route ->
        route
    end)

    quote do
      def routes(), do: unquote(Macro.escape(routes))
    end
  end

  defp add_path(method, path, module, function, pipeline) do
    quote do
      @routes %{
        method: unquote(method),
        path: unquote(path),
        module: unquote(module),
        function: unquote(function),
        pipeline: unquote(pipeline)
      }
    end
  end

  @http_methods [:get, :post, :put, :patch, :delete]

  for method <- @http_methods do
    defmacro unquote(method)(path, module, function \\ [], pipeline \\ nil)
    defmacro unquote(method)(path, function, [], nil),
             do: add_path(unquote(method), path, nil, function, [])
    defmacro unquote(method)(path, module, function, nil),
             do: add_path(unquote(method), path, module, function, [])
    defmacro unquote(method)(path, module, function, pipeline),
             do: add_path(unquote(method), path, module, function, pipeline)
  end

  @allowed_scoped_methods [:get, :post, :put, :patch, :delete]

  defmacro scope(path, do: {:__block__, opts, scoped_routes}) do
    plugs = Enum.flat_map(scoped_routes, fn
      {:plug, _, [plug]} ->
        [{plug, []}]
      {:plug, _, [plug, opts]} ->
        [{plug, opts}]
      _ ->
        []
    end)

    scoped_routes = Enum.flat_map(scoped_routes, fn
      {method, line, [sub_path, mod, func_name | pipelines]} when method in @allowed_scoped_methods ->
        new_sub_path =
          String.split(path, "/") ++ String.split(sub_path, "/")
          |> Enum.filter(&(&1 != ""))
          |> Enum.join("/")
          |> then(&("/#{&1}"))
        [{method, line, [new_sub_path, mod, func_name, pipelines ++ plugs]}]
      _ ->
        []
    end)

#    IO.inspect(plugs, label: "plugs")
#    IO.inspect(scoped_routes, label: "scoped_routes")

    quote do
      unquote({:__block__, opts, scoped_routes})
    end
  end
  defmacro scope(_, _),
           do: raise(ArgumentError, "scope macro must receive a block as argument")

end