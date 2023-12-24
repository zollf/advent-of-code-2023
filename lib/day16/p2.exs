defmodule AdventOfCode.Day16.P2 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  def traverse(map, _, energized \\ %{})
  def traverse(_, nil, energized), do: energized

  def traverse(map, {x, y, direction}, energized) do
    key = get_key(x, y, direction)

    if Map.has_key?(energized, key) do
      energized
    else
      energized_2 = Map.put(energized, key, "(#{x},#{y})")

      reflections = get(map, x, y) |> get_reflections(direction)

      if length(reflections) == 2 do
        [first_dir, second_dir] = reflections
        energized_3 = traverse(map, get_next(map, x, y, first_dir), energized_2)
        energized_4 = traverse(map, get_next(map, x, y, second_dir), energized_3)

        energized_4
      else
        [dir] = reflections
        energized_3 = traverse(map, get_next(map, x, y, dir), energized_2)

        energized_3
      end
    end
  end

  def get(map, x, y) do
    map
    |> Enum.at(y)
    |> Enum.at(x)
  end

  def get_next(map, x, y, direction) do
    x_bound = map |> hd |> length
    y_bound = map |> length

    cond do
      direction == :right && x + 1 < x_bound -> {x + 1, y, direction}
      direction == :left && x - 1 >= 0 -> {x - 1, y, direction}
      direction == :up && y - 1 >= 0 -> {x, y - 1, direction}
      direction == :down && y + 1 < y_bound -> {x, y + 1, direction}
      true -> nil
    end
  end

  def get_reflections("\\", :down), do: [:right]
  def get_reflections("\\", :left), do: [:up]
  def get_reflections("\\", :up), do: [:left]
  def get_reflections("\\", :right), do: [:down]
  def get_reflections("/", :down), do: [:left]
  def get_reflections("/", :left), do: [:down]
  def get_reflections("/", :up), do: [:right]
  def get_reflections("/", :right), do: [:up]
  def get_reflections("|", _), do: [:up, :down]
  def get_reflections("-", _), do: [:left, :right]
  def get_reflections(_, direction), do: [direction]

  def get_key(x, y, direction), do: "#{x},#{y},#{direction}"

  def energize_score(energized) do
    energized
    |> Map.values()
    |> Enum.uniq()
    |> length()
  end

  def max_edge_energize(map, edges \\ [], max_score \\ 0)

  def max_edge_energize(map, [], 0) do
    row_length = map |> hd |> length()
    last_row = row_length - 1
    col_length = map |> length()
    last_col = col_length - 1

    col_edges =
      0..last_col
      |> Enum.map(&[{&1, 0, :down}, {&1, last_col, :up}])
      |> List.flatten()

    row_edges =
      0..last_row
      |> Enum.map(&[{0, &1, :right}, {last_row, &1, :left}])
      |> List.flatten()

    max_edge_energize(map, col_edges ++ row_edges, 0)
  end

  def max_edge_energize(_map, [], max_score), do: max_score

  def max_edge_energize(map, [head | tail], max_score) do
    score =
      map
      |> traverse(head)
      |> energize_score()

    max_edge_energize(map, tail, max(max_score, score))
  end
end

File.read!("lib/day16/input.txt")
|> AdventOfCode.Day16.P2.parse()
|> AdventOfCode.Day16.P2.max_edge_energize()
|> IO.inspect()
