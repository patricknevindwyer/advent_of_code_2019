defmodule Aoc.Day18.Alternate do
  @moduledoc """
  Day 18 solutions
  """

  @doc ~S"""
  Solves the first riddle of day 18.

  ## Examples

      iex> AdventOfCode2019.Day18.part1("#########\n#b.A.@.a#\n#########")
      8
      iex> AdventOfCode2019.Day18.part1("########################\n#f.D.E.e.C.b.A.@.a.B.c.#\n######################.#\n#d.....................#\n########################")
      86
      iex> AdventOfCode2019.Day18.part1("########################\n#...............b.C.D.f#\n#.######################\n#.....@.a.B.c.d.A.e.F.g#\n########################")
      132
      iex> File.read!("inputs/day18.txt") |> AdventOfCode2019.Day18.part1()
      4762

  """
  def part1(input) do
    points =
      for {line, y} <- String.trim(input) |> String.split("\n") |> Enum.with_index(),
          {c, x} <- String.codepoints(line) |> Enum.with_index(),
          do: {{x, y}, c}

    {start, _} = Enum.find(points, fn {_, c} -> c == "@" end)
    keys = Enum.count(points, fn {_, c} -> c =~ ~r([a-z]) end)
    Map.new(points) |> find_path(start, keys)
  end

  @doc ~S"""
  Solves the second riddle of day 18.

  ## Examples

      iex> AdventOfCode2019.Day18.part2("#######\n#a.#Cd#\n##@#@##\n#######\n##@#@##\n#cB#Ab#\n#######")
      8
      iex> AdventOfCode2019.Day18.part2("###############\n#d.ABC.#.....a#\n######@#@######\n###############\n######@#@######\n#b.....#.....c#\n###############")
      24
      iex> AdventOfCode2019.Day18.part2("#############\n#DcBa.#.GhKl#\n#.###@#@#I###\n#e#d#####j#k#\n###C#@#@###J#\n#fEbA.#.FgHi#\n#############")
      32
      iex> File.read!("inputs/day18part2.txt") |> AdventOfCode2019.Day18.part2()
      1876

  """
  def part2(input) do
    points =
      for {line, y} <- String.trim(input) |> String.split("\n") |> Enum.with_index(),
          {c, x} <- String.codepoints(line) |> Enum.with_index(),
          do: {{x, y}, c}

    start_points =
      Enum.filter(points, fn {_, c} -> c == "@" end) |> Enum.map(fn {point, _} -> point end)

    keys = Enum.count(points, fn {_, c} -> c =~ ~r([a-z]) end)
    Map.new(points) |> find_path_part2(start_points, keys)
  end

  defp find_path(map, start, key_count) do
    find_path(
      map,
      key_count,
      MapSet.new([{start, MapSet.new()}]),
      :queue.from_list([{start, MapSet.new(), 0}])
    )
  end

  defp find_path(map, key_count, visited, queue) do
    {{:value, {current_point, keys, depth}}, queue} = :queue.out(queue)

    if MapSet.size(keys) == key_count do
      depth
    else
      {visited, queue} =
        adjacent(current_point)
        |> Enum.reduce({visited, queue}, fn new_point, unmodified = {visited, queue} ->
          modify = &modify(visited, queue, new_point, depth + 1, &1)

          case map[new_point] do
            "#" ->
              unmodified

            "." ->
              modify.(keys)

            "@" ->
              modify.(keys)

            x ->
              cond do
                x =~ ~r([a-z]) ->
                  MapSet.put(keys, String.upcase(x)) |> modify.()

                x =~ ~r([A-Z]) ->
                  if MapSet.member?(keys, x), do: modify.(keys), else: unmodified
              end
          end
        end)

      find_path(map, key_count, visited, queue)
    end
  end

  defp modify(visited, queue, new_point, new_depth, keys) do
    if MapSet.member?(visited, {new_point, keys}) do
      {visited, queue}
    else
      visited = MapSet.put(visited, {new_point, keys})
      queue = :queue.in({new_point, keys, new_depth}, queue)
      {visited, queue}
    end
  end

  defp find_path_part2(map, start_points, key_count) do
    start_points = Enum.map(start_points, &{&1, Enum.sort(start_points -- [&1])})

    queue =
      Enum.map(start_points, fn {pos, other_robots} -> {pos, MapSet.new(), other_robots, 0} end)
      |> :queue.from_list()

    find_path_part2(map, key_count, MapSet.new(start_points), queue)
  end

  defp find_path_part2(map, key_count, visited, queue) do
    {{:value, {current_point, keys, other_robots, depth}}, queue} = :queue.out(queue)

    if MapSet.size(keys) == key_count do
      depth
    else
      {visited, queue} =
        adjacent(current_point)
        |> Enum.reduce({visited, queue}, fn new_point, unmodified = {visited, queue} ->
          modify = &modify(visited, queue, new_point, depth + 1, &1, other_robots)

          case map[new_point] do
            "#" ->
              unmodified

            "." ->
              modify.(keys)

            "@" ->
              modify.(keys)

            x ->
              cond do
                x =~ ~r([a-z]) ->
                  inserted_key = MapSet.put(keys, String.upcase(x))
                  all_robots = [new_point | other_robots]

                  Enum.reduce(all_robots, {visited, queue}, fn robot_pos, {visited, queue} ->
                    modify(
                      visited,
                      queue,
                      robot_pos,
                      depth + 1,
                      inserted_key,
                      Enum.sort(all_robots -- [robot_pos])
                    )
                  end)

                x =~ ~r([A-Z]) ->
                  if MapSet.member?(keys, x), do: modify.(keys), else: unmodified
              end
          end
        end)

      find_path_part2(map, key_count, visited, queue)
    end
  end

  defp modify(visited, queue, new_point, new_depth, keys, other_robots) do
    if MapSet.member?(visited, {new_point, keys, other_robots}) do
      {visited, queue}
    else
      visited = MapSet.put(visited, {new_point, keys, other_robots})
      queue = :queue.in({new_point, keys, other_robots, new_depth}, queue)
      {visited, queue}
    end
  end

  defp adjacent({x, y}), do: [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
end