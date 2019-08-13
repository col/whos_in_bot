use Mix.Config

config :nadia, token: (System.get_env("BOT_TOKEN") || "")

config :whos_in_bot, ecto_repos: [WhosInBot.Repo]

import_config "#{Mix.env}.exs"
