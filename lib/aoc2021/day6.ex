defmodule Aoc2021.Day6 do
  def tick(input) do
    1..8
    |> Enum.reduce(input, fn num, counts ->
      Map.put(counts, num - 1, Map.get(input, num, 0))
    end)
    |> Map.update(6, 0, fn last_sixes ->
      last_sixes + Map.get(input, 0, 0)
    end)
    |> Map.put(8, Map.get(input, 0, 0))
  end

  def part1(input) do
    0..79
    |> Enum.reduce(input, fn _, state -> tick(state) end)
    |> Map.values()
    |> Enum.sum()
  end

  def part2(input) do
    0..255
    |> Enum.reduce(input, fn _, state -> tick(state) end)
    |> Map.values()
    |> Enum.sum()
  end

  def run() do
    input =
      File.read!("inputs/day6.txt")
      |> String.split(",")
      |> Enum.map(&Integer.parse/1)
      |> Enum.map(&elem(&1, 0))
      |> Enum.frequencies()

    [part1(input), part2(input)]
  end
end
