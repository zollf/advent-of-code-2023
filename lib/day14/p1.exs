defmodule AdventOfCode.Day14.P1 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> transpose()
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.map(fn row ->
      row
      |> String.split(~r{#}, include_captures: true, trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))
    end)
  end

  def transpose([[] | _]), do: []
  def transpose(m), do: [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]

  def tilt(system) do
    system
    |> Enum.map(&tilt_row/1)
  end

  def tilt_row(row) do
    row
    |> Enum.map(&tilt_chunk/1)
  end

  def tilt_chunk(chunk) when hd(chunk) == "#", do: chunk

  def tilt_chunk(chunk) do
    mirrors = Enum.count(chunk, &(&1 == "O"))

    0..(length(chunk) - 1)
    |> Enum.map(fn index -> if index < mirrors, do: "O", else: "." end)
  end

  def score(system) do
    system
    |> Enum.map(&List.flatten/1)
    |> Enum.map(fn row ->
      row_length = length(row)

      row
      |> Enum.with_index()
      |> Enum.map(fn {item, i} -> if item == "O", do: row_length - i, else: 0 end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end
end

File.read!("lib/day14/input.txt")
|> AdventOfCode.Day14.P1.parse()
|> AdventOfCode.Day14.P1.tilt()
|> AdventOfCode.Day14.P1.score()
|> IO.inspect()
