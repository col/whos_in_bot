defmodule WhosInBot do
  use Application

  @telegram_client Application.get_env(:whos_in_bot, :telegram_client)

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      worker(WhosInBot.Worker, [@telegram_client]),
      supervisor(WhosInBot.ChatGroupSupervisor, [])
    ]
    opts = [strategy: :one_for_one, name: WhosInBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def version do
    {:ok, app_version} = :application.get_key(:whos_in_bot, :vsn)
    app_version
  end

end
