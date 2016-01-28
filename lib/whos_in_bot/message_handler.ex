defmodule WhosInBot.MessageHandler do
  import WhosInBot.Message
  alias WhosInBot.Models.RollCall

  def handle_message(message) do
    message
    |> add_command
    |> add_params
    |> add_existing_roll_call
    |> execute_command
  end

  defp execute_command(message = %{ command: "/start_roll_call" }) do
    RollCall.close_existing_roll_calls(message)
    RollCall.create_roll_call(message)
    {:ok, "Roll call started"}
  end

  defp execute_command(message = %{ command: "/end_roll_call", roll_call: roll_call })
  when roll_call != nil do
    RollCall.close_existing_roll_calls(message)
    {:ok, "Roll call ended"}
  end
  defp execute_command(%{ command: "/end_roll_call" }) do
    {:ok, "No roll call in progress"}
  end

  defp execute_command(message = %{ command: "/in", roll_call: roll_call })
  when roll_call != nil do
    RollCall.update_attendance(message, "in")
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end
  defp execute_command(%{ command: "/in" }) do
    {:ok, "No roll call in progress"}
  end

  defp execute_command(message = %{ command: "/out", roll_call: roll_call })
  when roll_call != nil do
    RollCall.update_attendance(message, "out")
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end
  defp execute_command(%{ command: "/out" }) do
    {:ok, "No roll call in progress"}
  end

  defp execute_command(message = %{ command: "/maybe", roll_call: roll_call })
  when roll_call != nil do
    RollCall.update_attendance(message, "maybe")
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end
  defp execute_command(%{ command: "/maybe" }) do
    {:ok, "No roll call in progress"}
  end

  defp execute_command(message = %{ command: "/whos_in", roll_call: roll_call })
  when roll_call != nil do
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end
  defp execute_command(%{ command: "/whos_in" }) do
    {:ok, "No roll call in progress"}
  end

  defp execute_command(message = %{ command: "/set_title", roll_call: roll_call })
  when roll_call != nil do
    title = Enum.join(message.params, " ")
    RollCall.set_title(message.roll_call, title)
    {:ok, "Roll call title set"}
  end
  defp execute_command(%{ command: "/set_title" }) do
    {:ok, "No roll call in progress"}
  end

  defp execute_command(_) do
    {:error, "Unknown command"}
  end

end
