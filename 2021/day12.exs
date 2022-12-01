defmodule MySlickTools do
  def get_filename_from_arg() do
    args = System.argv()
    [filename | _] = args
    filename
  end

  def read_graph(filename) do
    {:ok, contents} = File.read(filename)

    contents
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn row, map ->
      [v1 | [v2 | _]] = String.split(row, "-", trim: true)

      map
      |> add_edge_to_map(v1, v2)
      |> add_edge_to_map(v2, v1)
    end)
  end

  defp parse_vertex("start"), do: {"start", :start}
  defp parse_vertex("end"), do: {"end", :end}

  defp parse_vertex(v) do
    cond do
      v =~ ~r(^[^a-z]*$) -> {v, :big}
      v =~ ~r(^[^A-Z]*$) -> {v, :small}
    end
  end

  defp add_edge_to_map(map, v1, v2) do
    parsed_v1 = parse_vertex(v1)
    parsed_v2 = parse_vertex(v2)

    case Map.get(map, parsed_v1) do
      nil -> Map.put(map, parsed_v1, MapSet.new([parsed_v2]))
      set -> Map.put(map, parsed_v1, MapSet.put(set, parsed_v2))
    end
  end
end

defmodule CaveNavigationSystem do
  def find_all_possible_paths(graph, visited \\ [], start_node \\ {"start", :start}) do
    graph
    |> Map.get(start_node)
    |> Enum.reduce([], fn adj, paths ->
      if adj in visited do
        paths
      else
        case adj do
          {"end", :end} ->
            [[start_node, {"end", :end}] | paths]

          {_, :small} ->
            paths ++
              (find_all_possible_paths(graph, [adj | visited], adj)
               |> Enum.map(&[start_node | &1]))

          {_, :big} ->
            paths ++
              (find_all_possible_paths(graph, visited, adj) |> Enum.map(&[start_node | &1]))

          {"start", :start} ->
            paths
        end
      end
    end)
  end

  ## PART TWO
  def find_all_possible_paths_part_2(
        graph,
        visited \\ [],
        is_double_visit_used \\ false,
        start_node \\ {"start", :start}
      ) do
    graph
    |> Map.get(start_node)
    |> Enum.reduce([], fn adj, paths ->
      if adj in visited do
        paths
      else
        case adj do
          {"end", :end} ->
            [[start_node, {"end", :end}] | paths]

          {_, :small} ->
            paths_found_double_visit =
              case is_double_visit_used do
                false ->
                  find_all_possible_paths_part_2(graph, visited, true, adj)
                  |> Enum.map(&[start_node | &1])

                true ->
                  []
              end

            paths_found =
              find_all_possible_paths_part_2(graph, [adj | visited], is_double_visit_used, adj)
              |> Enum.map(&[start_node | &1])

            (paths ++ paths_found ++ paths_found_double_visit)
            |> Enum.uniq_by(fn i -> Enum.map(i, fn {s, _} -> s end) |> Enum.join(",") end)

          {_, :big} ->
            paths ++
              (find_all_possible_paths_part_2(graph, visited, is_double_visit_used, adj)
               |> Enum.map(&[start_node | &1]))

          {"start", :start} ->
            paths
        end
      end
    end)
  end
end

##
# MAIN ENTRY SCRIPT
#

graph =
  MySlickTools.get_filename_from_arg()
  |> MySlickTools.read_graph()

IO.puts("Part one")

CaveNavigationSystem.find_all_possible_paths(graph)
|> Enum.count()
|> IO.inspect()

IO.puts("Part two")

CaveNavigationSystem.find_all_possible_paths_part_2(graph)
|> Enum.count()
|> IO.inspect()
