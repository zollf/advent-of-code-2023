defmodule AdventOfCode.Day18.P1 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [direction, amount, colour] =
        row
        |> String.split(" ", trim: true)

      {direction, String.to_integer(amount),
       colour |> String.replace("(", "") |> String.replace(")", "")}
    end)
  end

  def hex_to_decimal(hex) do
    case Integer.parse(hex, 16) do
      {num, _} -> num
      _ -> raise "Error"
    end
  end

  def add({x, y}, {"R", value, _}), do: {x + value, y}
  def add({x, y}, {"L", value, _}), do: {x - value, y}
  def add({x, y}, {"U", value, _}), do: {x, y - value}
  def add({x, y}, {"D", value, _}), do: {x, y + value}

  def get_direction(0), do: "R"
  def get_direction(1), do: "D"
  def get_direction(2), do: "L"
  def get_direction(3), do: "U"

  def trace(_, path \\ [{0, 0}])
  def trace([], path), do: path

  def trace([instruction | remaining], path) do
    current_point = hd(path)
    {cx, cy} = current_point
    {nx, ny} = add(current_point, instruction)
    trace(remaining, [{nx, ny}] ++ path)
  end

  def calc_area(path) do
    a =
      path
      |> trapezoid_area
      |> abs

    p =
      path
      |> calc_perimeter

    a + p * 0.5 + 1
  end

  def trapezoid_area(_, total \\ 0)

  # https://en.wikipedia.org/wiki/Shoelace_formula#Trapezoid_formula
  def trapezoid_area([cur | rest], total) do
    if length(rest) == 1 do
      total * 0.5
    else
      {cx, cy} = cur
      {nx, ny} = hd(rest)
      trapezoid_area(rest, total + (cx * ny - nx * cy))
    end
  end

  def calc_perimeter(_, total \\ 0)

  def calc_perimeter([cur | rest], total) do
    if length(rest) == 0 do
      total
    else
      {cx, cy} = cur
      {nx, ny} = hd(rest)

      dist = Enum.max([abs(ny - cy), abs(nx - cx)])
      # IO.inspect({cur, hd(rest), dist})

      calc_perimeter(rest, total + dist)
    end
  end
end

path =
  File.read!("lib/day18/input.txt")
  |> AdventOfCode.Day18.P1.parse()
  |> AdventOfCode.Day18.P1.trace()

AdventOfCode.Day18.P1.calc_area(path)
|> round
|> IO.inspect()
