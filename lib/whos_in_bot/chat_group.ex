defmodule WhosInBot.ChatGroup do
  require Logger
  use GenServer
  alias WhosInBot.{RollCall, MessageHandler}

  # Public API

  def start_link(chat_id) do
    GenServer.start_link(__MODULE__, chat_id)
  end

  def handle_message(message) do
    GenServer.call(chat_group_process(message.chat.id), {:handle_message, message})
  end

  # GenServer

  def init(chat_id) do
    Logger.debug "Starting new Chat Group: #{chat_id}"
    register(chat_id)
    state = load_state(chat_id)
    {:ok, state}
  end

  def handle_call({:handle_message, message}, _, roll_call) do
    Logger.debug "Handle Message: #{message.text}"
    case MessageHandler.handle_message(message, roll_call) do
      {:ok, response, roll_call} ->
        Logger.debug "Response: #{response}"
        save_state(message.chat.id, roll_call)
        {:reply, response, roll_call}
      {:error, error, roll_call} ->
        Logger.debug "Error handling message: #{error}"
        {:reply, nil, roll_call}
    end
  end

  # Private Methods

  defp load_state(chat_id) do
    case :ets.lookup(:chat_states, process_name(chat_id)) do
      [{_, state}] -> state
      _ -> nil
    end
  end

  defp save_state(chat_id, state) do
    :ets.insert(:chat_states, {process_name(chat_id), state})
  end

  defp chat_group_process(chat_id) do
    case where_is(chat_id) do
      nil ->
        {:ok, pid} = WhosInBot.ChatGroupSupervisor.start_chat_group(chat_id)
        pid
      pid -> pid
    end
  end

  defp where_is(chat_id) do
    Process.whereis(process_name(chat_id))
  end

  defp register(chat_id) do
    Process.register(self, process_name(chat_id))
  end

  defp process_name(chat_id) do
    String.to_atom("chat_id:#{chat_id}")
  end

end
