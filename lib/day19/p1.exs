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

defmodule AdventOfCode.Day19.P1 do
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
end

{workflows, ratings} =
  File.read!("lib/day19/input.txt")
  |> AdventOfCode.Day19.P1.parse()

ratings
|> Enum.filter(fn rating -> AdventOfCode.Day19.P1.process(rating, workflows) |> hd == "A" end)
|> Enum.map(&Map.values/1)
|> List.flatten()
|> Enum.sum()
|> IO.inspect()
