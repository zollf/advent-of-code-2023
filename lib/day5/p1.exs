defmodule Mapping do
  defstruct [
    :maps,
    :destination_category,
    :source_category
  ]

  def parse(input) do
    [categories_input | maps_input] = input |> String.split("\n", trim: true)

    [destination_category, source_category] =
      categories_input
      |> String.replace(" map:", "")
      |> String.split("-to-")

    maps =
      maps_input
      |> Enum.map(&parse_map/1)
      |> List.flatten()

    %Mapping{
      destination_category: destination_category,
      source_category: source_category,
      maps: maps
    }
  end

  def parse_map(map) do
    [destination, source, range] =
      map
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    %{destination: destination, source: source, range: range}
  end
end

defmodule Mappings do
  defstruct [:seeds, :mappings]

  def parse_seeds(%Mappings{} = mappings, input) do
    seeds =
      input
      |> String.split(":", trim: true)
      |> Enum.at(1)
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    mappings
    |> Map.put(:seeds, seeds)
  end

  def parse_mappings(%Mappings{} = mappings, input) do
    all_mappings =
      input
      |> Enum.map(&Mapping.parse/1)

    mappings
    |> Map.put(:mappings, all_mappings)
  end
end

defmodule AdventOfCode.Day5.P1 do
  def parse(input) do
    [seeds_input | mappings_input] = input |> String.split("\n\n", trim: true)

    %Mappings{}
    |> Mappings.parse_seeds(seeds_input)
    |> Mappings.parse_mappings(mappings_input)
  end

  def traverse_mapping(number, []), do: number

  def traverse_mapping(number, [%Mapping{} = mapping | tail]) do
    matching_map =
      mapping.maps
      |> Enum.find(fn %{range: range, source: source, destination: destination} ->
        source <= number && number <= source + range - 1
      end)

    case matching_map do
      %{range: _range, source: source, destination: destination} ->
        traverse_mapping(number - source + destination, tail)

      nil ->
        traverse_mapping(number, tail)
    end
  end
end

%{mappings: mappings, seeds: seeds} =
  File.read!("lib/day5/input.txt")
  |> AdventOfCode.Day5.P1.parse()

IO.puts("Done")

seeds
|> Enum.map(&AdventOfCode.Day5.P1.traverse_mapping(&1, mappings))
|> Enum.min()
|> IO.inspect()
