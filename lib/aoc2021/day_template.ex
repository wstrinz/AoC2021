defmodule Aoc2021.DayTemplate do
  def run() do
    input =
      File.read!("inputs/dayTemplate.txt") |> String.split("\n") |> Enum.map(&String.to_integer/1)

    part1 = input

    part2 = "?"

    [part1, part2]
  end
end
