defmodule Aoc2021.Day3 do
  @input Aoc2021.Util.read_strings("day3.txt")

  def most_common(counts) do
    counts
    |> Enum.map(fn col ->
      if Map.get(col, "0") > Map.get(col, "1") do
        "0"
      else
        "1"
      end
    end)
  end

  def least_common(counts) do
    counts
    |> Enum.map(fn col ->
      if Map.get(col, "0") > Map.get(col, "1") do
        "1"
      else
        "0"
      end
    end)
  end

  def binlist_to_dec(binlist) do
    binlist
    |> Enum.join()
    |> Integer.parse(2)
    |> elem(0)
  end

  def bit_counts(candidates) do
    columns = List.duplicate([], length(String.graphemes(Enum.at(candidates, 0))))

    candidates
    |> Enum.reduce(columns, fn line, columns ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.reduce(columns, fn {digit, idx}, cols ->
        List.replace_at(cols, idx, [digit | Enum.at(cols, idx)])
      end)
    end)
    |> Enum.map(&Enum.frequencies/1)
  end

  def find_masked_match(mask, criteria_fn) do
    mask
    |> Enum.with_index()
    |> Enum.reduce(@input, fn {_, idx}, candidates ->
      if length(candidates) == 1 do
        candidates
      else
        criterion =
          candidates
          |> Enum.map(&String.graphemes/1)
          |> Enum.map(fn chars -> Enum.at(chars, idx) end)
          |> Enum.frequencies()
          |> criteria_fn.()

        result =
          candidates
          |> Enum.filter(fn line ->
            Enum.at(String.graphemes(line), idx) == criterion
          end)

        result
      end
    end)
    |> Enum.at(0)
  end

  def part2 do
    o2_value =
      bit_counts(@input)
      |> most_common()
      |> find_masked_match(fn counts ->
        if Map.get(counts, "0") > Map.get(counts, "1") do
          "0"
        else
          "1"
        end
      end)
      |> Integer.parse(2)
      |> elem(0)

    co2_value =
      bit_counts(@input)
      |> least_common()
      |> find_masked_match(fn counts ->
        if Map.get(counts, "0") > Map.get(counts, "1") do
          "1"
        else
          "0"
        end
      end)
      |> Integer.parse(2)
      |> elem(0)

    o2_value * co2_value
  end

  def part1 do
    gamma = most_common(bit_counts(@input)) |> binlist_to_dec()

    epsilon = least_common(bit_counts(@input)) |> binlist_to_dec()

    gamma * epsilon
  end

  def run() do
    [part1(), part2()]
  end
end
