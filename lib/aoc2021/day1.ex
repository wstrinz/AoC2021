defmodule Aoc2021.Day1 do
  def part1 do
    File.read!("inputs/day1.txt")
    |> String.split("\n")
    |> Enum.reduce([999, 0], fn x, [last, count] ->
      current = elem(Integer.parse(x), 0)

      if current > last do
        [current, count + 1]
      else
        [current, count]
      end
    end)
    |> Enum.at(-1)
    |> IO.puts()
  end

  def part2 do
    measurements =
      File.read!("inputs/day1.txt")
      |> String.split("\n")
      |> Enum.map(&(Integer.parse(&1) |> elem(0)))

    count = length(measurements)

    0..(count - 3)
    |> Enum.map(fn window_start ->
      Enum.sum(Enum.slice(measurements, window_start..(window_start + 2)))
    end)
    |> Enum.reduce([9999, 0], fn current, [last, count] ->
      if current > last do
        [current, count + 1]
      else
        [current, count]
      end
    end)
    |> Enum.at(-1)
    |> IO.puts()
  end

  def run do
    part1()
    part2()
  end
end
