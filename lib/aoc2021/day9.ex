defmodule Aoc2021.Day9 do
  def get_point_at(field, [x, y]) do
    row = Enum.at(field, y)

    if row do
      Enum.at(row, x)
    else
      nil
    end
  end

  def neighbors_for(x, y, field) do
    [
      [x + 1, y],
      [x - 1, y],
      [x, y + 1],
      [x, y - 1]
    ]
    |> Enum.filter(fn [px, py] -> px >= 0 && py >= 0 end)
    |> Enum.map(fn [px, py] ->
      {px, py, get_point_at(field, [px, py])}
    end)
    |> Enum.reject(fn {_, _, value} -> is_nil(value) end)
  end

  def is_low_point(point, x, y, field) do
    neighbors_for(x, y, field)
    |> Enum.all?(fn {_, _, other_point_value} ->
      other_point_value > point
    end)
  end

  def part1(input) do
    input
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, y}, points ->
      low_points =
        row
        |> Enum.with_index()
        |> Enum.reduce([], fn {point, x}, acc ->
          if is_low_point(point, x, y, input) do
            [point + 1 | acc]
          else
            acc
          end
        end)

      low_points ++ points
    end)
    |> Enum.sum()
  end

  def update_basin(basin, field) do
    new_filled =
      Map.update!(basin, :filled, fn filled ->
        MapSet.union(filled, Map.get(basin, :edges))
      end)

    new_filled
    |> Map.update!(:edges, fn edges ->
      edges
      |> Enum.flat_map(fn {x, y} ->
        neighbors_for(x, y, field)
        |> Enum.reject(fn {nx, ny, value} ->
          value == 9 || MapSet.member?(Map.get(new_filled, :filled), {nx, ny})
        end)
        |> Enum.map(fn {nx, ny, _} ->
          {nx, ny}
        end)
      end)
      |> MapSet.new()
    end)
  end

  def merge_basins(basins) do
    basins
    |> Enum.map(fn %{filled: filled, edges: edges} ->
      connected_basins =
        basins
        |> Enum.filter(fn %{filled: other_filled, edges: other_edges} ->
          !(filled == other_filled && edges == other_edges) &&
            MapSet.size(MapSet.intersection(filled, other_filled)) > 0
        end)

      connected_basins
      |> Enum.reduce(%{filled: filled, edges: edges}, fn other_basin, new_basin ->
        %{
          filled: MapSet.union(Map.get(new_basin, :filled), Map.get(other_basin, :filled)),
          edges: MapSet.union(Map.get(new_basin, :edges), Map.get(other_basin, :edges))
        }
      end)
    end)
  end

  def fill_basins(basins, field) do
    if Enum.all?(basins, fn %{filled: _, edges: edges} -> MapSet.size(edges) == 0 end) do
      basins
    else
      basins
      |> Enum.map(fn basin ->
        update_basin(basin, field)
      end)
      |> fill_basins(field)
    end
  end

  def find_basins(input) do
    low_points =
      input
      |> Enum.with_index()
      |> Enum.reduce([], fn {row, y}, points ->
        row_lows =
          row
          |> Enum.with_index()
          |> Enum.reduce([], fn {point, x}, acc ->
            if is_low_point(point, x, y, input) do
              [{x, y} | acc]
            else
              acc
            end
          end)

        row_lows ++ points
      end)

    initial_basins =
      low_points
      |> Enum.map(fn point ->
        %{filled: MapSet.new([point]), edges: MapSet.new([point])}
      end)

    fill_basins(initial_basins, input)
  end

  def part2(input) do
    find_basins(input)
    |> Enum.map(fn %{edges: _, filled: filled} ->
      MapSet.size(filled)
    end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.slice(0..2)
    |> Enum.reduce(&*/2)
  end

  def parse_ints(digits_string) do
    String.graphemes(digits_string)
    |> Enum.map(&(Integer.parse(&1) |> elem(0)))
  end

  def run() do
    input = Aoc2021.Util.read_int_grid("inputs/day9.txt")

    [part1(input), part2(input)]
  end
end
