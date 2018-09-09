defmodule WhosInBot.Message do
  alias WhosInBot.Models.RollCall

  def is_known_command(command) do
    Enum.member?(~w(end_roll_call in out maybe whos_in set_title set_in_for set_out_for set_maybe_for shh louder), command)
  end

  def add_command(message = %{ text: "/" }) do
    Map.put(message, :command, nil)
  end
  def add_command(message = %{ text: "/"<>command }) do
    command = String.split(command) |> List.first
    command = case String.contains?(command, "@") do
      true -> String.split(command, "@") |> List.first
      _ -> command
    end
    Map.put(message, :command, command)
  end
  def add_command(message) do
    Map.put(message, :command, nil)
  end

  def add_params(message = %{ text: text }) do
    params = String.split(text) |> List.delete_at(0)
    Map.put(message, :params, params)
  end
  def add_params(message), do: message

  def add_existing_roll_call(message) do
    roll_call = RollCall.roll_call_for_message(message)
    Map.put(message, :roll_call, roll_call)
  end

  def requires_roll_call?(%{ command: command }), do: command != "start_roll_call"
  def requires_roll_call?(_), do: false

  def roll_call_not_found?(message) do
    message.roll_call == nil
  end

end
