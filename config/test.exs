use Mix.Config

config :logger, level: :warn

config :whos_in_bot,
       WhosInBot.Repo,
       username: "postgres",
       password: "postgres",
       database: "whos_in_bot_test",
       hostname: "localhost",
       port: 5432,
       pool: Ecto.Adapters.SQL.Sandbox