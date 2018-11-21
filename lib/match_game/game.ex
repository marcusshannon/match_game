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
    Enum.each(0..board_size, f(x) ->
      val = Enum.random(choices)
      List.insert_at(board, x - 1, val
    end)
    board
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
