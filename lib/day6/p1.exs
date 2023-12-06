defmodule Race do
  defstruct [:time, :record]
end

defmodule AdventOfCode.Day6.P1 do
  def parse(races) do
    [time_input, distance_input] = races |> String.split("\n", trim: true)

    times =
      time_input
      |> String.replace("Time:", "")
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    distances =
      distance_input
      |> String.replace("Distance:", "")
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    Enum.zip(times, distances)
    |> Enum.map(fn {time, distance} -> %Race{time: time, record: distance} end)
  end

  def total_winning_outcomes(races) do
    races
    |> Enum.map(&get_roots/1)
    |> Enum.map(fn {lower, upper} -> ceil(upper) - floor(lower) - 1 end)
    |> Enum.reduce(1, fn num, acc -> num * acc end)
  end

  def get_roots(%Race{time: time, record: record}) do
    solve_quadratic(-1, time, -record)
  end

  def solve_quadratic(a, b, c) when a != 0 do
    pos = -1 * b + (b ** 2 - 4 * a * c) ** 0.5
    neg = -1 * b - (b ** 2 - 4 * a * c) ** 0.5

    {pos / (2 * a), neg / (2 * a)}
  end
end

File.read!("lib/day6/input.txt")
|> AdventOfCode.Day6.P1.parse()
|> AdventOfCode.Day6.P1.total_winning_outcomes()
|> IO.inspect()
