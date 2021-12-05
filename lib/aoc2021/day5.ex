defmodule Aoc2021.Day5 do
  def parse_line(line) do
    [start, ed] = String.split(line, " -> ")
    [startx, starty] = String.split(start, ",") |> Enum.map(&(Integer.parse(&1) |> elem(0)))
    [endx, endy] = String.split(ed, ",") |> Enum.map(&(Integer.parse(&1) |> elem(0)))

    [[startx, starty], [endx, endy]]
  end

  def non_diagonal(line) do
    [[startx, starty], [endx, endy]] = parse_line(line)

    startx == endx || starty == endy
  end

  def print_field(field) do
    field
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()

    IO.puts("\n")

    field
  end

  def determine_bounds(input) do
    input
    |> Enum.reduce([0, 0], fn line, [maxx, maxy] ->
      [[startx, starty], [endx, endy]] = parse_line(line)

      newx =
        if Enum.max([startx, endx]) > maxx do
          Enum.max([startx, endx])
        else
          maxx
        end

      newy =
        if Enum.max([starty, endy]) > maxy do
          Enum.max([starty, endy])
        else
          maxx
        end

      [newx, newy]
    end)
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

  def mark_vent([x, y], field) do
    row = Enum.at(field, y)
    value = Enum.at(row, x)

    field
    |> List.replace_at(y, List.replace_at(row, x, value + 1))
  end

  def mark_vents(line, field) do
    line
    |> parse_line()
    |> points_between()
    |> Enum.reduce(field, &mark_vent/2)
  end

  def part1(input) do
    [maxx, maxy] = determine_bounds(input)
    field = List.duplicate(List.duplicate(0, maxx + 1), maxy + 1)

    input
    |> Enum.reduce(field, fn line, current_field ->
      if non_diagonal(line) do
        mark_vents(line, current_field)
      else
        current_field
      end
    end)
    |> Enum.map(fn row ->
      row
      |> Enum.filter(&(&1 > 1))
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def part2(input) do
    [maxx, maxy] = determine_bounds(input)
    field = List.duplicate(List.duplicate(0, maxx + 1), maxy + 1)

    input
    |> Enum.reduce(field, &mark_vents/2)
    |> Enum.map(fn row ->
      row
      |> Enum.filter(&(&1 > 1))
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def run() do
    input = File.read!("inputs/day5.txt") |> String.split("\n")

    [part1(input), part2(input)]
  end
end
