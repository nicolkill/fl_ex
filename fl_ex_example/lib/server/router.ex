defmodule FlExExample.Router do
  use FlEx.Router

  plug FlEx.Plug.Accepts, ["application/json"]

  get "/your_page/:param", FlExExample.ExampleController, :index
  get "/another_page/:param/more_complex/:param_2", :func

  def func(conn, %{"param" => param, "param_2" => _param_2} = _params) do
    IO.inspect(@plugs, label: "func")

    conn
    |> FlEx.Renderer.status(200)
    |> FlEx.Renderer.json(%{some_key: "value of param is #{param}"})
  end

  scope "/api/v1" do
    plug FlEx.Plug.Accepts, ["application/xml"]

    get "/your_scoped_page", FlExExample.ExampleController, :function_name, FlEx.Plug.Accepts
    get "/your_scoped_page/:param", FlExExample.ExampleController, :function_name_2, {FlEx.Plug.Accepts, ["json"]}
  end
end
