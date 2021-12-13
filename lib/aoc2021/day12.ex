defmodule Aoc2021.Day12 do
  def parse_edges(input) do
    input
    |> Enum.reduce(BiMultiMap.new(), fn edge, map ->
      [from, to] = String.split(edge, "-")

      BiMultiMap.put(map, from, to)
      |> BiMultiMap.put(to, from)
    end)
  end

  def is_small_cave(location) do
    location != "end" && String.downcase(location) == location
  end

  def can_visit(path, cave, can_visit_small_twice) do
    if can_visit_small_twice do
      cave != "start" &&
        (!is_small_cave(cave) ||
           !Enum.member?(path, cave) ||
           !Enum.any?(path, fn location ->
             Enum.count(Enum.filter(path, &(&1 == location))) > 1
           end))
    else
      !(cave == "start" ||
          (is_small_cave(cave) && Enum.member?(path, cave)))
    end
  end

  def explore_path(path, finished_paths, can_visit_small_twice, edges) do
    case Enum.at(path, -1) do
      "end" ->
        # IO.inspect("found end")
        # IO.inspect(path)
        # IO.puts("\n")
        [path | finished_paths]

      location ->
        # IO.inspect("path is")
        # IO.inspect(path)

        # IO.inspect("Checking #{location}")
        # IO.inspect(BiMultiMap.get(edges, location))

        next_edges =
          BiMultiMap.get(edges, location, [])
          |> Enum.filter(fn next_location ->
            can_visit(path, next_location, can_visit_small_twice)
          end)

        # IO.puts("next edges are")
        # IO.inspect(next_edges)

        next_edges
        |> Enum.reduce(finished_paths, fn next_location, current_finished_paths ->
          # IO.inspect("current path is")
          # IO.inspect(path)

          # IO.puts("Checking next")
          # IO.inspect(next_location)
          # IO.gets(:stdio, "paus")

          explore_path(
            path ++ [next_location],
            current_finished_paths,
            can_visit_small_twice,
            edges
          )
        end)
    end
  end

  def part1(input) do
    edges = parse_edges(input)

    BiMultiMap.get(edges, "start")
    |> Enum.reduce([], fn to, finished_paths ->
      finished_paths ++ explore_path(["start", to], finished_paths, false, edges)
    end)
    |> Enum.uniq()
    |> Enum.count()
  end

  def part2(input) do
    edges = parse_edges(input)

    BiMultiMap.get(edges, "start")
    |> Enum.reduce([], fn to, finished_paths ->
      finished_paths ++ explore_path(["start", to], finished_paths, true, edges)
    end)
    |> Enum.uniq()
    |> Enum.count()
  end

  def run() do
    input = File.read!("inputs/day12.txt") |> String.split("\n")

    [part1(input), part2(input)]
  end
end
