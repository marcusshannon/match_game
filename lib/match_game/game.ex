defmodule MatchGame.Game do
  alias MatchGame.Board

  def new(user_id) do
    %{
      owner: user_id,
      players: [user_id],
      current_state: "LOBBY",
      points: %{
        user_id => 0
      }
    }
  end

  def add_player(state, user_id) do
    Map.update!(state, :players, &[user_id | &1])
    |> Map.update!(:points, &Map.put(&1, user_id, 0))
  end

  def start_game(state) do
    state
    |> Map.put(:current_state, "GAME")
    |> Map.put(:board, Board.new())
    |> Map.put(:start_time, System.system_time(:second))
  end

  def end_game(state) do
    state |> Map.put(:current_state, "COMPLETE")
  end

  def swap(state, tile1, tile2, user_id) do
    next_board = Board.swap(state.board, tile1, tile2)
    points = Board.compare_boards(state.board, next_board)

    Map.put(state, :board, next_board)
    |> Map.update!(:points, &Map.update!(&1, user_id, fn prev_points -> prev_points + points end))
  end

  def log_game(%{players: players} = state) when length(players) > 1 do
    {winner, _} = Enum.max(state.points)
    result = MatchGame.Results.insert_result(winner)

    Enum.each(
      state.players,
      &MatchGame.UsersResults.insert_user_result(&1, result.id, state.points[&1])
    )
  end

  def log_game(state) do
    nil
  end
end
