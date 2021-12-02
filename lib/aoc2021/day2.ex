defmodule Aoc2021.Day2 do
  @directions Aoc2021.Util.read_strings("day2.txt")

  def parse_instruction(instruction) do
    [direction, amount] = String.split(instruction, " ")
    [direction, Integer.parse(amount) |> elem(0)]
  end

  def part1 do
    @directions
    |> Enum.reduce([0, 0], fn instruction, [x, y] ->
      case parse_instruction(instruction) do
        ["forward", amount] -> [x + amount, y]
        ["up", amount] -> [x, y - amount]
        ["down", amount] -> [x, y + amount]
      end
    end)
    |> Enum.reduce(&*/2)
  end

  def part2 do
    @directions
    |> Enum.reduce([0, 0, 0], fn instruction, [x, y, aim] ->
      case parse_instruction(instruction) do
        ["forward", amount] -> [x + amount, y + aim * amount, aim]
        ["up", amount] -> [x, y, aim - amount]
        ["down", amount] -> [x, y, aim + amount]
      end
    end)
    |> Enum.slice(0..1)
    |> Enum.reduce(&*/2)
  end

  def run do
    [part1(), part2()]
  end
end
