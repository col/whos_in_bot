defmodule WhosInBot.ChatGroup do
  use GenServer
  alias WhosInBot.RollCall

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  def handle_message(pid, message) do
    GenServer.cast(pid, {:handle_message, message})
  end

  def init(_) do
    {:ok, RollCall.new(nil, nil)}
  end

  def handle_cast({:handle_message, message}, state) do
    Nadia.send_message(message.chat.id, message.text)
    {:noreply, state}
  end

end
