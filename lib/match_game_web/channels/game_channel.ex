defmodule MatchGameWeb.GameChannel do
  use Phoenix.Channel

  alias MatchGame.Game
  alias MatchGame.Store

  def join("game:" <> game_id, _, socket) do
    if Store.game_exists?(game_id) do
      socket =
        socket
        |> assign(:game_id, game_id)

      state = Store.get(game_id)

      cond do
        socket.assigns[:current_user] in state.players ->
          {:ok, state, socket}

        state.current_state == "LOBBY" ->
          new_state = Game.add_player(state, socket.assigns[:current_user])
          Store.update(game_id, new_state)
          send(self, :after_join)
          {:ok, state, socket}

        true ->
          {:error, %{reason: "unauthorized"}}
      end
    else
      state = Game.new(socket.assigns[:current_user])
      Store.new_game(game_id, state)

      socket =
        socket
        |> assign(:game_id, game_id)

      {:ok, state, socket}
    end
  end

  def handle_in("swap", %{"tile1" => tile1, "tile2" => tile2}, socket) do
    game_id = socket.assigns[:game_id]

    next_state =
      Store.get(game_id)
      |> Game.swap(tile1, tile2, socket.assigns[:current_user])

    Store.update(game_id, next_state)
    broadcast(socket, "update", next_state)
    {:reply, {:ok, next_state}, socket}
  end

  def handle_in("start", _, socket) do
    game_id = socket.assigns[:game_id]

    next_state =
      Store.get(game_id)
      |> Game.start_game()

    Store.start_timer(game_id)

    Store.update(game_id, next_state)
    broadcast(socket, "update", next_state)
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    state = Store.get(socket.assigns[:game_id])
    broadcast(socket, "update", state)
    {:noreply, socket}
  end

  def handle_info(:stop, socket) do
    game_id = socket.assigns[:game_id]

    next_state =
      Store.get(game_id)
      |> Game.end_game()

    Store.update(game_id, next_state)
    broadcast(socket, "update", next_state)
    {:noreply, socket}
  end
end
