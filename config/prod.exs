use Mix.Config

config :logger, level: :warn

config :whos_in_bot,
       WhosInBot.Repo,
       username: System.fetch_env!("DB_USER"),
       password: System.fetch_env!("DB_PASSWORD"),
       database: System.fetch_env!("DB_NAME"),
       hostname: System.fetch_env!("DB_HOST"),
       port: System.fetch_env!("DB_PORT") |> String.to_integer(),
       ssl: System.get_env("DB_SSL", "false") |> String.to_existing_atom()

if File.exists?("prod.secret.exs") do
  import_config "prod.secret.exs"
end
