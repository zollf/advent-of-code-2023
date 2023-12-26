defmodule AdventOfCode.Day21.P1 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  def find_start(garden) do
    {row, y} =
      garden
      |> Enum.with_index()
      |> Enum.find(fn {row, _} -> Enum.member?(row, "S") end)

    {_, x} =
      row
      |> Enum.with_index()
      |> Enum.find(fn {cell, _} -> cell == "S" end)

    {x, y}
  end

  def get_steps(_, positions, 0), do: positions

  def get_steps(garden, positions, count) do
    all_neighbors =
      positions
      |> Enum.map(&get_neighbors(garden, &1))
      |> List.flatten()
      |> Enum.uniq()

    get_steps(garden, all_neighbors, count - 1)
  end

  def get_neighbors(garden, {x, y}) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
    |> Enum.filter(fn pos ->
      symbol = get(garden, pos)
      symbol && symbol != "#"
    end)
  end

  def get(map, {x, y}) do
    row = Enum.at(map, y)
    if row, do: Enum.at(row, x), else: nil
  end
end

garden =
  File.read!("lib/day21/input.txt")
  |> AdventOfCode.Day21.P1.parse()

start = AdventOfCode.Day21.P1.find_start(garden)

garden
|> AdventOfCode.Day21.P1.get_steps([start], 64)
|> length()
|> IO.inspect()
