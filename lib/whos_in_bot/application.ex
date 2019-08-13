defmodule WhosInBot.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {Plug.Cowboy, scheme: :http, plug: WhosInBot.Router, options: [port: 5000]},
      supervisor(WhosInBot.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: WhosInBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
