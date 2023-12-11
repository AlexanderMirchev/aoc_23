input_0 = """
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
"""

{_, input} = File.read("day11_input.txt")

defmodule Day11 do
  def solution_a(input) do
    universe = input
    |> String.split("\n")
    |> Enum.filter(fn line -> String.trim(line) != "" end)
    |> Enum.map(&String.graphemes/1)

    galaxies = universe
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} -> 
      row
      |> Enum.with_index()
      |> Enum.filter(fn {x, _} -> x == "#" end)
      |> Enum.map(fn {_, c} -> {r,c} end)
    end)

    has_galaxy_in_row = galaxies
    |> Enum.reduce(%{}, fn {r, _}, acc -> 
      Map.put(acc, r, true)
    end)

    has_galaxy_in_col = galaxies
    |> Enum.reduce(%{}, fn {_, c}, acc -> 
      Map.put(acc, c, true)
    end)
    
    galaxies
    |> Enum.map(&(after_expand(&1, has_galaxy_in_row, has_galaxy_in_col)))
    |> shortest_paths(0)
  end

  def solution_b(input) do
    universe = input
    |> String.split("\n")
    |> Enum.filter(fn line -> String.trim(line) != "" end)
    |> Enum.map(&String.graphemes/1)

    galaxies = universe
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} -> 
      row
      |> Enum.with_index()
      |> Enum.filter(fn {x, _} -> x == "#" end)
      |> Enum.map(fn {_, c} -> {r,c} end)
    end)

    has_galaxy_in_row = galaxies
    |> Enum.reduce(%{}, fn {r, _}, acc -> 
      Map.put(acc, r, true)
    end)

    has_galaxy_in_col = galaxies
    |> Enum.reduce(%{}, fn {_, c}, acc -> 
      Map.put(acc, c, true)
    end)
    
    galaxies
    |> Enum.map(&(after_expand_b(&1, has_galaxy_in_row, has_galaxy_in_col)))
    |> shortest_paths(0)
  end



  def after_expand({r,c}, has_galaxy_in_row, has_galaxy_in_col) do
    row = Enum.to_list(0..r) |> Enum.reduce(0, fn i, row -> 
      case Map.get(has_galaxy_in_row, i, false) do
        false -> row + 2
        _ -> row + 1
      end
    end)

    col = Enum.to_list(0..c) |> Enum.reduce(0, fn i, col -> 
      case Map.get(has_galaxy_in_col, i, false) do
        false -> col + 2
        _ -> col + 1
      end
    end)

    {row, col}
  end

  def after_expand_b({r,c}, has_galaxy_in_row, has_galaxy_in_col) do
    row = Enum.to_list(0..r) |> Enum.reduce(0, fn i, row -> 
      case Map.get(has_galaxy_in_row, i, false) do
        false -> row + 1000000 
        _ -> row + 1
      end
    end)

    col = Enum.to_list(0..c) |> Enum.reduce(0, fn i, col -> 
      case Map.get(has_galaxy_in_col, i, false) do
        false -> col + 1000000
        _ -> col + 1
      end
    end)

    {row, col}
  end

  def shortest_paths([], distance), do: distance
  def shortest_paths([galaxy | rest], distance) do
    shortest_paths(rest, shortest_paths_from(galaxy, rest, distance))
  end

  def shortest_paths_from(_, [], distance), do: distance
  def shortest_paths_from({r1, c1}, [{r2, c2} | rest], distance) do
    shortest_paths_from(
      {r1, c1}, 
      rest,
      distance + abs(r1 - r2) + abs(c1 - c2)
    )
  end

end

{timea, a} = :timer.tc(&Day11.solution_a/1, [input])
{timeb, b} = :timer.tc(&Day11.solution_b/1, [input])

IO.puts("Solution a #{a}, #{timea}μs")
IO.puts("Solution b #{b}, #{timeb}μs")
