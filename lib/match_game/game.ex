defmodule MatchGame.Game do

  def new do
    %{
      score: [],
      width: 5,
      height: 10,
      board: new_board(),
      to_delete: [],
      players: [],
      active_player: 0
    }
  end

  # Generates a new game board
  def new_board() do
    board_size = :width * :height
    # A board of empty slots
    board = List.duplicate(0, board_size)
    Enum.each(0..board_size - 1, fn(x) ->
      generate_new_cell_no_match(x)
    end)
    board
  end

  #Swaps the values at p1 and p2 if they are adjacent
  def swap_vals(p1, p2, playernum) do
    if playernum == :active_player do
      acceptable_indexs = [p1 - :width, p1 + :width]
      if (rem(p1, :width) != 0) and (rem(p1, :width) != :width - 1) do
        acceptable_indexs ++ [p1 - 1, p1 + 1]
        # Handles the case when p1 is on the edge of a row
      else
        if rem(p1, :width) == 0 do
          acceptable_indexs ++ [p1 + 1]
        else
          acceptable_indexs ++ [p1 - 1]
        end
      end
      if Enum.member?(acceptable_indexs, p2) do
        val1 = Enum.at(:board, p1)
        val2 = Enum.at(:board, p2)
        List.replace_at(:board, p1, val2)
        List.replace_at(:board, p2, val1)
      end

      check_for_stability(1)
    end
  end

  #Resolves as many falls as necesary
  #If turn based, advances the turns
  def check_for_stability(combo) do
    is_stable = check_board_for_matches()
    if not is_stable do
      dels = apply_deletions(combo)
      check_for_stability(combo + 1)
    end
    new_active_player = rem(:active_player + 1, length(:players))
  end

  #Generates a new cell at the index with no matches
  def generate_new_cell_no_match(index) do
    choices = [1, 2, 3, 4, 5]
    if (index < :width) and (index > 0) do
      left_val = Enum.at(:board, index - 1)
      choices = List.delete(choices, left_val)
    else
      left_val = Enum.at(:board, index - 1)
      bottom_val = Enum.at(:board, index - :width)
      choices = List.delete(choices, left_val)
      if List.member?(choices, bottom_val) do
        choices = List.delete(choices, bottom_val)
      end
    end

    List.replace_at(:board, index, Enum.random(choices))
  end


  #Deletes all the cells we have to delete
  def apply_deletions(combo) do
    board_size = :width * :height
    Enum.each(0..board_size - 1, fn(x) ->
      # If we are supposed to delete this tile, do it
      if Enum.member?(:to_delete, x) do
        List.replace_at(:board, x, 0)
        List.delete(:to_delete, x)
        current_score = Enum.at(:score, :active_player)
        List.replace_at(:score, :active_player, current_score + combo)
      end

      if Enum.at(:board, x) == 0 do
        # If we are not at the top
        if (x + :width < board_size) do
          upperVal = Enum.at(:board, x + :width)
          List.replace_at(:board, x, upperVal)
          List.replace_at(:board, x + :width, 0)
        else
          generate_new_cell_no_match(x)
        end
      end

    end)
  end

  # Returns true if there are matches anywhere on the board
  def check_board_for_matches() do
    match_found = False
    Enum.each(0...:height - 1, fn(y) ->
      Enum.each(0...:width - 1, fn(x) ->
        local_match = check_for_match(x, y)
        match_found = match_found or local_match
      end)

    end)

    match_found
  end

  #Checks to see if the cell at x,y is at the center of
  #A match
  def check_for_match(x, y) do
    horizontal_match = check_for_horizontal_match(x, y)
    vertical_match = check_for_vertical_match(x,y)
    match = horizontal_match or vertical_match
    match
  end

  # Checks to see if there is a horizontal_match with the cell
  # at x,y, in the center
  def check_for_horizontal_match(x, y) do
    if (x == 0) or (x == :width - 1) do
      False
    else
      index = (y * :width) + x
      center_val = Enum.at(:board, index)
      left_val = Enum.at(:board, index - 1)
      right_val = Enum.at(:board, index + 1)
      match = (center_val == left_val) and (center_val == right_val)
      #If we have a match, mark the tiles so we can delete them
      if match do
        deletions = :to_delete ++ [index - 1, index, index + 1]
        deletions = Enum.uniq(deletions)
        :to_delete = deletions
      end
      match
    end
  end

  # Checks to see if there is a vertical_match with the cell
  # at x,y, in the center
  def check_for_vertical_match(x, y) do
    if (y == 0) or (y == :height - 1) do
      False
    else
      index = (y * :width) + x
      center_val = Enum.at(:board, index)
      bottom_val = Enum.at(:board, index - :width)
      top_val = Enum.at(:board, index + :width)
      match = (center_val == top_val) and (center_val == bottom_val)
      #If we have a match, mark the tiles so we can delete them
      if match do
        deletions = :to_delete ++ [index - :width, index, index + :width]
      end
      match
    end
  end


end
