defmodule Instruction do
  defstruct [:type, :destination, :raw, :operation]

  # :raw -> [:direct, :operation]
  def new(raw_instruction) do
    instruction = %Instruction{raw: raw_instruction}

    if String.contains?(raw_instruction, ":") do
      [operation, destination] = raw_instruction |> String.split(":", trim: true)

      instruction
      |> Map.put(:destination, destination)
      |> Map.put(:type, :operation)
      |> Map.put(:operation, parse_operation(operation))
    else
      instruction
      |> Map.put(:destination, raw_instruction)
      |> Map.put(:type, :direct)
    end
  end

  def process(ratings, %Instruction{} = instruction) do
    cond do
      instruction.type == :direct ->
        instruction.destination

      instruction.type == :operation ->
        {key, value, symbol} = instruction.operation

        cond do
          symbol == "<" && Map.get(ratings, key) < value -> instruction.destination
          symbol == ">" && Map.get(ratings, key) > value -> instruction.destination
          true -> nil
        end

      true ->
        nil
    end
  end

  defp parse_operation(raw_operation) do
    symbol = if String.contains?(raw_operation, "<"), do: "<", else: ">"

    [key, value] =
      raw_operation
      |> String.split(symbol, trim: true)

    {key, String.to_integer(value), symbol}
  end
end

defmodule AdventOfCode.Day19.P2 do
  def parse(input) do
    [workflows, ratings] =
      input
      |> String.split("\n\n", trim: true)

    workflows =
      workflows
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn workflow, workflows ->
        [name, instructions] =
          workflow
          |> String.replace("}", "")
          |> String.split("{")

        instructions =
          instructions
          |> String.split(",", trim: true)
          |> Enum.map(&Instruction.new/1)

        Map.put(workflows, name, instructions)
      end)

    ratings =
      ratings
      |> String.split("\n", trim: true)
      |> Enum.map(fn rating ->
        rating
        |> String.replace("{", "")
        |> String.replace("}", "")
        |> String.split(",", trim: true)
        |> Enum.reduce(%{}, fn item, rating ->
          [name, value] = String.split(item, "=", trim: true)
          Map.put(rating, name, String.to_integer(value))
        end)
      end)

    {workflows, ratings}
  end

  def process_workflow(rating, [workflow | rest]) do
    result = Instruction.process(rating, workflow)

    if result != nil do
      result
    else
      process_workflow(rating, rest)
    end
  end

  def process(rating, workflows, path \\ ["in"])

  def process(rating, workflows, path) do
    current = hd(path)

    if current == "A" or current == "R" do
      path
    else
      current_workflow = Map.get(workflows, current)
      next = process_workflow(rating, current_workflow)
      process(rating, workflows, [next] ++ path)
    end
  end

  def total_ranges(ranges) do
    ranges
    |> Map.values()
    |> Enum.map(&Range.size/1)
    |> Enum.product()
  end

  # s > 400
  # s < 400
  # 100..500
  def update_ranges(%Instruction{type: :operation} = instruction, ranges) do
    {key, value, symbol} = instruction.operation
    lower..upper = Map.get(ranges, key)

    cond do
      symbol == "<" && upper < value ->
        {Map.put(ranges, key, lower..upper), nil}

      symbol == ">" && lower > value ->
        {Map.put(ranges, key, lower..upper), nil}

      symbol == "<" && lower < value ->
        {Map.put(ranges, key, lower..(value - 1)), Map.put(ranges, key, value..upper)}

      symbol == ">" && upper > value ->
        {Map.put(ranges, key, (value + 1)..upper), Map.put(ranges, key, lower..value)}

      true ->
        nil
    end
  end

  def get_ranges(workflows, workflow, ranges) do
    workflow
    |> Enum.reduce({0, ranges}, fn %Instruction{} = instruction, {running_total, ranges} ->
      cond do
        instruction.type == :direct && instruction.destination == "A" ->
          {running_total + total_ranges(ranges), ranges}

        instruction.type == :direct && instruction.destination == "R" ->
          {running_total, ranges}

        instruction.type == :operation ->
          destination_workflow = Map.get(workflows, instruction.destination)
          updated_ranges = update_ranges(instruction, ranges)

          cond do
            instruction.destination == "A" ->
              if updated_ranges do
                {new_ranges, inverse_ranges} = updated_ranges
                {running_total + total_ranges(new_ranges), inverse_ranges}
              else
                {running_total, ranges}
              end

            instruction.destination == "R" ->
              if updated_ranges do
                {new_ranges, inverse_ranges} = updated_ranges
                {running_total, inverse_ranges}
              else
                {running_total, ranges}
              end

            true ->
              if updated_ranges do
                {new_ranges, inverse_ranges} = updated_ranges
                new_total = get_ranges(workflows, destination_workflow, new_ranges)
                {running_total + new_total, inverse_ranges}
              else
                {running_total, ranges}
              end
          end

        true ->
          destination_workflow = Map.get(workflows, instruction.destination)
          new_total = get_ranges(workflows, destination_workflow, ranges)
          {running_total + new_total, ranges}
      end
    end)
    |> Tuple.to_list()
    |> Enum.at(0)
  end
end

{workflows, ratings} =
  File.read!("lib/day19/input.txt")
  |> AdventOfCode.Day19.P2.parse()

workflows
|> AdventOfCode.Day19.P2.get_ranges(Map.get(workflows, "in"), %{
  "x" => 1..4000,
  "m" => 1..4000,
  "a" => 1..4000,
  "s" => 1..4000
})
|> IO.inspect()
