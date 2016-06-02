defmodule WhosInBot.ChatGroup do
  use GenServer
  alias WhosInBot.RollCall

  def start_link(chat_id) do
    GenServer.start_link(__MODULE__, chat_id)
  end

  def handle_message(message) do
    GenServer.cast(chat_group_process(message.chat.id), {:handle_message, message})
  end

  def init(chat_id) do
    IO.puts "Starting new Chat Group: #{chat_id}"
    register(chat_id)
    {:ok, nil}
  end

  def handle_cast({:handle_message, message}, roll_call) do
    case WhosInBot.MessageHandler.handle_message(message, roll_call) do
      {:ok, response, roll_call} ->
        IO.puts "Response: #{response}"
        Nadia.send_message(message.chat.id, response)
      {:error, response} ->
        IO.puts "Error handling message: #{response}"
    end
    {:noreply, roll_call}
  end


  defp chat_group_process(chat_id) do
    case where_is(chat_id) do
      :undefined ->
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
