defmodule WhosInBot.MessageHandler do
  import WhosInBot.Message
  alias WhosInBot.Models.RollCall

  def execute_command(:start_roll_call, message) do
    RollCall.close_existing_roll_calls(message)
    roll_call = RollCall.create_roll_call(message)
    if RollCall.has_title?(roll_call) do
      {:ok, "#{roll_call.title} roll call started"}
    else
      {:ok, "Roll call started"}
    end
  end

  def execute_command(:end_roll_call, message) do
    RollCall.close_existing_roll_calls(message)
    if RollCall.has_title?(message.roll_call) do
      {:ok, "#{message.roll_call.title} roll call ended"}
    else
      {:ok, "Roll call ended"}
    end
  end

  def execute_command(:in, message) do
    RollCall.update_attendance(message, "in")
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end

  def execute_command(:out, message) do
    RollCall.update_attendance(message, "out")
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end

  def execute_command(:maybe, message) do
    RollCall.update_attendance(message, "maybe")
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end

  def execute_command(:whos_in, message) do
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end

  def execute_command(:set_title, message) do
    title = Enum.join(message.params, " ")
    RollCall.set_title(message.roll_call, title)
    {:ok, "Roll call title set"}
  end

  def execute_command(_, _) do
    # unknown command
    {:ok, nil}
  end

  def handle_message(message) do
    message
    |> add_command
    |> add_params
    |> add_existing_roll_call
    |> execute_command
  end

  defp execute_command(message) do
    if requires_roll_call?(message) && roll_call_not_found?(message) do
      {:ok, "No roll call in progress"}
    else
      execute_command(message.command, message)
    end
  end

end
