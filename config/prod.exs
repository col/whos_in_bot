use Mix.Config

# Do not print debug messages in production
config :logger, level: :info

# Configure your database
config :whos_in_bot, WhosInBot.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: {:system, "DATABASE_URL"},
  pool_size: 20

# Load the prod secrets if it exists. This can be used to load the Bot Token.
import_config "prod.secret.exs"
