defmodule NetworkNode do
  defstruct [:id, :left, :right]

  def parse(input) do
    [id_input, connection_input] =
      input
      |> String.split("=", trim: true)

    [left, right] =
      connection_input
      |> String.replace("(", "")
      |> String.replace(")", "")
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)

    id =
      id_input
      |> String.trim()

    %NetworkNode{id: id, left: left, right: right}
  end
end

defmodule AdventOfCode.Day8.P1 do
  def parse(input) do
    [path_input, network_input] =
      input
      |> String.split("\n\n", trim: true)

    network =
      network_input
      |> String.split("\n", trim: true)
      |> Enum.map(&NetworkNode.parse/1)
      |> Enum.reduce(%{}, fn %NetworkNode{id: id} = node, acc -> Map.put(acc, id, node) end)

    path =
      path_input
      |> String.split("", trim: true)

    {path, network}
  end

  def traverse(%NetworkNode{} = current_node, network, path, count)
      when current_node.id == "ZZZ",
      do: count

  def traverse(%NetworkNode{} = current_node, network, path, count) do
    direction = Enum.at(path, rem(count, length(path)))
    next_node_id = if direction == "L", do: current_node.left, else: current_node.right
    traverse(Map.get(network, next_node_id), network, path, count + 1)
  end
end

{path, network} =
  File.read!("lib/day8/input.txt")
  |> AdventOfCode.Day8.P1.parse()

IO.puts("Done")

network
|> Map.get("AAA")
|> AdventOfCode.Day8.P1.traverse(network, path, 0)
|> IO.inspect()
