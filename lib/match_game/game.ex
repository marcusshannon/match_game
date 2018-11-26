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

  def add_player(game, player_name) do
    Map.replace(game, :players, game.players ++ [player_name])
    game
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
    #Base case; we've been every where
    if index == size do
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
      # If we have a cell to our right, make it available for switching
      acceptable_indexs = acceptable_indexs ++ if rem(p1, game.width) < game.width - 1 do
        [p1 + 1]
      else
        []
      end
      #If we have a cell to our left, make it available for switching
      acceptable_indexs = acceptable_indexs ++ if rem(p1, game.width) > 0 do
        [p1 - 1]
      else
        []
      end

      # We've created a list of acceptable indexs to switch: is the
      #Desired index in it?
      if Enum.member?(acceptable_indexs, p2) do
        val1 = Enum.at(game.board, p1)
        val2 = Enum.at(game.board, p2)
        l1 = List.replace_at(game.board, p1, val2)
        l2 = List.replace_at(l1, p2, val1)
        game = Map.replace(game, :board, l2)
        #Only need to check for stability if the swap goes through
        check_for_stability(game, 1)
      #If we can't make the move, just return the game state
      else
        #TODO Possibly throw error?
        game
      end
    end
  end

  #Resolves as many falls as necesary
  #If turn based, advances the turns
  def check_for_stability(game, combo) do
    checkedGame = check_board_for_matches(game, 0)
    #If there are no more matches on the board, the state is stable
    is_stable = length(checkedGame.to_delete) == 0
    if not is_stable do
      #Replace all matches with 0s
      cleanGame = apply_deletions_loop(checkedGame, 0, combo)
      #Drops values onto 0s
      game = dropdown(cleanGame, 0)
      check_for_stability(game, combo + 1)
    else
      #TODO Player changes
      new_active_player = 0
      Map.replace(game, :active_player, new_active_player)
    end

  end

  #Generates a new cell at the index with no matches
  def generate_new_cell_no_match(game, index) do
    choices = [1, 2, 3, 4, 5]
    special_tiles = [6 , 7]
    #If we have a val to our left
    left_val = if rem(index, game.width) > 1 do
      Enum.at(game.board, index - 1)
    end
    #If we have a val below us
    bottom_val = Enum.at(game.board, index - game.width)

    #If the two in a row below us are the same, the third can't be that
    choices = if Enum.at(game.board, index - (2 * game.width)) == bottom_val do
      List.delete(choices, bottom_val)
    else
      choices
    end

    #Same for the two to our left
    choices = if Enum.at(game.board, index - 2) == left_val do
      List.delete(choices, left_val)
    else
      choices
    end

    newVal = if :rand.uniform(15) != 15 do
      Enum.random(choices)
    else
      Enum.random(special_tiles)
    end

    List.replace_at(game.board, index, newVal)

  end


  #Deletes all the cells we have to delete [ Fills them with 0s]
  def apply_deletions_loop(game, index, combo) do
    board_size = game.width * game.height
    if index >= board_size do
      game
    else
      if Enum.member?(game.to_delete, index) do
        #Replace the cell value with a 0, mark it for deletion
        game = Map.replace(game, :board, List.replace_at(game.board, index, 0))
        game = Map.replace(game, :to_delete, List.delete(game.to_delete, index))
        #Update the score for this player
        current_score = Enum.at(game.score, game.active_player)
        current_score = if current_score == nil do 0 else current_score end
        game = Map.replace(game, :score, List.replace_at(game.score, game.active_player, current_score + combo))
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
      #If this value is a 0, replace it
      if Enum.at(game.board, index) == 0 do
        #If we're not at the top, take the value from above you
        if (index + game.width < board_size) do
          upperVal = Enum.at(game.board, index + game.width)
          tempBoard = List.replace_at(game.board, index, upperVal)
          tempBoard = List.replace_at(tempBoard, index + game.width, 0)
          game = Map.replace(game, :board, tempBoard)
          dropdown(game, index + 1)
          #If we're at the top, just make a new value
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
    board_size = game.width * game.height
    if index >= board_size do
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


  def active_special_tile(game, x, y) do
    index = (y * game.width) + x
    val = Enum.at(game.board, index)
    if val == 6 do
      bomb_super_power(game, x, y)
    else
      if val == 7 do

      end
    end
  end

  #Explodes the 3x3 square around the bomb tile
  def bomb_super_power(game, x, y) do
    index = (y * game.width) + x
    deletions = [index, index + 1, index - 1]
    deletions = deletions ++ [index + game.width, index + game.width - 1, index + game.width + 1]
    deletions = deletions ++ [index - game.width, index - game.width - 1, index + game.width + 1]
    total_deletions = deletions ++ game.to_delete
    newGame = Map.put(game, :to_delete, total_deletions)
    check_for_stability(newGame, 1)
  end

  #Swap any two tiles, not necesarily adjacent
  def any_swap_super_power(game, p1, p2) do
    val1 = Enum.at(game.board, p1)
    val2 = Enum.at(game.board, p2)
    l1 = List.replace_at(game.board, p1, val2)
    l2 = List.replace_at(l1, p2, val1)
    game = Map.replace(game, :board, l2)

    check_for_stability(game, 1)
  end





end
