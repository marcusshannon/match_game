defmodule MatchGameWeb.UserView do
  use MatchGameWeb, :view

  def render("index.json", %{users: users}) do
    Enum.reduce(users, %{}, fn user, acc ->
      Map.put(acc, user.id, render(MatchGameWeb.UserView, "user.json", user: user))
    end)
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      name: user.name
    }
  end
end
