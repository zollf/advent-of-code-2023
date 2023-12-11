defmodule Pipe do
  defstruct [:value, :x, :y]

  def parse(value, x, y) do
    %Pipe{value: value, x: x, y: y}
  end

  def get_connections(%Pipe{x: x, y: y, value: "S"} = start_pipe, map) do
    top = get_pipe(x, y - 1, map)
    bottom = get_pipe(x, y + 1, map)
    left = get_pipe(x - 1, y, map)
    right = get_pipe(x + 1, y, map)

    [c1, c2] =
      [top, bottom, left, right]
      |> Enum.filter(& &1)
      |> Enum.filter(fn conn ->
        {c1, c2} = Pipe.get_connections(conn, map)

        if c1 != nil && c2 != nil do
          Pipe.is_pipe_equal?(start_pipe, c1) || Pipe.is_pipe_equal?(start_pipe, c2)
        else
          false
        end
      end)

    {c1, c2}
  end

  def get_connections(%Pipe{x: x, y: y} = pipe, map) do
    cond do
      pipe.value == "|" -> {get_pipe(x, y - 1, map), get_pipe(x, y + 1, map)}
      pipe.value == "-" -> {get_pipe(x - 1, y, map), get_pipe(x + 1, y, map)}
      pipe.value == "L" -> {get_pipe(x + 1, y, map), get_pipe(x, y - 1, map)}
      pipe.value == "J" -> {get_pipe(x - 1, y, map), get_pipe(x, y - 1, map)}
      pipe.value == "7" -> {get_pipe(x - 1, y, map), get_pipe(x, y + 1, map)}
      pipe.value == "F" -> {get_pipe(x + 1, y, map), get_pipe(x, y + 1, map)}
      true -> {nil, nil}
    end
  end

  def get_pipe(x, y, map) do
    max_y = length(map)
    max_x = length(Enum.at(map, 0))

    if 0 <= x && x < max_x && 0 <= y && y < max_y do
      map
      |> Enum.at(y)
      |> Enum.at(x)
    else
      nil
    end
  end

  def is_pipe_equal?(%Pipe{} = p1, %Pipe{} = p2), do: p1.x == p2.x && p1.y == p2.y
end

defmodule AdventOfCode.Day10.P1 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {cell, x} -> Pipe.parse(cell, x, y) end)
    end)
  end

  def find_start(map) do
    map
    |> Enum.reduce(fn row, acc ->
      start = Enum.find(row, fn cell -> cell.value == "S" end)
      if start, do: start, else: acc
    end)
  end

  def traverse(%Pipe{} = current_pipe, map, []) do
    {c1, c2} = Pipe.get_connections(current_pipe, map)
    traverse(c1, map, [current_pipe])
  end

  def traverse(%Pipe{} = current_pipe, _map, stack)
      when current_pipe.value == "S",
      do: stack

  def traverse(%Pipe{} = current_pipe, map, [previous_pipe | _] = stack) do
    {c1, c2} = Pipe.get_connections(current_pipe, map)

    if Pipe.is_pipe_equal?(c1, previous_pipe) do
      traverse(c2, map, [current_pipe] ++ stack)
    else
      traverse(c1, map, [current_pipe] ++ stack)
    end
  end
end

map =
  File.read!("lib/day10/input.txt")
  |> AdventOfCode.Day10.P1.parse()

loop =
  map
  |> AdventOfCode.Day10.P1.find_start()
  |> AdventOfCode.Day10.P1.traverse(map, [])

IO.inspect(length(loop) / 2)
