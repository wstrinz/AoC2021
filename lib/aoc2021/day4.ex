defmodule Aoc2021.Day4 do
  def mark_board(board, number) do
    board
    |> Enum.map(fn board_line ->
      board_line
      |> Enum.map(fn [value, marked] ->
        [value, marked || value == number]
      end)
    end)
  end

  def marked?([_, marked]), do: marked
  def number([number, _]), do: number

  def has_bingo(board) do
    row_wins =
      board
      |> Enum.any?(fn row ->
        row
        |> Enum.all?(&marked?/1)
      end)

    col_wins =
      0..(length(Enum.at(board, 1)) - 1)
      |> Enum.any?(fn col ->
        board
        |> Enum.map(fn row ->
          Enum.at(row, col)
        end)
        |> Enum.all?(&marked?/1)
      end)

    row_wins || col_wins
  end

  def update_boards(number, nil, boards) do
    updated_boards =
      boards
      |> Enum.map(&mark_board(&1, number))

    winning_number = if Enum.any?(updated_boards, &has_bingo/1), do: number

    [winning_number, updated_boards]
  end

  def update_boards(_, winner, boards), do: [winner, boards]

  def update_boards_to_last(_, last_winning_number, boards, true) do
    [last_winning_number, boards, true]
  end

  def update_boards_to_last(number, _, boards, false)
      when length(boards) == 1 do
    updated_boards =
      boards
      |> Enum.map(&mark_board(&1, number))

    [number, updated_boards, true]
  end

  def update_boards_to_last(number, last_winning_number, boards, false) do
    updated_boards =
      boards
      |> Enum.map(&mark_board(&1, number))

    winning_number = if Enum.any?(updated_boards, &has_bingo/1), do: number

    [winning_number || last_winning_number, updated_boards |> Enum.reject(&has_bingo/1), false]
  end

  def sum_unmarked(board) do
    board
    |> Enum.map(fn row ->
      Enum.filter(row, &(!marked?(&1)))
      |> Enum.map(&number/1)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def make_board(board_lines) do
    board_lines
    |> Enum.map(fn line ->
      String.graphemes(line)
      |> Enum.chunk_every(3)
      |> Enum.map(fn number ->
        parsed = Enum.join(number) |> String.trim() |> Integer.parse() |> elem(0)
        [parsed, false]
      end)
    end)
  end

  def part1([numbers, _ | board_lines]) do
    boards =
      board_lines
      |> Enum.reject(&(&1 == ""))
      |> Enum.chunk_every(5)
      |> Enum.map(&make_board/1)

    [winner, final_boards] =
      numbers
      |> String.split(",")
      |> Enum.map(&elem(Integer.parse(&1), 0))
      |> Enum.reduce([nil, boards], fn number, [winning_number, boardstate] ->
        update_boards(number, winning_number, boardstate)
      end)

    unmarked_sum = Enum.find(final_boards, &has_bingo/1) |> sum_unmarked()

    unmarked_sum * winner
  end

  def part2([numbers, _ | board_lines]) do
    boards =
      board_lines
      |> Enum.reject(&(&1 == ""))
      |> Enum.chunk_every(5)
      |> Enum.map(&make_board/1)

    [winner, final_boards, _] =
      numbers
      |> String.split(",")
      |> Enum.map(&elem(Integer.parse(&1), 0))
      |> Enum.reduce([nil, boards, false], fn number, [winning_number, boardstate, stop] ->
        update_boards_to_last(number, winning_number, boardstate, stop)
      end)

    unmarked_sum = Enum.at(final_boards, 0) |> sum_unmarked()

    unmarked_sum * winner
  end

  def run() do
    input = File.read!("inputs/day4.txt") |> String.split("\n")

    [part1(input), part2(input)]
  end
end
