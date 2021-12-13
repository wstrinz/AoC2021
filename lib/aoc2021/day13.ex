defmodule Aoc2021.Day13 do
  def parse_paper(input) do
    [points, folds] = String.split(input, "\n\n")

    parsed_points =
      points
      |> String.split("\n")
      |> Enum.reduce(MapSet.new(), fn point, set ->
        [x, y] = String.split(point, ",") |> Enum.map(&Integer.parse/1) |> Enum.map(&elem(&1, 0))
        MapSet.put(set, {x, y})
      end)

    parsed_folds =
      folds
      |> String.split("\n")
      |> Enum.map(fn fold ->
        [_, _, details] = String.split(fold, " ")

        [dimension, line] = String.split(details, "=")

        [dimension, Integer.parse(line) |> elem(0)]
      end)

    %{points: parsed_points, folds: parsed_folds}
  end

  def map_string(points) do
    {maxx, _} = Enum.max_by(points, fn {x, _} -> x end)
    {_, maxy} = Enum.max_by(points, fn {_, y} -> y end)

    0..maxy
    |> Enum.map(fn y ->
      0..maxx
      |> Enum.map(fn x ->
        if MapSet.member?(points, {x, y}) do
          "#"
        else
          "."
        end
      end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
  end

  def print_map(points) do
    points
    |> map_string()
    |> IO.puts()

    IO.puts("\n")
  end

  def fold(points, ["x", line]) do
    folded_points =
      points
      |> Enum.filter(fn {x, _} -> x > line end)
      |> MapSet.new()

    folded_points
    |> Enum.reduce(MapSet.difference(points, folded_points), fn {x, y}, current_points ->
      MapSet.put(current_points, {line - (x - line), y})
    end)
  end

  def fold(points, ["y", line]) do
    folded_points =
      points
      |> Enum.filter(fn {_, y} -> y > line end)
      |> MapSet.new()

    folded_points
    |> Enum.reduce(MapSet.difference(points, folded_points), fn {x, y}, current_points ->
      MapSet.put(current_points, {x, line - (y - line)})
    end)
  end

  def part1(input) do
    parsed = input |> parse_paper()

    fold(Map.get(parsed, :points), Map.get(parsed, :folds) |> Enum.at(0)) |> MapSet.size()
  end

  def part2(input) do
    parsed = input |> parse_paper()

    Map.get(parsed, :folds)
    |> Enum.reduce(Map.get(parsed, :points), fn fold, current_points ->
      fold(current_points, fold)
    end)
    |> map_string()
  end

  def run() do
    input = File.read!("inputs/day13.txt")

    %{part1: part1(input), part2: part2(input)}
  end
end
