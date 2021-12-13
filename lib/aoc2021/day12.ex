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

  def can_visit(path, cave, visit_doubles_for) do
    if visit_doubles_for do
      cave != "start" &&
        (!is_small_cave(cave) ||
           !Enum.member?(path, cave) ||
           (cave == visit_doubles_for && Enum.count(Enum.filter(path, &(&1 == cave))) < 2))
    else
      !(cave == "start" ||
          (is_small_cave(cave) && Enum.member?(path, cave)))
    end
  end

  def explore_path(path, finished_paths, visit_doubles_for, edges) do
    case Enum.at(path, -1) do
      "end" ->
        [path | finished_paths]

      location ->
        next_edges =
          BiMultiMap.get(edges, location, [])
          |> Enum.filter(fn next_location ->
            can_visit(path, next_location, visit_doubles_for)
          end)

        next_edges
        |> Enum.reduce(finished_paths, fn next_location, current_finished_paths ->
          explore_path(
            path ++ [next_location],
            current_finished_paths,
            visit_doubles_for,
            edges
          )
        end)
    end
  end

  def part1(input) do
    edges = parse_edges(input)

    BiMultiMap.get(edges, "start")
    |> Enum.reduce([], fn to, finished_paths ->
      finished_paths ++ explore_path(["start", to], finished_paths, nil, edges)
    end)
    |> Enum.uniq()
    |> Enum.count()
  end

  def part2(input) do
    edges = parse_edges(input)

    small_caves =
      BiMultiMap.keys(edges)
      |> Enum.filter(&(&1 != "start" && &1 != "end" && String.downcase(&1) == &1))

    base_paths =
      BiMultiMap.get(edges, "start")
      |> Enum.reduce([], fn to, finished_paths ->
        finished_paths ++ explore_path(["start", to], finished_paths, nil, edges)
      end)
      |> Enum.uniq()

    doubled_paths =
      small_caves
      |> Enum.map(fn double_cave ->
        Task.async(fn ->
          BiMultiMap.get(edges, "start")
          |> Enum.map(fn to ->
            Task.async(fn ->
              explore_path(["start", to], [], double_cave, edges)
            end)
          end)
          |> Enum.map(&Task.await/1)
          |> Enum.reduce(&++/2)
          |> Enum.uniq()
        end)
      end)
      |> Enum.map(&Task.await/1)
      |> Enum.reduce(&++/2)
      |> Enum.uniq()

    (base_paths ++ doubled_paths)
    |> Enum.uniq()
    |> Enum.count()
  end

  def run() do
    input = File.read!("inputs/day12.txt") |> String.split("\n")

    %{part1: part1(input), part2: part2(input)}
  end
end
