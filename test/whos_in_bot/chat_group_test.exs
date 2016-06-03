defmodule WhosInBot.ChatGroupTest do
  use ExUnit.Case
  alias WhosInBot.ChatGroup
  alias Telegram.{Message, Entity, User, Chat}

  defp message(text, length) do
    %Message{text: text, chat: %Chat{id: 1}, from: %User{id: 1, first_name: "Fred"}}
      |> Message.set_entity(Entity.new("bot_command", 0, length))
      |> Message.process_entities
  end

  test "recovery from process crashing" do
    start_message = message("/start_roll_call", 16)
    ChatGroup.handle_message(start_message)

    in_message = message("/in", 3)
    ChatGroup.handle_message(in_message)

    Process.whereis(:"chat_id:1")
      |> Process.exit("Kill chat group process")
    :timer.sleep(5) #TODO: why does it crash sometimes without this?!?

    whos_in_message = message("/whos_in", 8)
    assert ChatGroup.handle_message(whos_in_message) == "1. Fred\n"
  end

end
