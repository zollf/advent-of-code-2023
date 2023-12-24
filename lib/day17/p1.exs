# Credit: https://github.com/bjorng/advent-of-code-2023/blob/main/day17/lib/day17.ex
defmodule AdventOfCode.Day17.P1 do
  @big_number 999_999_999_999
  @max_con 3

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def traverse(map, target, queue, visited) do
    {next, queue} = :gb_sets.take_smallest(queue)
    {heat, {cur_coords, steps, direction}} = next

    if cur_coords == target do
      heat
    else
      neighbors =
        map
        |> get_neighbors(cur_coords)
        |> Enum.filter(fn {_, neighbor_direction} ->
          !is_opp_dir?(neighbor_direction, direction)
        end)
        |> Enum.map(fn {neighbor_coords, neighbor_direction} ->
          steps = if direction == neighbor_direction, do: steps + 1, else: 1
          {neighbor_coords, steps, neighbor_direction}
        end)
        |> Enum.reject(fn {_, steps, _} -> steps == @max_con + 1 end)
        |> Enum.reject(fn key -> MapSet.member?(visited, key) end)

      visited = Enum.reduce(neighbors, visited, fn key, visited -> MapSet.put(visited, key) end)

      queue =
        Enum.reduce(neighbors, queue, fn {new_pos, _, _} = key, queue ->
          :gb_sets.insert({heat + get(map, new_pos), key}, queue)
        end)

      traverse(map, target, queue, visited)
    end
  end

  def is_opp_dir?(:left, :right), do: true
  def is_opp_dir?(:right, :left), do: true
  def is_opp_dir?(:up, :down), do: true
  def is_opp_dir?(:down, :up), do: true
  def is_opp_dir?(_, _), do: false

  def get_neighbors(map, {x, y}) do
    x_length = map |> hd |> length
    y_length = map |> length

    [
      {{x + 1, y}, :right},
      {{x - 1, y}, :left},
      {{x, y + 1}, :down},
      {{x, y - 1}, :up}
    ]
    |> Enum.filter(fn {{new_x, new_y}, _} ->
      0 <= new_x && new_x < x_length && 0 <= new_y && new_y < y_length
    end)
  end

  def get(map, x, y) do
    map
    |> Enum.at(y)
    |> Enum.at(x)
  end

  def get(map, {x, y}) do
    map
    |> Enum.at(y)
    |> Enum.at(x)
  end
end

map =
  File.read!("lib/day17/input.txt")
  |> AdventOfCode.Day17.P1.parse()

x_max = map |> hd |> length()
y_max = map |> length()

queue = :gb_sets.singleton({0, {{0, 0}, 0, :start}})

AdventOfCode.Day17.P1.traverse(map, {x_max - 1, y_max - 1}, queue, MapSet.new())
|> IO.inspect()
