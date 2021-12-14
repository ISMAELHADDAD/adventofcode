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
  end
end

##
# MAIN ENTRY SCRIPT
#

{template, rules} =
  MySlickTools.get_filename_from_arg()
  |> MySlickTools.read_polymerization_instructions()

IO.puts("Part one")

PolymerizationEquipment.insert_n_steps(template, rules, 10)
|> Enum.frequencies()
|> IO.inspect()
