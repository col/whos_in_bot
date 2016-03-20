defmodule WhosInBot.Models.RollCallResponse do
  use Ecto.Schema
  import Ecto
  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2]

  schema "roll_call_responses" do
    field :status, :string
    field :name, :string
    field :user_id, :integer
    field :reason, :string
    belongs_to :roll_call, Tbot.RollCall

    timestamps
  end

  @required_fields ~w(status name)
  @optional_fields ~w(reason user_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def for_roll_call(query, roll_call) do
    from r in query,
    where: r.roll_call_id == ^roll_call.id
  end

  def with_status(query, status) do
    from r in query,
    where: r.status == ^status
  end

  def ordered(query, status) do
    from r in query,
    order_by: r.updated_at
  end

end
