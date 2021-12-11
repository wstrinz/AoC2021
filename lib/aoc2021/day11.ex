defmodule Aoc2021.Day11 do
  def get_point_at(state, [x, y]) do
    row = Enum.at(state, y)

    if row do
      Enum.at(row, x)
    else
      nil
    end
  end

  def neighbors_for({x, y}, state) do
    [
      [x + 1, y],
      [x - 1, y],
      [x, y + 1],
      [x, y - 1],
      [x + 1, y + 1],
      [x - 1, y + 1],
      [x + 1, y - 1],
      [x - 1, y - 1]
    ]
    |> Enum.filter(fn [px, py] -> px >= 0 && py >= 0 end)
    |> Enum.map(fn [px, py] ->
      {px, py, get_point_at(state, [px, py])}
    end)
    |> Enum.reject(fn {_, _, value} -> is_nil(value) end)
  end

  def update_on_flash(flash, state) do
    neighbors_for(flash, state)
    |> Enum.reduce(state, fn {x, y, current_value}, current_state ->
      if current_value == 0 do
        current_state
      else
        next_row = Enum.at(current_state, y) |> List.replace_at(x, current_value + 1)
        next_state = List.replace_at(current_state, y, next_row)

        next_state
      end
    end)
  end

  def propagate_flashes(state, flash_count) do
    {after_flash_state, flashes} =
      state
      |> Enum.with_index()
      |> Enum.map_reduce([], fn {row, y}, row_flashes ->
        {row_results, row_flash_results} =
          row
          |> Enum.with_index()
          |> Enum.map_reduce([], fn {col, x}, col_flashes ->
            if col >= 10 do
              {0, [{x, y} | col_flashes]}
            else
              {col, col_flashes}
            end
          end)

        {row_results, row_flash_results ++ row_flashes}
      end)

    if length(flashes) == 0 do
      [after_flash_state, flash_count]
    else
      flashes
      |> Enum.reduce(after_flash_state, fn flash, current_state ->
        update_on_flash(flash, current_state)
      end)
      |> propagate_flashes(flash_count + length(flashes))
    end
  end

  def tick(state, flash_count) do
    state
    |> Enum.map(fn row ->
      row
      |> Enum.map(fn col ->
        col + 1
      end)
    end)
    |> propagate_flashes(flash_count)
  end

  def part1(input) do
    [_, final_count] =
      0..99
      |> Enum.reduce([input, 0], fn _, [state, flash_count] ->
        tick(state, flash_count)
      end)

    final_count
  end

  def tick_until_all_zeros(input, tick_num) do
    [next_state, _] = tick(input, 0)

    all_zeros =
      Enum.all?(next_state, fn row ->
        Enum.all?(row, &(&1 == 0))
      end)

    if all_zeros do
      tick_num
    else
      tick_until_all_zeros(next_state, tick_num + 1)
    end
  end

  def part2(input) do
    tick_until_all_zeros(input, 0) + 1
  end

  def run() do
    input = Aoc2021.Util.read_int_grid("inputs/day11.txt")

    [part1(input), part2(input)]
  end
end
