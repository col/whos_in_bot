defmodule WhosInBot.Worker do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, "WhosInBot")
  end

  def handle_message(pid, message) do
    GenServer.cast(pid, {:handle_message, message})
  end

  def init(name) do
    connect_to_hub
    :global.register_name(name, self)
    IO.puts "Registered Bot: #{name}"
    {:ok, []}
  end

  def connect_to_hub do
    node_name = Application.get_env(:whos_in_bot, :bot_hub_node)
    result = Node.connect String.to_atom(node_name)
    IO.puts "Connecting to bot_hub (#{node_name}): #{result}"
  end

  def handle_cast({:handle_message, json}, roll_call) do
    message = Telegram.Update.parse(json).message
    case WhosInBot.MessageHandler.handle_message(message, roll_call) do
      {:ok, response, roll_call} ->
        Nadia.send_message(message.chat.id, response)
      {:error, response, _} ->
        IO.puts "Error: #{response}"
    end
    {:noreply, roll_call}
  end

  def handle_call(:version, _from, state) do
    {:reply, WhoInBot.version, state}
  end
end
