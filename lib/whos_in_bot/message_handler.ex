defmodule WhosInBot.MessageHandler do
  import WhosInBot.Message
  alias WhosInBot.Models.RollCall
  alias WhosInBot.Repo

  def handle_message(message) do
    message
    |> add_command
    |> add_params
    |> add_existing_roll_call
    |> execute_command
  end

  defp execute_command(%{ command: nil }) do
    {:error, "Not a bot command"}
  end

  defp execute_command(message = %{ command: "start_roll_call" }) do
    RollCall.close_existing_roll_calls(message)
    RollCall.create_roll_call(message)
    {:ok, "Roll call started"}
  end

  defp execute_command(%{ command: command, roll_call: nil }) do
    case is_known_command(command) do
      true -> {:ok, "No roll call in progress"}
      false -> {:error, "Unknown command"}
    end
  end

  defp execute_command(message = %{ command: "end_roll_call" }) do
    RollCall.close_existing_roll_calls(message)
    {:ok, "Roll call ended"}
  end

  defp execute_command(message = %{ command: "in" }) do
    {:ok, roll_call_response} = RollCall.update_attendance(message, "in")
    {:ok, RollCall.attendance_updated_message(message.roll_call, roll_call_response)}
  end

  defp execute_command(message = %{ command: "out" }) do
    {:ok, roll_call_response} = RollCall.update_attendance(message, "out")
    {:ok, RollCall.attendance_updated_message(message.roll_call, roll_call_response)}
  end

  defp execute_command(message = %{ command: "maybe" }) do
    {:ok, roll_call_response} = RollCall.update_attendance(message, "maybe")
    {:ok, RollCall.attendance_updated_message(message.roll_call, roll_call_response)}
  end

  defp execute_command(message = %{ command: "whos_in"}) do
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end

  defp execute_command(message = %{ command: "set_title" }) do
    title = Enum.join(message.params, " ")
    RollCall.set_title(message.roll_call, title)
    {:ok, "Roll call title set"}
  end

  defp execute_command(%{ command: "set_in_for", params: [] }) do
    {:ok, "Please provide the persons first name.\n"}
  end

  defp execute_command(message = %{ command: "set_in_for" }) do
    set_state_for(message, "in")
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end

  defp execute_command(%{ command: "set_out_for", params: [] }) do
    {:ok, "Please provide the persons first name.\n"}
  end

  defp execute_command(message = %{ command: "set_out_for" }) do
    set_state_for(message, "out")
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end

  defp execute_command(%{ command: "set_maybe_for", params: [] }) do
    {:ok, "Please provide the persons first name.\n"}
  end

  defp execute_command(message = %{ command: "set_maybe_for" }) do
    set_state_for(message, "maybe")
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end

  defp execute_command(message = %{ command: "shh" }) do
    changeset = RollCall.changeset(message.roll_call, %{ quiet: true })
    case Repo.update(changeset) do
      {:ok, _} -> {:ok, "Ok fine, I'll be quiet. 🤐"}
      {:error, _} -> {:ok, "I'm sorry Dave, I'm afraid I can't do that."}
    end
  end

  defp execute_command(message = %{ command: "louder" }) do
    changeset = RollCall.changeset(message.roll_call, %{ quiet: false })
    case Repo.update(changeset) do
      {:ok, _} -> {:ok, "Sure. 😃\n"<>RollCall.whos_in_list(message.roll_call)}
      {:error, _} -> {:ok, "I'm sorry Dave, I'm afraid I can't do that."}
    end
  end

  defp execute_command(_) do
    {:error, "Unknown command"}
  end

  defp set_state_for(message, status) do
    message = message
      |> Map.put(:from, %{ first_name: List.first(message.params) })
      |> Map.put(:params, List.delete_at(message.params, 0))
    RollCall.update_attendance(message, status)
  end

end
