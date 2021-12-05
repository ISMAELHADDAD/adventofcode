defmodule MySlickTools do
  def get_filename_from_arg() do
    args = System.argv()
    [filename | _] = args
    filename
  end

  def read_list_of_numbers_and_board_matrices(filename) do
    {:ok, contents} = File.read(filename)
    numbers = contents
     |> String.split("\n", trim: true)
     |> List.first()
     |> String.split(",", trim: true)
     |> Enum.map(&(Integer.parse(&1) |> Kernel.elem(0)))
    board_matrices = contents
     |> String.split("\n", trim: true)
     |> Enum.split(1)
     |> Kernel.elem(1)
     |> Enum.chunk_every(5)
     |> Enum.reduce([], fn matrix, acc ->
          acc ++ [Enum.map(matrix, fn row ->
            row
            |> String.split(" ", trim: true)
            |> Enum.map(&(Integer.parse(&1) |> Kernel.elem(0)))
          end)]
        end)
    {numbers, board_matrices}
  end
end

defmodule Board do
  defstruct(
    matrix: [],
    turn: 0,
    numbers_used: [],
    board_state: :init # :waiting_next_number or :winner
  )

  def new_board(matrix) do
    %Board{
      matrix: matrix,
      board_state: :waiting_next_number,
    }
  end

  def get_score(board) do
    sum_unmarked_numbers(board) * last_called_number(board)
  end

  def check_number(board, number) do
    next_turn_board = %Board{board | numbers_used: board.numbers_used ++ [number], turn: board.turn + 1}
    with false <- any_row_completed?(next_turn_board), false <- any_col_completed?(next_turn_board) do
      next_turn_board
    else
      true -> %Board{next_turn_board | board_state: :winner}
    end
  end

  ### PRIVATE

  defp any_row_completed?(%{matrix: matrix, numbers_used: numbers_used}) do
    Enum.any?(matrix, fn row ->
      Enum.all?(row, fn cell ->
        Enum.member?(numbers_used, cell)
      end)
    end)
  end

  defp any_col_completed?(%{matrix: matrix, numbers_used: numbers_used}) do
    matrix
    |> Enum.zip()
    |> Enum.any?(fn col ->
      col
      |> Tuple.to_list()
      |> Enum.all?(fn cell -> Enum.member?(numbers_used, cell) end)
    end)
  end

  def sum_unmarked_numbers(%Board{matrix: matrix, numbers_used: numbers_used}) do
    Enum.reduce(matrix, 0, fn row, sum_matrix ->
      sum_matrix + Enum.reduce(row, 0, fn cell, sum_row ->
        if Enum.member?(numbers_used, cell), do: sum_row, else: sum_row + cell
      end)
    end)
  end

  def last_called_number(%Board{numbers_used: numbers_used}),
    do: numbers_used |> List.last()

end

defmodule BingoSubsystem do
  def search_first_winning_board(numbers, board_matrices) do
    boards = Enum.map(board_matrices, &(Board.new_board(&1)))
    numbers
    |> Enum.reduce_while({:no_winner, boards, nil}, fn number, acc ->
      {_, boards_to_check, _} = acc
      current_turn = Enum.reduce_while(boards_to_check, {:no_winner, [], nil}, fn board, acc_boards ->
        {_, boards_until_now, _} = acc_boards
        case board |> Board.check_number(number) do
          %Board{board_state: :winner} = new_board -> {:halt, {:winner, boards_until_now ++ [new_board], new_board}}
          new_board -> {:cont, {:no_winner, boards_until_now ++ [new_board], nil}}
        end
      end)
      case current_turn do
        {:winner, _, winner_board} -> {:halt, winner_board}
        no_winner -> {:cont, no_winner}
      end
    end)
  end

  def search_last_winning_board(numbers, board_matrices) do
    boards = Enum.map(board_matrices, &(Board.new_board(&1)))
    numbers
    |> Enum.reduce_while({boards, nil}, fn number, acc ->
      {boards_to_check, _last_winning_board} = acc
      {boards_left, winner_board} = Enum.reduce(boards_to_check, {[], nil}, fn board, acc_boards ->
        {boards_until_now, last_winning_board_curr} = acc_boards
        case board |> Board.check_number(number) do
          %Board{board_state: :winner} = new_board ->
            {boards_until_now, new_board}
          %Board{board_state: :waiting_next_number} = new_board ->
            {boards_until_now ++ [new_board], last_winning_board_curr}
        end
      end)
      cond do
        Enum.count(boards_left) == 0 -> {:halt, winner_board}
        true -> {:cont, {boards_left, winner_board}}
      end
    end)
  end
end

##
# MAIN ENTRY SCRIPT
#

{numbers, board_matrices} = MySlickTools.get_filename_from_arg()
 |> MySlickTools.read_list_of_numbers_and_board_matrices()

IO.puts "Part one"

BingoSubsystem.search_first_winning_board(numbers, board_matrices)
 |> Board.get_score()
 |> IO.inspect

IO.puts "Part two"

BingoSubsystem.search_last_winning_board(numbers, board_matrices)
 |> Board.get_score()
 |> IO.inspect
