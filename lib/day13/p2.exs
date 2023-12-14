defmodule AdventOfCode.Day13.P2 do
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

  def transpose(m) do
    [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]
  end

  def reflection(pattern, ref \\ {0, 1})
  def reflection(pattern, {_, ref2}) when ref2 == length(pattern), do: nil

  def reflection(pattern, {ref1, ref2}) do
    distance_from_ref2_to_end = length(pattern) - ref2 - 1
    distance_from_ref1_to_start = ref1

    ref_box_size = min(distance_from_ref1_to_start, distance_from_ref2_to_end)

    non_reflected_rows =
      0..ref_box_size
      |> Enum.filter(&(Enum.at(pattern, ref1 - &1) != Enum.at(pattern, ref2 + &1)))

    cond do
      length(non_reflected_rows) == 1 ->
        maybe_smudge_row = hd(non_reflected_rows)

        if has_smudge?(
             Enum.at(pattern, ref1 - maybe_smudge_row),
             Enum.at(pattern, ref2 + maybe_smudge_row)
           ) do
          {ref1, ref2}
        else
          reflection(pattern, {ref1 + 1, ref2 + 1})
        end

      true ->
        reflection(pattern, {ref1 + 1, ref2 + 1})
    end
  end

  def has_smudge?(_, _, smudge_flag \\ false)
  def has_smudge?([], [], true), do: true
  def has_smudge?([], [], _), do: false

  def has_smudge?(r1, r2, smudge_flag) do
    cond do
      hd(r1) == hd(r2) ->
        has_smudge?(tl(r1), tl(r2), smudge_flag)

      hd(r1) != hd(r2) && !smudge_flag ->
        has_smudge?(tl(r1), tl(r2), true)

      hd(r1) != hd(r2) ->
        false
    end
  end
end

patterns =
  File.read!("lib/day13/input.txt")
  |> AdventOfCode.Day13.P2.parse()

rows =
  patterns
  |> Enum.map(&AdventOfCode.Day13.P2.reflection/1)
  |> Enum.filter(& &1)
  |> Enum.map(fn {r1, _} -> (r1 + 1) * 100 end)
  |> Enum.sum()

columns =
  patterns
  |> Enum.map(&AdventOfCode.Day13.P2.transpose/1)
  |> Enum.map(&AdventOfCode.Day13.P2.reflection/1)
  |> Enum.filter(& &1)
  |> Enum.map(fn {r1, _} -> r1 + 1 end)
  |> Enum.sum()

(columns + rows)
|> IO.inspect()
