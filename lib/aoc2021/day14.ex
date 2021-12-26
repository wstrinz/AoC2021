defmodule Aoc2021.Day14 do
  def parse_rules(input) do
    [sequence, rules_string] = String.split(input, "\n\n")

    rules_map =
      rules_string
      |> String.split("\n")
      |> Enum.reduce(%{}, fn rule_string, map ->
        [from, to] = String.split(rule_string, " -> ")
        Map.put(map, String.graphemes(from), to)
      end)

    %{sequence: String.graphemes(sequence), rules: rules_map}
  end

  def next_sequence(sequence, rules) do
    0..(length(sequence) - 2)
    |> Enum.map(fn start_idx ->
      start_char = Enum.at(sequence, start_idx)
      end_char = Enum.at(sequence, start_idx + 1)
      new_char = Map.get(rules, [start_char, end_char])

      [start_char, new_char]
    end)
    |> List.flatten()
    |> Enum.concat([Enum.at(sequence, -1)])
  end

  def gen_iterations(sequence, rules, n_iterations) do
    0..(n_iterations - 1)
    |> Enum.reduce(sequence, fn _, current_sequence ->
      next_sequence(current_sequence, rules)
    end)
  end

  def part1(%{sequence: sequence, rules: rules}) do
    letter_counts =
      gen_iterations(sequence, rules, 10)
      |> Enum.frequencies()

    {{_, min_count}, {_, max_count}} = letter_counts |> Enum.min_max_by(fn {_, v} -> v end)

    max_count - min_count
  end

  def part2(%{sequence: _, rules: rules}) do
    IO.puts("tens")

    tens_seqs =
      Map.keys(rules)
      |> Enum.map(fn seq ->
        Task.async(fn ->
          result = gen_iterations(seq, rules, 10)
          [seq, result, Enum.frequencies(result)]
        end)
      end)
      |> Enum.map(&Task.await/1)
      |> Enum.reduce(%{}, fn [seq, result, freqs], map ->
        Map.put(map, seq, %{result: result, frequencies: freqs})
      end)

    IO.puts("twenties")

    twenties_seqs =
      tens_seqs
      |> Enum.map(fn {seq, %{result: result, frequencies: _}} ->
        Task.async(fn ->
          next_result =
            0..(length(result) - 2)
            |> Enum.map(fn idx ->
              [Enum.at(result, idx), Enum.at(result, idx + 1)]
            end)
            |> Enum.map(fn pair ->
              Map.get(tens_seqs, pair) |> Map.get(:result)
            end)
            |> List.flatten()

          [seq, next_result, Enum.frequencies(next_result)]
        end)
      end)
      |> Enum.map(fn t -> Task.await(t, 15000) end)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {[seq, result, freqs], idx}, map ->
        IO.puts("reduce #{idx}")
        Map.put(map, seq, %{result: Arrays.new(result), frequencies: freqs})
      end)

    IO.puts("forties")

    # forties_seqs =
    twenties_seqs
    |> Enum.map(fn {seq, %{result: result, frequencies: _}} ->
      IO.puts("Checking #{seq} of length #{Arrays.size(result)}")

      next_results =
        0..(Arrays.size(result) - 2)
        |> Enum.map(fn idx ->
          if Integer.mod(idx, 1000) == 0 do
            IO.puts("pairing #{idx}")
          end

          [Enum.at(result, idx), Enum.at(result, idx + 1)]
        end)
        |> Enum.with_index()
        |> Enum.map(fn {pair, pair_idx} ->
          if Integer.mod(pair_idx, 1000) == 0 do
            IO.puts(pair_idx)
          end

          Map.get(twenties_seqs, pair) |> Map.get(:result)
        end)

      IO.puts("gonna count #{length(next_results)}")

      freqs =
        next_results
        |> Enum.reduce(%{}, fn list, map ->
          IO.puts("counting")
          IO.inspect(map)

          list
          |> Enum.reduce(map, fn char, thismap -> Map.update(thismap, char, 0, &(&1 + 1)) end)
        end)
        |> List.flatten()

      IO.puts("finished")

      [seq, freqs]
    end)
    |> Enum.reduce(%{}, fn [seq, result, freqs], map ->
      Map.put(map, seq, %{result: result, frequencies: freqs})
    end)

    # letter_counts =
    #   0..39
    #   |> Enum.reduce(sequence, fn n, current_sequence ->
    #     IO.puts("Iteration #{n}")
    #     next_sequence(current_sequence, rules)
    #   end)
    #   |> Enum.frequencies()

    # {{_, min_count}, {_, max_count}} = letter_counts |> Enum.min_max_by(fn {_, v} -> v end)

    # max_count - min_count
  end

  def part2_exp(%{sequence: sequence, rules: rules}) do
    tens_seqs =
      Map.keys(rules)
      |> Enum.map(fn seq ->
        Task.async(fn ->
          result = gen_iterations(seq, rules, 10)
          [seq, result, Enum.frequencies(result)]
        end)
      end)
      |> Enum.map(&Task.await/1)
      |> Enum.reduce(%{}, fn [seq, result, freqs], map ->
        Map.put(map, seq, %{result: result, frequencies: freqs})
      end)

    {_, first_seq_results} = Enum.at(tens_seqs, 0)
  end

  def run() do
    rules = File.read!("inputs/day14.txt") |> parse_rules()

    # %{part1: part1(rules), part2: part2(rules)}
    part2(rules)
  end
end
