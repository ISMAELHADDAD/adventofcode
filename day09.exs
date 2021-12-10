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

defmodule Heightmap do
  def calculate_risk_points({matrix_map, _, _}) do
    Enum.reduce(matrix_map, 0, fn {pos, _}, sum ->
      cur = Map.get(matrix_map, pos)

      if cur < get_adjecents_min_val(matrix_map, pos) do
        sum + cur + 1
      else
        sum
      end
    end)
  end

  defp get_adjecents_positions({row, col}),
    do: [
      {row - 1, col},
      {row + 1, col},
      {row, col + 1},
      {row, col - 1}
    ]

  defp get_adjecents_min_val(matrix_map, pos) do
    get_adjecents_positions(pos)
    |> Enum.reduce(9, fn pos, min ->
      case Map.fetch(matrix_map, pos) do
        {:ok, value} -> Kernel.min(min, value)
        :error -> min
      end
    end)
  end
end

matrix =
  MySlickTools.get_filename_from_arg()
  |> MySlickTools.read_matrix_of_integers()

IO.puts("Part one")

Heightmap.calculate_risk_points(matrix)
|> IO.inspect()
