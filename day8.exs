input_0 = """
RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)
"""

input_1 = """
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
"""

input_2 = """
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
"""

{_, input} = File.read("day8_input.txt")

defmodule Day8 do
  def solution_a(input) do
    [directions | instructions] = input
    |> String.split("\n")
    |> Enum.filter(fn line -> String.trim(line) != "" end)

    directions = directions
    |> String.graphemes()

    instruction_map = instructions
    |> Enum.map(&parse_instruction/1)
    |> Enum.reduce(%{}, fn {s, l, r}, acc -> 
      Map.put(acc, s, {l, r})
    end)

    find_ZZZ("AAA", directions, instruction_map, 0, directions)
  end

  def solution_b(input) do
    [directions | instructions] = input
    |> String.split("\n")
    |> Enum.filter(fn line -> String.trim(line) != "" end)

    directions = directions
    |> String.graphemes()

    instructions = instructions
    |> Enum.map(&parse_instruction/1)

    instruction_map = instructions
    |> Enum.reduce(%{}, fn {s, l, r}, acc -> 
      Map.put(acc, s, {l, r})
    end)

    instructions
    |> Enum.map(fn {i, _, _} -> i end)
    |> Enum.filter(fn s -> 
      case s do
        <<_, _, "A">> -> true
        _ -> false
      end
    end)
    |> Enum.map(&(find_count_till_Z(&1, directions, instruction_map, 0, directions)))
    |> Enum.reduce(fn x,y -> div(x * y, Integer.gcd(x,y)) end)
  end

  def parse_instruction(instruction) do
    regex_pattern = ~r/^(\w{3})\s*=\s*\(\s*(\w{3})\s*,\s*(\w{3})\s*\)$/

    case Regex.run(regex_pattern, instruction) do
      [_, source, left, right] -> {source, left, right}
    end
  end

  def find_ZZZ("ZZZ", _, _, count, _), do: count
  def find_ZZZ(current, [], map, count, baseDirections), do: find_ZZZ(current, baseDirections, map, count, baseDirections)
  def find_ZZZ(current, ["L" | directions], map, count, baseDirections) do
    {left, _} = Map.get(map, current)
    find_ZZZ(left, directions, map, count + 1, baseDirections)
  end
  def find_ZZZ(current, ["R" | directions], map, count, baseDirections) do
    {_, right} = Map.get(map, current)
    find_ZZZ(right, directions, map, count + 1, baseDirections)
  end


  def find_count_till_Z(current, [], map, count, baseDirections), do: find_count_till_Z(current, baseDirections, map, count, baseDirections)
  def find_count_till_Z(current, [d | directions], map, count, baseDirections) do
    current_after_step = take_step(current, d, map)
    
    case current_after_step |> current_ends_in_Z() do
      true -> count + 1
      false -> find_count_till_Z(current_after_step, directions, map, count + 1, baseDirections)
    end
  end

  def take_step(current, "L", map) do
    {left, _} = Map.get(map, current)
    left
  end
  def take_step(current, "R", map) do
    {_, right} = Map.get(map, current)
    right
  end

  def current_ends_in_Z(current) do
    case current do
      <<_, _, "Z">> -> true
      _ -> false
    end
  end
end

# {timea, a} = :timer.tc(&Day8.solution_a/1, [input])
{timeb, b} = :timer.tc(&Day8.solution_b/1, [input])

# IO.puts("Solution a #{a}, #{timea}μs")
IO.puts("Solution b #{b}, #{timeb}μs")
