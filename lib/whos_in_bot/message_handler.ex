defmodule WhosInBot.MessageHandler do
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
    handle_response(message, roll_call, "in")
  end

  def handle_message(message = %{command: "/out"}, roll_call) do
    handle_response(message, roll_call, "out")
  end

  def handle_message(message = %{command: "/maybe"}, roll_call) do
    handle_response(message, roll_call, "maybe")
  end

  def handle_message(message = %{command: "/set_in_for"}, roll_call) do
    handle_response_for(message, roll_call, "in")
  end

  def handle_message(message = %{command: "/set_out_for"}, roll_call) do
    handle_response_for(message, roll_call, "out")
  end

  def handle_message(message = %{command: "/set_maybe_for"}, roll_call) do
    handle_response_for(message, roll_call, "maybe")
  end

  def handle_message(%{command: "/whos_in"}, roll_call) do
    {:ok, RollCall.whos_in(roll_call), roll_call}
  end

  def handle_message(message = %{command: "/set_title"}, roll_call) do
    roll_call = RollCall.set_title(roll_call, Enum.join(message.params, " "))
    {:ok, "Roll call title set", roll_call}
  end

  def handle_message(%{command: "/shh"}, roll_call) do
    {:ok, "Ok fine, I'll be quiet. 🤐", %{roll_call | quiet: true}}
  end

  def handle_message(%{command: "/louder"}, roll_call) do
    roll_call = %{roll_call | quiet: false}
    {:ok, "Sure. 😃\n#{RollCall.whos_in(roll_call)}", roll_call}
  end

  def handle_message(%{command: _}, roll_call) do
    {:error, "Not a bot command", roll_call}
  end

  defp handle_response(%{params: params, from: user}, roll_call, status) do
    reason = Enum.join(params, " ")
    response = Response.new(user.id, user.first_name, status, reason)
    roll_call = RollCall.add_response(roll_call, response)
    {:ok, RollCall.whos_in(roll_call, response), roll_call}
  end

  defp handle_response_for(message, roll_call, response_type) do
    {name, params} = Enum.split(message.params, 1)
    name = Enum.join(name, " ")
    reason = Enum.join(params, " ")
    handle_response_for(roll_call, response_type, name, reason)
  end

  defp handle_response_for(roll_call, _, "", _) do
    {:ok, "Please provide the persons first name.\n", roll_call}
  end

  defp handle_response_for(roll_call, response_type, name, reason) do
    roll_call = RollCall.add_response(roll_call, nil, name, response_type, reason)
    {:ok, RollCall.whos_in(roll_call), roll_call}
  end

  defp is_known_command(command) do
    Enum.member?(~w(/end_roll_call /in /out /maybe /whos_in /set_title /set_in_for /set_out_for /set_maybe_for /shh /louder), command)
  end
  
end
