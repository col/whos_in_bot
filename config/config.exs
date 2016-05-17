use Mix.Config

config :whos_in_bot, bot_hub_node: "bot_hub@bothub"

config :nadia, token: (System.get_env("WHOS_IN_BOT_TOKEN") || "")

import_config "#{Mix.env}.exs"
