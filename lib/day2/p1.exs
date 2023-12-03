defmodule AdventOfCode.Day2.P1 do
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

  def is_game_possible?([_id, results]), do: results |> Enum.all?(&is_result_possible?/1)
  def is_result_possible?(result), do: result |> Enum.all?(&is_colour_amount_possible?/1)
  def is_colour_amount_possible?([amount, "blue"]), do: amount <= 14
  def is_colour_amount_possible?([amount, "green"]), do: amount <= 13
  def is_colour_amount_possible?([amount, "red"]), do: amount <= 12
  def is_colour_amount_possible?(_), do: true
end

File.read!("lib/day2/input.txt")
|> String.split("\n", trim: true)
|> Enum.map(&AdventOfCode.Day2.P1.parse_game/1)
|> Enum.filter(&AdventOfCode.Day2.P1.is_game_possible?/1)
|> Enum.map(&Enum.at(&1, 0))
|> Enum.sum()
|> IO.inspect()
