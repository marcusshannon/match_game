defmodule MatchGame.Repo.Migrations.CreateUsersResults do
  use Ecto.Migration

  def change do
    create table(:users_results) do
      add :user_id, references(:users)
      add :result_id, references(:results)
      add :score, :integer

      timestamps()
    end
  end
end
