# Credit: https://www.youtube.com/watch?v=99Mjs1i0JxU&ab_channel=IanCarey
defmodule AdventOfCode.Day21.P2 do
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

  def get_steps(_, _, 0, steps), do: steps

  def get_steps(garden, positions, count, steps) do
    steps = Map.put(steps, map_size(steps), length(positions))

    all_neighbors =
      positions
      |> Enum.map(&get_neighbors(garden, &1))
      |> List.flatten()
      |> Enum.uniq()

    get_steps(garden, all_neighbors, count - 1, steps)
  end

  def get_neighbors(garden, {{x, y}, plane}) do
    x_max = garden |> hd |> length
    y_max = garden |> length

    boundaries = {x_max, y_max}

    [
      extend({x + 1, y}, plane, boundaries),
      extend({x - 1, y}, plane, boundaries),
      extend({x, y + 1}, plane, boundaries),
      extend({x, y - 1}, plane, boundaries)
    ]
    |> Enum.filter(fn {pos, _} -> get(garden, pos) != "#" end)
  end

  def extend({x, y}, {px, py}, {x_max, y_max}) do
    cond do
      x >= x_max -> {{0, y}, {px + 1, py}}
      x < 0 -> {{x_max - 1, y}, {px - 1, py}}
      y >= y_max -> {{x, 0}, {px, py + 1}}
      y < 0 -> {{x, y_max - 1}, {px, py - 1}}
      true -> {{x, y}, {px, py}}
    end
  end

  def get(map, {x, y}) do
    map
    |> Enum.at(y)
    |> Enum.at(x)
  end
end

garden =
  File.read!("lib/day21/input.txt")
  |> AdventOfCode.Day21.P2.parse()

start = AdventOfCode.Day21.P2.find_start(garden)

steps = AdventOfCode.Day21.P2.get_steps(garden, [{start, {0, 0}}], 350, %{})

one = Map.get(steps, 65)
two = Map.get(steps, 196)
three = Map.get(steps, 327)

a = (three - 2 * two + one) / 2
b = two - one - a
c = one
n = (26_501_365 - 65) / 131

(a * n ** 2 + b * n + c)
|> round()
|> IO.inspect()
