defmodule MatchGame.Email do
  import Bamboo.Email

  defp generate_code(user) do
    Phoenix.Token.sign(MatchGameWeb.Endpoint, "salt", user.id)
  end

  def verification_email(user) do
    new_email(
      to: user.email,
      from: "verification@match.com",
      subject: "Welcome to Match Game",
      html_body:
        "<a href='https://match.marcusshannon.com/verify/#{generate_code(user)}'>Click to verify</a>",
      text_body: "Thanks for joining!"
    )
  end
end
