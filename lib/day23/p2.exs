defmodule Forest do
  defstruct [:map, :width, :height, :graph, :start, :end]

  def new(tiles) do
    width = tiles |> hd |> length
    height = tiles |> length

    map =
      tiles
      |> List.flatten()
      |> Enum.reduce(%{}, fn {pos, symbol}, map -> Map.put(map, pos, symbol) end)

    forest = %Forest{map: map, width: width, height: height}

    forest
    |> Map.put(:start, Forest.get_start(forest))
    |> Map.put(:end, Forest.get_end(forest))
    |> create_graph()
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

  def create_graph(%Forest{} = forest) do
    nodes = get_nodes(forest)

    graph =
      Enum.reduce(nodes, %{}, &Map.put(&2, &1, []))
      |> Map.put(forest.start, [])
      |> Map.put(forest.end, [])

    graph = create_graph(forest, get_nodes(forest), graph)

    IO.inspect("done")

    forest
    |> Map.put(:graph, graph)
  end

  def get_nodes(%Forest{} = forest) do
    0..(forest.height - 1)
    |> Enum.map(fn y ->
      0..(forest.width - 1)
      |> Enum.map(fn x -> {x, y} end)
      |> Enum.filter(fn pos ->
        (Forest.get(forest, pos) != "#" && length(Forest.get_neighbors(forest, pos)) >= 3) ||
          pos == forest.start || pos == forest.end
      end)
    end)
    |> List.flatten()
    |> Enum.uniq()
  end

  def create_graph(_, [], graph), do: graph

  def create_graph(%Forest{} = forest, [node | rest], graph) do
    nodes = explore(forest, {0, node}, graph, MapSet.new(), [])
    create_graph(forest, rest, Map.put(graph, node, nodes))
  end

  def explore(%Forest{} = forest, {dist, pos}, graph, visited, nodes) do
    visited = MapSet.put(visited, pos)

    if Map.has_key?(graph, pos) && dist > 0 do
      [{dist, pos}]
    else
      forest
      |> get_neighbors(pos)
      |> Enum.filter(&(!Enum.member?(visited, &1)))
      |> Enum.reduce(nodes, fn neighbor, nodes ->
        nodes ++ explore(forest, {dist + 1, neighbor}, graph, visited, nodes)
      end)
      |> Enum.uniq()
    end
  end

  def hike(%Forest{} = forest) do
    pqueue = :gb_sets.singleton({0, forest.start, MapSet.new(), []})
    hike(forest.graph, forest.end, pqueue, 0)
  end

  def hike(graph, target, pqueue, max_steps) do
    if :gb_sets.is_empty(pqueue) do
      max_steps
    else
      {next, pqueue} = :gb_sets.take_largest(pqueue)
      {steps, pos, visited, path} = next

      visited = MapSet.put(visited, pos)

      if pos == target do
        hike(graph, target, pqueue, max(max_steps, steps))
      else
        neighbors =
          graph
          |> Map.get(pos)
          |> Enum.reject(fn {_, pos} -> MapSet.member?(visited, pos) end)

        pqueue =
          Enum.reduce(neighbors, pqueue, fn {ns, np}, pqueue ->
            :gb_sets.insert({steps + ns, np, visited, path ++ [{ns, np}]}, pqueue)
          end)

        hike(graph, target, pqueue, max_steps)
      end
    end
  end

  def get(%Forest{} = forest, {x, y}), do: Map.get(forest.map, {x, y})
  def exists?(%Forest{} = forest, {x, y}), do: Map.has_key?(forest.map, {x, y})

  def get_neighbors(%Forest{} = forest, {x, y}) do
    tile = Forest.get(forest, {x, y})

    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
    |> Enum.filter(&(Forest.exists?(forest, &1) && Forest.get(forest, &1) != "#"))
  end
end

defmodule AdventOfCode.Day23.P2 do
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
|> AdventOfCode.Day23.P2.parse()
|> Forest.hike()
|> IO.inspect()
