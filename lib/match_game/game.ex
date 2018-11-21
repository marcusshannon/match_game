defmodule MatchGame.Game do

  def new do
    %{
      board: new_board(),
      score: 0,
      width: 5,
      height: 10,
      to_delete: []
    }

  # Generates a new game board
  def new_board() do
    choices = [1, 2, 3, 4, 5]
    board_size = :width * :height
    # A board of empty slots
    board = List.duplicate(0, board_size)
    Enum.each(0..board_size - 1, f(x) ->
      val = Enum.random(choices)
      List.replace_at(board, x - 1, val)
    end)
    board
  end

  #Swaps the values at p1 and p2 if they are adjacent
  def swap_vals(p1, p2) do
    acceptable_indexs = [p1 + 1, p1 - 1, p1 - :width, p1 + :width]
    if Enum.member?(acceptable_indexs, p2) do
      val1 = Enum.at(:board, p1)
      val2 = Enum.at(:board, p2)
      List.replace_at(:board, p1, val2)
      List.replace_at(:board, p2, val1)
    end
  end


  def apply_deletions() do
    board_size - :width * :height
    Enum.each(0..board_size - 1, f(x) ->
      # If we are supposed to delete this tile, do it
      if Enum.member?(:to_delete, x) do
        List.replace_at(:board, x, 0)
        List.delete(:to_delete, x)
      end

      if Enum.at(:board, x) == 0 do
        # If we are not at the top
        if (x + :width < board_size) do
          upperVal = Enum.at(:board, x + :width)
          List.replace_at(:board, x, upperVal)
          List.replace_at(:board, x + :width, 0)
        else
          newVal = Enum.random([1, 2, 3, 4, 5])
          List.replace_at(:board, x, newVal)
        end
      end

    end)
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
