defmodule MatchGameWeb.UserController do
  use MatchGameWeb, :controller

  alias MatchGame.Accounts
  alias MatchGame.Accounts.User
  alias MatchGame.Email
  alias MatchGame.Mailer

  plug :put_layout, {MatchGameWeb.LayoutView, "accounts.html"}

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def fetch_users(conn, %{"players" => ids}) do
    users = Accounts.fetch_users(ids)
    render(conn, "index.json", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "sign_up.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Email.verification_email(user) |> Mailer.deliver_later()

        conn
        |> put_flash(:state, :account_created)
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "sign_up.html", changeset: changeset)
    end
  end

  def log_in(conn, _params) do
    render(conn, "log_in.html", action: Routes.user_path(conn, :verify))
  end

  def log_out(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def verify(conn, %{"user" => user_params}) do
    case Accounts.get_user_by_email(user_params)
         |> Comeonin.Bcrypt.check_pass(user_params["password"]) do
      {:ok, user} ->
        if user.verified do
          conn
          |> put_session(:current_user, user.id)
          |> redirect(to: Routes.user_path(conn, :show, user))
        else
          conn
          |> render("log_in.html", state: :unverified)
        end

      {:error, _} ->
        conn
        |> render("log_in.html", state: :error)
    end
  end

  def verify_email(conn, %{"token" => token}) do
    {:ok, id} = Phoenix.Token.verify(MatchGameWeb.Endpoint, "salt", token, max_age: :infinity)
    Accounts.verify_user(id)

    conn
    |> put_flash(:info, "Email verified, you may log in now")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    results = MatchGame.UsersResults.get_scores(user.id)

    render(conn, "show.html", user: user, state: get_flash(conn, :state), results: results)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
