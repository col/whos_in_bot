defmodule WhosInBot.Models.RollCall do
  alias WhosInBot.Models.RollCall

  defstruct [:chat_id, :title, :quiet, :responses]

  def new(chat_id, title) do
    %RollCall{chat_id: chat_id, title: title, quiet: false, responses: []}
  end
end
