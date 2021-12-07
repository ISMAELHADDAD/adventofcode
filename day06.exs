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

defmodule Lanternfish do
  use Agent

  def start do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def how_many_fishes_in_n_days(9, days) do
    cached_value = Agent.get(__MODULE__, &Map.get(&1, days))

    if cached_value do
      cached_value
    else
      cond do
        9 < days ->
          num_of_lanternfishes_to_have = Kernel.ceil((days - 9) / 7)

          v =
            Enum.reduce(0..num_of_lanternfishes_to_have, 0, fn index, sum ->
              sum + how_many_fishes_in_n_days(9, days - 9 - index * 7)
            end)

          Agent.update(__MODULE__, &Map.put(&1, days, v))
          v

        true ->
          Agent.update(__MODULE__, &Map.put(&1, days, 1))
          1
      end
    end
  end

  def how_many_fishes_in_n_days(days_cycle, days) do
    cond do
      days_cycle < days ->
        num_of_lanternfishes_to_have = Kernel.ceil((days - days_cycle) / 7)

        Enum.reduce(0..num_of_lanternfishes_to_have, 0, fn index, sum ->
          sum + how_many_fishes_in_n_days(9, days - days_cycle - index * 7)
        end)

      true ->
        1
    end
  end
end

defmodule LanternfishSimulator do
  def start do
    {:ok, _} = Lanternfish.start()
  end

  def total_lanternfish_in_n_days(list, days) do
    Enum.reduce(list, 0, fn lanternfish, sum ->
      sum + Lanternfish.how_many_fishes_in_n_days(lanternfish, days)
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

LanternfishSimulator.start()

LanternfishSimulator.total_lanternfish_in_n_days(list, 80)
|> IO.inspect()

IO.puts("Part two")

LanternfishSimulator.total_lanternfish_in_n_days(list, 256)
|> IO.inspect()
