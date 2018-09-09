defmodule WhosInBot.MessageHandlerTest do
  use ExUnit.Case
  import Ecto.Query, only: [from: 2]
  alias WhosInBot.Repo
  alias WhosInBot.MessageHandler
  alias WhosInBot.Models.RollCall
  alias WhosInBot.Models.RollCallResponse

  defp count(query), do: Repo.one(from v in query, select: count(v.id))

  @chat %{ id: 123 }
  @from %{ first_name: "Fred", id: 456 }
  @message %{ chat: @chat, from: @from, date: 1451868542}

  defp message(params) do
    Map.merge(@message, params)
  end

  setup config do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(WhosInBot.Repo)

    roll_call = case config[:roll_call_open] do
      true -> %RollCall{ chat_id: @chat.id, status: "open" } |> Repo.insert!
      _ -> nil
    end

    case config[:sample_responses] do
      true -> [
        %RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: 1, name: "User 1"} |> Repo.insert!,
        %RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: 2, name: "User 2"} |> Repo.insert!,
        %RollCallResponse{ roll_call_id: roll_call.id, status: "maybe", user_id: 3, name: "User 3"} |> Repo.insert!
      ]
      _ -> nil
    end

    {:ok, roll_call: roll_call}
  end

  test "does not respond to normal chat messages" do
    {status, response} = MessageHandler.handle_message(message(%{text: "Hey, what's up guys?"}))
    assert {status, response} == {:error, "Not a bot command"}
  end

  @tag :roll_call_open
  test "doesn't crash when there is no :text attribute in the message" do
    {status, response} = MessageHandler.handle_message(message(%{}))
    assert {status, response} == {:error, "Not a bot command"}
  end

  @tag :roll_call_open
  test "doesn't crash when just a '/' in the message" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/"}))
    assert {status, response} == {:error, "Not a bot command"}
  end

  @tag :roll_call_open
  test "/in, if there happens to be more than one open roll call, it will close them" do
    Repo.insert!(%RollCall{ chat_id: @chat.id, status: "open" })
    Repo.insert!(%RollCall{ chat_id: @chat.id, status: "open" })
    MessageHandler.handle_message(message(%{text: "/in"}))
    [r1|[r2,r3]] = Repo.all(from(r in RollCall, where: r.chat_id == ^@chat.id))
    assert r1.status == "open"
    assert r2.status == "closed"
    assert r3.status == "closed"
  end

  @tag :roll_call_open
  test "doesn't respond to unknown commands" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/some_unknown_command"}))
    assert {status, response} == {:error, "Unknown command"}
  end

  test "/start_roll_call responds with 'Roll Call Started'" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/start_roll_call"}))
    assert {status, response} == {:ok, "Roll call started"}
  end

  test "handles messages when they contain the name of the bot" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/start_roll_call@BotName"}))
    assert {status, response} == {:ok, "Roll call started"}
  end

  test "handles messages when they contain multiple @ in the bot name (Prod Bug)" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/start_roll_call@Bot@Name"}))
    assert {status, response} == {:ok, "Roll call started"}
  end

  test "/start_roll_call creates a new RollCall" do
    assert count(RollCall) == 0
    MessageHandler.handle_message(message(%{text: "/start_roll_call"}))
    assert Repo.get_by(RollCall, %{chat_id: @chat.id, status: "open"}) != nil
  end

  test "'/start_roll_call Monday Night Football' creates a new RollCall with a title" do
    assert count(RollCall) == 0
    MessageHandler.handle_message(message(%{text: "/start_roll_call Monday Night Football"}))
    response = Repo.get_by(RollCall, %{chat_id: @chat.id, status: "open"})
    assert response != nil
    assert response.title == "Monday Night Football"
  end

  test "'/start_roll_call Monday Night Football' doesn't include the title in the response" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/start_roll_call Monday Night Football"}))
    assert {status, response} == {:ok, "Roll call started"}
  end

  @tag :roll_call_open
  test "/start_roll_call closes all existing roll calls for the same chat", %{ roll_call: roll_call } do
    MessageHandler.handle_message(message(%{text: "/start_roll_call"}))
    assert Repo.get(RollCall, roll_call.id).status == "closed"
  end


  @tag :roll_call_open
  test "/end_roll_call responds with 'Roll call ended'" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/end_roll_call"}))
    assert {status, response} == {:ok, "Roll call ended"}
  end

  @tag :roll_call_open
  test "/end_roll_call does not responds with the title when it's been set" do
    RollCall.changeset(Repo.one(RollCall), %{title: "Monday Night Football"}) |> Repo.update!
    {status, response} = MessageHandler.handle_message(message(%{text: "/end_roll_call"}))
    assert {status, response} == {:ok, "Roll call ended"}
  end

  test "/end_roll_call responds with an error message when no active roll call exists" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/end_roll_call"}))
    assert {status, response} == {:ok, "No roll call in progress"}
  end

  @tag :roll_call_open
  test "/end_roll_call closes the existing roll call", %{ roll_call: roll_call } do
    MessageHandler.handle_message(message(%{text: "/end_roll_call"}))
    assert Repo.get(RollCall, roll_call.id).status == "closed"
  end


  @tag :roll_call_open
  test "/in responds correctly" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/in"}))
    assert {status, response} == {:ok, "1. Fred\n"}
  end

  @tag :roll_call_open
  test "/in responds with minimal info when in quiet mode", %{ roll_call: roll_call } do
    RollCall.changeset(roll_call, %{ quiet: true }) |> Repo.update!
    %RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: 1, name: "User 1"}
      |> Repo.insert!
    %RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: 2, name: "User 2"}
      |> Repo.insert!
    {status, response} = MessageHandler.handle_message(message(%{text: "/in"}))
    assert {status, response} == {:ok, "Fred is in!\nTotal: 2 In, 1 Out, 0 Maybe\n"}
  end

  @tag :roll_call_open
  test "/in responds with reason" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/in plus 1"}))
    assert {status, response} == {:ok, "1. Fred (plus 1)\n"}
  end

  @tag :roll_call_open
  test "/in|out|maybe doesn't add () if the reason already has them" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/in (plus 1)"}))
    assert {status, response} == {:ok, "1. Fred (plus 1)\n"}
  end

  test "/in responds with an error message when no active roll call exists" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/in"}))
    assert {status, response} == {:ok, "No roll call in progress"}
  end

  @tag :roll_call_open
  test "/in records the users response", %{ roll_call: roll_call } do
    MessageHandler.handle_message(message(%{text: "/in"}))
    response = Repo.get_by!(RollCallResponse, %{status: "in", user_id: @from.id, name: @from.first_name})
    assert response.roll_call_id == roll_call.id
  end

  @tag :roll_call_open
  test "/in updates an existing response", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{roll_call_id: roll_call.id, status: "out", user_id: @from.id, name: @from.first_name})
    MessageHandler.handle_message(message(%{text: "/in"}))
    assert Repo.one!(RollCallResponse).status == "in"
    assert Repo.one!(RollCallResponse).reason == nil
  end

  @tag :roll_call_open
  test "/out responds correctly" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/out"}))
    assert {status, response} == {:ok, "Out\n - Fred\n"}
  end

  @tag roll_call_open: true, sample_responses: true
  test "/out responds with minimal info when out quiet mode", %{ roll_call: roll_call } do
    RollCall.changeset(roll_call, %{ quiet: true }) |> Repo.update!
    {status, response} = MessageHandler.handle_message(message(%{text: "/out"}))
    assert {status, response} == {:ok, "Fred is out!\nTotal: 1 In, 2 Out, 1 Maybe\n"}
  end

  @tag :roll_call_open
  test "/out includes the reason in the response when it's provided" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/out Injured"}))
    assert {status, response} == {:ok, "Out\n - Fred (Injured)\n"}
  end

  test "/out responds with an error message when no active roll call exists" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/out"}))
    assert {status, response} == {:ok, "No roll call in progress"}
  end

  @tag :roll_call_open
  test "/out records the users response", %{ roll_call: roll_call } do
    MessageHandler.handle_message(message(%{text: "/out"}))
    response = Repo.get_by!(RollCallResponse, %{status: "out", user_id: @from.id, name: @from.first_name})
    assert response.roll_call_id == roll_call.id
  end

  @tag :roll_call_open
  test "'/out Injured' records the users response and the reason", %{ roll_call: roll_call } do
    MessageHandler.handle_message(message(%{text: "/out Injured"}))
    response = Repo.get_by!(RollCallResponse, %{status: "out", user_id: @from.id, name: @from.first_name})
    assert response.roll_call_id == roll_call.id
    assert response.reason == "Injured"
  end

  @tag :roll_call_open
  test "/out updates an existing response", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: @from.id, name: @from.first_name})
    MessageHandler.handle_message(message(%{text: "/out"}))
    assert Repo.one!(RollCallResponse).status == "out"
  end

  @tag :roll_call_open
  test "/maybe responds correctly" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/maybe"}))
    assert {status, response} == {:ok, "Maybe\n - Fred\n"}
  end

  @tag roll_call_open: true, sample_responses: true
  test "/maybe responds with minimal info when out quiet mode", %{ roll_call: roll_call } do
    RollCall.changeset(roll_call, %{ quiet: true }) |> Repo.update!
    {status, response} = MessageHandler.handle_message(message(%{text: "/maybe"}))
    assert {status, response} == {:ok, "Fred might come.\nTotal: 1 In, 1 Out, 2 Maybe\n"}
  end

  @tag :roll_call_open
  test "/maybe includes the reason in the response when it's provided" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/maybe Injured"}))
    assert {status, response} == {:ok, "Maybe\n - Fred (Injured)\n"}
  end

  test "/maybe responds with an error message when no active roll call exists" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/maybe"}))
    assert {status, response} == {:ok, "No roll call in progress"}
  end

  @tag :roll_call_open
  test "/maybe records the users response", %{ roll_call: roll_call } do
    MessageHandler.handle_message(message(%{text: "/maybe"}))
    response = Repo.get_by!(RollCallResponse, %{status: "maybe", user_id: @from.id, name: @from.first_name})
    assert response.roll_call_id == roll_call.id
  end

  @tag :roll_call_open
  test "'/maybe Injured' records the users response and the reason", %{ roll_call: roll_call } do
    MessageHandler.handle_message(message(%{text: "/maybe Injured"}))
    response = Repo.get_by!(RollCallResponse, %{status: "maybe", user_id: @from.id, name: @from.first_name})
    assert response.roll_call_id == roll_call.id
    assert response.reason == "Injured"
  end

  @tag :roll_call_open
  test "/maybe updates an existing response", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: @from.id, name: @from.first_name})
    MessageHandler.handle_message(message(%{text: "/maybe"}))
    assert Repo.one!(RollCallResponse).status == "maybe"
  end


  @tag :roll_call_open
  test "'/set_in_for OtherUser' records a response for a different user" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/set_in_for OtherUser Fred's Friend"}))
    record = Repo.one!(RollCallResponse)
    assert record.status == "in"
    assert record.name == "OtherUser"
    assert record.user_id == nil
    assert {status, response} == {:ok, "1. OtherUser (Fred's Friend)\n"}
  end

  @tag :roll_call_open
  test "'/set_in_for' without a user name param prints a helpful message" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/set_in_for"}))
    record = Repo.one(RollCallResponse)
    assert record == nil
    assert {status, response} == {:ok, "Please provide the persons first name.\n"}
  end

  @tag :roll_call_open
  test "'/set_out_for OtherUser' records a response for a different user" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/set_out_for OtherUser Fred's Friend"}))
    record = Repo.one!(RollCallResponse)
    assert record.status == "out"
    assert record.name == "OtherUser"
    assert record.user_id == nil
    assert {status, response} == {:ok, "Out\n - OtherUser (Fred's Friend)\n"}
  end

  @tag :roll_call_open
  test "'/set_out_for' without a user name param prints a helpful message" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/set_out_for"}))
    record = Repo.one(RollCallResponse)
    assert record == nil
    assert {status, response} == {:ok, "Please provide the persons first name.\n"}
  end

  @tag :roll_call_open
  test "'/set_maybe_for OtherUser' records a response for a different user" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/set_maybe_for OtherUser Fred's Friend"}))
    record = Repo.one!(RollCallResponse)
    assert record.status == "maybe"
    assert record.name == "OtherUser"
    assert record.user_id == nil
    assert {status, response} == {:ok, "Maybe\n - OtherUser (Fred's Friend)\n"}
  end

  @tag :roll_call_open
  test "'/set_maybe_for' without a user name param prints a helpful message" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/set_maybe_for"}))
    record = Repo.one(RollCallResponse)
    assert record == nil
    assert {status, response} == {:ok, "Please provide the persons first name.\n"}
  end

  @tag :roll_call_open
  test "/in after someone else has responded for you", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: nil, name: @from.first_name})
    {status, response} = MessageHandler.handle_message(message(%{text: "/in"}))
    record = Repo.one!(RollCallResponse)
    assert record.status == "in"
    assert record.name == @from.first_name
    assert record.user_id == @from.id
    assert {status, response} == {:ok, "1. Fred\n"}
  end

  @tag :roll_call_open
  test "'/set_out_for Fred' after Fred has already responded", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: @from.id, name: @from.first_name})
    {status, response} = MessageHandler.handle_message(message(%{text: "/set_out_for Fred"}))
    record = Repo.one!(RollCallResponse)
    assert record.status == "out"
    assert record.name == @from.first_name
    assert record.user_id == nil
    assert {status, response} == {:ok, "Out\n - Fred\n"}
  end

  @tag roll_call_open: true, sample_responses: true
  test "/whos_in lists all the in, out and maybe responses" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "1. User 1\n\nMaybe\n - User 3\n\nOut\n - User 2\n"}
  end

  @tag roll_call_open: true, sample_responses: true
  test "/whos_in lists includes the title when it's been set", %{ roll_call: roll_call } do
    RollCall.changeset(roll_call, %{title: "Monday Night Football"}) |> Repo.update!
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "Monday Night Football\n1. User 1\n\nMaybe\n - User 3\n\nOut\n - User 2\n"}
  end

  test "/whos_in responds with an error message when no active roll call exists" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "No roll call in progress"}
  end

  @tag roll_call_open: true, sample_responses: true
  test "/whos_in doesn't print an empty 'in' list" do
    Repo.delete_all(RollCallResponse.with_status(RollCallResponse, "in"))
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "Maybe\n - User 3\n\nOut\n - User 2\n"}
  end

  @tag roll_call_open: true, sample_responses: true
  test "/whos_in doesn't print an empty 'out' list" do
    Repo.delete_all(RollCallResponse.with_status(RollCallResponse, "out"))
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "1. User 1\n\nMaybe\n - User 3\n"}
  end

  @tag roll_call_open: true, sample_responses: true
  test "/whos_in doesn't print an empty 'maybe' list" do
    Repo.delete_all(RollCallResponse.with_status(RollCallResponse, "maybe"))
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "1. User 1\n\nOut\n - User 2\n"}
  end

  @tag roll_call_open: true
  test "/whos_in prints a message when there have not been any responses" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "No responses yet. 😢"}
  end

  @tag :roll_call_open
  test "/whos_in lists 'in' people in correct order", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: 2, name: "User 2", inserted_at: Ecto.DateTime.from_erl({{2015, 2, 2}, {2, 2, 2}})})
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: 1, name: "User 1", inserted_at: Ecto.DateTime.from_erl({{2015, 1, 1}, {1, 1, 1}})})
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: 3, name: "User 3", inserted_at: Ecto.DateTime.from_erl({{2015, 3, 3}, {3, 3, 3}})})
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "1. User 1\n2. User 2\n3. User 3\n"}
  end

  @tag :roll_call_open
  test "/whos_in lists 'out' people in correct order", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: 2, name: "User 2", inserted_at: Ecto.DateTime.from_erl({{2015, 2, 2}, {2, 2, 2}})})
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: 1, name: "User 1", inserted_at: Ecto.DateTime.from_erl({{2015, 1, 1}, {1, 1, 1}})})
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: 3, name: "User 3", inserted_at: Ecto.DateTime.from_erl({{2015, 3, 3}, {3, 3, 3}})})
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "Out\n - User 1\n - User 2\n - User 3\n"}
  end

  @tag :roll_call_open
  test "/set_title sets the title of the roll call", %{ roll_call: roll_call } do
    {status, response} = MessageHandler.handle_message(message(%{text: "/set_title Monday Night Football"}))
    assert {status, response} == {:ok, "Roll call title set"}
    roll_call = Repo.get(RollCall, roll_call.id)
    assert roll_call.title == "Monday Night Football"
  end

  @tag :roll_call_open
  test "/shh sets the quiet flag to true", %{ roll_call: roll_call } do
    assert false == roll_call.quiet
    {status, response} = MessageHandler.handle_message(message(%{text: "/shh"}))
    assert {status, response} == {:ok, "Ok fine, I'll be quiet. 🤐"}
    roll_call = Repo.get(RollCall, roll_call.id)
    assert true == roll_call.quiet
  end

  test "/shh - when these is no roll call in progress" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/shh"}))
    assert {status, response} == {:ok, "No roll call in progress"}
  end

  @tag :roll_call_open
  test "/louder sets the quiet flag to false", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: nil, name: @from.first_name})
    assert false == roll_call.quiet
    {status, response} = MessageHandler.handle_message(message(%{text: "/louder"}))
    assert {status, response} == {:ok, "Sure. 😃\n1. Fred\n"}
    roll_call = Repo.get(RollCall, roll_call.id)
    assert false == roll_call.quiet
  end

  test "/louder - when these is no roll call in progress" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/louder"}))
    assert {status, response} == {:ok, "No roll call in progress"}
  end

end
