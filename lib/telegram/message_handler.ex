defmodule Telegram.MessageHandler do
  # import Tbot.Message
  # alias Tbot.RollCall
  #
  # def start_roll_call_command(message) do
  #   RollCall.close_existing_roll_calls(message)
  #   roll_call = RollCall.create_roll_call(message)
  #   if RollCall.has_title?(roll_call) do
  #     {:ok, "#{roll_call.title} roll call started"}
  #   else
  #     {:ok, "Roll call started"}
  #   end
  # end
  #
  # def end_roll_call_command(message) do
  #   RollCall.close_existing_roll_calls(message)
  #   if RollCall.has_title?(message.roll_call) do
  #     {:ok, "#{message.roll_call.title} roll call ended"}
  #   else
  #     {:ok, "Roll call ended"}
  #   end
  # end
  #
  # def in_command(message) do
  #   RollCall.update_attendance(message, "in")
  #   {:ok, RollCall.whos_in_list(message.roll_call)}
  # end
  #
  # def out_command(message) do
  #   RollCall.update_attendance(message, "out")
  #   {:ok, RollCall.whos_in_list(message.roll_call)}
  # end
  #
  # def maybe_command(message) do
  #   RollCall.update_attendance(message, "maybe")
  #   {:ok, RollCall.whos_in_list(message.roll_call)}
  # end
  #
  # def whos_in_command(message) do
  #   {:ok, RollCall.whos_in_list(message.roll_call)}
  # end
  #
  # def set_title_command(message) do
  #   title = Enum.join(message.params, " ")
  #   RollCall.set_title(message.roll_call, title)
  #   {:ok, "Roll call title set"}
  # end

  def handle_message(message) do
    # message = message
    # |> add_command
    # |> add_params
    # |> add_existing_roll_call
    #
    # if valid_command?(message) do
    #   if requires_roll_call?(message) && roll_call_not_found?(message) do
    #     {:ok, "No roll call in progress"}
    #   else
    #     execute_command(message)
    #   end
    # end
    {:ok, "No roll call in progress"}
  end

  # defp execute_command(message) do
  #   try do
  #     apply(Tbot.MessageHandler, message.command, [message])
  #   rescue UndefinedFunctionError ->
  #     {:error, "Unknown command: #{to_string(message.command)}"}
  #   end
  # end

end
