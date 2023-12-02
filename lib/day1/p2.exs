defmodule AdventOfCode.Day1.P2 do
  def get_calibration(value) do
    {first, last} =
      value
      |> String.split("", trim: true)
      |> all_nums
      |> get_first_and_last_elements

    first * 10 + last
  end

  def get_first_and_last_elements(list) do
    {List.first(list), List.last(list)}
  end

  def all_nums(value, acc \\ [])

  def all_nums([head | tail] = value, acc) do
    case string_num(value) do
      nil ->
        case Integer.parse(head) do
          {num, _rem} -> all_nums(tail, acc ++ [num])
          _ -> all_nums(tail, acc)
        end

      num ->
        all_nums(tail, acc ++ [num])
    end
  end

  def all_nums([], acc), do: acc

  def string_num(str) do
    case str do
      ["o", "n", "e" | _] -> 1
      ["t", "w", "o" | _] -> 2
      ["t", "h", "r", "e", "e" | _] -> 3
      ["f", "o", "u", "r" | _] -> 4
      ["f", "i", "v", "e" | _] -> 5
      ["s", "i", "x" | _] -> 6
      ["s", "e", "v", "e", "n" | _] -> 7
      ["e", "i", "g", "h", "t" | _] -> 8
      ["n", "i", "n", "e" | _] -> 9
      _ -> nil
    end
  end
end

File.read!("lib/day1/example.txt")
|> String.split("\n")
|> Enum.map(&AdventOfCode.Day1.P2.get_calibration/1)
|> Enum.sum()
|> IO.inspect()
