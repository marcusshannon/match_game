# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MatchGame.Repo.insert!(%MatchGame.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

MatchGame.Repo.insert!(%MatchGame.Accounts.User{
  email: "mpshannon@me.com",
  name: "Marcus Shannon",
  password_hash: "$2b$12$3WjF8iU76Y14WhFJUC5xVuFUp1Ik3EFCk2dGEZQyOMFCNaHqUFMn6",
  verified: true
})

MatchGame.Repo.insert!(%MatchGame.Results.Result{
  winner: 1
})

MatchGame.Repo.insert!(%MatchGame.UsersResults.UserResult{
  user_id: 1,
  result_id: 1,
  score: 500
})
