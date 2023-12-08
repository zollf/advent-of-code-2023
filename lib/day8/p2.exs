defmodule NetworkNode do
  defstruct [:id, :left, :right, :last_char]

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

    last_char =
      id
      |> String.split("", trim: true)
      |> List.last()

    %NetworkNode{id: id, left: left, right: right, last_char: last_char}
  end

  def is_end(%NetworkNode{last_char: last_char}) when last_char == "Z", do: true
  def is_end(_), do: false

  def is_start(%NetworkNode{last_char: last_char}) when last_char == "A", do: true
  def is_start(_), do: false
end

defmodule AdventOfCode.Day8.P2 do
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

  def traverse(%NetworkNode{} = current_node, network, path, count) do
    if NetworkNode.is_end(current_node) do
      count
    else
      direction = Enum.at(path, rem(count, length(path)))
      next_node_id = if direction == "L", do: current_node.left, else: current_node.right
      traverse(Map.get(network, next_node_id), network, path, count + 1)
    end
  end

  def lcm([head | tail] = numbers, count \\ 1) do
    multiple = head * count

    if Enum.any?(tail, &(rem(multiple, &1) !== 0)) do
      AdventOfCode.Day8.P2.lcm(numbers, count + 1)
    else
      head * count
    end
  end

  # def traverse(current_nodes, network, path, count) do
  #   direction = Enum.at(path, rem(count, length(path)))

  #   IO.inspect(current_nodes |> Enum.map(&Map.get(&1, :id)))

  #   if(Enum.all?(current_nodes, &NetworkNode.is_end/1)) do
  #     count
  #   else
  #     next_nodes =
  #       current_nodes
  #       |> Enum.map(fn %NetworkNode{} = current_node ->
  #         next_node_id = if direction == "L", do: current_node.left, else: current_node.right
  #         Map.get(network, next_node_id)
  #       end)

  #     traverse(next_nodes, network, path, count + 1)
  #   end
  # end
end

{path, network} =
  File.read!("lib/day8/input.txt")
  |> AdventOfCode.Day8.P2.parse()

IO.puts("Done")

network
|> Map.values()
|> Enum.filter(&NetworkNode.is_start/1)
|> Enum.map(&AdventOfCode.Day8.P2.traverse(&1, network, path, 0))
|> AdventOfCode.Day8.P2.lcm()
|> IO.inspect()
