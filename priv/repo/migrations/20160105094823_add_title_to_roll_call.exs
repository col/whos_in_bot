defmodule Tbot.Repo.Migrations.AddTitleToRollCall do
  use Ecto.Migration

  def change do
    alter table(:roll_calls) do
      add :title, :string
    end
  end
end
