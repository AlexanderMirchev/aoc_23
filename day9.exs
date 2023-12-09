input_0 = """
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"""

{_, input} = File.read("day9_input.txt")

defmodule Day9 do
  def solution_a(input) do
    input
    |> String.split("\n")
    |> Enum.filter(fn line -> String.trim(line) != "" end)
    |> Enum.map(&parse/1)
    |> Enum.map(&predict/1)
    |> Enum.sum()
  end

  def solution_b(input) do
    input
    |> String.split("\n")
    |> Enum.filter(fn line -> String.trim(line) != "" end)
    |> Enum.map(&parse/1)
    |> Enum.map(&predict_previous/1)
    |> Enum.sum()
  end
  
  def parse(line) do
    line
    |> String.split(~r/\s+/)
    |> Enum.map(&String.to_integer/1)
  end

  def predict(sequence) do
    case Enum.all?(sequence, fn x -> x == 0 end) do
      true -> 0
      _ -> 
        increment = sequence
        |> seq_differences()
        |> predict()

        List.last(sequence) + increment
    end
  end

  def predict_previous(sequence) do
    case Enum.all?(sequence, fn x -> x == 0 end) do
      true -> 0
      _ -> 
        increment = sequence
        |> seq_differences()
        |> predict_previous()

        hd(sequence) - increment
    end
  end

  def seq_differences([head | tail]) do
    Enum.zip_with(tail, [head | tail], fn x,y -> x - y end)
  end
end

{timea, a} = :timer.tc(&Day9.solution_a/1, [input])
{timeb, b} = :timer.tc(&Day9.solution_b/1, [input])

IO.puts("Solution a #{a}, #{timea}μs")
IO.puts("Solution b #{b}, #{timeb}μs")
