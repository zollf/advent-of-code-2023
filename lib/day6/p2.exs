defmodule Race do
  defstruct [:time, :record]
end

defmodule AdventOfCode.Day6.P2 do
  def parse(races) do
    [time_input, distance_input] = races |> String.split("\n", trim: true)

    time =
      time_input
      |> String.replace("Time:", "")
      |> String.replace(" ", "")
      |> String.to_integer()

    distance =
      distance_input
      |> String.replace("Distance:", "")
      |> String.replace(" ", "")
      |> String.to_integer()

    %Race{time: time, record: distance}
  end

  def total_winning_outcomes(races) do
    races
    |> get_roots()
    |> then(fn {lower, upper} -> ceil(upper) - floor(lower) - 1 end)
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
|> AdventOfCode.Day6.P2.parse()
|> AdventOfCode.Day6.P2.total_winning_outcomes()
|> IO.inspect()
