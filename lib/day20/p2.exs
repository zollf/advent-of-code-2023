defmodule PulseModule do
  defstruct [:name, :type, :destinations, :state]
end

defmodule AdventOfCode.Day20.P2 do
  def parse(input) do
    modules =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn row ->
        [module, destinations] = String.split(row, " -> ", trim: true)
        {module_type, module_name, initial_state} = parse_module(module)

        %PulseModule{
          name: module_name,
          type: module_type,
          destinations: String.split(destinations, ", ", trim: true),
          state: initial_state
        }
      end)

    modules
    |> Enum.map(fn %PulseModule{} = module ->
      if module.type == :conjunction do
        all_modules_linking =
          modules
          |> Enum.filter(fn m -> Enum.member?(m.destinations, module.name) end)
          |> Enum.map(fn m -> m.name end)
          |> Enum.reduce(%{}, fn m, initial_state -> Map.put(initial_state, m, false) end)

        module
        |> Map.put(:state, all_modules_linking)
      else
        module
      end
    end)
    |> Enum.reduce(%{}, fn module, acc -> Map.put(acc, module.name, module) end)
  end

  defp parse_module(module) do
    case String.first(module) do
      "%" -> {:flip_flop, String.replace(module, "%", ""), false}
      "&" -> {:conjunction, String.replace(module, "&", ""), %{}}
      "b" -> {:broadcast, "broadcast", nil}
    end
  end

  def send_pulse(modules, [], target), do: modules

  def send_pulse(modules, [{type, name, prev_module} | rest], target) do
    state = if type, do: "high", else: "low"

    # cond do
    #   prev_module == nil ->
    #     IO.inspect("button -#{state}-> #{name}")

    #   prev_module.type == :flip_flop ->
    #     IO.inspect("%#{prev_module.name} -#{state}-> #{name}")

    #   prev_module.type == :conjunction ->
    #     IO.inspect("&#{prev_module.name} -#{state}-> #{name}")

    #   prev_module.type == :broadcast ->
    #     IO.inspect("#{prev_module.name} -#{state}-> #{name}")
    # end

    # IO.inspect([name] ++ Enum.map(rest, fn {_, name, _} -> name end))
    cond do
      name == target && !type ->
        nil

      Map.has_key?(modules, name) ->
        module = Map.get(modules, name)

        {destinations, updated_module} =
          case module.type do
            :flip_flop when type == false ->
              module = Map.put(module, :state, !module.state)

              {
                Enum.map(module.destinations, &{module.state, &1, module}),
                module
              }

            :conjunction ->
              module = Map.put(module, :state, Map.put(module.state, prev_module.name, type))
              all_on = Map.values(module.state) |> Enum.all?(& &1)

              {
                Enum.map(module.destinations, &{!all_on, &1, module}),
                module
              }

            :broadcast ->
              {
                Enum.map(module.destinations, &{type, &1, module}),
                module
              }

            _ ->
              {[], module}
          end

        send_pulse(Map.put(modules, module.name, updated_module), rest ++ destinations, target)

      true ->
        send_pulse(modules, rest, target)
    end
  end

  # def smash_button(_, count \\ 160_994_286)

  def smash_button(modules, count, target) do
    results = send_pulse(modules, [{false, "broadcast", nil}], target)

    if results == nil do
      count
    else
      smash_button(results, count + 1, target)
    end
  end

  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b), do: a * b / gcd(a, b)
end

modules =
  File.read!("lib/day20/input.txt")
  |> AdventOfCode.Day20.P2.parse()

moduleWithRxDest =
  Map.values(modules) |> Enum.find(fn module -> Enum.member?(module.destinations, "rx") end)

moduleWithRxDest.state
|> Map.keys()
|> Enum.map(fn key -> AdventOfCode.Day20.P2.smash_button(modules, 1, key) end)
|> Enum.reduce(&AdventOfCode.Day20.P2.lcm(&1, round(&2)))
|> round
|> IO.inspect()
