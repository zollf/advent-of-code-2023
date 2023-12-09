defmodule AdventOfCode.Day9.P1 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_row/1)
  end

  def parse_row(input) do
    input
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def create_difference_sequences([head | tail] = sequences) do
    if Enum.all?(head, &(&1 == 0)) do
      sequences
    else
      new_sequence =
        head
        |> Enum.reduce([], &difference_reduce/2)
        |> List.delete_at(0)
        |> Enum.reverse()

      create_difference_sequences([new_sequence] ++ sequences)
    end
  end

  def difference_reduce(number, []), do: [number]

  def difference_reduce(number, [head | tail]),
    do: [number, number - head] ++ tail

  def extrapolate(difference_sequences) do
    difference_sequences
    |> Enum.map(&List.last/1)
    |> Enum.sum()
  end
end

File.read!("lib/day9/input.txt")
|> AdventOfCode.Day9.P1.parse()
|> Enum.map(&AdventOfCode.Day9.P1.create_difference_sequences([&1]))
|> Enum.map(&AdventOfCode.Day9.P1.extrapolate/1)
|> Enum.sum()
|> IO.inspect(charlists: :as_lists)
