use Mix.Config

config :nadia, token: (System.get_env("BOT_TOKEN") || "")

config :whos_in_bot, ecto_repos: [WhosInBot.Repo]
config :whos_in_bot, port: 5000

import_config "#{Mix.env}.exs"
