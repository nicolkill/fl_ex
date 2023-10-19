## Testing

> Just remember that all the tests files must be `.exs` files

You can test your server using the module `FlEx.ConnTest` sharing with key `endpoint` your implemented server

To keep the dynamism of the project the recommendation it's create your own `conn_text.exs` helper and use this module
in the future controller/router/servers

```elixir
# test/conn_test.exs
defmodule FlExExample.ConnTest do
  defmacro __using__(_) do
    quote do
      use FlEx.ConnTest, endpoint: FlExExample.Server

      setup %{conn: conn} do
        {:ok, conn: put_req_header(conn, "accept", "application/json")}
      end
    end
  end
end
```

and just implement the module directly in your test file

```elixir
# test/server_test.exs
defmodule FlExExample.ServerTest do
  use FlExExample.ConnTest

  test "should work /your_page/:param", %{conn: conn} do
    conn = get(conn, "/your_page/some_value")
    assert %{"some_key" => _} = json_response(conn, 200)
  end

end
```

## Assertions

...
