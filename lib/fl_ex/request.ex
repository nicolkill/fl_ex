defmodule FlEx.Server.Request do

  defmodule RouteNotFoundException do
    defexception message: "route not found"
  end

  defmacro __using__(opts) do
    quote do
      def server(),
          do: unquote(opts[:mod])

      def json_handler(),
        do:
          unquote(opts[:otp_app])
          |> Application.get_env(FlEx.Server, [])
          |> Keyword.get(:json_handler, Jason)

      defp encode!(data), do: json_handler().encode!(data)
      defp decode!(data), do: json_handler().decode!(data)

      plug :handle_call

#      def handle_call(
#            %{
#              method: method,
#              request_path: path,
#              body_params: %Plug.Conn.Unfetched{aspect: :body_params}
#            } = conn,
#            _
#          ) do
#
#        {:ok, body, _} = Plug.Conn.read_body(conn)
#
#        body =
#          case body do
#            "" ->
#              %{}
#
#            body ->
#              body
#              |> String.replace("\n", "")
#              |> String.replace("\\", "")
#              |> decode!()
#          end
#
#        request(method, path, conn, body)
#      end

      def handle_call(
            %{method: method, request_path: path, body_params: body_params, params: params} =
              conn,
            _
          ) do
        request(method, path, conn, Map.merge(body_params, params))
      end

      defp find_route(router_mod, method, structured_path) do
        result =
          Enum.flat_map(router_mod.routes(), fn route ->
            route_split =
              route.path
              |> String.split("/")
              |> Enum.with_index()

            {valid?, params} =
              Enum.reduce(route_split, {length(route_split) == length(structured_path) and route.method == method, %{}}, fn
                {"", _}, {valid?, path_params} ->
                  {valid?, path_params}

                {":" <> token, index}, {valid?, path_params} ->
                  value = Enum.at(structured_path, index)
                  {valid?, Map.put(path_params, token, value)}

                {token, index}, {valid?, path_params} ->
                  {valid? and token == Enum.at(structured_path, index), path_params}
              end)

            if valid?, do: [{route, params}], else: []
          end)

        case result do
          [] ->
            []

          [{route, path_params}] ->
            [{router_mod, route, path_params}]
        end
      end

      defp request(method, path, conn, params) do

        method =
          method
          |> String.downcase()
          |> String.to_atom()
        structured_path =
          String.split(path, "/")

        result =
          server()
          |> then(&(&1.routers()))
          |> Enum.flat_map(&find_route(&1, method, structured_path))

        case result do
          [] ->
            Plug.Conn.send_resp(conn, 404, encode!(%{message: "route not found"}))
          [{router_mod, route, path_params}] ->
            do_request(router_mod, route, conn, Map.merge(params, path_params))
        end
      rescue
        e ->
          message = Exception.message(e)
          Plug.Conn.send_resp(conn, 500, encode!(%{message: message}))

          reraise e, __STACKTRACE__
      end

      defp do_request(router_mod, route, conn, params) do
        %{
          module: mod,
          function: func,
          pipeline: pipe
        } = route

        pipeline =
          router_mod.plugs()
          |> then(&(&1 ++ pipe))
          |> Enum.map(fn {plug, opts} ->
            try do
              Module.split(plug)
              {plug, opts}
            rescue
              _ ->
                &apply(__MODULE__, plug, [&1])
            end
          end)

        conn = Plug.run(conn, pipeline)

        apply(mod, func, [conn, params])
      end
    end
  end
end
