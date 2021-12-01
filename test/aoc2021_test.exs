defmodule Aoc2021Test do
  use ExUnit.Case
  doctest Aoc2021

  test "day1" do
    assert Aoc2021.Day1.run() == [1722, 1748]
  end
end
