defmodule CoffeeRouletteTest do
  use ExUnit.Case
  doctest CoffeeRoulette

  test "greets the world" do
    assert CoffeeRoulette.hello() == :world
  end
end
