defmodule MatchGameWeb.Router do
  use MatchGameWeb, :router

  forward "/sent_emails", Bamboo.SentEmailViewerPlug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :authentication
    plug :put_token
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authorization do
    plug :auth
  end

  pipeline :accounts_layout do
    plug :put_layout, {MatchGameWeb.LayoutView, "accounts.html"}
  end

  scope "/", MatchGameWeb do
    pipe_through :browser

    get "/", PageController, :index

    get("/sign_up", UserController, :new)
    get("/log_in", UserController, :log_in)
    get("/log_out", UserController, :log_out)
    post("/verify", UserController, :verify)
    get("/verify/:token", UserController, :verify_email)
    resources "/users", UserController, only: [:create]

    pipe_through :authorization

    resources "/users", UserController, only: [:show, :create]

    # plug for auth to load user
    get("/game/new", PageController, :new)
    get("/game/:game", PageController, :game)
    post("/game", PageController, :join)

    resources "/results", ResultController
  end

  scope "/api", MatchGameWeb do
    pipe_through :api

    post("/fetchUsersById", UserController, :fetch_users)
  end

  defp put_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "salt", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end

  defp authentication(conn, _) do
    case(get_session(conn, :current_user)) do
      nil ->
        conn

      user_id ->
        conn
        |> assign(:current_user, MatchGame.Accounts.get_user!(user_id))
    end
  end

  defp auth(conn, _) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> redirect(to: "/")
      |> halt()
    end
  end
end
