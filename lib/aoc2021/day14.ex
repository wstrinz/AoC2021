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

  def sum_maps(maps) do
    maps
    |> Enum.reduce(%{}, fn map, accmap ->
      map
      |> Enum.reduce(accmap, fn {key, val}, thismap ->
        Map.update(thismap, key, val, &(&1 + val))
      end)
    end)
  end

  def gen_frequencies_from(seq, map) do
    0..(length(seq) - 2)
    |> Enum.map(fn idx ->
      [Enum.at(seq, idx), Enum.at(seq, idx + 1)]
    end)
    |> Enum.reduce(%{}, fn pair, count_map ->
      if map_size(count_map) == 0 do
        Map.get(map, pair)
        |> Enum.reduce(count_map, fn {freq_char, freq_val}, acc_map ->
          Map.update(acc_map, freq_char, freq_val, &(&1 + freq_val))
        end)
      else
        Map.get(map, pair)
        |> Map.update!(Enum.at(pair, 0), &(&1 - 1))
        |> Enum.reduce(count_map, fn {freq_char, freq_val}, acc_map ->
          Map.update(acc_map, freq_char, freq_val, &(&1 + freq_val))
        end)
      end
    end)
  end

  def gen_results_from_map(seq, map) do
    0..(length(seq) - 2)
    |> Enum.map(fn idx ->
      [Enum.at(seq, idx), Enum.at(seq, idx + 1)]
    end)
    |> Enum.with_index()
    |> Enum.map(fn {pair, idx} ->
      if idx == 0 do
        Map.get(map, pair)
        |> Map.get(:result)
      else
        [_ | nxt] =
          Map.get(map, pair)
          |> Map.get(:result)

        nxt
      end
    end)
    |> List.flatten()
  end

  def cached_generate_sequence(sequence, rules, sequence_cache) do
    # IO.puts("check")
    IO.inspect(sequence)

    case :ets.lookup(sequence_cache, sequence) do
      [{_, subsequence}] ->
        IO.puts("cache_hit")

        subsequence

      _ ->
        IO.puts("cache_miss")

        case length(sequence) do
          1 ->
            gen_iterations(Enum.at(sequence, 0), rules, 1)

          2 ->
            # IO.inspect(sequence)

            {gen_head, gen_tail} = Enum.split(sequence, 1)

            next_seq_head = cached_generate_sequence(gen_head, rules, sequence_cache)

            [_ | next_seq_tail] = cached_generate_sequence(gen_tail, rules, sequence_cache)

            [next_seq_head, next_seq_tail]

          # [gen_head, gen_tail]
          # |> Enum.map(fn sub_seq ->
          #   result = cached_generate_sequence(sub_seq, rules, sequence_cache)

          #   IO.inspect(sub_seq)
          #   IO.inspect(result)
          #   :ets.insert(sequence_cache, {sub_seq, result})

          #   result
          # end)
          # |> List.flatten()

          _ ->
            # IO.inspect(sequence)

            {gen_head, gen_tail} = Enum.split(sequence, 2)

            next_seq_head = cached_generate_sequence(gen_head, rules, sequence_cache)

            [_ | next_seq_tail] = cached_generate_sequence(gen_tail, rules, sequence_cache)

            List.flatten([next_seq_head, next_seq_tail])
            # IO.inspect(sequence)

            # {gen_head, gen_tail} = Enum.split(sequence, 2)

            # [gen_head, gen_tail]
            # |> Enum.map(fn sub_seq ->
            #   result = cached_generate_sequence(sub_seq, rules, sequence_cache)

            #   :ets.insert(sequence_cache, {sub_seq, result})

            #   result
            # end)
            # |> List.flatten()
        end
    end
  end

  def part2_slow(%{sequence: original_sequence, rules: rules}) do
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
            gen_results_from_map(result, tens_seqs)
            |> List.flatten()

          [seq, next_result, Enum.frequencies(next_result)]
        end)
      end)
      |> Enum.map(fn t -> Task.await(t, 120_000) end)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {[seq, result, freqs], idx}, map ->
        IO.puts("reducing #{idx}")
        Map.put(map, seq, %{frequencies: freqs, result: Arrays.new(result)})
      end)

    IO.puts("fourties")

    fourties_seqs =
      twenties_seqs
      |> Enum.with_index()
      |> Enum.map(fn {{seq, %{result: result, frequencies: _}}, overall_idx} ->
        IO.puts("checking pair #{overall_idx}")

        next_freqs =
          0..(Arrays.size(result) - 2)
          |> Enum.map(fn idx ->
            [Enum.at(result, idx), Enum.at(result, idx + 1)]
          end)
          |> Enum.map(fn pair ->
            fs = Map.get(twenties_seqs, pair) |> Map.get(:frequencies)
            firstl = Map.get(twenties_seqs, pair) |> Map.get(:result) |> Enum.at(0)

            %{frequencies: fs, mod_freqs: Map.update!(fs, firstl, &(&1 - 1))}
          end)
          |> Enum.with_index()
          |> Enum.map(fn {fs, idx} ->
            if idx == 0 do
              Map.get(fs, :frequencies)
            else
              Map.get(fs, :mod_freqs)
            end
          end)
          |> sum_maps()

        [seq, next_freqs]
      end)
      |> Enum.reduce(%{}, fn [seq, freqs], map ->
        Map.put(map, seq, freqs)
      end)
      |> Enum.reduce(%{}, fn {pair, freqs}, map -> Map.put(map, pair, freqs) end)

    letter_counts = gen_frequencies_from(original_sequence, fourties_seqs)

    {{_, min_count}, {_, max_count}} = letter_counts |> Enum.min_max_by(fn {_, v} -> v end)

    max_count - min_count
  end

  def part2_skip_gen(_) do
    letter_counts = %{
      "B" => 211_999_150_163,
      "C" => 422_415_532_942,
      "F" => 12_464_638_059_775,
      "H" => 206_420_145_579,
      "K" => 193_200_271_245,
      "N" => 378_279_145_958,
      "O" => 198_828_019_091,
      "P" => 6_287_180_922_765,
      "S" => 252_943_215_762,
      "V" => 274_816_464_465
    }

    {{_, min_count}, {_, max_count}} = letter_counts |> Enum.min_max_by(fn {_, v} -> v end)

    max_count - min_count
  end

  def part2(%{sequence: original_sequence, rules: rules}) do
    cache = :ets.new(:sequence_cache, [:set])

    start_pairs =
      0..(length(original_sequence) - 2)
      |> Enum.map(fn idx ->
        [Enum.at(original_sequence, idx), Enum.at(original_sequence, idx + 1)]
      end)

    next_seq = cached_generate_sequence(start_pairs, rules, cache)

    next_pairs =
      0..(length(next_seq) - 2)
      |> Enum.map(fn idx ->
        [Enum.at(next_seq, idx), Enum.at(next_seq, idx + 1)]
      end)

    cached_generate_sequence(next_pairs, rules, cache)
  end

  def run() do
    rules = File.read!("inputs/day14.txt") |> parse_rules()

    part2(rules)
    # %{part1: part1(rules), part2: part2(rules)}
  end
end
