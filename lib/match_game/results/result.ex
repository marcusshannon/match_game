defmodule MatchGame.Results.Result do
  use Ecto.Schema
  import Ecto.Changeset

  schema "results" do
    belongs_to(:winner, MatchGame.Accounts.User)
    many_to_many :users, MatchGame.Accounts.User, join_through: MatchGame.UsersResults.UserResult

    timestamps()
  end

  @doc false
  def changeset(result, attrs) do
    result
    |> cast(attrs, [:winner])
    |> validate_required([:winner])
  end
end
