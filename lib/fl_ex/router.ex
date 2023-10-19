defmodule FlEx.Router do
  @moduledoc """
  This module contains the routing implementation where you can define routes, pipelines for every route

  Example:

  ```elixir
  defmodule MyApp.SomeRouter do
    use FlEx.Router

    plug :accepts, ["json"]

    scope "/api/v1" do
      get "/your_page", MyApp.SomeOtherModule, :function_name
    end
  end
  ```
  """

  defmacro __using__(_) do
    quote do
      use FlEx.Router.Methods
      use FlEx.Plug.PlugHandler

      def init(opts),
          do: opts

      def call(conn, opts) do
        pipeline = Enum.map(plugs(), fn {plug, opts} ->
          try do
            Module.split(plug)
            {plug, opts}
          rescue
            _ ->
              fn conn ->
                apply(__MODULE__, plug, [conn, opts])
              end
          end
        end)

        conn
        |> Plug.Conn.fetch_cookies()
        |> Plug.Conn.fetch_query_params()
        |> Plug.run(pipeline)
      end
    end
  end
end