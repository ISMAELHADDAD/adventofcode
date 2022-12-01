defmodule MySlickTools do
  def get_filename_from_arg() do
    args = System.argv()
    [filename | _] = args
    filename
  end

  def read_matrix_of_integers(filename) do
    {:ok, contents} = File.read(filename)

    contents
    |> String.split("\n", trim: true)
    |> Enum.reduce({%{}, 0, 0}, fn row, {map, row_index, _} ->
      {row_map, cols} =
        String.graphemes(row)
        |> Enum.reduce({%{}, 0}, fn val, {cur_row_map, col_index} ->
          {Map.put(cur_row_map, {row_index, col_index}, String.to_integer(val)), col_index + 1}
        end)

      {Map.merge(map, row_map), row_index + 1, cols}
    end)
  end
end

defmodule CavernNavigator do
  def lowest_total_risk_path({matrix, row, col}) do
    # {weight, distance from start, visited}
    matrix
    |> Map.to_list()
    |> Enum.map(fn {pos, _} = node -> if pos == {0, 0}, do: {0, node}, else: {:infinity, node} end)
    |> Enum.into(PriorityQueue.new())
    |> dijkstra(matrix, {row, col}, [{0, 0}])
  end

  defp dijkstra(priority_queue, matrix, goal, visited) do
    {{dist, cur_node}, next_priority_queue} = priority_queue |> PriorityQueue.pop()
    {pos, val} = cur_node

    if pos == goal do
      dist + val
    else
      pos
      |> get_adjecents_positions()
      |> Enum.reduce(matrix, fn {adj_pos, adj_val}, _ ->
        case Enum.member?(visited, adj_pos) do
          true -> matrix
          false -> temp = dist + adj_val
        end
      end)
    end
  end

  defp get_adjecents_positions({row, col}),
    do: [
      {row - 1, col},
      {row + 1, col},
      {row, col + 1},
      {row, col - 1}
    ]
end

##
# MAIN ENTRY SCRIPT
#

matrix =
  MySlickTools.get_filename_from_arg()
  |> MySlickTools.read_matrix_of_integers()

IO.puts("Part one")

CavernNavigator.lowest_total_risk_path(matrix)
|> IO.inspect()
