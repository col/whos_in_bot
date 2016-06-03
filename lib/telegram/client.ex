defmodule Telegram.Client do
  require Logger

  #TODO: Add OTP

  def send_message(chat_id, message) do
    Nadia.send_message(chat_id, message)
  end

end
