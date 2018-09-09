defmodule WhosInBot.Mixfile do
  use Mix.Project

  def project do
    [app: :whos_in_bot,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:honeybadger, :logger, :cowboy, :nadia, :ecto, :postgrex, :beaker, :plug],
     mod: {WhosInBot, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:beaker, git: "https://github.com/col/beaker.git"},
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.0"},
      {:ecto, "~> 2.2", override: true},
      {:postgrex, "~> 0.13"},
      {:nadia, "~> 0.3"},
      {:honeybadger, "~> 0.1"}
    ]
  end
end
