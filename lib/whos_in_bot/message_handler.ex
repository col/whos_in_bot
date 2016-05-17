defmodule WhosInBot.MessageHandler do
  # alias Telegram.Message
  alias WhosInBot.Models.{RollCall, Response}

  def handle_message(message = %{command: "/start_roll_call"}, _) do
    roll_call = RollCall.new(message.chat.id, Enum.join(message.params, " "))
    {:ok, "Roll call started", roll_call}
  end

  def handle_message(%{command: command}, nil) do
    case is_known_command(command) do
      true -> {:ok, "No roll call in progress", nil}
      false -> {:error, "Not a bot command", nil}
    end
  end

  def handle_message(%{command: "/end_roll_call"}, _) do
    {:ok, "Roll call ended", nil}
  end

  def handle_message(message = %{command: "/in"}, roll_call) do
    reason = Enum.join(message.params, " ")
    roll_call = RollCall.set_in(roll_call, message.from, reason)
    {:ok, RollCall.whos_in(roll_call), roll_call}
  end

  def handle_message(message = %{command: "/out"}, roll_call) do
    reason = Enum.join(message.params, " ")
    roll_call = RollCall.set_out(roll_call, message.from, reason)
    {:ok, RollCall.whos_in(roll_call), roll_call}
  end

  def handle_message(%{command: _}, roll_call) do
    {:error, "Not a bot command", roll_call}
  end

  # def handle_message(%{ command: command, roll_call: nil }) do
  #   case is_known_command(command) do
  #     true -> {:ok, "No roll call in progress"}
  #     false -> {:error, "Unknown command"}
  #   end
  # end

  # def handle_message(message = %{ command: "end_roll_call" }) do
  #   RollCall.close_existing_roll_calls(message)
  #   {:ok, "Roll call ended"}
  # end
  #
  # def handle_message(message = %{ command: "in" }) do
  #   {:ok, roll_call_response} = RollCall.update_attendance(message, "in")
  #   {:ok, RollCall.attendance_updated_message(message.roll_call, roll_call_response)}
  # end
  #
  # def handle_message(message = %{ command: "out" }) do
  #   {:ok, roll_call_response} = RollCall.update_attendance(message, "out")
  #   {:ok, RollCall.attendance_updated_message(message.roll_call, roll_call_response)}
  # end
  #
  # def handle_message(message = %{ command: "maybe" }) do
  #   {:ok, roll_call_response} = RollCall.update_attendance(message, "maybe")
  #   {:ok, RollCall.attendance_updated_message(message.roll_call, roll_call_response)}
  # end
  #
  # def handle_message(message = %{ command: "whos_in"}) do
  #   {:ok, RollCall.whos_in_list(message.roll_call)}
  # end
  #
  # def handle_message(message = %{ command: "set_title" }) do
  #   title = Enum.join(message.params, " ")
  #   RollCall.set_title(message.roll_call, title)
  #   {:ok, "Roll call title set"}
  # end
  #
  # def handle_message(%{ command: "set_in_for", params: [] }) do
  #   {:ok, "Please provide the persons first name.\n"}
  # end
  #
  # def handle_message(message = %{ command: "set_in_for" }) do
  #   set_state_for(message, "in")
  #   {:ok, RollCall.whos_in_list(message.roll_call)}
  # end
  #
  # def handle_message(%{ command: "set_out_for", params: [] }) do
  #   {:ok, "Please provide the persons first name.\n"}
  # end
  #
  # def handle_message(message = %{ command: "set_out_for" }) do
  #   set_state_for(message, "out")
  #   {:ok, RollCall.whos_in_list(message.roll_call)}
  # end
  #
  # def handle_message(%{ command: "set_maybe_for", params: [] }) do
  #   {:ok, "Please provide the persons first name.\n"}
  # end
  #
  # def handle_message(message = %{ command: "set_maybe_for" }) do
  #   set_state_for(message, "maybe")
  #   {:ok, RollCall.whos_in_list(message.roll_call)}
  # end
  #
  # def handle_message(message = %{ command: "shh" }) do
  #   changeset = RollCall.changeset(message.roll_call, %{ quiet: true })
  #   case Repo.update(changeset) do
  #     {:ok, _} -> {:ok, "Ok fine, I'll be quiet. 🤐"}
  #     {:error, _} -> {:ok, "I'm sorry Dave, I'm afraid I can't do that."}
  #   end
  # end
  #
  # def handle_message(message = %{ command: "louder" }) do
  #   changeset = RollCall.changeset(message.roll_call, %{ quiet: false })
  #   case Repo.update(changeset) do
  #     {:ok, _} -> {:ok, "Sure. 😃\n"<>RollCall.whos_in_list(message.roll_call)}
  #     {:error, _} -> {:ok, "I'm sorry Dave, I'm afraid I can't do that."}
  #   end
  # end
  #
  # def handle_message(_) do
  #   {:error, "Unknown command"}
  # end
  #
  # defp set_state_for(message, status) do
  #   message = message
  #     |> Map.put(:from, %{ first_name: List.first(message.params) })
  #     |> Map.put(:params, List.delete_at(message.params, 0))
  #   RollCall.update_attendance(message, status)
  # end

  defp is_known_command(command) do
    Enum.member?(~w(/end_roll_call /in /out /maybe /whos_in /set_title /set_in_for /set_out_for /set_maybe_for /shh /louder), command)
  end

end
