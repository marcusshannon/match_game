defmodule MatchGame.UsersResults do
  import Ecto.Query, warn: false
  alias MatchGame.Repo

  alias MatchGame.UsersResults.UserResult

  def insert_user_result(user_id, result_id, score) do
    %UserResult{user_id: user_id, result_id: result_id, score: score}
    |> Repo.insert()
  end

  def get_scores(user_id) do
    Repo.all(
      from ur in UserResult,
        where: ur.user_id == ^user_id,
        preload: [result: [:winner]],
        order_by: ur.id
    )
  end
end
