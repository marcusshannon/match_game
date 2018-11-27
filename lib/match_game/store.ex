defmodule MatchGame.Store do
  use GenServer

  def registry(id) do
    {:via, Registry, {MatchGame.Store.Registry, id}}
  end

  # Client

  def game_exists?(id) do
    case Registry.lookup(MatchGame.Store.Registry, id) do
      [] -> false
      _ -> true
    end
  end

  def new_game(id, state) do
    DynamicSupervisor.start_child(MatchGame.Store.Supervisor, %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [id, state]}
    })
  end

  def start_link(id, state) do
    GenServer.start_link(__MODULE__, state, name: registry(id))
  end

  def update(id, state) do
    GenServer.cast(registry(id), {:update, state})
  end

  def get(id) do
    GenServer.call(registry(id), :get)
  end

  def start_timer(id) do
    [{pid, _}] = Registry.lookup(MatchGame.Store.Registry, id)
    Process.send_after(pid, {:stop, id}, 120_000)
  end

  # Server 
  def init(map) do
    {:ok, map}
  end

  def handle_cast({:update, newState}, _) do
    {:noreply, newState}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:stop, id}, state) do
    IO.inspect(state)

    next_state =
      state
      |> MatchGame.Game.end_game()

    MatchGame.Game.log_game(next_state)

    MatchGameWeb.Endpoint.broadcast("game:" <> id, "update", next_state)
    {:noreply, next_state}
  end
end
