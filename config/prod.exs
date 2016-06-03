use Mix.Config

config :whos_in_bot, bot_hub_node: "bot_hub@bothub"

config :whos_in_bot, :telegram_client, Telegram.Client

config :logger, level: :info
