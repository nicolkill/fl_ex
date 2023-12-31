defmodule FlExExample.ExampleController do

  def index(conn, %{"param" => param} = _params) do
    conn
    |> FlEx.Renderer.status(200)
    |> FlEx.Renderer.json(%{some_key: "value of param is #{param}"})
  end

  def function_name(conn, _params) do
    conn
    |> FlEx.Renderer.status(201)
    |> FlEx.Renderer.json(%{some_key: "no params here"})
  end

  def function_name_2(conn, %{"param" => param} = _params) do
    conn
    |> FlEx.Renderer.json(%{some_key: "value of param is #{param}"})
  end

  def create(conn, params) do
    IO.inspect(params, label: "post params")

    conn
    |> FlEx.Renderer.status(201)
    |> FlEx.Renderer.json(%{message: "received params", params: params})
  end

end