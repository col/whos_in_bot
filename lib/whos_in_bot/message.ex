defmodule WhosInBot.Message do
  alias WhosInBot.Models.RollCall

  @valid_commands [
    :start_roll_call,
    :end_roll_call,
    :in,
    :out,
    :maybe,
    :whos_in,
    :set_title
  ]

  def add_command(message) do
    command = String.split(message.text) |> List.first |> String.slice(1..-1)
    if String.contains?(command, "@") do
      {command, _} = String.split(command, "@") |> List.to_tuple
    end

    Map.put(message, :command, String.to_atom(command))
  end

  def add_params(message) do
    params = String.split(message.text) |> List.delete_at(0)
    Map.put(message, :params, params)
  end

  def add_existing_roll_call(message) do
    roll_call = RollCall.roll_call_for_message(message)
    Map.put(message, :roll_call, roll_call)
  end

  def requires_roll_call?(message) do
    message.command != :start_roll_call
  end

  def roll_call_not_found?(message) do
    message.roll_call == nil
  end

  def valid_command?(message) do
    Enum.find(@valid_commands, fn x -> x == message.command end)
  end

end
