defmodule AdventOfCode.Day14.P2 do
  @total 1_000_000_000

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> transpose()
  end

  def transpose([[] | _]), do: []
  def transpose(m), do: [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]

  def tilt(system) do
    system
    |> Enum.map(&tilt_row/1)
  end

  def tilt_row(row) do
    row
    |> Enum.join("")
    |> String.split(~r{#}, include_captures: true, trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.map(&tilt_chunk/1)
    |> List.flatten()
  end

  def tilt_chunk(chunk) when hd(chunk) == "#", do: chunk

  def tilt_chunk(chunk) do
    mirrors = Enum.count(chunk, &(&1 == "O"))

    0..(length(chunk) - 1)
    |> Enum.map(fn index -> if index < mirrors, do: "O", else: "." end)
  end

  def score(system) do
    system
    |> Enum.map(fn row ->
      row_length = length(row)

      row
      |> Enum.with_index()
      |> Enum.map(fn {item, i} -> if item == "O", do: row_length - i, else: 0 end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def rotate(system) do
    row_length = system |> hd |> length()

    0..(row_length - 1)
    |> Enum.map(fn row_num ->
      0..(length(system) - 1)
      |> Enum.map(fn col_num -> get(system, col_num, row_length - row_num - 1) end)
    end)
  end

  def get(list_2d, r, c) do
    list_2d
    |> Enum.at(r)
    |> Enum.at(c)
  end

  def spin(system) do
    system
    |> AdventOfCode.Day14.P2.tilt()
    |> AdventOfCode.Day14.P2.rotate()
    |> AdventOfCode.Day14.P2.tilt()
    |> AdventOfCode.Day14.P2.rotate()
    |> AdventOfCode.Day14.P2.tilt()
    |> AdventOfCode.Day14.P2.rotate()
    |> AdventOfCode.Day14.P2.tilt()
    |> AdventOfCode.Day14.P2.rotate()
  end

  def spin_multi(_, count \\ @total, mem \\ %{})

  def spin_multi(system, 0, _), do: system

  def spin_multi(system, count, mem) do
    IO.inspect(count)
    cache_key = get_cache_key(system)

    if Map.has_key?(mem, cache_key) do
      cycle = Map.get(mem, cache_key) - count
      skip_count = rem(count, cycle)
      IO.inspect("HERHE: #{Map.get(mem, cache_key)} - #{count} = #{cycle} | #{skip_count}")
      spin_multi(system, skip_count, %{})
    else
      spin_multi(spin(system), count - 1, Map.put(mem, cache_key, count))
    end
  end

  def get_cache_key(system) do
    system
    |> List.flatten()
    |> Enum.join("")
  end
end

File.read!("lib/day14/input.txt")
|> AdventOfCode.Day14.P2.parse()
|> AdventOfCode.Day14.P2.spin_multi()
|> AdventOfCode.Day14.P2.score()
|> IO.inspect()
