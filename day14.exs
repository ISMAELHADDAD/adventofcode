defmodule MySlickTools do
  def get_filename_from_arg() do
    args = System.argv()
    [filename | _] = args
    filename
  end

  def read_polymerization_instructions(filename) do
    {:ok, contents} = File.read(filename)

    [template | rules] =
      contents
      |> String.split("\n", trim: true)

    {template,
     rules
     |> Enum.reduce(%{}, fn line, rules_map ->
       [key | [val | _]] = String.split(line, " -> ")
       Map.put(rules_map, key, val)
     end)}
  end
end

defmodule PolymerizationEquipment do
  def insert_n_steps(template, rules, steps) do
    list_template = String.graphemes(template)

    Enum.reduce(1..steps, list_template, fn step, acc_template ->
      acc_template
      |> Enum.reverse()
      |> Enum.chunk_every(2, 1)
      |> Enum.reduce([], fn pair, acc ->
        [first_letter | _] = pair

        if Enum.count(pair) == 1 do
          [first_letter | acc]
        else
          [_, second_letter | _] = pair
          key = List.to_string([second_letter, first_letter])

          case Map.get(rules, key) do
            nil -> [first_letter | acc]
            val -> [val, first_letter | acc]
          end
        end
      end)
    end)
    |> Enum.frequencies()
  end

  ## PART TWO
  def insert_n_steps_part_2(template, rules, steps) do
    freq_map =
      template
      |> String.graphemes()
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&List.to_string(&1))
      |> Enum.frequencies()

    Enum.reduce(1..steps, freq_map, fn _, freq_map ->
      PolymerizationEquipment.get_frequencies(freq_map, rules)
    end)
    |> Enum.reduce(%{}, fn {pair, amount}, acc ->
      [first_letter | _] = String.graphemes(pair)
      Map.update(acc, first_letter, amount, &(&1 + amount))
    end)
  end

  def get_frequencies(freq_map, rules) do
    Enum.reduce(freq_map, %{}, fn {pair, amount}, acc ->
      get_after_insertion_pairs(pair, rules)
      |> Enum.reduce(acc, fn next_pair, acc ->
        Map.update(acc, next_pair, amount, &(&1 + amount))
      end)
    end)
  end

  defp get_after_insertion_pairs(pair, rules) do
    [first_letter, second_letter | _] = String.graphemes(pair)
    inserted = Map.get(rules, pair)

    [
      [first_letter, inserted] |> List.to_string(),
      [inserted, second_letter] |> List.to_string()
    ]
  end
end

##
# MAIN ENTRY SCRIPT
#

{template, rules} =
  MySlickTools.get_filename_from_arg()
  |> MySlickTools.read_polymerization_instructions()

IO.puts("Part one")

{min1, max1} =
  PolymerizationEquipment.insert_n_steps(template, rules, 10)
  |> Map.values()
  |> Enum.min_max()

IO.inspect(max1 - min1)

IO.puts("Part two")

{min2, max2} =
  PolymerizationEquipment.insert_n_steps_part_2(template, rules, 40)
  |> Map.values()
  |> Enum.min_max()

IO.inspect(max2 - min2 + 1)
