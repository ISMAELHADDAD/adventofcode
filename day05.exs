defmodule MySlickTools do
  def get_filename_from_arg() do
    args = System.argv()
    [filename | _] = args
    filename
  end

  def read_list_of_point_pairs(filename) do
    {:ok, contents} = File.read(filename)
    contents
     |> String.split("\n", trim: true)
     |> Enum.map(fn x ->
      [point1_str | [point2_str | _]] = String.split(x, " -> ", trim: true)
      [point1_x_str | [point1_y_str | _]] = String.split(point1_str, ",", trim: true)
      [point2_x_str | [point2_y_str | _]] = String.split(point2_str, ",", trim: true)
      {
        {Integer.parse(point1_x_str) |> Kernel.elem(0), Integer.parse(point1_y_str) |> Kernel.elem(0)},
        {Integer.parse(point2_x_str) |> Kernel.elem(0), Integer.parse(point2_y_str) |> Kernel.elem(0)}
      }
    end)
  end
end

defmodule Diagram do
  defstruct(
    matrix: [],
    num_of_overlaps: 0
  )

  def new_diagram_from_list_of_lines(list_of_lines) do
    {width, height} = size(list_of_lines)
    %Diagram{
      matrix: new_matrix(width + 1, height + 1),
      num_of_overlaps: 0
    }
  end

  def draw(%Diagram{matrix: matrix, num_of_overlaps: num_of_overlaps} = diagram, row, col) do
    row_vals = Enum.at(matrix, row)
    new_val = Enum.at(row_vals, col, 0) + 1
    new_row = List.replace_at(row_vals, col, new_val)
    %Diagram{diagram |
      matrix: List.replace_at(matrix, row, new_row),
      num_of_overlaps: num_of_overlaps + increase_if_overlap(new_val)
    }
  end

  def elem(%Diagram{matrix: matrix}, row, col, default \\ nil) do
    row_vals = Enum.at(matrix, row, nil)
    if row_vals == nil, do: default, else: Enum.at(row_vals, col, default)
  end

  ## PRIVATE

  defp increase_if_overlap(new_val) when new_val == 2, do: 1
  defp increase_if_overlap(_), do: 0

  defp size(list_of_lines),
    do: Enum.reduce(list_of_lines, {0, 0}, fn line, acc ->
      {max_x, max_y} = acc
      {{x1, y1}, {x2, y2}} = line
      {Enum.max([max_y, y1, y2]), Enum.max([max_x, x1, x2])}
    end)

  defp new_matrix(rows, cols, val \\ 0) do
    for _r <- 1..rows, do: make_row(cols,val)
  end

  defp make_row(0, _val), do: []
  defp make_row(n, val), do: [val] ++ make_row(n-1, val)


end

defmodule HydrothermalVentRadar do

  def draw_diagram(lines) do
    {horizontal, vertical, _} = get_horiz_vert_and_diag_lines(lines)
    diagram = Diagram.new_diagram_from_list_of_lines(lines)
    horiz_diagram = Enum.reduce(horizontal, diagram, fn line, diagram_acc ->
      {{x1, y1}, {x2, _y2}} = line
      Enum.reduce(x1..x2, diagram_acc, fn x, diagram_acc2 ->
        Diagram.draw(diagram_acc2, y1, x)
      end)
    end)
    Enum.reduce(vertical, horiz_diagram, fn line, diagram_acc ->
      {{x1, y1}, {_x2, y2}} = line
      Enum.reduce(y1..y2, diagram_acc, fn y, diagram_acc2 ->
        Diagram.draw(diagram_acc2, y, x1)
      end)
    end)
  end

  def draw_diagram_with_diagonals(lines) do
    {horizontal, vertical, diagonals} = get_horiz_vert_and_diag_lines(lines)
    diagram = Diagram.new_diagram_from_list_of_lines(lines)
    horiz_diagram = Enum.reduce(horizontal, diagram, fn line, diagram_acc ->
      {{x1, y1}, {x2, _y2}} = line
      Enum.reduce(x1..x2, diagram_acc, fn x, diagram_acc2 ->
        Diagram.draw(diagram_acc2, y1, x)
      end)
    end)
    vert_diagram = Enum.reduce(vertical, horiz_diagram, fn line, diagram_acc ->
      {{x1, y1}, {_x2, y2}} = line
      Enum.reduce(y1..y2, diagram_acc, fn y, diagram_acc2 ->
        Diagram.draw(diagram_acc2, y, x1)
      end)
    end)
    Enum.reduce(diagonals, vert_diagram, fn line, diagram_acc ->
      {{x1, y1}, {x2, y2}} = line
      direction = cond do
        y1 < y2 -> 1
        true -> -1
      end
      {diagram_result, _} = Enum.reduce(x1..x2, {diagram_acc, 0}, fn x, diagram_acc2 ->
        {diagram_to_update, index} = diagram_acc2
        {Diagram.draw(diagram_to_update, y1 + index * direction, x), index + 1}
      end)
      diagram_result
    end)
  end

  ## PRIVATE

  defp get_horiz_vert_and_diag_lines(list) do
    Enum.reduce(list, {[], [], []}, fn line, acc ->
      {horiz, vert, diag} = acc
      {{x1, y1}, {x2, y2}} = line
      cond do
        x1 == x2 -> {horiz, vert ++ [line], diag}
        y1 == y2 -> {horiz ++ [line], vert, diag}
        true -> {horiz, vert, diag ++ [line]}
      end
    end)
  end
end


##
# MAIN ENTRY SCRIPT
#

list = MySlickTools.get_filename_from_arg()
 |> MySlickTools.read_list_of_point_pairs()

IO.puts "Part one"

%Diagram{num_of_overlaps: num_of_overlaps1} = list
 |> HydrothermalVentRadar.draw_diagram()

IO.inspect num_of_overlaps1

IO.puts "Part two"

%Diagram{num_of_overlaps: num_of_overlaps2} = list
 |> HydrothermalVentRadar.draw_diagram_with_diagonals()

IO.inspect num_of_overlaps2
