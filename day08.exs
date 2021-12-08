defmodule MySlickTools do
  def get_filename_from_arg() do
    args = System.argv()
    [filename | _] = args
    filename
  end

  def read_list_of_digits_output_value_pairs(filename) do
    {:ok, contents} = File.read(filename)

    contents
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      digits = String.split(line, " | ") |> Enum.at(0) |> String.split(" ", trim: true)
      output_value = String.split(line, " | ") |> Enum.at(1) |> String.split(" ", trim: true)
      {digits, output_value}
    end)
  end
end

defmodule SevenSegmentDisplayDiagnostic do
  def how_many_1_4_7_8_digits(list) do
    Enum.reduce(list, 0, fn {_, output_value}, sum ->
      sum +
        Enum.reduce(output_value, 0, fn output_value_digit, display_sum ->
          if Enum.member?([2, 3, 4, 7], String.length(output_value_digit)) do
            display_sum + 1
          else
            display_sum
          end
        end)
    end)
  end

  def decode_output_values(list) do
    Enum.map(list, fn {digits, output_value} ->
      %{one: one, four: four, eight: eight} =
        Enum.reduce(digits, %{}, fn d, acc ->
          cond do
            String.length(d) == 2 -> Map.merge(acc, %{one: d})
            String.length(d) == 4 -> Map.merge(acc, %{four: d})
            String.length(d) == 7 -> Map.merge(acc, %{eight: d})
            true -> acc
          end
        end)

      Enum.reduce(output_value, [], fn value, decoded_values ->
        case String.length(value) do
          2 ->
            decoded_values ++ [1]

          3 ->
            decoded_values ++ [7]

          4 ->
            decoded_values ++ [4]

          7 ->
            decoded_values ++ [8]

          5 ->
            case how_many_letters_share(value, one) do
              2 ->
                decoded_values ++ [3]

              _ ->
                case how_many_letters_share(value, four) do
                  3 -> decoded_values ++ [5]
                  _ -> decoded_values ++ [2]
                end
            end

          6 ->
            case how_many_letters_share(value, one) do
              1 ->
                decoded_values ++ [6]

              _ ->
                case how_many_letters_share(value, eight, String.graphemes(four)) do
                  false -> decoded_values ++ [9]
                  true -> decoded_values ++ [0]
                end
            end
        end
      end)
    end)
    |> Enum.map(&Integer.undigits(&1))
  end

  defp how_many_letters_share(digit1, digit2) do
    total = String.length(digit1)

    difference =
      (String.graphemes(digit1) -- String.graphemes(digit2))
      |> Enum.count()

    total - difference
  end

  defp how_many_letters_share(digit1, digit2, diff) do
    digit_set1 = MapSet.new(String.graphemes(digit1))
    digit_set2 = MapSet.new(String.graphemes(digit2))
    d = MapSet.difference(digit_set2, digit_set1)
    Enum.any?(diff, &MapSet.member?(d, &1))
  end
end

##
# MAIN ENTRY SCRIPT
#

list =
  MySlickTools.get_filename_from_arg()
  |> MySlickTools.read_list_of_digits_output_value_pairs()

IO.puts("Part one")

SevenSegmentDisplayDiagnostic.how_many_1_4_7_8_digits(list)
|> IO.inspect()

IO.puts("Part two")

SevenSegmentDisplayDiagnostic.decode_output_values(list)
|> Enum.sum()
|> IO.inspect()
