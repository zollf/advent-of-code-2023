defmodule AdventOfCode.Day2.P2 do
  def parse_game(game) do
    [id, results] = String.split(game, ":")

    [
      id
      |> String.split(" ", trim: true)
      |> then(fn [_, id] -> String.to_integer(id) end),
      results
      |> String.split(";")
      |> Enum.map(&parse_result/1)
    ]
  end

  def parse_result(result) do
    result
    |> String.split(",")
    |> Enum.map(&parse_colour/1)
  end

  def parse_colour(colour) do
    colour
    |> String.split(" ", trim: true)
    |> then(fn [amount, type] -> [String.to_integer(amount), type] end)
  end

  def calc_power([_id, results]) do
    red = calc_colour_power(results, "red")
    blue = calc_colour_power(results, "blue")
    green = calc_colour_power(results, "green")
    red * blue * green
  end

  def calc_colour_power(results, colour) do
    results
    |> Enum.map(&get_colour_amount_from_result(&1, colour))
    |> Enum.max()
  end

  def get_colour_amount_from_result(result, colour) do
    result
    |> Enum.map(&get_colour_amount(&1, colour))
    |> Enum.max()
  end

  def get_colour_amount([amount, type], colour) when type == colour, do: amount
  def get_colour_amount(_, _), do: 1
end

File.read!("lib/day2/input.txt")
|> String.split("\n", trim: true)
|> Enum.map(&AdventOfCode.Day2.P2.parse_game/1)
|> Enum.map(&AdventOfCode.Day2.P2.calc_power/1)
|> Enum.sum()
|> IO.inspect()
