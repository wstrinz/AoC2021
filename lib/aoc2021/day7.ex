defmodule Aoc2021.Day7 do
  def part1(input) do
    0..Enum.max(input)
    |> Enum.reduce([], fn location, costs ->
      [
        Enum.map(input, fn crab ->
          abs(crab - location)
        end)
        |> Enum.sum()
        | costs
      ]
    end)
    |> Enum.min()
  end

  def part2(input) do
    0..Enum.max(input)
    |> Enum.reduce([], fn location, costs ->
      [
        Enum.map(input, fn crab ->
          diff = abs(crab - location)
          trunc((diff + 1) * diff / 2)
        end)
        |> Enum.sum()
        | costs
      ]
    end)
    |> Enum.min()
  end

  def run() do
    input =
      File.read!("inputs/day7.txt")
      |> String.split(",")
      |> Enum.map(&Integer.parse/1)
      |> Enum.map(&elem(&1, 0))

    [part1(input), part2(input)]
  end
end
