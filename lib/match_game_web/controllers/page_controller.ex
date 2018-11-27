defmodule MatchGameWeb.PageController do
  use MatchGameWeb, :controller

  def index(conn, _params) do
    if user = conn.assigns[:current_user] do
      conn
      |> redirect(to: Routes.user_path(conn, :show, user))
    else
      render(conn, "index.html", state: get_flash(conn, :state))
    end
  end

  def new(conn, _) do
    conn
    |> redirect(to: Routes.page_path(conn, :game, Nanoid.generate(8)))
  end

  def game(conn, %{"game" => game_id}) do
    conn
    |> put_layout({MatchGameWeb.LayoutView, "game.html"})
    |> render("game.html", game_id: game_id)
  end

  def join(conn, %{"game" => game_id}) do
    if MatchGame.Store.game_exists?(game_id) do
      conn
      |> redirect(to: Routes.page_path(conn, :game, game_id))
    else
      conn
      |> put_flash(:state, :game_not_found)
      |> redirect(to: Routes.user_path(conn, :show, conn.assigns[:current_user]))
    end
  end
end
