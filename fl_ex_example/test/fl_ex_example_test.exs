defmodule FlExExampleTest do
  use ExUnit.Case
  doctest FlExExample

  test "greets the world" do
    assert FlExExample.hello() == :world
  end
end
