defmodule Aoc2021.Day8 do
  def find_key(map, value) do
    Map.keys(map)
    |> Enum.find(fn k ->
      Map.get(map, k) == value
    end)
  end

  def candidates_with_length(map, len) do
    Map.keys(map) |> Enum.filter(&(String.length(&1) == len))
  end

  def find_length_all_in(map, candidate_length, target_inclusion) do
    target_key =
      candidates_with_length(map, candidate_length)
      |> Enum.find(nil, fn key ->
        Enum.all?(String.graphemes(find_key(map, target_inclusion)), fn letter ->
          key =~ letter
        end)
      end)

    Map.put(map, target_key, 3)
  end

  def find_five(map) do
    fours_not_ones =
      find_key(map, 4)
      |> String.graphemes()
      |> Enum.reject(fn letter ->
        find_key(map, 1) =~ letter
      end)

    five_key =
      candidates_with_length(map, 5)
      |> Enum.find(nil, fn key ->
        Enum.all?(fours_not_ones, fn letter ->
          key =~ letter
        end)
      end)

    Map.put(map, five_key, 5)
  end

  def find_remaining_unassigned(map, candidate_length, target_assignment) do
    target_key =
      candidates_with_length(map, candidate_length)
      |> Enum.find(nil, fn key ->
        Map.get(map, key) == "?"
      end)

    Map.put(map, target_key, target_assignment)
  end

  def find_six(map) do
    six_key =
      candidates_with_length(map, 6)
      |> Enum.find(nil, fn candidate ->
        !Enum.all?(find_key(map, 1) |> String.graphemes(), fn letter ->
          candidate =~ letter
        end)
      end)

    Map.put(map, six_key, 6)
  end

  def find_zero(map) do
    zero_key =
      candidates_with_length(map, 6)
      |> Enum.reject(&(Map.get(map, &1) != "?"))
      |> Enum.find(nil, fn candidate ->
        !Enum.all?(find_key(map, 4) |> String.graphemes(), fn letter ->
          candidate =~ letter
        end)
      end)

    Map.put(map, zero_key, 0)
  end

  def find_nine(map) do
    {nine_key, _} =
      map
      |> Enum.find(nil, fn {_, v} -> v == "?" end)

    Map.put(map, nine_key, 9)
  end

  def determine_mapping(signal_strings) do
    signal_strings
    |> Enum.reduce(%{}, fn signal_string, map ->
      Map.put(map, signal_string, simple_digit_for(signal_string))
    end)
    |> find_length_all_in(5, 7)
    |> find_five()
    |> find_remaining_unassigned(5, 2)
    |> find_six()
    |> find_zero()
    |> find_nine()
  end

  def simple_digit_for(signal_string) do
    case String.graphemes(signal_string) |> length() do
      2 ->
        1

      3 ->
        7

      4 ->
        4

      7 ->
        8

      _ ->
        "?"
    end
  end

  def sorted_strings(string) do
    string
    |> String.split(" ")
    |> Enum.map(&(String.graphemes(&1) |> Enum.sort() |> Enum.join()))
  end

  def decode_reading(line) do
    [clues, readings] = String.split(line, " | ")

    readings
    |> sorted_strings()
    |> Enum.map(fn reading ->
      Map.get(sorted_strings(clues) |> determine_mapping(), reading)
      |> Integer.to_string()
    end)
    |> Enum.join()
    |> Integer.parse()
    |> elem(0)
  end

  def part1(input) do
    input
    |> Enum.map(&(String.split(&1, " | ") |> Enum.at(1)))
    |> Enum.map(&String.split(&1, " "))
    |> List.flatten()
    |> Enum.map(&simple_digit_for/1)
    |> Enum.count(&(&1 != "?"))
  end

  def part2(input) do
    input |> Enum.map(&decode_reading/1) |> Enum.sum()
  end

  def run() do
    input = File.read!("inputs/day8.txt") |> String.split("\n")

    [part1(input), part2(input)]
  end
end
