defmodule Tbot.Repo.Migrations.CreateRollCallResponse do
  use Ecto.Migration

  def change do
    create table(:roll_call_responses) do
      add :status, :string
      add :name, :string
      add :user_id, :integer
      add :roll_call_id, references(:roll_calls, on_delete: :nothing)

      timestamps
    end
    create index(:roll_call_responses, [:roll_call_id])

  end
end
