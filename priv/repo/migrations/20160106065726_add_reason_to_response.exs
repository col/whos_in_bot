defmodule Tbot.Repo.Migrations.AddReasonToResponse do
  use Ecto.Migration

  def change do
    alter table(:roll_call_responses) do
      add :reason, :string
    end
  end

end
