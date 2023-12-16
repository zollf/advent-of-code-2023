defmodule AdventOfCode.Day12.P2 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [condition_input, arrangement_input] = String.split(row, " ", trim: true)

      conditions =
        condition_input
        |> String.split("", trim: true)
        |> replicate()
        |> Enum.with_index()
        |> Enum.map(fn {chunk, i} -> if i < 4, do: chunk ++ ["?"], else: chunk end)
        |> List.flatten()

      arrangements =
        arrangement_input
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> replicate()
        |> List.flatten()

      {conditions, arrangements}
    end)
  end

  def cache_key(conditions, arrangements),
    do: "#{Enum.join(conditions, ",")}--#{Enum.join(arrangements, ",")}"

  def get_spring_arrangements(_, mem \\ %{})

  def get_spring_arrangements({conditions, []}, mem) do
    if Enum.any?(conditions, &(&1 == "#")),
      do: Map.put(mem, cache_key(conditions, []), 0),
      else: Map.put(mem, cache_key(conditions, []), 1)
  end

  def get_spring_arrangements({conditions, [arr | arr_tail] = arrangements}, mem) do
    # Is current arrangement + conditions in memory
    cacheKey = "#{Enum.join(conditions, ",")}--#{Enum.join(arrangements, ",")}"

    cond do
      Enum.sum(arrangements) > length(conditions) ->
        mem

      Map.has_key?(mem, cacheKey) ->
        mem

      true ->
        mem2 =
          if hd(conditions) == "#",
            do: mem,
            else: get_spring_arrangements({tl(conditions), arrangements}, mem)

        updated_mem2 =
          mem2
          |> Map.put(cacheKey, Map.get(mem2, cache_key(tl(conditions), arrangements), 0))

        # Does arrangement fit in current conditions
        can_arr_fit =
          conditions
          |> Enum.slice(0, arr)
          |> Enum.all?(&(&1 == "?" || &1 == "#"))

        # Need to make sure the one we are skipping over isnt hashtag
        if can_arr_fit && Enum.at(conditions, arr) != "#" do
          slice_conditions = Enum.slice(conditions, arr + 1, length(conditions) - arr)

          mem3 = get_spring_arrangements({slice_conditions, arr_tail}, mem2)

          mem3
          |> Map.put(
            cacheKey,
            Map.get(mem3, cache_key(slice_conditions, arr_tail), 0) +
              Map.get(mem2, cache_key(tl(conditions), arrangements), 0)
          )
        else
          updated_mem2
        end
    end
  end

  defp replicate(x), do: for(_ <- 1..5, do: x)
end

File.read!("lib/day12/input.txt")
|> AdventOfCode.Day12.P2.parse()
|> Enum.map(fn {conditions, arrangements} = params ->
  {AdventOfCode.Day12.P2.cache_key(conditions, arrangements),
   AdventOfCode.Day12.P2.get_spring_arrangements(params)}
end)
|> Enum.map(fn {cache_key, mem} -> Map.get(mem, cache_key) end)
|> Enum.sum()
|> IO.inspect()
