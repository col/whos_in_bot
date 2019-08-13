use Mix.Config

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :whos_in_bot,
       WhosInBot.Repo,
       username: "postgres",
       password: "postgres",
       database: "whos_in_bot_dev",
       hostname: "localhost",
       port: 5432,
       pool_size: 10

if File.exists?("dev.secret.exs") do
  import_config "dev.secret.exs"
end
