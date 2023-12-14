defmodule Springs do
  defstruct [:record, :arrangements]

  def parse(input) do
    [record_input, arrangement_input] =
      input
      |> String.split(" ", trim: true)

    record =
      record_input
      |> String.split("", trim: true)

    arrangements =
      arrangement_input
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    %Springs{record: record, arrangements: arrangements}
  end
end

defmodule AdventOfCode.Day12.P1 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Springs.parse/1)
  end

  def get_all_arrangements(_, _, index \\ 0, spring_arrangements \\ 0)

  def get_all_arrangements(record, [], _, spring_arrangements) do
    if Enum.any?(record, &(&1 == "#")) do
      spring_arrangements
    else
      spring_arrangements + 1
    end
  end

  def get_all_arrangements(records, _, index, spring_arrangements) when index >= length(records),
    do: spring_arrangements

  def get_all_arrangements(records, [arrangement | _], index, spring_arrangements)
      when index + arrangement > length(records),
      do: spring_arrangements

  def get_all_arrangements(
        records,
        [arrangement | arrangement_tail] = arrangements,
        index,
        spring_arrangements
      ) do
    # Can current arrangement fit
    can_fit_arrangement =
      records
      |> Enum.slice(index, arrangement)
      |> Enum.all?(&(&1 == "?" || &1 == "#"))

    if can_fit_arrangement do
      updated_record =
        records
        |> Enum.with_index()
        |> Enum.map(fn {record, i} ->
          if index <= i && i < index + arrangement, do: "x", else: record
        end)

      get_all_arrangements(
        updated_record,
        arrangement_tail,
        index + arrangement + 1,
        spring_arrangements
      ) + get_all_arrangements(records, arrangements, index + 1, spring_arrangements)
    else
      get_all_arrangements(records, arrangements, index + 1, spring_arrangements)
    end
  end
end

all_records =
  File.read!("lib/day12/input.txt")
  |> AdventOfCode.Day12.P1.parse()

all_records
|> Enum.map(fn records ->
  AdventOfCode.Day12.P1.get_all_arrangements(
    records.record,
    records.arrangements
  )
end)
|> Enum.sum()
|> IO.inspect()
