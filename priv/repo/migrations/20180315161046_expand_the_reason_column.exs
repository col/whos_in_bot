defmodule WhosInBot.Repo.Migrations.ExpandTheReasonColumn do
  use Ecto.Migration

  def change do
    alter table(:roll_call_responses) do
      modify :reason, :text
    end
  end
end
