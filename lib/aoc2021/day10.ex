defmodule Aoc2021.Day10 do
  @opener_operators ["(", "[", "{", "<"]

  def operator_matches(opener, closer) do
    case opener do
      ")" -> closer == "("
      "]" -> closer == "["
      "}" -> closer == "{"
      ">" -> closer == "<"
    end
  end

  def syntax_error_value_for(operator) do
    case operator do
      ")" -> 3
      "]" -> 57
      "}" -> 1197
      ">" -> 25137
    end
  end

  def autocomplete_value_for(operator) do
    case operator do
      ")" -> 1
      "]" -> 2
      "}" -> 3
      ">" -> 4
    end
  end

  def closing_operator_for(opening_operator) do
    case opening_operator do
      "(" -> ")"
      "[" -> "]"
      "{" -> "}"
      "<" -> ">"
    end
  end

  def process_line(line) do
    line
    |> String.graphemes()
    |> Enum.reduce({[], :missing, nil}, fn operator, {operator_stack, result, invalid_operator} ->
      if result == :invalid || Enum.member?(@opener_operators, operator) do
        {[operator | operator_stack], result, invalid_operator}
      else
        [popped_operator | rest_operators] = operator_stack

        if operator_matches(operator, popped_operator) do
          {rest_operators, result, invalid_operator}
        else
          {[operator | rest_operators], :invalid, operator}
        end
      end
    end)
  end

  def part1(input) do
    input
    |> Enum.map(&process_line/1)
    |> Enum.filter(fn {_, result, _} -> result == :invalid end)
    |> Enum.map(fn {_, _, operator} -> syntax_error_value_for(operator) end)
    |> Enum.sum()
  end

  def autocomplete_score_for({operator_stack, :missing, _}) do
    operator_stack
    |> Enum.map(&closing_operator_for/1)
    |> Enum.reduce(0, fn operator, sum ->
      sum * 5 + autocomplete_value_for(operator)
    end)
  end

  def part2(input) do
    scores =
      input
      |> Enum.map(&process_line/1)
      |> Enum.filter(fn {_, result, _} -> result == :missing end)
      |> Enum.map(&autocomplete_score_for/1)
      |> Enum.sort()

    Enum.at(scores, div(length(scores), 2))
  end

  def run() do
    input = File.read!("inputs/day10.txt") |> String.split("\n")

    [part1(input), part2(input)]
  end
end
