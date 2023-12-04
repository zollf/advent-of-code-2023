defmodule Game do
  defstruct [:card_number, :winning_numbers, :my_numbers, :score]

  def parse(game) do
    [card_number_string, numbers] = game |> String.split(":")

    card_number =
      card_number_string
      |> String.split(" ", trim: true)
      |> Enum.at(1)
      |> String.to_integer()

    [winning_numbers, my_numbers] =
      numbers
      |> String.split("|")
      |> Enum.map(&String.split(&1, " ", trim: true))
      |> Enum.map(fn numbers -> numbers |> Enum.map(&String.to_integer/1) end)

    score =
      my_numbers
      |> Enum.filter(&Enum.member?(winning_numbers, &1))
      |> length()

    %Game{
      card_number: card_number,
      winning_numbers: winning_numbers,
      my_numbers: my_numbers,
      score: score
    }
  end

  def with_winning_scores([], memoized), do: memoized

  def with_winning_scores([%Game{} = head | tail], memoized) when head.score == 0 do
    with_winning_scores(tail, memoized ++ [{head, head.score}])
  end

  def with_winning_scores([%Game{} = head | tail], memoized) when head.score > 0 do
    total_length = length(tail) + length(memoized) + 1

    sum_of_copies =
      0..(head.score - 1)
      |> Enum.map(&Enum.at(memoized, total_length - 1 - (head.card_number + &1), nil))
      |> Enum.filter(&(!is_nil(&1)))
      |> Enum.map(fn {_, score} -> score end)
      |> Enum.sum()

    with_winning_scores(tail, memoized ++ [{head, sum_of_copies + head.score}])
  end
end

defmodule AdventOfCode.Day4.P2 do
  def parse(games) do
    games
    |> String.split("\n", trim: true)
    |> Enum.map(&Game.parse/1)
  end

  def memoize(games) do
    games
    |> Enum.reverse()
    |> Game.with_winning_scores([])
  end
end

games =
  File.read!("lib/day4/input.txt")
  |> AdventOfCode.Day4.P2.parse()

games
|> AdventOfCode.Day4.P2.memoize()
|> Enum.map(fn {_, score} -> score end)
|> Enum.sum()
|> then(fn total -> total + length(games) end)
|> IO.inspect()
