defmodule Aoc2021.Day6 do
  def tick(input) do
    1..8
    |> Enum.reduce(input, fn num, counts ->
      Map.put(counts, num - 1, Map.get(input, num, 0))
    end)
    |> Map.update(6, 0, &(&1 + Map.get(input, 0, 0)))
    |> Map.put(8, Map.get(input, 0, 0))
  end

  def fish_at_tick(input, ticks) do
    0..(ticks - 1)
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

    [fish_at_tick(input, 80), fish_at_tick(input, 256)]
  end
end
