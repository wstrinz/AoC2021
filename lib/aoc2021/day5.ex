defmodule Aoc2021.Day5 do
  def parse_line(line) do
    [start, ed] = String.split(line, " -> ")
    [startx, starty] = String.split(start, ",") |> Enum.map(&(Integer.parse(&1) |> elem(0)))
    [endx, endy] = String.split(ed, ",") |> Enum.map(&(Integer.parse(&1) |> elem(0)))

    [[startx, starty], [endx, endy]]
  end

  def non_diagonal?(line) do
    [[startx, starty], [endx, endy]] = parse_line(line)

    startx == endx || starty == endy
  end

  def points_between([[startx, starty], [endx, endy]]) do
    cond do
      startx == endx ->
        starty..endy
        |> Enum.map(&[startx, &1])

      starty == endy ->
        startx..endx
        |> Enum.map(&[&1, starty])

      true ->
        offset =
          if endy > starty do
            1
          else
            -1
          end

        if endx > startx do
          startx..endx
          |> Enum.map(fn x ->
            [x, starty + (x - startx) * offset]
          end)
        else
          startx..endx
          |> Enum.map(fn x ->
            [x, starty + (startx - x) * offset]
          end)
        end
    end
  end

  def mark_vent(point, field) do
    Map.update(field, point, 1, &(&1 + 1))
  end

  def mark_vents(line, field) do
    line
    |> parse_line()
    |> points_between()
    |> Enum.reduce(field, &mark_vent/2)
  end

  def part1(input) do
    input
    |> Enum.reduce(Map.new(), fn line, current_field ->
      if non_diagonal?(line) do
        mark_vents(line, current_field)
      else
        current_field
      end
    end)
    |> Map.values()
    |> Enum.count(&(&1 > 1))
  end

  def part2(input) do
    input
    |> Enum.reduce(Map.new(), &mark_vents/2)
    |> Map.values()
    |> Enum.count(&(&1 > 1))
  end

  def run() do
    input = File.read!("inputs/day5.txt") |> String.split("\n")

    [part1(input), part2(input)]
  end
end
