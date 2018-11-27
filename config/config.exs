# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :match_game,
  ecto_repos: [MatchGame.Repo]

# Configures the endpoint
config :match_game, MatchGameWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QUuCashK0IXIyha+xTGPX4tZQANj3L4heFWfjWwv6btINJ60JTMPxjM8rvHf7Zn6",
  render_errors: [view: MatchGameWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MatchGame.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :match_game, MatchGame.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: "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"
