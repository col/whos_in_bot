defmodule WhosInBot.MessageHandlerTest do
  use ExUnit.Case
  alias WhosInBot.MessageHandler
  alias WhosInBot.Models.{RollCall, Response}
  alias Telegram.{Message, Chat, User, Entity}

  @chat %Chat{id: 123}
  @from %User{first_name: "Fred", id: 456}
  @message %Message{chat: @chat, from: @from, date: 1451868542}

  defp message(params) do
    Map.merge(@message, params)
  end

  defp message(text, length) do
    Map.put(@message, :text, text)
      |> Message.set_entity(Entity.new("bot_command", 0, length))
      |> Message.process_entities
  end

  setup config do
    if config[:sample_responses] do
      roll_call = RollCall.new(@chat.id, "")
      response1 = %Response{status: "in", user_id: 1, name: "User 1"}
      response2 = %Response{status: "out", user_id: 2, name: "User 2"}
      response3 = %Response{status: "maybe", user_id: 3, name: "User 3"}
      roll_call = %{roll_call | responses: [response1, response2, response3]}
      {:ok, roll_call: roll_call}
    else
      :ok
    end
  end

  test "does not respond to normal chat messages" do
    message = message(%{text: "Hey, what's up guys?"})
    assert {:error, "Not a bot command", nil} = MessageHandler.handle_message(message, nil)
    assert {:error, "Not a bot command", %RollCall{}} = MessageHandler.handle_message(message, %RollCall{})
  end

  test "doesn't crash when there is no :text attribute in the message" do
    message = message(%{})
    assert {:error, "Not a bot command", nil} = MessageHandler.handle_message(message, nil)
    assert {:error, "Not a bot command", %RollCall{}} = MessageHandler.handle_message(message, %RollCall{})
  end

  test "doesn't crash when just a '/' in the message" do
    message = message(%{text: "/"})
    assert {:error, "Not a bot command", nil} = MessageHandler.handle_message(message, nil)
    assert {:error, "Not a bot command", %RollCall{}} = MessageHandler.handle_message(message, %RollCall{})
  end

  test "doesn't respond to unknown commands" do
    message = message("/some_unknown_command", 21)
    assert {:error, "Not a bot command", nil} = MessageHandler.handle_message(message, nil)
    assert {:error, "Not a bot command", %RollCall{}} = MessageHandler.handle_message(message, %RollCall{})
  end


  test "/start_roll_call responds with 'Roll Call Started'" do
    message = message("/start_roll_call", 16)
    {:ok, response, _} = MessageHandler.handle_message(message, nil)
    assert response == "Roll call started"
  end

  test "handles messages when they contain the name of the bot" do
    message = message("/start_roll_call@BotName", 16)
    {:ok, response, _} = MessageHandler.handle_message(message, nil)
    assert response == "Roll call started"
  end

  test "handles messages when they contain multiple @ in the bot name (Prod Bug)" do
    message = message("/start_roll_call@Bot@Name", 16)
    {:ok, response, _} = MessageHandler.handle_message(message, nil)
    assert response == "Roll call started"
  end

  test "/start_roll_call creates a new RollCall" do
    message = message("/start_roll_call", 16)
    {:ok, _, roll_call} = MessageHandler.handle_message(message, nil)
    assert roll_call == RollCall.new(@chat.id, "")
  end

  test "'/start_roll_call Monday Night Football' creates a new RollCall with a title" do
    message = message("/start_roll_call Monday Night Football", 16)
    {:ok, response, roll_call} = MessageHandler.handle_message(message, nil)
    assert response == "Roll call started"
    assert roll_call == RollCall.new(@chat.id, "Monday Night Football")
  end


  test "/end_roll_call responds with 'Roll call ended'" do
    message = message("/end_roll_call", 14)
    {:ok, response, _} = MessageHandler.handle_message(message, %RollCall{})
    assert response == "Roll call ended"
  end

  test "/end_roll_call closes the existing roll call" do
    message = message("/end_roll_call", 14)
    {:ok, _, roll_call} = MessageHandler.handle_message(message, %RollCall{})
    assert roll_call == nil
  end

  test "/end_roll_call responds with an error message when no active roll call exists" do
    message = message("/end_roll_call", 14)
    {:ok, response, roll_call} = MessageHandler.handle_message(message, nil)
    assert response == "No roll call in progress"
    assert roll_call == nil
  end


  test "/in responds with with who's in list" do
    message = message("/in", 3)
    {:ok, response, _} = MessageHandler.handle_message(message, %RollCall{})
    assert response == "1. Fred\n"
  end

  test "/in records the users response" do
    message = message("/in", 3)
    {:ok, _, roll_call} = MessageHandler.handle_message(message, %RollCall{})
    assert roll_call.responses == [Response.new(456, "Fred", "in")]
  end

  test "/in updates an existing response" do
    roll_call = RollCall.new(@chat.id, "") |> RollCall.add_response(@from, "out")
    message = message("/in", 3)
    {:ok, _, roll_call} = MessageHandler.handle_message(message, roll_call)
    assert roll_call.responses == [Response.new(456, "Fred", "in")]
  end

  # TODO: quiet mode
  # test "/in responds with minimal info when in quiet mode" do
  #   roll_call = RollCall.new(@chat.id, "")
  #     |> RollCall.set_in(User.new(6, "User 1"))
  #     |> RollCall.set_out(User.new(7, "User 2"))
  #   message = message("/in", 3)
  #   {:ok, response, roll_call} = MessageHandler.handle_message(message, roll_call)
  #   assert response == "Fred is in!\nTotal: 2 In, 1 Out, 0 Maybe\n"
  # end

  test "/in responds with reason" do
    message = message("/in plus 1", 3)
    {:ok, response, _} = MessageHandler.handle_message(message, %RollCall{})
    assert response == "1. Fred (plus 1)\n"
  end

  test "/in|out|maybe doesn't add () if the reason already has them" do
    message = message("/in (plus 1)", 3)
    {:ok, response, _} = MessageHandler.handle_message(message, %RollCall{})
    assert response == "1. Fred (plus 1)\n"
  end

  test "/in responds with an error message when no active roll call exists" do
    message = message("/in", 3)
    {:ok, response, _} = MessageHandler.handle_message(message, nil)
    assert response == "No roll call in progress"
  end


  test "/out responds correctly" do
    {:ok, response, _} = MessageHandler.handle_message(message("/out", 4), %RollCall{})
    assert response == "Out\n - Fred\n"
  end

  test "/out records the users response" do
    {:ok, _, roll_call} = MessageHandler.handle_message(message("/out", 4), %RollCall{})
    assert roll_call.responses == [Response.new(@from.id, @from.first_name, "out")]
  end

  test "/out updates an existing response" do
    roll_call = RollCall.new(@chat.id, "") |> RollCall.add_response(@from, "in")
    {:ok, _, roll_call} = MessageHandler.handle_message(message("/out", 4), roll_call)
    assert roll_call.responses == [Response.new(@from.id, @from.first_name, "out")]
  end

  # TODO: quiet mode
  # @tag sample_responses: true
  # test "/out responds with minimal info when in quiet mode", %{ roll_call: roll_call } do
  #   RollCall.changeset(roll_call, %{ quiet: true }) |> Repo.update!
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/out"}))
  #   assert {status, response} == {:ok, "Fred is out!\nTotal: 1 In, 2 Out, 1 Maybe\n"}
  # end

  test "/out includes the reason in the response when it's provided" do
    {:ok, response, roll_call} = MessageHandler.handle_message(message("/out Injured", 4), %RollCall{})
    assert response == "Out\n - Fred (Injured)\n"
    assert roll_call.responses == [Response.new(@from.id, @from.first_name, "out", "Injured")]
  end

  test "/out responds with an error message when no active roll call exists" do
    {:ok, response, _} = MessageHandler.handle_message(message("/out", 4), nil)
    assert response == "No roll call in progress"
  end


  test "/maybe responds correctly" do
    {:ok, response, _} = MessageHandler.handle_message(message("/maybe", 6), %RollCall{})
    assert response == "Maybe\n - Fred\n"
  end

  test "/maybe records the users response" do
    {:ok, _, roll_call} = MessageHandler.handle_message(message("/maybe", 6), %RollCall{})
    assert roll_call.responses == [Response.new(@from.id, @from.first_name, "maybe")]
  end

  # TODO: quiet mode
  # @tag roll_call_open: true, sample_responses: true
  # test "/maybe responds with minimal info when out quiet mode", %{ roll_call: roll_call } do
  #   RollCall.changeset(roll_call, %{ quiet: true }) |> Repo.update!
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/maybe"}))
  #   assert {status, response} == {:ok, "Fred might come.\nTotal: 1 In, 1 Out, 2 Maybe\n"}
  # end

  test "'/maybe Injured' includes the reason in the response when it's provided" do
    {:ok, response, _} = MessageHandler.handle_message(message("/maybe Injured", 6), %RollCall{})
    assert response == "Maybe\n - Fred (Injured)\n"
  end

  test "'/maybe Injured' records the users response and the reason" do
    {:ok, _, roll_call} = MessageHandler.handle_message(message("/maybe Injured", 6), %RollCall{})
    assert roll_call.responses == [Response.new(@from.id, @from.first_name, "maybe", "Injured")]
  end

  test "/maybe responds with an error message when no active roll call exists" do
    {:ok, response, _} = MessageHandler.handle_message(message("/maybe", 6), nil)
    assert response == "No roll call in progress"
  end


  # @tag :roll_call_open
  # test "'/maybe Injured' records the users response and the reason", %{ roll_call: roll_call } do
  #   MessageHandler.handle_message(message(%{text: "/maybe Injured"}))
  #   response = Repo.get_by!(RollCallResponse, %{status: "maybe", user_id: @from.id, name: @from.first_name})
  #   assert response.roll_call_id == roll_call.id
  #   assert response.reason == "Injured"
  # end
  #
  # @tag :roll_call_open
  # test "/maybe updates an existing response", %{ roll_call: roll_call } do
  #   Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: @from.id, name: @from.first_name})
  #   MessageHandler.handle_message(message(%{text: "/maybe"}))
  #   assert Repo.one!(RollCallResponse).status == "maybe"
  # end
  #
  #
  # @tag :roll_call_open
  # test "'/set_in_for OtherUser' records a response for a different user" do
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/set_in_for OtherUser Fred's Friend"}))
  #   record = Repo.one!(RollCallResponse)
  #   assert record.status == "in"
  #   assert record.name == "OtherUser"
  #   assert record.user_id == nil
  #   assert {status, response} == {:ok, "1. OtherUser (Fred's Friend)\n"}
  # end
  #
  # @tag :roll_call_open
  # test "'/set_in_for' without a user name param prints a helpful message" do
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/set_in_for"}))
  #   record = Repo.one(RollCallResponse)
  #   assert record == nil
  #   assert {status, response} == {:ok, "Please provide the persons first name.\n"}
  # end
  #
  # @tag :roll_call_open
  # test "'/set_out_for OtherUser' records a response for a different user" do
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/set_out_for OtherUser Fred's Friend"}))
  #   record = Repo.one!(RollCallResponse)
  #   assert record.status == "out"
  #   assert record.name == "OtherUser"
  #   assert record.user_id == nil
  #   assert {status, response} == {:ok, "Out\n - OtherUser (Fred's Friend)\n"}
  # end
  #
  # @tag :roll_call_open
  # test "'/set_out_for' without a user name param prints a helpful message" do
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/set_out_for"}))
  #   record = Repo.one(RollCallResponse)
  #   assert record == nil
  #   assert {status, response} == {:ok, "Please provide the persons first name.\n"}
  # end
  #
  # @tag :roll_call_open
  # test "'/set_maybe_for OtherUser' records a response for a different user" do
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/set_maybe_for OtherUser Fred's Friend"}))
  #   record = Repo.one!(RollCallResponse)
  #   assert record.status == "maybe"
  #   assert record.name == "OtherUser"
  #   assert record.user_id == nil
  #   assert {status, response} == {:ok, "Maybe\n - OtherUser (Fred's Friend)\n"}
  # end
  #
  # @tag :roll_call_open
  # test "'/set_maybe_for' without a user name param prints a helpful message" do
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/set_maybe_for"}))
  #   record = Repo.one(RollCallResponse)
  #   assert record == nil
  #   assert {status, response} == {:ok, "Please provide the persons first name.\n"}
  # end
  #
  # @tag :roll_call_open
  # test "/in after someone else has responded for you", %{ roll_call: roll_call } do
  #   Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: nil, name: @from.first_name})
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/in"}))
  #   record = Repo.one!(RollCallResponse)
  #   assert record.status == "in"
  #   assert record.name == @from.first_name
  #   assert record.user_id == @from.id
  #   assert {status, response} == {:ok, "1. Fred\n"}
  # end
  #
  # @tag :roll_call_open
  # test "'/set_out_for Fred' after Fred has already responded", %{ roll_call: roll_call } do
  #   Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: @from.id, name: @from.first_name})
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/set_out_for Fred"}))
  #   record = Repo.one!(RollCallResponse)
  #   assert record.status == "out"
  #   assert record.name == @from.first_name
  #   assert record.user_id == nil
  #   assert {status, response} == {:ok, "Out\n - Fred\n"}
  # end
  #
  # @tag roll_call_open: true, sample_responses: true
  # test "/whos_in lists all the in, out and maybe responses" do
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
  #   assert {status, response} == {:ok, "1. User 1\n\nMaybe\n - User 3\n\nOut\n - User 2\n"}
  # end
  #
  # @tag roll_call_open: true, sample_responses: true
  # test "/whos_in lists includes the title when it's been set", %{ roll_call: roll_call } do
  #   RollCall.changeset(roll_call, %{title: "Monday Night Football"}) |> Repo.update!
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
  #   assert {status, response} == {:ok, "Monday Night Football\n1. User 1\n\nMaybe\n - User 3\n\nOut\n - User 2\n"}
  # end
  #
  # test "/whos_in responds with an error message when no active roll call exists" do
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
  #   assert {status, response} == {:ok, "No roll call in progress"}
  # end
  #
  # @tag roll_call_open: true, sample_responses: true
  # test "/whos_in doesn't print an empty 'in' list" do
  #   Repo.delete_all(RollCallResponse.with_status(RollCallResponse, "in"))
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
  #   assert {status, response} == {:ok, "Maybe\n - User 3\n\nOut\n - User 2\n"}
  # end
  #
  # @tag roll_call_open: true, sample_responses: true
  # test "/whos_in doesn't print an empty 'out' list" do
  #   Repo.delete_all(RollCallResponse.with_status(RollCallResponse, "out"))
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
  #   assert {status, response} == {:ok, "1. User 1\n\nMaybe\n - User 3\n"}
  # end
  #
  # @tag roll_call_open: true, sample_responses: true
  # test "/whos_in doesn't print an empty 'maybe' list" do
  #   Repo.delete_all(RollCallResponse.with_status(RollCallResponse, "maybe"))
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
  #   assert {status, response} == {:ok, "1. User 1\n\nOut\n - User 2\n"}
  # end
  #
  # @tag roll_call_open: true
  # test "/whos_in prints a message when there have not been any responses" do
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
  #   assert {status, response} == {:ok, "No responses yet. 😢"}
  # end
  #
  # @tag :roll_call_open
  # test "/whos_in lists 'in' people in correct order", %{ roll_call: roll_call } do
  #   Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: 2, name: "User 2", updated_at: Ecto.DateTime.from_erl({{2015, 2, 2}, {2, 2, 2}})})
  #   Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: 1, name: "User 1", updated_at: Ecto.DateTime.from_erl({{2015, 1, 1}, {1, 1, 1}})})
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
  #   assert {status, response} == {:ok, "1. User 1\n2. User 2\n"}
  # end
  #
  # @tag :roll_call_open
  # test "/whos_in lists 'out' people in correct order", %{ roll_call: roll_call } do
  #   Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: 2, name: "User 2", updated_at: Ecto.DateTime.from_erl({{2015, 2, 2}, {2, 2, 2}})})
  #   Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: 1, name: "User 1", updated_at: Ecto.DateTime.from_erl({{2015, 1, 1}, {1, 1, 1}})})
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
  #   assert {status, response} == {:ok, "Out\n - User 1\n - User 2\n"}
  # end
  #
  # @tag :roll_call_open
  # test "/set_title sets the title of the roll call", %{ roll_call: roll_call } do
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/set_title Monday Night Football"}))
  #   assert {status, response} == {:ok, "Roll call title set"}
  #   roll_call = Repo.get(RollCall, roll_call.id)
  #   assert roll_call.title == "Monday Night Football"
  # end
  #
  # @tag :roll_call_open
  # test "/shh sets the quiet flag to true", %{ roll_call: roll_call } do
  #   assert false == roll_call.quiet
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/shh"}))
  #   assert {status, response} == {:ok, "Ok fine, I'll be quiet. 🤐"}
  #   roll_call = Repo.get(RollCall, roll_call.id)
  #   assert true == roll_call.quiet
  # end
  #
  # test "/shh - when these is no roll call in progress" do
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/shh"}))
  #   assert {status, response} == {:ok, "No roll call in progress"}
  # end
  #
  # @tag :roll_call_open
  # test "/louder sets the quiet flag to false", %{ roll_call: roll_call } do
  #   Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: nil, name: @from.first_name})
  #   assert false == roll_call.quiet
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/louder"}))
  #   assert {status, response} == {:ok, "Sure. 😃\n1. Fred\n"}
  #   roll_call = Repo.get(RollCall, roll_call.id)
  #   assert false == roll_call.quiet
  # end
  #
  # test "/louder - when these is no roll call in progress" do
  #   {status, response} = MessageHandler.handle_message(message(%{text: "/louder"}))
  #   assert {status, response} == {:ok, "No roll call in progress"}
  # end

end
