defmodule MySlickTools do
  def get_filename_from_arg() do
    args = System.argv()
    [filename | _] = args
    filename
  end

  def read_list_of_command_integer_pairs(filename) do
    {:ok, contents} = File.read(filename)
    contents
     |> String.split("\n", trim: true)
     |> Enum.map(fn x ->
      [command | [integer | _]] = String.split(x, " ", trim: true)
      {String.to_atom(command), Integer.parse(integer) |> Kernel.elem(0)}
    end)
  end
end

defmodule Measurements do
  def measure_planned_distance(list) do
    list
    |> Enum.reduce({0, 0}, fn cmd, acc ->
      {x, y} = acc
      case cmd do
        {:forward, value} -> {x + value, y}
        {:down, value} -> {x, y + value}
        {:up, value} -> {x, y - value}
      end
    end)
  end

  def measure_planned_distance_with_aim(list) do
    list
    |> Enum.reduce({0, 0, 0}, fn cmd, acc ->
      {x, y, aim} = acc
      case cmd do
        {:forward, value} -> {x + value, y + aim*value, aim}
        {:down, value} -> {x, y, aim + value}
        {:up, value} -> {x, y, aim - value}
      end
    end)
  end
end

##
# MAIN ENTRY SCRIPT
#

list = MySlickTools.get_filename_from_arg()
 |> MySlickTools.read_list_of_command_integer_pairs()

IO.puts "Part one"

{x, y} = list
 |> Measurements.measure_planned_distance()

IO.puts x * y

IO.puts "Part two"

{x2, y2, _aim} = list
 |> Measurements.measure_planned_distance_with_aim()

IO.puts x2 * y2
