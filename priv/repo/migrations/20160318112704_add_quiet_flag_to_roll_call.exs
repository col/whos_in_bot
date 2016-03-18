defmodule WhosInBot.Repo.Migrations.AddQuietFlagToRollCall do
  use Ecto.Migration

  def change do
    alter table(:roll_calls) do
      add :quiet, :boolean, default: false
    end
  end
end
