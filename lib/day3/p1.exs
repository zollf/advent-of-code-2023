defmodule Cell do
  defstruct [:value, :x, :y, :schematic]

  def is_adjacent_to_symbol(%Cell{schematic: schematic, y: y, x: x}) do
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
    |> Enum.any?(fn {x, y} -> is_symbol_at?(schematic, x, y) end)
  end

  defp is_symbol_at?(schematic, x, y) do
    schematic
    |> Enum.at(y)
    |> Enum.at(x)
    |> is_symbol?
  end

  defp is_symbol?(%Cell{} = cell) when is_integer(cell.value), do: false
  defp is_symbol?(%Cell{} = cell) when cell.value == ".", do: false
  defp is_symbol?(_), do: true
end

defmodule AdventOfCode.Day3.P1 do
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

  def get_part_numbers_in_row(row, cur_num \\ 0, stack \\ [], submit \\ false)

  def get_part_numbers_in_row([], cur_num, stack, submit) do
    if submit && cur_num do
      stack ++ [cur_num]
    else
      stack
    end
  end

  def get_part_numbers_in_row([%Cell{} = head | tail], cur_num, stack, submit)
      when is_integer(head.value) do
    get_part_numbers_in_row(
      tail,
      cur_num * 10 + head.value,
      stack,
      submit || Cell.is_adjacent_to_symbol(head)
    )
  end

  def get_part_numbers_in_row([_ | tail], cur_num, stack, submit) do
    if submit && cur_num do
      get_part_numbers_in_row(tail, 0, stack ++ [cur_num], false)
    else
      get_part_numbers_in_row(tail, 0, stack, false)
    end
  end
end

File.read!("lib/day3/example.txt")
|> String.split("\n", trim: true)
|> AdventOfCode.Day3.P1.parse()
|> AdventOfCode.Day3.P1.get_part_numbers()
|> List.flatten()
|> Enum.sum()
|> IO.inspect()
