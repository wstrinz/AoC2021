defmodule Aoc2021.Day1 do
  def count_increases(measurements) do
    measurements
    |> Enum.reduce([:infinity, 0], fn current, [last, count] ->
      if current > last do
        [current, count + 1]
      else
        [current, count]
      end
    end)
    |> Enum.at(-1)
  end

  def part1 do
    File.read!("inputs/day1.txt")
    |> String.split("\n")
    |> Enum.map(&(Integer.parse(&1) |> elem(0)))
    |> count_increases()
  end

  def part2 do
    measurements =
      File.read!("inputs/day1.txt")
      |> String.split("\n")
      |> Enum.map(&(Integer.parse(&1) |> elem(0)))

    0..(length(measurements) - 3)
    |> Enum.map(fn window_start ->
      Enum.slice(measurements, window_start..(window_start + 2))
      |> Enum.sum()
    end)
    |> count_increases()
  end

  def run do
    [part1(), part2()]
  end
end
