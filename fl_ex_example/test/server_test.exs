defmodule FlExExample.ServerTest do
  use FlEx.ConnTest, endpoint: FlExExample.Server

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "should work /your_page/:param", %{conn: conn} do
    conn = get(conn, "/your_page/some_value")
    assert %{"some_key" => _} = json_response(conn, 200)
  end

  test "should work /api/v1/your_post", %{conn: conn} do
    conn = post(conn, "/api/v1/your_post", %{key: "value"})
    assert %{"message" => _} = json_response(conn, 201)
  end

end
