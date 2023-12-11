defmodule Space do
  defstruct [:value, :x, :y]

  def create(value, x, y) do
    %Space{value: value, x: x, y: y}
  end
end

defmodule AdventOfCode.Day11.P1 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.split("", trim: true)
      |> Enum.map(fn space -> space end)
    end)
  end

  def transpose([[] | _]), do: []

  def transpose(m) do
    [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]
  end

  def expand([], new_map), do: new_map

  def expand([row | tail] = map, new_map) do
    expanded_row =
      if Enum.all?(row, fn space -> space == "." end) do
        expand(tail, new_map ++ [row, row])
      else
        expand(tail, new_map ++ [row])
      end
  end

  def redefined(map) do
    map
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {space, x} -> %Space{value: space, x: x, y: y} end)
    end)
  end

  def get_distances([], total), do: total

  def get_distances([star | tail], total) do
    distances =
      tail
      |> Enum.map(fn target_star ->
        abs(target_star.x - star.x) + abs(target_star.y - star.y)
      end)
      |> Enum.sum()

    get_distances(tail, total + distances)
  end
end

result =
  File.read!("lib/day11/input.txt")
  |> AdventOfCode.Day11.P1.parse()
  |> AdventOfCode.Day11.P1.expand([])
  |> AdventOfCode.Day11.P1.transpose()
  |> AdventOfCode.Day11.P1.expand([])
  |> AdventOfCode.Day11.P1.transpose()
  |> AdventOfCode.Day11.P1.transpose()
  |> AdventOfCode.Day11.P1.redefined()
  |> Enum.reduce([], fn row, acc ->
    List.flatten(acc ++ [Enum.filter(row, fn space -> space.value == "#" end)])
  end)
  |> AdventOfCode.Day11.P1.get_distances(0)
  |> IO.inspect()

# result
# |> Enum.reduce([], fn row, acc -> acc ++ [Enum.filter(row, fn space ->)])
