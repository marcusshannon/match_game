defmodule MatchGame.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string, unique: true
    field :name, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :verified, :boolean

    many_to_many :results, MatchGame.Results.Result,
      join_through: MatchGame.UsersResults.UserResult

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
  end

  def create_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Comeonin.Bcrypt.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset
end
