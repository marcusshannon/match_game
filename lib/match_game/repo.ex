defmodule MatchGame.Repo do
  use Ecto.Repo,
    otp_app: :match_game,
    adapter: Ecto.Adapters.Postgres
end
