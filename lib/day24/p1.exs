defmodule Hailstone do
  defstruct [:id, :px, :py, :pz, :vx, :vy, :vz]

  def new(id, [[px, py, pz], [vx, vy, vz]]) do
    %Hailstone{
      id: id,
      px: px,
      py: py,
      pz: pz,
      vx: vx,
      vy: vy,
      vz: vz
    }
  end

  def collide?(%Hailstone{} = h1, %Hailstone{} = h2) do
    # (h1.vx, h1.vy, h1.vz)t1 + (h1.px, h1.py, h1.pz) = (h2.vx, h2.vy, h2.vz)t2 + (h2.px, h2.py, h2.pz)

    #
    #      h2.vx * (h1.py - h2.py) - h2.vy * (h1.px - h2.px)
    # t1 = -------------------------------------------------
    #                h1.vx * h2.vy - h1.vy * h2.vx
    #
    #      h1.vx * (h1.py - h2.py) - h1.vy * (h1.px - h2.px)
    # t2 = -------------------------------------------------
    #                h1.vx * h2.vy - h1.vy * h2.vx
    #

    t1_top = h2.vx * (h1.py - h2.py) - h2.vy * (h1.px - h2.px)
    t2_top = h1.vx * (h1.py - h2.py) - h1.vy * (h1.px - h2.px)
    bottom = h1.vx * h2.vy - h1.vy * h2.vx

    if bottom > 0 do
      t1 = t1_top / bottom
      t2 = t2_top / bottom

      if t1 > 0 && t2 > 0 do
        x = h1.vx * t1 + h1.px
        y = h1.vy * t1 + h1.py
        {true, {x, y}}
      else
        {false, {nil, nil}}
      end
    else
      {false, {nil, nil}}
    end
  end
end

defmodule AdventOfCode.Day24.P1 do
  @min 200_000_000_000_000
  @max 400_000_000_000_000
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.split(" @ ", trim: true)
      |> Enum.map(fn coords ->
        coords
        |> String.split(", ")
        |> Enum.map(&String.trim/1)
        |> Enum.map(&String.to_integer/1)
      end)
    end)
    |> Enum.with_index()
    |> Enum.map(fn {v, i} -> Hailstone.new(i, v) end)
  end

  def get_collisions(_, [], collisions), do: collisions

  def get_collisions(hailstones) do
    get_collisions(hailstones, hailstones, %{})
  end

  def get_collisions(hailstones, [h1 | rest], collisions) do
    collides =
      hailstones
      |> Enum.filter(fn h2 ->
        {collides, {x, y}} = Hailstone.collide?(h1, h2)

        if collides do
          x >= @min && x <= @max && y >= @min && y <= @max
        else
          false
        end
      end)
      |> Enum.map(fn h2 ->
        {"#{min(h1.id, h2.id)}-#{max(h1.id, h2.id)}", Hailstone.collide?(h1, h2)}
      end)

    if length(collides) > 0 do
      collisions =
        collides
        |> Enum.reduce(collisions, fn {key, c}, collisions ->
          Map.put(collisions, key, c)
        end)

      get_collisions(hailstones, rest, collisions)
    else
      get_collisions(hailstones, rest, collisions)
    end
  end
end

File.read!("lib/day24/input.txt")
|> AdventOfCode.Day24.P1.parse()
|> AdventOfCode.Day24.P1.get_collisions()
|> Kernel.map_size()
|> IO.inspect()
