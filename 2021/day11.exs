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

defmodule DumboOctopusNavigatorPredictor do
  def total_flashes_in_n_steps({matrix_map, _, _}, steps) do
    Enum.reduce(1..steps, {matrix_map, 0}, fn _step, {cur_step_matrix, cur_step_sum} ->
      {next_step_matrix, next_step_sum, list_flashed} = process_next_step(cur_step_matrix)

      {Enum.reduce(list_flashed, next_step_matrix, fn pos, acc_matrix ->
         Map.put(acc_matrix, pos, 0)
       end), cur_step_sum + next_step_sum}
    end)
    |> Kernel.elem(1)
  end

  defp process_next_step(cur_step_matrix) do
    Enum.reduce(cur_step_matrix, {cur_step_matrix, 0, []}, fn {pos, _},
                                                              {acc_matrix, sum, flashed} ->
      if Enum.member?(flashed, pos) do
        {acc_matrix, sum, flashed}
      else
        case Map.get(acc_matrix, pos) do
          9 ->
            {result_matrix, result_flashes, result_flashed} =
              increase_adjecents(Map.put(acc_matrix, pos, 0), pos, [pos | flashed])

            {result_matrix, sum + result_flashes, result_flashed}

          val ->
            {Map.put(acc_matrix, pos, val + 1), sum, flashed}
        end
      end
    end)
  end

  defp get_adjecents_positions({row, col}),
    do: [
      {row - 1, col - 1},
      {row - 1, col},
      {row - 1, col + 1},
      {row, col + 1},
      {row + 1, col + 1},
      {row + 1, col},
      {row + 1, col - 1},
      {row, col - 1}
    ]

  defp increase_adjecents(matrix_map, pos, flashed) do
    get_adjecents_positions(pos)
    |> Enum.filter(&(not Enum.member?(flashed, &1)))
    |> Enum.reduce({matrix_map, 1, flashed}, fn adj_pos, {acc_matrix, sum, acc_flashed} ->
      case Map.get(acc_matrix, adj_pos) do
        nil ->
          {acc_matrix, sum, acc_flashed}

        9 ->
          {result_matrix, result_flashes, result_flashed} =
            increase_adjecents(Map.put(acc_matrix, adj_pos, 0), adj_pos, [adj_pos | acc_flashed])

          {result_matrix, sum + result_flashes, result_flashed}

        val ->
          {Map.put(acc_matrix, adj_pos, val + 1), sum, acc_flashed}
      end
    end)
  end

  ## PART TWO

  def step_in_which_everyone_flashes({matrix_map, rows, cols}) do
    size = rows * cols
    loop_until_all_flashes(1, matrix_map, size)
  end

  def loop_until_all_flashes(step, matrix_map, size) do
    {next_step_matrix, next_step_sum, list_flashed} = process_next_step(matrix_map)

    if next_step_sum == size do
      step
    else
      matrix =
        Enum.reduce(list_flashed, next_step_matrix, fn pos, acc_matrix ->
          Map.put(acc_matrix, pos, 0)
        end)

      loop_until_all_flashes(step + 1, matrix, size)
    end
  end
end

##
# MAIN ENTRY SCRIPT
#

matrix =
  MySlickTools.get_filename_from_arg()
  |> MySlickTools.read_matrix_of_integers()

IO.puts("Part one")

DumboOctopusNavigatorPredictor.total_flashes_in_n_steps(matrix, 100)
|> IO.inspect()

IO.puts("Part two")

DumboOctopusNavigatorPredictor.step_in_which_everyone_flashes(matrix)
|> IO.inspect()
