defmodule FlEx.Router do

  defmacro __using__(_) do
    quote do
      use FlEx.Router.Methods
      use FlEx.PlugHandler

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

        Plug.run(conn, pipeline)
      end
    end
  end
end