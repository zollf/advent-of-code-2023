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
      |> Enum.uniq()

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
      |> Enum.chunk_every(2)
      |> Enum.map(fn [start, range] -> {start, start + range - 1} end)

    mappings
    |> Map.put(:seeds, seeds)
  end

  def parse_mappings(%Mappings{} = mappings, input) do
    all_mappings =
      input
      |> Enum.map(&Mapping.parse/1)
      |> Enum.reverse()

    mappings
    |> Map.put(:mappings, all_mappings)
  end
end

defmodule AdventOfCode.Day5.P2 do
  def parse(input) do
    [seeds_input | mappings_input] = input |> String.split("\n\n", trim: true)

    %Mappings{}
    |> Mappings.parse_seeds(seeds_input)
    |> Mappings.parse_mappings(mappings_input)
  end

  def inverse_traverse_mapping(number, []), do: number

  def inverse_traverse_mapping(number, [%Mapping{} = mapping | tail]) do
    matching_map =
      mapping.maps
      |> Enum.find(fn %{range: range, source: _source, destination: destination} ->
        destination <= number && number <= destination + range - 1
      end)

    case matching_map do
      %{range: _range, source: source, destination: destination} ->
        inverse_traverse_mapping(number - destination + source, tail)

      nil ->
        inverse_traverse_mapping(number, tail)
    end
  end

  def number_exists?(number, mappings, seeds) do
    start_number = inverse_traverse_mapping(number, mappings)
    # IO.puts("#{number} -> #{start_number}")

    seeds
    |> Enum.any?(fn {first, last} -> first <= start_number && start_number <= last end)
  end
end

%{mappings: mappings, seeds: seeds} =
  File.read!("lib/day5/input.txt")
  |> AdventOfCode.Day5.P2.parse()
  |> IO.inspect()

IO.inspect("done")

batch_size = 100_000

0..2_000
|> Task.async_stream(
  fn i ->
    IO.puts("#{i} - Processing:  #{i * batch_size} -> #{(i + 1) * batch_size - 1}")

    number =
      (i * batch_size)..((i + 1) * batch_size - 1)
      |> Enum.find(fn number -> AdventOfCode.Day5.P2.number_exists?(number, mappings, seeds) end)

    IO.puts(
      "#{i} Processed: #{i * batch_size} -> #{(i + 1) * batch_size - 1}, found: #{number || "nothing"}"
    )

    number
  end,
  max_concurrency: 250,
  timeout: :infinity
)
|> Enum.map(fn {:ok, num} -> num end)
|> Enum.filter(& &1)
|> Enum.min()
|> IO.inspect()
