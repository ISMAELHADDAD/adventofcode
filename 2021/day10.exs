defmodule MySlickTools do
  def get_filename_from_arg() do
    args = System.argv()
    [filename | _] = args
    filename
  end

  def read_list_of_charlists(filename) do
    {:ok, contents} = File.read(filename)

    contents
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes(&1))
  end
end

defmodule NavigationSubsystemSyntax do
  def total_syntax_error_score(list) do
    Enum.reduce(list, 0, fn row, sum ->
      case parse_tokens(row) do
        {")", _} -> sum + 3
        {"]", _} -> sum + 57
        {"}", _} -> sum + 1197
        {">", _} -> sum + 25137
        {"noerror", _} -> sum
      end
    end)
  end

  defp parse_tokens(row) do
    Enum.reduce_while(row, {"noerror", []}, fn token, {_, tokens} ->
      case tokens do
        [] ->
          {:cont, {"noerror", [token]}}

        [prev_token | rest_tokens] ->
          case parse_next(prev_token, token) do
            {:open, return_token} -> {:cont, {"noerror", [return_token | tokens]}}
            :close -> {:cont, {"noerror", rest_tokens}}
            {:error, return_token} -> {:halt, {return_token, tokens}}
          end
      end
    end)
  end

  defp parse_next("(", ")"), do: :close
  defp parse_next("[", "]"), do: :close
  defp parse_next("{", "}"), do: :close
  defp parse_next("<", ">"), do: :close
  defp parse_next(_prev_token, token) when token in [")", "]", "}", ">"], do: {:error, token}
  defp parse_next(_prev_token, token), do: {:open, token}

  ## PART TWO
  def total_autocomplete_score(list) do
    sorted_scores =
      Enum.reduce(list, [], fn row, acc ->
        case parse_tokens(row) do
          {"noerror", remaining_tokens} -> [autocomplete_score(remaining_tokens) | acc]
          {_, _} -> acc
        end
      end)
      |> Enum.sort()

    middle_index = sorted_scores |> Enum.count() |> div(2)
    Enum.at(sorted_scores, middle_index)
  end

  defp autocomplete_score(tokens) do
    Enum.reduce(tokens, 0, fn token, acc ->
      case token do
        "(" -> acc * 5 + 1
        "[" -> acc * 5 + 2
        "{" -> acc * 5 + 3
        "<" -> acc * 5 + 4
      end
    end)
  end
end

##
# MAIN ENTRY SCRIPT
#

list =
  MySlickTools.get_filename_from_arg()
  |> MySlickTools.read_list_of_charlists()

IO.puts("Part one")

NavigationSubsystemSyntax.total_syntax_error_score(list)
|> IO.inspect()

IO.puts("Part two")

NavigationSubsystemSyntax.total_autocomplete_score(list)
|> IO.inspect()
