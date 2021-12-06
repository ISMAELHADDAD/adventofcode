defmodule MySlickTools do
  def get_filename_from_arg() do
    args = System.argv()
    [filename | _] = args
    filename
  end

  def read_list_of_integers(filename) do
    {:ok, contents} = File.read(filename)
    contents
     |> String.split(",", trim: true)
     |> Enum.map(&(Integer.parse(&1) |> Kernel.elem(0)))
  end
end

defmodule LanternfishSimulator do
  def total_lanternfish_in_n_days(list, days) do
    Enum.reduce(list, 0, fn lanternfish, sum -> sum + recursive_count(lanternfish, days) end)
  end

  defp recursive_count(days_cycle, days) do
    cond do
      days_cycle < days ->
        num_of_lanternfishes_to_have = Kernel.ceil((days - days_cycle) / 7)
        Enum.reduce(0..num_of_lanternfishes_to_have, 0, fn index, sum ->
          sum + recursive_count(9, (days - days_cycle) - index * 7)
        end)
      true -> 1
    end
  end
end


##
# MAIN ENTRY SCRIPT
#

list = MySlickTools.get_filename_from_arg()
 |> MySlickTools.read_list_of_integers()

IO.puts "Part one"

LanternfishSimulator.total_lanternfish_in_n_days(list, 80)
|> IO.inspect

# IO.puts "Part two"

# LanternfishSimulator.total_lanternfish_in_n_days(list, 256)
# |> IO.inspect
