defmodule WhosInBot.Repo.Migrations.ChangeChatIdToBigint do
  use Ecto.Migration

  def change do
    alter table(:roll_calls) do
      modify :chat_id, :bigint
    end
  end
end
