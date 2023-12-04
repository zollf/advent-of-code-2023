defmodule Cell do
  defstruct [:value, :x, :y, :schematic]

  def get_adjacent_to_symbol(%Cell{schematic: schematic, y: y, x: x}) do
    max_y = length(schematic)
    max_x = length(Enum.at(schematic, y))

    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1},
      {x + 1, y + 1},
      {x + 1, y - 1},
      {x - 1, y + 1},
      {x - 1, y - 1}
    ]
    |> Enum.filter(fn {x, y} -> x >= 0 && x < max_x && y >= 0 && y < max_y end)
    |> Enum.filter(fn {x, y} -> is_symbol_at?(schematic, x, y) end)
    |> Enum.map(fn {x, y} -> get(schematic, x, y) end)
  end

  def get_xy_string(%Cell{x: x, y: y}), do: "#{x},#{y}"

  def cells_equal?(%Cell{} = cell1, %Cell{} = cell2) do
    get_xy_string(cell1) == get_xy_string(cell2)
  end

  defp is_symbol_at?(schematic, x, y) do
    schematic
    |> get(x, y)
    |> is_symbol?
  end

  defp get(schematic, x, y) do
    schematic
    |> Enum.at(y)
    |> Enum.at(x)
  end

  defp is_symbol?(%Cell{} = cell) when cell.value == "*", do: true
  defp is_symbol?(_), do: false
end

defmodule AdventOfCode.Day3.P2 do
  def parse(schematic) do
    parsed_schematic =
      schematic
      |> Enum.with_index()
      |> Enum.map(fn {row, y} ->
        row
        |> String.split("", trim: true)
        |> Enum.map(&parse_if_int/1)
        |> Enum.with_index()
        |> Enum.map(fn {value, x} -> %Cell{value: value, x: x, y: y} end)
      end)

    parsed_schematic
    |> Enum.map(fn row ->
      row
      |> Enum.map(fn %Cell{} = cell ->
        %Cell{value: cell.value, x: cell.x, y: cell.y, schematic: parsed_schematic}
      end)
    end)
  end

  def parse_if_int(value) do
    case Integer.parse(value) do
      {num, _rem} -> num
      _ -> value
    end
  end

  def get_part_numbers(parsed_schematic) do
    parsed_schematic
    |> Enum.map(&get_part_numbers_in_row/1)
  end

  def get_part_numbers_in_row(row, cur_num \\ 0, stack \\ [], adj_symbols \\ [])

  def get_part_numbers_in_row([], cur_num, stack, adj_symbols) do
    if cur_num && not Enum.empty?(adj_symbols) do
      stack ++ [{cur_num, adj_symbols}]
    else
      stack
    end
  end

  def get_part_numbers_in_row([%Cell{} = head | tail], cur_num, stack, adj_symbols)
      when is_integer(head.value) do
    cur_adj_symbols = Cell.get_adjacent_to_symbol(head)
    updated_num = cur_num * 10 + head.value

    if not Enum.empty?(cur_adj_symbols) do
      get_part_numbers_in_row(
        tail,
        updated_num,
        stack,
        (adj_symbols ++ cur_adj_symbols)
        |> Enum.uniq_by(&Cell.get_xy_string/1)
      )
    else
      get_part_numbers_in_row(tail, updated_num, stack, adj_symbols)
    end
  end

  def get_part_numbers_in_row([_ | tail], cur_num, stack, adj_symbols) do
    if cur_num && not Enum.empty?(adj_symbols) do
      get_part_numbers_in_row(tail, 0, stack ++ [{cur_num, adj_symbols}], [])
    else
      get_part_numbers_in_row(tail, 0, stack, [])
    end
  end
end

part_numbers =
  File.read!("lib/day3/input.txt")
  |> String.split("\n", trim: true)
  |> AdventOfCode.Day3.P2.parse()
  |> AdventOfCode.Day3.P2.get_part_numbers()
  |> List.flatten()

part_numbers
|> Enum.map(fn {_, cell} -> cell end)
|> List.flatten()
|> Enum.uniq_by(&Cell.get_xy_string/1)
|> Enum.map(fn cell ->
  {
    cell,
    part_numbers
    |> Enum.filter(fn {_num, cells} -> Enum.any?(cells, &Cell.cells_equal?(&1, cell)) end)
    |> Enum.map(fn {num, _} -> num end)
  }
end)
|> Enum.filter(fn {_, numbers} -> length(numbers) == 2 end)
|> Enum.map(fn {_, [one, two]} -> one * two end)
|> Enum.sum()
|> IO.inspect()
