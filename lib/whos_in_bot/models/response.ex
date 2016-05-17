defmodule WhosInBot.Models.Response do
  alias WhosInBot.Models.Response

  defstruct [:status, :name, :user_id, :reason]

  def new(status, reason \\ nil) do
    %Response{status: status, reason: reason}
  end
end
