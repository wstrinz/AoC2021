defmodule Aoc2021Test do
  use ExUnit.Case
  doctest Aoc2021

  test "day1" do
    assert Aoc2021.Day1.run() == [1722, 1748]
  end

  test "day2" do
    assert Aoc2021.Day2.run() == [1_580_000, 1_251_263_225]
  end

  test "day3" do
    assert Aoc2021.Day3.run() == [845_186, 4_636_702]
  end
end
