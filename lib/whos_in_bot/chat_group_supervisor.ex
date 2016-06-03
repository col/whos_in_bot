defmodule WhosInBot.ChatGroupSupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    :ets.new(:chat_states, [:named_table, :public, :set])

    children = [
      worker(WhosInBot.ChatGroup, [], restart: :transient)
    ]
    supervise children, strategy: :simple_one_for_one
  end

  def start_chat_group(chat_id) do
    Supervisor.start_child(__MODULE__, [chat_id])
  end
end
