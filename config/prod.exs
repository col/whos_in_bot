use Mix.Config

config :logger, level: :warn

# Load the prod secrets if it exists. This can be used to load the Bot Token.
if File.exists?("dev.secret.exs") do
  import_config "prod.secret.exs"
end
