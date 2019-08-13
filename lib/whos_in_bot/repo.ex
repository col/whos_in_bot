defmodule WhosInBot.Repo do
  use Ecto.Repo,
      otp_app: :whos_in_bot,
      adapter: Ecto.Adapters.Postgres
end
