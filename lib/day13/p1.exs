defmodule AdventOfCode.Day13.P1 do
  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn pattern ->
      pattern
      |> String.split("\n", trim: true)
      |> Enum.map(fn row ->
        row
        |> String.split("", trim: true)
      end)
    end)
  end

  def transpose([[] | _]), do: []
  def transpose(m), do: [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]

  def reflection(pattern, ref \\ {0, 1})
  def reflection(pattern, {_, ref2}) when ref2 == length(pattern), do: nil

  def reflection(pattern, {ref1, ref2}) do
    distance_from_ref2_to_end = length(pattern) - ref2 - 1
    distance_from_ref1_to_start = ref1

    ref_box_size = min(distance_from_ref1_to_start, distance_from_ref2_to_end)

    rows_reflected =
      0..ref_box_size
      |> Enum.filter(&(Enum.at(pattern, ref1 - &1) == Enum.at(pattern, ref2 + &1)))
      |> length()

    if ref_box_size + 1 == rows_reflected do
      {ref1, ref2}
    else
      reflection(pattern, {ref1 + 1, ref2 + 1})
    end
  end
end

patterns =
  File.read!("lib/day13/input.txt")
  |> AdventOfCode.Day13.P1.parse()

rows =
  patterns
  |> Enum.map(&AdventOfCode.Day13.P1.reflection/1)
  |> Enum.filter(& &1)
  |> Enum.map(fn {r1, _} -> (r1 + 1) * 100 end)
  |> Enum.sum()

columns =
  patterns
  |> Enum.map(&AdventOfCode.Day13.P1.transpose/1)
  |> Enum.map(&AdventOfCode.Day13.P1.reflection/1)
  |> Enum.filter(& &1)
  |> Enum.map(fn {r1, _} -> r1 + 1 end)
  |> Enum.sum()

(columns + rows)
|> IO.inspect()
