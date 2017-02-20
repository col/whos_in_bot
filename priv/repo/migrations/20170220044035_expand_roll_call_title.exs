defmodule WhosInBot.Repo.Migrations.ExpandRollCallTitle do
  use Ecto.Migration

  def change do
    alter table(:roll_calls) do
      modify :title, :text
    end
  end
end
