defmodule MatchGame.Game do

  def new do
    %{
      score: [],
      width: 5,
      height: 10,
      board: new_board(5, 10),
      to_delete: [],
      players: [],
      active_player: 0
    }
  end

  # Generates a new game board
  def new_board(width, height) do
    board_size = width * height
    # A board of empty slots
    board = List.duplicate(0, board_size)
    Enum.each(0..board_size - 1, fn(x) ->
      generate_new_cell_no_match(x)
    end)
    board
  end

  #Swaps the values at p1 and p2 if they are adjacent
  def swap_vals(game, p1, p2, playernum) do
    if playernum == game.active_player do
      acceptable_indexs = [p1 - game.width, p1 + game.width]
      if (rem(p1, game.width) != 0) and (rem(p1, game.width) != game.width - 1) do
        acceptable_indexs ++ [p1 - 1, p1 + 1]
        # Handles the case when p1 is on the edge of a row
      else
        if rem(p1, game.width) == 0 do
          acceptable_indexs ++ [p1 + 1]
        else
          acceptable_indexs ++ [p1 - 1]
        end
      end
      if Enum.member?(acceptable_indexs, p2) do
        val1 = Enum.at(game.board, p1)
        val2 = Enum.at(game.board, p2)
        List.replace_at(game.board, p1, val2)
        List.replace_at(game.board, p2, val1)
      end

      check_for_stability(1)
    end
  end

  #Resolves as many falls as necesary
  #If turn based, advances the turns
  def check_for_stability(game, combo) do
    is_stable = check_board_for_matches()
    if not is_stable do
      dels = apply_deletions(combo)
      check_for_stability(combo + 1)
    end
    new_active_player = rem(game.active_player + 1, length(game.players))
  end

  #Generates a new cell at the index with no matches
  def generate_new_cell_no_match(game, index) do
    choices = [1, 2, 3, 4, 5]
    if (index < game.width) and (index > 0) do
      left_val = Enum.at(game.board, index - 1)
      choices = List.delete(choices, left_val)
    else
      left_val = Enum.at(game.board, index - 1)
      bottom_val = Enum.at(game.board, index - game.width)
      choices = List.delete(choices, left_val)
      if List.member?(choices, bottom_val) do
        choices = List.delete(choices, bottom_val)
      end
    end

    List.replace_at(game.board, index, Enum.random(choices))
  end


  #Deletes all the cells we have to delete
  def apply_deletions(game, combo) do
    board_size = game.width * game.height
    Enum.each(0..board_size - 1, fn(x) ->
      # If we are supposed to delete this tile, do it
      if Enum.member?(game.to_delete, x) do
        List.replace_at(game.board, x, 0)
        List.delete(game.to_delete, x)
        current_score = Enum.at(game.score, game.active_player)
        List.replace_at(game.score, game.active_player, current_score + combo)
      end

      if Enum.at(game.board, x) == 0 do
        # If we are not at the top
        if (x + game.width < board_size) do
          upperVal = Enum.at(game.board, x + game.width)
          List.replace_at(game.board, x, upperVal)
          List.replace_at(game.board, x + game.width, 0)
        else
          generate_new_cell_no_match(x)
        end
      end

    end)
  end

  # Returns true if there are matches anywhere on the board
  def check_board_for_matches(game) do
    match_found = False
    Enum.each(0..game.height - 1, fn(y) ->
      Enum.each(0..game.width - 1, fn(x) ->
        local_match = check_for_match(x, y)
        match_found = match_found or local_match
      end)

    end)

    match_found
  end

  #Checks to see if the cell at x,y is at the center of
  #A match
  def check_for_match(game, x, y) do
    horizontal_match = check_for_horizontal_match(game, x, y)
    vertical_match = check_for_vertical_match(game, x,y)
    match = horizontal_match or vertical_match
    match
  end

  # Checks to see if there is a horizontal_match with the cell
  # at x,y, in the center
  def check_for_horizontal_match(game, x, y) do
    if (x == 0) or (x == game.width - 1) do
      False
    else
      index = (y * game.width) + x
      center_val = Enum.at(game.board, index)
      left_val = Enum.at(game.board, index - 1)
      right_val = Enum.at(game.board, index + 1)
      match = (center_val == left_val) and (center_val == right_val)
      #If we have a match, mark the tiles so we can delete them
      if match do
        deletions = game.to_delete ++ [index - 1, index, index + 1]
        deletions = Enum.uniq(deletions)
        game.to_delete = deletions
      end
      match
    end
  end

  # Checks to see if there is a vertical_match with the cell
  # at x,y, in the center
  def check_for_vertical_match(game, x, y) do
    if (y == 0) or (y == game.height - 1) do
      False
    else
      index = (y * game.width) + x
      center_val = Enum.at(game.board, index)
      bottom_val = Enum.at(game.board, index - game.width)
      top_val = Enum.at(game.board, index + game.width)
      match = (center_val == top_val) and (center_val == bottom_val)
      #If we have a match, mark the tiles so we can delete them
      if match do
        deletions = game.to_delete ++ [index - game.width, index, index + game.width]
      end
      match
    end
  end


end
