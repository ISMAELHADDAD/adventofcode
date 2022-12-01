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
    |> Enum.map(&String.to_integer(&1))
  end
end

defmodule CrabShipSimulator do
  def find_least_fuel_consumtion_cost(type, list) do
    Enum.reduce(list, {0, 0}, fn _item, {min, pos} ->
      case min do
        0 -> {calculate_total_fuel_cost(type, list, pos), pos + 1}
        v -> {Kernel.min(v, calculate_total_fuel_cost(type, list, pos)), pos + 1}
      end
    end)
    |> Kernel.elem(0)
  end

  defp calculate_total_fuel_cost(type, list, pos) do
    Enum.reduce(list, 0, fn crab_pos, sum ->
      case type do
        :constant_rate ->
          sum + Kernel.abs(crab_pos - pos)

        :gauss_rate ->
          n = Kernel.abs(crab_pos - pos) + 1
          gauss_sum = Kernel.trunc(n * (n - 1) / 2)
          sum + gauss_sum
      end
    end)
  end
end

##
# MAIN ENTRY SCRIPT
#

list =
  MySlickTools.get_filename_from_arg()
  |> MySlickTools.read_list_of_integers()

IO.puts("Part one")

CrabShipSimulator.find_least_fuel_consumtion_cost(:constant_rate, list)
|> IO.inspect()

IO.puts("Part two")

CrabShipSimulator.find_least_fuel_consumtion_cost(:gauss_rate, list)
|> IO.inspect()
