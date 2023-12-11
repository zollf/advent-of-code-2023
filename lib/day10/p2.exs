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

  def replace_start(%Pipe{x: x, y: y, value: "S"} = start_pipe, map) do
    {c1, c2} = get_connections(start_pipe, map)

    cond do
      c1.x == x && c1.y == y + 1 ->
        if c2.x + 1 == x, do: %Pipe{x: x, y: y, value: "7"}, else: %Pipe{x: x, y: y, value: "F"}

      c1.x == x && c1.y == y - 1 ->
        if c2.x - 1 == x, do: %Pipe{x: x, y: y, value: "J"}, else: %Pipe{x: x, y: y, value: "L"}
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

defmodule AdventOfCode.Day10.P2 do
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
    |> Enum.find(fn row -> Enum.any?(row, fn pipe -> pipe.value == "S" end) end)
    |> Enum.find(fn pipe -> pipe.value == "S" end)
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

  def mark_enclosed([], stack, _), do: stack

  def mark_enclosed([%Pipe{} = head | tail], stack, is_inside) when head.value == "." do
    if is_inside do
      mark_enclosed(tail, stack ++ [%Pipe{value: "x", x: head.x, y: head.y}], is_inside)
    else
      mark_enclosed(tail, stack ++ [head], is_inside)
    end
  end

  def mark_enclosed([%Pipe{} = head | tail], stack, is_inside) do
    cond do
      Enum.member?(["|", "F", "7"], head.value) ->
        mark_enclosed(tail, stack ++ [head], !is_inside)

      true ->
        mark_enclosed(tail, stack ++ [head], is_inside)
    end
  end

  def redefine_map(map, loop) do
    map
    |> Enum.map(fn row ->
      row
      |> Enum.map(fn %Pipe{} = cell ->
        cond do
          cell.value == "S" -> Pipe.replace_start(cell, map)
          Enum.any?(loop, fn loop_pipe -> Pipe.is_pipe_equal?(loop_pipe, cell) end) -> cell
          true -> Pipe.parse(".", cell.x, cell.y)
        end
      end)
      |> mark_enclosed([], false)
    end)
  end
end

map =
  File.read!("lib/day10/input.txt")
  |> AdventOfCode.Day10.P2.parse()

loop =
  map
  |> AdventOfCode.Day10.P2.find_start()
  |> AdventOfCode.Day10.P2.traverse(map, [])

enclosed_map =
  map
  |> AdventOfCode.Day10.P2.redefine_map(loop)

# [Enum.at(enclosed_map, 1)]
enclosed_map
|> Enum.map(fn row -> Enum.map(row, fn cell -> cell.value end) end)

# |> IO.inspect(width: 110)

enclosed_map
|> Enum.map(fn row -> Enum.count(row, fn pipe -> pipe.value == "x" end) end)
|> Enum.sum()
|> IO.inspect(width: :infinity)
