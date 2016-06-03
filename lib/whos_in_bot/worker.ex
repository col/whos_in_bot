defmodule WhosInBot.Worker do
  require Logger
  use GenServer
  alias WhosInBot.ChatGroup

  def start_link(telegram_client) do
    GenServer.start_link(__MODULE__, ["WhosInBot", telegram_client])
  end

  def handle_message(pid, json) do
    GenServer.cast(pid, {:handle_message, json})
  end

  def init([name, telegram_client]) do
    connect_to_hub
    :global.register_name(name, self)
    Logger.debug "Registered Bot: #{name}"
    {:ok, telegram_client}
  end

  def connect_to_hub do
    node_name = Application.get_env(:whos_in_bot, :bot_hub_node)
    result = Node.connect String.to_atom(node_name)
    Logger.debug "Connecting to bot_hub (#{node_name}): #{result}"
  end

  def handle_cast({:handle_message, json}, telegram_client) do
    message = Telegram.Update.parse(json).message
    response = ChatGroup.handle_message(message)
    telegram_client.send_message(message.chat.id, response)
    {:noreply, telegram_client}
  end

  def handle_call(:version, _from, state) do
    {:reply, WhosInBot.version, state}
  end

  def handle_info(message, _) do
    Logger.debug "WhosInBot.Worker.handle_info - received message: #{message}"
  end
end
