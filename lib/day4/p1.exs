defmodule Game do
  defstruct [:card_number, :winning_numbers, :my_numbers]

  def parse(game) do
    [card_number_string, numbers] = game |> String.split(":")

    [_, card_number] = card_number_string |> String.split(" ", trim: true)

    [winning_numbers, my_numbers] =
      numbers
      |> String.split("|")
      |> Enum.map(&String.split(&1, " ", trim: true))

    %Game{
      card_number: String.to_integer(card_number),
      winning_numbers: winning_numbers |> Enum.map(&String.to_integer/1),
      my_numbers: my_numbers |> Enum.map(&String.to_integer/1)
    }
  end

  def get_score(%Game{my_numbers: my_numbers, winning_numbers: winning_numbers}) do
    my_winning_numbers =
      my_numbers
      |> Enum.filter(&Enum.member?(winning_numbers, &1))

    if not Enum.empty?(my_winning_numbers) do
      2 ** (length(my_winning_numbers) - 1)
    else
      0
    end
  end
end

defmodule AdventOfCode.Day4.P1 do
  def parse(games) do
    games
    |> String.split("\n", trim: true)
    |> Enum.map(&Game.parse/1)
  end
end

File.read!("lib/day4/input.txt")
|> AdventOfCode.Day4.P1.parse()
|> Enum.map(&Game.get_score/1)
|> Enum.sum()
|> IO.inspect()
