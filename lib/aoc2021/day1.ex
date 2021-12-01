defmodule Aoc2021.Day1 do
  @measurements Aoc2021.Util.read_ints("day1.txt")

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
    @measurements
    |> count_increases()
  end

  def part2 do
    0..(length(@measurements) - 3)
    |> Enum.map(fn window_start ->
      Enum.slice(@measurements, window_start..(window_start + 2))
      |> Enum.sum()
    end)
    |> count_increases()
  end

  def run do
    [part1(), part2()]
  end
end
