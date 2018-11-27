defmodule MatchGame.UsersResults.UserResult do
  use Ecto.Schema

  @primary_key false
  schema "users_results" do
    belongs_to :user, MatchGame.Accounts.User
    belongs_to :result, MatchGame.Results.Result
    field :score, :integer
    timestamps()
  end
end
