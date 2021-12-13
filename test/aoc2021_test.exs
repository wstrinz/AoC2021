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

  test "day6" do
    assert Aoc2021.Day6.run() == [358_214, 1_622_533_344_325]
  end

  test "day7" do
    assert Aoc2021.Day7.run() == [355_764, 99_634_572]
  end

  test "day8" do
    assert Aoc2021.Day8.run() == [539, 1_084_606]
  end

  test "day9" do
    assert Aoc2021.Day9.run() == [444, 1_168_440]
  end

  test "day10" do
    assert Aoc2021.Day10.run() == [389_589, 1_190_420_163]
  end

  test "day11" do
    assert Aoc2021.Day11.run() == [1732, 290]
  end

  test "day12" do
    assert Aoc2021.Day12.run() == %{part1: 4413, part2: 118_803}
  end

  test "day13" do
    map_string = """
    ####..##..#..#..##..#..#.###..####..##.
    #....#..#.#.#..#..#.#.#..#..#....#.#..#
    ###..#....##...#....##...###....#..#...
    #....#.##.#.#..#....#.#..#..#..#...#.##
    #....#..#.#.#..#..#.#.#..#..#.#....#..#
    #.....###.#..#..##..#..#.###..####..###
    """

    assert Aoc2021.Day13.run() == %{part1: 687, part2: String.trim(map_string)}
  end
end
