defmodule MySlickTools do
  def get_filename_from_arg() do
    args = System.argv()
    [filename | _] = args
    filename
  end

  def read_list_of_points_and_commands(filename) do
    {:ok, contents} = File.read(filename)

    contents
    |> String.split("\n", trim: true)
    |> Enum.reduce({[], []}, fn line, {points, commands} ->
      case parse_line(line) do
        {:point, point} -> {points ++ [point], commands}
        {:command, command} -> {points, commands ++ [command]}
      end
    end)
  end

  defp parse_line(line) do
    cond do
      String.contains?(line, "fold") ->
        [cmd | [val | []]] = String.split(line, "=")

        case cmd do
          "fold along x" -> {:command, {:x, String.to_integer(val)}}
          "fold along y" -> {:command, {:y, String.to_integer(val)}}
        end

      true ->
        [val1 | [val2 | _]] = String.split(line, ",")
        {:point, {String.to_integer(val1), String.to_integer(val2)}}
    end
  end

  def write_list_to_file(list) do
    {:ok, file} = File.open("output.txt", [:write])

    Enum.each(list, fn line ->
      IO.binwrite(file, line)
      IO.binwrite(file, "\n")
    end)

    File.close(file)
  end
end

defmodule ThermalImagingSystemManual do
  def fold_n_setps(points, commands, steps) do
    Enum.reduce(1..steps, points, fn step, acc_points ->
      commands
      |> Enum.at(step - 1)
      |> fold(acc_points)
    end)
  end

  defp fold(command, points) do
    size = size(points)

    points
    |> Enum.filter(fn {px, py} ->
      case command do
        {:y, y} -> py != y
        {:x, x} -> px != x
      end
    end)
    |> Enum.reduce([], fn point, acc_points ->
      [process_next_position(command, size, point) | acc_points]
    end)
    |> Enum.uniq_by(fn {x, y} -> "#{x},#{y}" end)
  end

  defp process_next_position({along, f}, {w, h}, {px, py}) do
    p_compare = if along == :y, do: py, else: px
    s_compare = if along == :y, do: h, else: w

    cond do
      s_compare / 2 <= f ->
        cond do
          p_compare < f ->
            {px, py}

          p_compare > f ->
            if along == :y,
              do: {px, f * 2 - py},
              else: {f * 2 - px, py}
        end

      s_compare / 2 > f ->
        cond do
          p_compare < f ->
            if along == :y,
              do: {px, s_compare - (f + 1) - py},
              else: {s_compare - (f + 1) - py, py}

          p_compare > f ->
            if along == :y, do: {px, s_compare - py}, else: {s_compare - px, py}
        end
    end
  end

  defp size(points) do
    Enum.reduce(points, {0, 0}, fn {x, y}, {w, h} ->
      {max(w, x), max(h, y)}
    end)
  end

  ## PART TWO
  def draw_paper(points) do
    {w, h} = size(points)

    Enum.reduce(0..h, [], fn y, acc_y ->
      acc_y ++
        [
          Enum.reduce(0..w, [], fn x, acc_x ->
            acc_x ++
              [
                case Enum.member?(points, {x, y}) do
                  true -> "#"
                  false -> "."
                end
              ]
          end)
          |> List.to_string()
        ]
    end)
  end
end

##
# MAIN ENTRY SCRIPT
#

{points, commands} =
  MySlickTools.get_filename_from_arg()
  |> MySlickTools.read_list_of_points_and_commands()

IO.puts("Part one")

ThermalImagingSystemManual.fold_n_setps(points, commands, 1)
|> Enum.count()
|> IO.inspect()

IO.puts("Part two")

ThermalImagingSystemManual.fold_n_setps(points, commands, Enum.count(commands))
|> ThermalImagingSystemManual.draw_paper()
|> Enum.each(&IO.puts(&1))
