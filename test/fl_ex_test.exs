defmodule FlExTest do
  use ExUnit.Case
  doctest FlEx

  defmodule ExampleServer do
    use FlEx.Server, otp_app: :fl_ex

    get "/your_page/:param", :my_func

    def my_func(conn, %{"param" => param} = _params) do
      conn
      |> FlEx.Renderer.status(200)
      |> FlEx.Renderer.json(%{some_key: "value of param is #{param}"})
    end
  end


  test "greets the world" do
    ExampleServer.__params__(:app)
    |> IO.inspect(label: ":app")
    ExampleServer.__params__(:external_routers)
    |> IO.inspect(label: ":external_routers")
    ExampleServer.__params__(:routes)
    |> IO.inspect(label: ":routes")
    ExampleServer.__params__(:plugs)
    |> IO.inspect(label: ":plugs")
  end

end
