defmodule MySlickTools do
  def get_filename_from_arg() do
    args = System.argv()
    [filename | _] = args
    filename
  end

  def read_list_of_binary_numbers(filename) do
    {:ok, contents} = File.read(filename)
    contents
     |> String.split("\n", trim: true)
     |> Enum.map(&(String.graphemes(&1)))
  end
end

defmodule SubmarineDiagnostic do
  defp invert_bit(0), do: 1
  defp invert_bit(1), do: 0
  defp bit_by_rate_type(:gamma_rate, value), do: value
  defp bit_by_rate_type(:oxygen_generator_rate, value), do: value
  defp bit_by_rate_type(:epsilon_rate, value), do: invert_bit(value)
  defp bit_by_rate_type(:co2_scrubber_rate, value), do: invert_bit(value)

  def calculate_rate(list, rate_type) do
    list
    |> Enum.zip()
    |> Enum.reduce([], fn x, acc ->
      current_bit = x |> Tuple.to_list()
      zeros = Enum.count(current_bit, fn bit -> bit == "0" end)
      ones = Enum.count(current_bit, fn bit -> bit == "1" end)
      cond do
        zeros > ones -> acc ++ [bit_by_rate_type(rate_type, 0)]
        zeros <= ones -> acc ++ [bit_by_rate_type(rate_type, 1)]
      end
    end)
  end

  def binary_to_decimal(list_binary) do
    list_binary
    |> Enum.reverse()
    |> Enum.reduce({0, 0}, fn x, acc ->
      {index, sum} = acc
      {index + 1, x * :math.pow(2, index) + sum}
    end)
    |> Kernel.elem(1)
    |> Kernel.trunc()
  end

  def search_rate_values(list, rate_type) do
    list
    |> Enum.reduce_while({0,list}, fn _x, acc ->
      {index, remaining_list} = acc
      if Enum.count(remaining_list) == 1 do
        {:halt, acc}
      else
        filtered_list = Enum.filter(remaining_list, fn list_binary ->
          curr_bit = Enum.at(list_binary, index) |> Integer.parse() |> Kernel.elem(0)
          freq_bit = calculate_rate(remaining_list, rate_type) |> Enum.at(index)
          curr_bit == freq_bit
        end)
        {:cont, {index + 1, filtered_list}}
      end
    end)
    |> Kernel.elem(1)
    |> Enum.at(0)
    |> Enum.map(fn x -> if x == "0", do: 0, else: 1 end)
  end
end

##
# MAIN ENTRY SCRIPT
#

list = MySlickTools.get_filename_from_arg()
 |> MySlickTools.read_list_of_binary_numbers()

IO.puts "Part one"

gamma_rate = list
 |> SubmarineDiagnostic.calculate_rate(:gamma_rate)
 |> SubmarineDiagnostic.binary_to_decimal()

epsilon_rate = list
 |> SubmarineDiagnostic.calculate_rate(:epsilon_rate)
 |> SubmarineDiagnostic.binary_to_decimal()

IO.inspect gamma_rate * epsilon_rate

IO.puts "Part two"

oxygen_generator_rate = list
 |> SubmarineDiagnostic.search_rate_values(:oxygen_generator_rate)
 |> SubmarineDiagnostic.binary_to_decimal()

co2_scrubber_rate = list
 |> SubmarineDiagnostic.search_rate_values(:co2_scrubber_rate)
 |> SubmarineDiagnostic.binary_to_decimal()

IO.inspect oxygen_generator_rate * co2_scrubber_rate
