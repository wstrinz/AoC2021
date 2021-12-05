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

  test "day4" do
    assert Aoc2021.Day4.run() == [46920, 12635]
  end

  test "day5" do
    assert Aoc2021.Day5.run() == [6267, 20196]
  end
end
