# Credit: https://github.com/mathsaey/adventofcode/blob/master/lib/2023/25.ex
defmodule AdventOfCode.Day25.P1 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.split(": ", trim: true)
      |> Enum.map(&String.split(&1, " ", trim: true))
    end)
    |> Enum.reduce(%{}, fn [[wire], connections], graph ->
      connections
      |> Enum.reduce(graph, fn connected_wire, graph ->
        graph
        |> Map.put(connected_wire, Enum.uniq(Map.get(graph, connected_wire, []) ++ [wire]))
        |> Map.put(wire, Enum.uniq(Map.get(graph, wire, []) ++ [connected_wire]))
      end)
    end)
  end

  def delete_most_used_connections(graph) do
    most_used_connections =
      0..1000
      |> Enum.map(fn _ -> dijkstra(graph, random_connection(graph), random_connection(graph)) end)
      |> Enum.flat_map(&Enum.chunk_every(&1, 2, 1, :discard))
      |> Enum.map(&Enum.sort/1)
      |> Enum.frequencies()
      |> Enum.sort_by(fn {_, v} -> v end, :desc)
      |> Enum.take(3)

    most_used_connections
    |> IO.inspect()
    |> Enum.map(fn {con, _} -> con end)
    |> Enum.reduce(graph, fn [c1, c2], graph -> delete_connection(graph, {c1, c2}) end)
  end

  def delete_connection(graph, {c1, c2}) do
    graph
    |> Map.put(c1, Map.get(graph, c1) |> Enum.filter(&(&1 != c2)))
    |> Map.put(c2, Map.get(graph, c2) |> Enum.filter(&(&1 != c1)))
  end

  def random_connection(graph) do
    graph
    |> Map.keys()
    |> Enum.random()
  end

  def dijkstra(graph, source, target) do
    pqueue = :gb_sets.singleton({0, source, [source]})
    visited = MapSet.new([source])
    dijkstra(graph, pqueue, target, visited)
  end

  def dijkstra(graph, pqueue, target, visited) do
    {{steps, component, path}, pqueue} = :gb_sets.take_smallest(pqueue)

    if component == target do
      path
    else
      connections =
        graph
        |> Map.get(component)
        |> Enum.filter(&(!MapSet.member?(visited, &1)))

      visited = Enum.reduce(connections, visited, &MapSet.put(&2, &1))

      pqueue =
        Enum.reduce(connections, pqueue, &:gb_sets.insert({steps + 1, &1, path ++ [&1]}, &2))

      dijkstra(graph, pqueue, target, visited)
    end
  end

  def traverse_loop(graph, start) do
    traverse_loop(graph, [start], MapSet.new([start]))
  end

  def traverse_loop(graph, [], visited), do: MapSet.to_list(visited)

  def traverse_loop(graph, [connection | queue], visited) do
    connections =
      graph
      |> Map.get(connection)
      |> Enum.filter(&(!MapSet.member?(visited, &1)))

    visited = Enum.reduce(connections, visited, &MapSet.put(&2, &1))
    traverse_loop(graph, queue ++ connections, visited)
  end

  def get_enclosed_loops(graph, totals \\ [])

  def get_enclosed_loops(graph, totals) do
    if Enum.empty?(graph) do
      totals
    else
      loop = traverse_loop(graph, random_connection(graph))
      graph = Enum.reduce(loop, graph, &Map.delete(&2, &1))

      get_enclosed_loops(graph, totals ++ [length(loop)])
    end
  end
end

File.read!("lib/day25/input.txt")
|> AdventOfCode.Day25.P1.parse()
|> AdventOfCode.Day25.P1.delete_most_used_connections()
# |> AdventOfCode.Day25.P1.delete_connection({"bvb", "cmg"})
# |> AdventOfCode.Day25.P1.delete_connection({"hfx", "pzl"})
# |> AdventOfCode.Day25.P1.delete_connection({"nvd", "jqt"})
|> AdventOfCode.Day25.P1.get_enclosed_loops()
|> Enum.product()
|> IO.inspect()
