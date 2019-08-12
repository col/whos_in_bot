defmodule WhosInBot.Models.RollCall do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2, order_by: 2]
  alias WhosInBot.Repo
  alias WhosInBot.Models.{RollCall, RollCallResponse}

  schema "roll_calls" do
    field :chat_id, :integer
    field :date, :integer
    field :status, :string
    field :title, :string
    field :quiet, :boolean, default: false
    has_many :responses, RollCallResponse

    timestamps()
  end

  @all_fields [:chat_id, :status, :date, :title, :quiet]
  @required_fields [:chat_id, :status]

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  def has_title?(roll_call) do
    roll_call.title != nil && String.length(roll_call.title) > 0
  end

  def roll_call_for_message(%{ chat: %{ id: chat_id } }) do
    Repo.all(from(r in WhosInBot.Models.RollCall, where: r.chat_id == ^chat_id and r.status == "open"))
    |> most_recent_roll_call
  end
  def roll_call_for_message(_), do: nil

  defp most_recent_roll_call([]), do: nil
  defp most_recent_roll_call([roll_call]) do
    Repo.preload(roll_call, :responses)
    roll_call
  end
  defp most_recent_roll_call([roll_call|t]) do
    Repo.update(changeset(roll_call, %{ status: "closed" }))
    most_recent_roll_call(t)
  end

  def create_roll_call(message) do
    changeset(%WhosInBot.Models.RollCall{}, %{
      chat_id: message.chat.id,
      status: "open",
      date: message.date,
      title: Enum.join(message.params, " ")
    }) |> Repo.insert!
  end

  def close_existing_roll_calls(message) do
    from(r in WhosInBot.Models.RollCall, where: r.status == "open", where: r.chat_id == ^message.chat.id)
      |> Repo.update_all(set: [status: "closed"])
  end


  def update_attendance(message, status) do
    case response_for_name(message) || response_for_user_id(message) do
      nil  -> Ecto.build_assoc(message.roll_call, :responses)
      response -> response
    end
    |> RollCallResponse.changeset(%{
      user_id: Map.get(message.from, :id),
      name: message.from.first_name,
      status: status,
      reason: Enum.join(message.params, " ")
      })
    |> Repo.insert_or_update
  end

  def response_for_name(message) do
    from(r in RollCallResponse, where: r.roll_call_id == ^message.roll_call.id and r.name == ^message.from.first_name)
    |> Repo.all
    |> List.first
  end

  def response_for_user_id(message) do
    Repo.get_by(RollCallResponse, %{ roll_call_id: message.roll_call.id, user_id: Map.get(message.from, :id, -1) })
  end

  def set_title(roll_call, title) do
    changeset(roll_call, %{title: title}) |> Repo.update!
  end

  def attendance_updated_message(roll_call = %{ quiet: true }, response) do
    num_in = RollCall.responses(roll_call, "in") |> Enum.count
    num_out = RollCall.responses(roll_call, "out") |> Enum.count
    num_maybe = RollCall.responses(roll_call, "maybe") |> Enum.count
    response = case response.status do
      "in" -> "#{response.name} is in!"
      "out" -> "#{response.name} is out!"
      "maybe" -> "#{response.name} might come."
    end
    "#{response}\nTotal: #{num_in} In, #{num_out} Out, #{num_maybe} Maybe\n"
  end

  def attendance_updated_message(roll_call, _) do
    whos_in_list(roll_call)
  end

  def whos_in_list(roll_call) do
    output = case has_title?(roll_call) do
      true -> [roll_call.title]
      _ -> []
    end

    in_list = in_response_list(roll_call)
    output = case String.length(in_list) > 0 do
      true -> output ++ [in_list]
      _ -> output
    end

    maybe_list = maybe_response_list(roll_call)
    output = case String.length(maybe_list) > 0 do
      true -> output ++ [maybe_list]
      _ -> output
    end

    out_list = out_response_list(roll_call)
    output = case String.length(out_list) > 0 do
      true -> output ++ [out_list]
      _ -> output
    end

    output = case Enum.count(responses(roll_call)) do
      0 -> output ++ ["No responses yet. 😢"]
      _ -> output
    end

    Enum.join(output, "\n")
  end

  def responses(roll_call) do
    RollCallResponse |> RollCallResponse.for_roll_call(roll_call) |> Repo.all
  end

  def responses(roll_call, status) do
    RollCallResponse |> RollCallResponse.for_roll_call(roll_call) |> RollCallResponse.with_status(status) |> order_by(:inserted_at) |> Repo.all
  end

  defp in_response_list(roll_call) do
    in_responses = RollCall.responses(roll_call, "in")
    case Enum.empty?(in_responses) do
      false ->
        Enum.with_index(in_responses)
        |> Enum.reduce("", fn({response, index}, acc) -> acc <> response_to_string("#{index+1}. ", response) end)
      _ -> ""
    end
  end

  defp out_response_list(roll_call) do
    out_responses = RollCall.responses(roll_call, "out")
    case Enum.empty?(out_responses) do
      false ->
        Enum.reduce(out_responses, "Out\n", fn(response, acc) -> acc <> response_to_string(" - ", response) end)
      _ -> ""
    end
  end

  defp maybe_response_list(roll_call) do
    maybe_responses = RollCall.responses(roll_call, "maybe")
    case Enum.empty?(maybe_responses) do
      false ->
        Enum.reduce(maybe_responses, "Maybe\n", fn(response, acc) -> acc <> response_to_string(" - ", response) end)
      _ -> ""
    end
  end

  defp response_to_string(prefix, response = %{reason: reason}) do
    if reason != nil && String.length(reason) > 0 do
      prefix <> "#{response.name} #{parenthesize_reason(reason)}\n"
    else
      prefix <> "#{response.name}\n"
    end
  end

  defp parenthesize_reason(reason) do
    case reason do
      "("<>_ ->
          reason
      _ ->
        "(#{reason})"
    end
  end

end
