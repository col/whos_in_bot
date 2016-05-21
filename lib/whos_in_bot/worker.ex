defmodule WhosInBot.Worker do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, "WhosInBot")
  end

  def handle_message(pid, json) do
    GenServer.cast(pid, {:handle_message, json})
  end

  def init(name) do
    connect_to_hub
    :global.register_name(name, self)
    IO.puts "Registered Bot: #{name}"
    {:ok, nil}
  end

  def connect_to_hub do
    node_name = Application.get_env(:whos_in_bot, :bot_hub_node)
    result = Node.connect String.to_atom(node_name)
    IO.puts "Connecting to bot_hub (#{node_name}): #{result}"
  end

  def handle_cast({:handle_message, json}, state) do
    message = Telegram.Update.parse(json).message
    WhosInBot.ChatGroup.handle_message(message)
    {:noreply, state}
  end

  def handle_call(:version, _from, state) do
    {:reply, WhosInBot.version, state}
  end

  def handle_info(message, _) do
    IO.puts "Worker.handle_info - received message: #{message}"
  end
end
