defmodule Aoc2021.DayTemplate do
  def part1(input) do
    input
  end

  def part2(_) do
    "?"
  end

  def run() do
    input = File.read!("inputs/dayTemplate.txt") |> String.split("\n")

    [part1(input), part2(input)]
  end
end
