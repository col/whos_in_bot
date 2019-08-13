import Config

config :whos_in_bot, :port, System.get_env("PORT", "8080") |> String.to_integer()

# Set log level from environment variable at runtime, defaulting to info.
config :logger, level: System.get_env("LOG_LEVEL", "info") |> String.to_atom()

# Configure your database
config :whos_in_bot,
       WhosInBot.Repo,
       url: System.fetch_env!("DATABASE_URL"),
       pool_size: 20

config :nadia, token: System.fetch_env!("BOT_TOKEN")