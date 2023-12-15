defmodule AdventOfCode.Day15.P1 do
  def hash(input) do
    input
    |> String.split("", trim: true)
    |> Enum.reduce(0, fn char, acc -> rem((acc + to_ascii(char)) * 17, 256) end)
  end

  def parse(input) do
    input
    |> String.split(",", trim: true)
  end

  defp to_ascii(string) when is_binary(string) do
    :binary.first(string)
  end
end

File.read!("lib/day15/input.txt")
|> AdventOfCode.Day15.P1.parse()
|> Enum.map(&AdventOfCode.Day15.P1.hash/1)
|> Enum.sum()
|> IO.inspect()
