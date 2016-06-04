defmodule WhosInBot.Mixfile do
  use Mix.Project

  def project do
    [app: :whos_in_bot,
     version: "0.0.6",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      applications: [:logger, :poison, :nadia, :telegram, :edeliver],
      mod: {WhosInBot, []}
    ]
  end

  defp deps do
    [
      {:nadia, git: "https://github.com/zhyu/nadia.git"},
      {:poison, "~> 2.0"},
      {:telegram, git: "https://github.com/col/telegram"},
      # Deployment
      {:edeliver, "~> 1.2.8"},
      {:exrm, "~> 1.0.5"},
      {:conform, "~> 2.0.0"},
      {:conform_exrm, "~> 1.0.0"}
    ]
  end
end
