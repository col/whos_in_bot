defmodule WhosInBot.Models.RollCall do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2]
  alias WhosInBot.Repo
  alias WhosInBot.Models.{RollCall, RollCallResponse}

  schema "roll_calls" do
    field :chat_id, :integer
    field :date, :integer
    field :status, :string
    field :title, :string
    field :quiet, :boolean, default: false
    has_many :responses, RollCallResponse

    timestamps
  end

  @required_fields ~w(chat_id status)
  @optional_fields ~w(date title quiet)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
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
      nil  -> Ecto.Model.build(message.roll_call, :responses)
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
    Repo.get_by(RollCallResponse, %{ roll_call_id: message.roll_call.id, name: message.from.first_name })
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
    # TODO: this could definitely do with a functional refactoring!
    output = []

    if has_title?(roll_call) do
      output = [roll_call.title]
    end

    in_list = in_response_list(roll_call)
    if String.length(in_list) > 0 do
      output = output ++ [in_list]
    end

    maybe_list = maybe_response_list(roll_call)
    if String.length(maybe_list) > 0 do
      output = output ++ [maybe_list]
    end

    out_list = out_response_list(roll_call)
    if String.length(out_list) > 0 do
      output = output ++ [out_list]
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
    RollCallResponse |> RollCallResponse.for_roll_call(roll_call) |> RollCallResponse.with_status(status) |> Repo.all
  end

  defp in_response_list(roll_call) do
    output = ""
    in_responses = RollCall.responses(roll_call, "in")
    unless Enum.empty?(in_responses) do
      output = Enum.with_index(in_responses)
      |> Enum.reduce("", fn({response, index}, acc) -> acc <> response_to_string("#{index+1}. ", response) end)
    end
    output
  end

  defp out_response_list(roll_call) do
    output = ""
    out_responses = RollCall.responses(roll_call, "out")
    unless Enum.empty?(out_responses) do
      output = output <> "Out\n"
      output = Enum.reduce(out_responses, output, fn(response, acc) -> acc <> response_to_string(" - ", response) end)
    end
    output
  end

  defp maybe_response_list(roll_call) do
    output = ""
    maybe_responses = RollCall.responses(roll_call, "maybe")
    unless Enum.empty?(maybe_responses) do
      output = output <> "Maybe\n"
      output = Enum.reduce(maybe_responses, output, fn(response, acc) -> acc <> response_to_string(" - ", response) end)
    end
    output
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
