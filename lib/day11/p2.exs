defmodule Space do
  defstruct [:value, :x, :y]

  def create(value, x, y) do
    %Space{value: value, x: x, y: y}
  end
end

defmodule AdventOfCode.Day11.P2 do
  @multiplier 1_000_000

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {space, x} -> %Space{value: space, x: x, y: y} end)
    end)
  end

  def get_empty_spaces(results) do
    results
    |> Enum.with_index()
    |> Enum.filter(fn {row, _} -> Enum.all?(row, fn space -> space.value == "." end) end)
    |> Enum.map(fn {_, i} -> i end)
  end

  def transpose([[] | _]), do: []

  def transpose(m) do
    [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]
  end

  def get_distances([], total, _, _), do: total

  def get_distances([star | tail], total, empty_rows, empty_columns) do
    distances =
      tail
      |> Enum.map(fn target_star ->
        intersecting_empty_rows =
          empty_rows
          |> Enum.filter(fn row ->
            min(target_star.y, star.y) < row && row < max(target_star.y, star.y)
          end)
          |> length()

        intersecting_empty_columns =
          empty_columns
          |> Enum.filter(fn column ->
            min(target_star.x, star.x) < column && column < max(target_star.x, star.x)
          end)
          |> length()

        # Intersects with Empty Row
        # Intersects with Empty Column
        abs(target_star.x - star.x) +
          intersecting_empty_rows * (@multiplier - 1) +
          abs(target_star.y - star.y) +
          intersecting_empty_columns * (@multiplier - 1)
      end)
      |> Enum.sum()

    get_distances(tail, total + distances, empty_rows, empty_columns)
  end
end

results =
  File.read!("lib/day11/input.txt")
  |> AdventOfCode.Day11.P2.parse()

empty_rows = AdventOfCode.Day11.P2.get_empty_spaces(results)

empty_columns =
  results
  |> AdventOfCode.Day11.P2.transpose()
  |> AdventOfCode.Day11.P2.get_empty_spaces()

results
|> Enum.reduce([], fn row, acc ->
  List.flatten(acc ++ [Enum.filter(row, fn space -> space.value == "#" end)])
end)
|> AdventOfCode.Day11.P2.get_distances(0, empty_rows, empty_columns)
|> IO.inspect()

# AdventOfCode.Day11.P2.get_distances(
#   [Space.create("#", 1, 5), Space.create("#", 4, 9)],
#   0,
#   empty_rows,
#   empty_columns
# )
# |> IO.inspect()
