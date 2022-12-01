defmodule MySlickTools do
  def get_filename_from_arg() do
    args = System.argv()
    [filename | _] = args
    filename
  end

  def read_list_of_integers(filename) do
    {:ok, contents} = File.read(filename)
    contents
     |> String.split("\n", trim: true)
     |> Enum.map(&(Integer.parse(&1) |> Kernel.elem(0)))
  end
end

defmodule Measurements do
  def count_measurments_larger_than_previous(list) do
    list
    |> Enum.reduce({0, 0}, fn x, acc ->
      {count, prev_measurment} = acc
      if prev_measurment === 0 or prev_measurment >= x do
        {count, x}
      else
        {count + 1, x}
      end
    end)
    |> Kernel.elem(0)
  end

  def three_measurement_sliding_window(list) do
    list
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.reduce([], fn x, acc -> acc ++ [Enum.sum(x)] end)
  end
end

##
# MAIN ENTRY SCRIPT
#

list = MySlickTools.get_filename_from_arg()
 |> MySlickTools.read_list_of_integers()

IO.puts "Part one"

list
 |> Measurements.count_measurments_larger_than_previous()
 |> IO.inspect

IO.puts "Part two"

list
 |> Measurements.three_measurement_sliding_window()
 |> Measurements.count_measurments_larger_than_previous()
 |> IO.inspect
