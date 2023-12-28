defmodule Forest do
  defstruct [:map, :width, :height]

  def new(tiles) do
    width = tiles |> hd |> length
    height = tiles |> length

    map =
      tiles
      |> List.flatten()
      |> Enum.reduce(%{}, fn {pos, symbol}, map -> Map.put(map, pos, symbol) end)

    %Forest{map: map, width: width, height: height}
  end

  def print(%Forest{} = forest) do
    0..(forest.height - 1)
    |> Enum.map(fn y ->
      0..(forest.width - 1)
      |> Enum.map(fn x -> Map.get(forest.map, {x, y}) end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
    |> IO.puts()

    forest
  end

  def get_start(%Forest{} = forest) do
    x = Enum.find(0..(forest.width - 1), &(Map.get(forest.map, {&1, 0}) == "."))
    {x, 0}
  end

  def get_end(%Forest{} = forest) do
    x = Enum.find(0..(forest.width - 1), &(Map.get(forest.map, {&1, forest.height - 1}) == "."))
    {x, forest.height - 1}
  end

  def hike(%Forest{} = forest) do
    source = Forest.get_start(forest)
    target = Forest.get_end(forest)
    pqueue = :gb_sets.singleton({0, source, MapSet.new()})
    hike(forest, target, pqueue, 0)
  end

  def hike(%Forest{} = forest, target, pqueue, max_steps) do
    if :gb_sets.is_empty(pqueue) do
      max_steps
    else
      {next, pqueue} = :gb_sets.take_largest(pqueue)
      {steps, pos, visited} = next

      if pos == target do
        hike(forest, target, pqueue, max(max_steps, steps))
      else
        neighbors =
          Forest.get_neighbors(forest, pos)
          |> Enum.reject(&MapSet.member?(visited, &1))

        visited = Enum.reduce(neighbors, visited, fn key, visited -> MapSet.put(visited, key) end)

        pqueue =
          Enum.reduce(neighbors, pqueue, fn pos, pqueue ->
            :gb_sets.insert({steps + 1, pos, visited}, pqueue)
          end)

        hike(forest, target, pqueue, max_steps)
      end
    end
  end

  def get(%Forest{} = forest, {x, y}), do: Map.get(forest.map, {x, y})
  def exists?(%Forest{} = forest, {x, y}), do: Map.has_key?(forest.map, {x, y})

  def get_neighbors(%Forest{} = forest, {x, y}) do
    tile = Forest.get(forest, {x, y})

    cond do
      tile == ">" ->
        [{x + 1, y}]

      tile == "<" ->
        [{x - 1, y}]

      tile == "v" ->
        [{x, y + 1}]

      tile == "^" ->
        [{x, y - 1}]

      true ->
        [
          {x + 1, y},
          {x - 1, y},
          {x, y + 1},
          {x, y - 1}
        ]
    end
    |> Enum.filter(&(Forest.exists?(forest, &1) && Forest.get(forest, &1) != "#"))
  end
end

defmodule AdventOfCode.Day23.P1 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {tile, x} -> {{x, y}, tile} end)
    end)
    |> Forest.new()
  end
end

File.read!("lib/day23/input.txt")
|> AdventOfCode.Day23.P1.parse()
|> Forest.hike()
|> IO.inspect()
