defmodule MatchGame.Repo.Migrations.CreateResults do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :winner_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:results, [:winner])
  end
end
