defmodule Aoc2021.Util do
  def read_ints(file) do
    File.read!("inputs/#{file}")
    |> String.split("\n")
    |> Enum.map(&(Integer.parse(&1) |> elem(0)))
  end

  def read_strings(file) do
    File.read!("inputs/#{file}")
    |> String.split("\n")
  end

  def read_int_grid(file) do
    File.read!(file)
    |> String.split("\n")
    |> Enum.map(fn digits_string ->
      String.graphemes(digits_string)
      |> Enum.map(&(Integer.parse(&1) |> elem(0)))
    end)
  end
end
