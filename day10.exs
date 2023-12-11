input_0 = """
.....
.S-7.
.|.|.
.L-J.
.....
"""
input_1 = """
..F7.
.FJ|.
SJ.L7
|F--J
LJ...
"""

input_2 = """
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
"""

# .qqqqqqqqqqqqqqq....
# .qqqqqqqqqqqqqqq....
# .qq.qqqqqqqqqqqq....
# qqqqqqqqqqqqqq.qqq..
# qqqq-qq...qqQqqqqqq.
# ....qqq..qqqqqqqqqqq
# ....qq.F7qqqqq.qqqqq
# .....qqqqqqqqqqqq.qq
# ....qqqqq.qq.qqqq...
# ....qqqqq.qq.qqqq...


{_, input} = File.read("day10_input.txt")

defmodule Day10 do
  require Logger
  def solution_a(input) do
    matrix = input
    |> String.split("\n")
    |> Enum.filter(fn line -> String.trim(line) != "" end)
    |> Enum.map(&String.graphemes/1)

    {s_x, s_y} = find_s(matrix)
    [pipe1, pipe2 | []] = starting_pipes(s_x, s_y, matrix)
    solve({pipe1, {s_x, s_y}}, {pipe2, {s_x, s_y}}, matrix, 1)
  end

  def solution_b(input) do
    matrix = input
    |> String.split("\n")
    |> Enum.filter(fn line -> String.trim(line) != "" end)
    |> Enum.map(&String.graphemes/1)

    {s_x, s_y} = find_s(matrix)
    paips = starting_pipes(s_x, s_y, matrix)
    [pipe1, pipe2 | _] = paips

    {p_r1, p_c1} = pipe1
    {p_r2, p_c2} = pipe2

    map = %{}
    |> update_map(s_x, s_y)
    |> update_map(p_r1, p_c1)
    |> update_map(p_r2, p_c2)

    loop_map = populate_loop_map(
      {pipe1, {s_x, s_y}}, 
      {pipe2, {s_x, s_y}}, 
      matrix, 
      map
    )

    matrix
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} -> 
      row
      |> Enum.with_index()
      |> Enum.filter(fn {char, _} -> 
          char == "." 
        end)
      |> Enum.map(fn {_, c} -> {r, c} end)
    end)
    |> Enum.filter(fn {r,c} -> 
      row = matrix
      |> Enum.at(r)
      |> Enum.with_index(fn x, col -> 
          case x do
            "." -> "."
            x -> 
              case Map.get(Map.get(loop_map, r), col, false) do
                true -> x
                _ -> "."
              end
          end
        end)

      result = is_inside(row, ".", false, 0, c)
      IO.puts("#{r} #{c} #{result}")
      result
    end)
   |> length()
  end

  def find_s(matrix), do: find_s(0, 0, matrix)
  def find_s(row, col, matrix) do
    symbol = matrix 
    |> Enum.at(row) 
    |> Enum.at(col)

    case symbol do
      "S" -> {row, col}
      _ -> 
        row_length = length(matrix |> Enum.at(row))

        case col do
          col when col >= row_length - 1 -> find_s(row + 1, 0, matrix)
          col -> find_s(row, col + 1, matrix)
        end
    end
  end

  def starting_pipes(s_r, s_c, matrix) do
    n_r = Enum.to_list(s_r-1..s_r+1)
    n_c = Enum.to_list(s_c-1..s_c+1)
    
    n_r
    |> Enum.flat_map(fn r -> 
      n_c
      |> Enum.map(fn c -> 
        symbol = matrix |> Enum.at(r) |> Enum.at(c) 
        {r, c, symbol}
      end)
    end)
    |> Enum.map(fn {r, c, s} -> {r, c, pipe(r, c, s)} end)
    |> Enum.filter(fn {_, _, arr} -> 
      Enum.any?(arr, fn {r1, c1} -> r1 == s_r && c1 == s_c end) 
    end)
    |> Enum.map(fn {r,c, _} -> {r,c} end)
  end

  def solve({{r1,c1}, _}, {{r1,c1}, _}, _, count), do: count
  def solve(pair1, pair2, matrix, count) do
    solve(
      move(pair1, matrix),
      move(pair2, matrix),
      matrix,
      count + 1
    )
  end

  def populate_loop_map({{r1,c1}, _}, {{r1,c1}, _}, _, map), do: map
  def populate_loop_map(pair1, pair2, matrix, map) do
    new1 = move(pair1, matrix)
    new2 = move(pair2, matrix)
    
    {{n_r1, n_c1}, _} = new1
    {{n_r2, n_c2}, _} = new2
  
    new_map = map 
      |> update_map(n_r1, n_c1)
      |> update_map(n_r2, n_c2)
    
    populate_loop_map(
      new1,
      new2,
      matrix,
      new_map
    )
  end

  def update_map(map, r, c) do
    Map.put(map, r, Map.put(Map.get(map, r, %{}), c, true))
  end

  def move({{r, c}, {prev_r, prev_c}}, matrix) do
    pipe_symbol = matrix 
    |> Enum.at(r) 
    |> Enum.at(c)

    [new_pos | _] = pipe(r, c, pipe_symbol)
    |> Enum.filter(fn {row, col} -> prev_r != row || prev_c != col end)

    {new_pos, {r, c}}
  end

  # | is a vertical pipe connecting north and south.
  # - is a horizontal pipe connecting east and west.
  # L is a 90-degree bend connecting north and east.
  # J is a 90-degree bend connecting north and west.
  # 7 is a 90-degree bend connecting south and west.
  # F is a 90-degree bend connecting south and east.
  # . is ground; there is no pipe in this tile.
  def pipe(r, c, "|"), do: [{r - 1, c}, {r + 1, c}]
  def pipe(r, c, "-"), do: [{r, c - 1}, {r, c + 1}]
  def pipe(r, c, "L"), do: [{r - 1, c}, {r, c + 1}]
  def pipe(r, c, "J"), do: [{r - 1, c}, {r, c - 1}]
  def pipe(r, c, "7"), do: [{r, c - 1}, {r + 1, c}]
  def pipe(r, c, "F"), do: [{r, c + 1}, {r + 1, c}]
  def pipe(_, _, _), do: []

  def is_inside(_, _, inside, index, target_index) when index == target_index, do: inside
  def is_inside([char | rest], last_char, inside, index, target_index) do
    case last_char do
      "|" -> case char do
        # edge cases for passing through vertical pipes
        "|" -> is_inside(rest, char, not(inside), index + 1, target_index)
        _ -> is_inside(rest, char, true, index + 1, target_index)
        end
      _ -> case char do
        "." -> is_inside(rest, char, inside, index + 1, target_index)
        "-" -> is_inside(rest, char, inside, index + 1, target_index)
        _ -> is_inside(rest, char, not(inside), index + 1, target_index)
      end
    end
  end
end

{timea, a} = :timer.tc(&Day10.solution_a/1, [input])
{timeb, b} = :timer.tc(&Day10.solution_b/1, [input_2])

IO.puts("Solution a #{a}, #{timea}μs")
IO.puts("Solution b #{b}, #{timeb}μs")
