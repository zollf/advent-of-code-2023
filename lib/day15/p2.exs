defmodule AdventOfCode.Day15.P2 do
  def hash(input) do
    input
    |> String.split("", trim: true)
    |> Enum.reduce(0, fn char, acc -> rem((acc + to_ascii(char)) * 17, 256) end)
  end

  def process(operations) do
    operations
    |> Enum.reduce(%{}, fn operation, boxes ->
      if String.contains?(operation, "=") do
        [label, focal] = String.split(operation, "=", trim: true)
        box_number = hash(label)
        box = Map.get(boxes, box_number, [])

        if Enum.any?(box, fn {box_label, _} -> box_label == label end) do
          updated_box =
            box
            |> Enum.map(fn {box_label, _} = b ->
              if box_label == label, do: {box_label, String.to_integer(focal)}, else: b
            end)

          boxes |> Map.put(box_number, updated_box)
        else
          updated_box = box ++ [{label, String.to_integer(focal)}]

          boxes |> Map.put(box_number, updated_box)
        end
      else
        label = String.replace(operation, "-", "")
        box_number = hash(label)

        if Map.has_key?(boxes, box_number) do
          box = Map.get(boxes, box_number)

          updated_box =
            box
            |> Enum.filter(fn {box_label, _} -> box_label != label end)

          if length(updated_box) == 0 do
            boxes |> Map.delete(box_number)
          else
            boxes |> Map.put(box_number, updated_box)
          end
        else
          boxes
        end
      end
    end)
  end

  def calc_total_focal(boxes) do
    boxes
    |> Enum.map(fn {box_number, box} ->
      box
      |> Enum.with_index()
      |> Enum.map(fn {{_, focal}, i} -> (box_number + 1) * (i + 1) * focal end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def parse(input) do
    input
    |> String.split(",", trim: true)
  end

  defp to_ascii(string) when is_binary(string) do
    :binary.first(string)
  end
end

File.read!("lib/day15/input.txt")
|> AdventOfCode.Day15.P2.parse()
|> AdventOfCode.Day15.P2.process()
|> AdventOfCode.Day15.P2.calc_total_focal()
|> IO.inspect()
