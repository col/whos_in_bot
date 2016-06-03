defmodule Telegram.MockClient do
  require Logger

  def send_message(chat_id, message) do
    Logger.info "Telegram.MockClient.send_message: #{chat_id} - #{message}"
  end

end
