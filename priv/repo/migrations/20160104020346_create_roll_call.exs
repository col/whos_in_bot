defmodule Tbot.Repo.Migrations.CreateRollCall do
  use Ecto.Migration

  def change do
    create table(:roll_calls) do
      add :chat_id, :integer
      add :date, :integer
      add :status, :string

      timestamps
    end

  end
end
