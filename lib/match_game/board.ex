defmodule MatchGame.Board do
  def new() do
    Enum.map(1..64, fn _ -> :rand.uniform(5) end)
    |> find_and_replace_matches()
  end

  def rows(board) do
    Enum.chunk_every(board, 8)
  end

  def cols(board) do
    cols(board, [Enum.take_every(board, 8)])
  end

  def cols([_ | rest], acc) when length(acc) < 8 do
    cols(rest, acc ++ [Enum.take_every(rest, 8)])
  end

  def cols(_, acc) do
    acc
  end

  def from_cols(cols) do
    board = List.flatten(cols)
    from_cols(board, [Enum.take_every(board, 8)], 1)
  end

  def from_cols([_ | rest], acc, counter) when counter < 8 do
    from_cols(rest, acc ++ [Enum.take_every(rest, 8)], counter + 1)
  end

  def from_cols(_, acc, _) do
    acc
    |> List.flatten()
  end

  def matches([h | t]) do
    matches(t, h, 0, 1, 0, [])
  end

  def matches([], _, index, len, _, acc) do
    if len > 2 do
      [{index, len} | acc]
    else
      acc
    end
  end

  def matches([h | t], prev, index, len, counter, acc) when len > 2 do
    if prev == h do
      matches(t, h, index, len + 1, counter + 1, acc)
    else
      matches(t, h, counter + 1, 1, counter + 1, [{index, len} | acc])
    end
  end

  def matches([h | t], prev, index, len, counter, acc) do
    if prev == h do
      matches(t, h, index, len + 1, counter + 1, acc)
    else
      matches(t, h, counter + 1, 1, counter + 1, acc)
    end
  end

  def zero_list(list, {index, len}) when len > 0 do
    zero_list(List.replace_at(list, index, 0), {index + 1, len - 1})
  end

  def zero_list(list, _) do
    list
  end

  def replace_zeros(cols) do
    Enum.map(cols, fn col ->
      dropped = Enum.reject(col, fn x -> x == 0 end)
      to_add = 8 - length(dropped)

      if to_add > 0 do
        Enum.map(1..to_add, fn _ -> :rand.uniform(5) end) ++ dropped
      else
        dropped
      end
    end)
  end

  def zero_matches(list, [match | rest]) do
    zero_matches(zero_list(list, match), rest)
  end

  def zero_matches(list, []) do
    list
  end

  def contains_match(board) do
    col_matches =
      board
      |> cols
      |> Enum.map(fn col ->
        matches(col)
      end)
      |> List.flatten()
      |> length

    row_matches =
      board
      |> rows
      |> Enum.map(fn row ->
        matches(row)
      end)
      |> List.flatten()
      |> length

    col_matches + row_matches > 0
  end

  def find_and_replace_matches(board) do
    if contains_match(board) do
      new_board =
        board
        |> rows
        |> Enum.map(fn row ->
          list_of_matches = matches(row)
          zero_matches(row, list_of_matches)
        end)
        |> List.flatten()
        |> cols
        |> Enum.map(fn col ->
          list_of_matches = matches(col)
          zero_matches(col, list_of_matches)
        end)
        |> replace_zeros
        |> from_cols

      find_and_replace_matches(new_board)
    else
      board
    end
  end

  def swap(board, index_1, index_2)
      when index_2 in [index_1 + 1, index_1 - 1, index_1 + 8, index_1 - 8] and index_1 >= 0 and
             index_1 < 64 and index_2 >= 0 and index_2 < 64 do
    value_1 = Enum.at(board, index_1)
    value_2 = Enum.at(board, index_2)

    new_board =
      List.replace_at(board, index_1, value_2)
      |> List.replace_at(index_2, value_1)

    if contains_match(new_board) do
      find_and_replace_matches(new_board)
    else
      board
    end
  end

  def swap(board, _, _) do
    board
  end

  def compare_boards(prev, next) do
    compare_boards(prev, next, 0)
  end

  def compare_boards([h1 | t1], [h2 | t2], points) do
    if h1 == h2 do
      compare_boards(t1, t2, points)
    else
      compare_boards(t1, t2, points + 1)
    end
  end

  def compare_boards([], [], points) do
    points
  end
end
