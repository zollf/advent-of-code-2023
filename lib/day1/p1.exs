defmodule AdventOfCode.Day1.P1 do
  def get_calibration(value) do
    first_num_from_front = value |> first_num
    first_num_from_back = value |> String.reverse() |> first_num
    first_num_from_front * 10 + first_num_from_back
  end

  def first_num([head | tail]) do
    case Integer.parse(head) do
      {num, _rem} -> num
      _ -> first_num(tail)
    end
  end

  def first_num(value) when is_binary(value) do
    value
    |> String.split("")
    |> first_num()
  end
end

File.read!("lib/day1/input.txt")
|> String.split("\n")
|> Enum.map(&AdventOfCode.Day1.P1.get_calibration/1)
|> Enum.sum()
|> IO.inspect()
