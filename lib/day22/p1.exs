defmodule Brick do
  defstruct [:id, :start, :end]

  def is_touching?(%Brick{} = b1, %Brick{} = b2) do
    is_touching?(b1, b2, :x) && is_touching?(b1, b2, :y)
  end

  # b1 is top brick
  # b2 is bottom brick
  def is_touching?(%Brick{} = b1, %Brick{} = b2, axis) do
    b1_min_z = min(b1.start.z, b1.end.z)
    b2_max_z = max(b2.start.z, b2.end.z)

    b1_start = Map.get(b1.start, axis)
    b1_end = Map.get(b1.end, axis)
    b2_start = Map.get(b2.start, axis)
    b2_end = Map.get(b2.end, axis)

    b2_max_z + 1 == b1_min_z &&
      ((b2_start <= b1_start && b1_start <= b2_end) ||
         (b1_start <= b2_start && b2_start <= b1_end))
  end

  def lower(%Brick{} = brick) do
    lowered_start = Map.put(brick.start, :z, brick.start.z - 1)
    lowered_end = Map.put(brick.end, :z, brick.end.z - 1)

    brick
    |> Map.put(:start, lowered_start)
    |> Map.put(:end, lowered_end)
  end
end

defmodule AdventOfCode.Day22.P1 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {row, i} ->
      row
      |> String.split("~", trim: true)
      |> Enum.map(fn brick ->
        brick
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)
      |> then(fn [[sx, sy, sz], [ex, ey, ez]] ->
        %Brick{
          id: i,
          start: %{:x => sx, :y => sy, :z => sz},
          end: %{:x => ex, :y => ey, :z => ez}
        }
      end)
    end)
  end

  def drop_brick_until_touching(%Brick{} = brick, bricks) do
    cond do
      brick.start.z <= 1 ->
        brick

      Enum.any?(bricks, &Brick.is_touching?(brick, &1)) ->
        brick

      true ->
        drop_brick_until_touching(Brick.lower(brick), bricks)
    end
  end

  def drop_bricks(bricks) do
    bricks
    |> Enum.sort_by(fn %Brick{} = brick -> brick.start.z end)
    |> IO.inspect()
    |> Enum.reduce([], fn %Brick{} = brick, updated_bricks ->
      brick = drop_brick_until_touching(brick, updated_bricks)
      [brick] ++ updated_bricks
    end)
  end

  def get_touching_bricks(%Brick{} = brick, bricks) do
    bricks
    |> Enum.filter(fn %Brick{} = maybe_touching_brick ->
      Brick.is_touching?(brick, maybe_touching_brick)
    end)
    |> Enum.map(fn brick -> brick.id end)
  end

  def get_touching_bricks(bricks) do
    bricks
    |> Enum.reduce(%{}, fn %Brick{} = brick, touching_map ->
      touching_bricks = get_touching_bricks(brick, bricks)

      touching_map
      |> Map.put(brick.id, touching_bricks)
    end)
  end

  def can_disintegrate_brick?(brick, touching_bricks_map) do
    not (touching_bricks_map
         |> Map.values()
         |> Enum.any?(fn touching_bricks ->
           length(touching_bricks) == 1 && hd(touching_bricks) == brick.id
         end))
  end
end

bricks =
  File.read!("lib/day22/input.txt")
  |> AdventOfCode.Day22.P1.parse()
  |> AdventOfCode.Day22.P1.drop_bricks()

touching_bricks_map =
  AdventOfCode.Day22.P1.get_touching_bricks(bricks) |> IO.inspect(limit: :infinity)

bricks
|> Enum.filter(&AdventOfCode.Day22.P1.can_disintegrate_brick?(&1, touching_bricks_map))
|> length()
|> IO.inspect()
