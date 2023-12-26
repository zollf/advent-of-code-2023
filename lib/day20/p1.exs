defmodule PulseModule do
  defstruct [:name, :type, :destinations, :state]
end

defmodule AdventOfCode.Day20.P1 do
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

  def send_pulse(modules, [], total_low, total_high), do: {modules, total_low, total_high}

  def send_pulse(modules, [{type, name, prev_module} | rest], total_low, total_high) do
    state = if type, do: "high", else: "low"
    total_low = if(!type, do: total_low + 1, else: total_low)
    total_high = if(type, do: total_high + 1, else: total_high)

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

    if Map.has_key?(modules, name) do
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

      send_pulse(
        Map.put(modules, module.name, updated_module),
        rest ++ destinations,
        total_low,
        total_high
      )
    else
      send_pulse(
        modules,
        rest,
        total_low,
        total_high
      )
    end
  end

  def smash_button(state, 0), do: state

  def smash_button({modules, total_low, total_high}, count) do
    results = send_pulse(modules, [{false, "broadcast", nil}], total_low, total_high)
    smash_button(results, count - 1)
  end
end

modules =
  File.read!("lib/day20/input.txt")
  |> AdventOfCode.Day20.P1.parse()

{_, total_low, total_high} = AdventOfCode.Day20.P1.smash_button({modules, 0, 0}, 1000)

IO.inspect({total_low, total_high})
IO.inspect(total_low * total_high)
