defmodule FlExTest do
  use ExUnit.Case
  doctest FlEx

  test "greets the world" do
    assert FlEx.hello() == :world
  end
end
