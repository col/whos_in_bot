defmodule WhosInBot do
  use Application

  def version do
    {:ok, version} = :application.get_key(:whos_in_bot, :vsn)
    version
  end

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      worker(WhosInBot.Worker, []),
      supervisor(WhosInBot.ChatGroupSupervisor, [])
    ]
    opts = [strategy: :one_for_one, name: WhosInBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
