# Credit: https://github.com/MarkSinke/aoc2023/blob/main/day24_test.go
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

defmodule AdventOfCode.Day24.P2 do
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

  def calculate_rock_position(hailstones) do
    h0 = hd(hailstones)

    [h1, h2, h3 | _] =
      hailstones
      |> Enum.slice(1, 3)
      |> Enum.map(fn %Hailstone{} = hailstone ->
        hailstone
        |> Map.merge(%{
          px: hailstone.px - h0.px,
          py: hailstone.py - h0.py,
          pz: hailstone.pz - h0.pz,
          vx: hailstone.vx - h0.vx,
          vy: hailstone.vy - h0.vy,
          vz: hailstone.vz - h0.vz
        })
      end)

    n =
      cross_product(
        {h1.px, h1.py, h1.pz},
        {h1.px + h1.vx, h1.py + h1.vy, h1.pz + h1.vz}
      )

    {{p2x, p2y, p2z}, t2} = intersect_plane_and_line(h2, n)
    {{p3x, p3y, p3z}, t3} = intersect_plane_and_line(h3, n)

    t_diff = t2 - t3

    {vx, vy, vz} = {(p2x - p3x) / t_diff, (p2y - p3y) / t_diff, (p2z - p3z) / t_diff}
    {px, py, pz} = {p2x - vx * t2 + h0.px, p2y - vy * t2 + h0.py, p2z - vz * t2 + h0.pz}

    # IO.inspect({px, py, pz})

    px + py + pz
  end

  defp cross_product({x1, y1, z1}, {x2, y2, z2}) do
    {y1 * z2 - z1 * y2, z1 * x2 - x1 * z2, x1 * y2 - y1 * x2}
  end

  defp dot_product({x1, y1, z1}, {x2, y2, z2}) do
    x1 * x2 + y1 * y2 + z1 * z2
  end

  defp intersect_plane_and_line(%Hailstone{} = hailstone, n) do
    a = dot_product({-hailstone.px, -hailstone.py, -hailstone.pz}, n)
    b = dot_product({hailstone.vx, hailstone.vy, hailstone.vz}, n)
    t = a / b

    p =
      {
        hailstone.px + hailstone.vx * t,
        hailstone.py + hailstone.vy * t,
        hailstone.pz + hailstone.vz * t
      }

    {p, t}
  end
end

File.read!("lib/day24/input.txt")
|> AdventOfCode.Day24.P2.parse()
|> AdventOfCode.Day24.P2.calculate_rock_position()
|> round()
|> IO.inspect()
