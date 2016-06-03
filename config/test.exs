use Mix.Config

config :whos_in_bot, bot_hub_node: "bot_hub@127.0.0.1"

config :whos_in_bot, :telegram_client, Telegram.MockClient

config :logger, level: :info
