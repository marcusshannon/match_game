defmodule MatchGame.Game do

  def new do
    newgame = %{
      score: [],
      width: 5,
      height: 10,
      board: [],
      to_delete: [],
      players: [],
      active_player: 0
    }
    newboard = new_board(newgame)
    %{
      score: [0,0,0],
      width: 5,
      height: 10,
      board: newboard,
      to_delete: [],
      players: [],
      active_player: 0
    }

  end

  # Generates a new game board
  def new_board(game) do
    board_size = game.width * game.height
    # A board of empty slots
    game = Map.replace(game, :board, List.duplicate(0, board_size))
    game = create_board_loop(game, 0, board_size)
    game.board
  end

  def create_board_loop(game, index, size) do
    if index == size - 1 do
      game
    else
      newBoard = generate_new_cell_no_match(game, index)
      newGame = Map.replace(game, :board, newBoard)
      create_board_loop(newGame, index + 1, size)
    end
  end

  #Swaps the values at p1 and p2 if they are adjacent
  def swap_vals(game, p1, p2, playernum) do
    if playernum == game.active_player do
      acceptable_indexs = [p1 - game.width, p1 + game.width]
      acceptable_indexs = acceptable_indexs ++ if rem(p1, game.width) < game.width - 1 do
        [p1 + 1]
      else
        []
      end
      acceptable_indexs = acceptable_indexs ++ if rem(p1, game.width) > 0 do
        [p1 - 1]
      else
        []
      end

      if Enum.member?(acceptable_indexs, p2) do
        val1 = Enum.at(game.board, p1)
        val2 = Enum.at(game.board, p2)
        l1 = List.replace_at(game.board, p1, val2)
        l2 = List.replace_at(l1, p2, val1)
        game = Map.replace(game, :board, l2)
        #Only need to check for stability if the swap goes through
        check_for_stability(game, 1)
      else
        game
      end
    end
  end

  #Resolves as many falls as necesary
  #If turn based, advances the turns
  def check_for_stability(game, combo) do
    checkedGame = check_board_for_matches(game, 0)
    is_stable = length(checkedGame.to_delete) == 0
    if not is_stable do
      cleanGame = apply_deletions_loop(checkedGame, 0, combo)
      game = dropdown(cleanGame, 0)
      game
      #check_for_stability(game, combo + 1)
    else
      #TODO Player changes
      new_active_player = 0
      Map.replace(game, :active_player, new_active_player)
    end

  end

  #Generates a new cell at the index with no matches
  def generate_new_cell_no_match(game, index) do
    choices = [1, 2, 3, 4, 5]

    left_val = if rem(index, game.width) > 1 do
      Enum.at(game.board, index - 1)
    end
    bottom_val = Enum.at(game.board, index - game.width)

    choices = if Enum.at(game.board, index - (2 * game.width)) == bottom_val do
      List.delete(choices, bottom_val)
    else
      choices
    end

    choices = if Enum.at(game.board, index - 2) == left_val do
      List.delete(choices, left_val)
    else
      choices
    end

    newVal = Enum.random(choices)
    List.insert_at(game.board, index, newVal)

  end


  #Deletes all the cells we have to delete [ Fills them with 0s]
  def apply_deletions_loop(game, index, combo) do
    board_size = game.width * game.height
    if index >= board_size do
      game
    else
      if Enum.member?(game.to_delete, index) do
        game = Map.replace(game, :board, List.replace_at(game.board, index, 0))
        game = Map.replace(game, :to_delete, List.delete(game.to_delete, index))
        current_score = Enum.at(game.score, game.active_player)
        current_score = if current_score == nil do 0 else current_score end
        game = Map.replace(game, :score, List.replace_at(game.score, game.active_player, current_score + combo))
        IO.inspect(game.score)
        apply_deletions_loop(game, index + 1, combo)
      else
        apply_deletions_loop(game, index + 1, combo)
      end
    end
  end

  #Drops cells from above if there is a 0 in the spot
  def dropdown(game, index) do
    board_size = game.width * game.height
    if index >= board_size do
      game
    else
      if Enum.at(game.board, index) == 0 do
        if (index + game.width < board_size) do
          upperVal = Enum.at(game.board, index + game.width)
          tempBoard = List.replace_at(game.board, index, upperVal)
          tempBoard = List.replace_at(tempBoard, index + game.width, 0)
          game = Map.replace(game, :board, tempBoard)
          dropdown(game, index + 1)
        else
          game = Map.replace(game, :board, generate_new_cell_no_match(game, index))
          dropdown(game, index + 1)
        end
      else
        dropdown(game, index + 1)
      end
    end
  end

  # Returns the game state with to_deletes filled out
  def check_board_for_matches(game, index) do
    IO.inspect("Checking board for matches")
    board_size = game.width * game.height
    if index >= board_size do
      IO.inspect("Done checking board for matches")
      game
    else
      index_x = rem(index, game.width)
      index_y = div(index, game.width)
      newGame = check_for_match(game, index_x, index_y)
      check_board_for_matches(newGame, index + 1)
    end
  end

  #Checks to see if the cell at x,y is at the center of
  #A match
  def check_for_match(game, x, y) do
    game = check_for_horizontal_match(game, x, y)
    game = check_for_vertical_match(game, x,y)
    game
  end

  # Checks to see if there is a horizontal_match with the cell
  # at x,y, in the center
  def check_for_horizontal_match(game, x, y) do
    if (x == 0) or (x == game.width - 1) do
      game
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
        game = Map.put(game, :to_delete, deletions)
        game
      else
        game
      end
    end
  end

  # Checks to see if there is a vertical_match with the cell
  # at x,y, in the center
  def check_for_vertical_match(game, x, y) do
    if (y == 0) or (y == game.height - 1) do
      game
    else
      index = (y * game.width) + x
      center_val = Enum.at(game.board, index)
      bottom_val = Enum.at(game.board, index - game.width)
      top_val = Enum.at(game.board, index + game.width)
      match = (center_val == top_val) and (center_val == bottom_val)
      #If we have a match, mark the tiles so we can delete them
      if match do
        deletions = game.to_delete ++ [index - game.width, index, index + game.width]
        deletions = Enum.uniq(deletions)
        game = Map.put(game, :to_delete, deletions)
        game
      else
        game
      end
    end
  end


end
