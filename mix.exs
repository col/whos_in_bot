defmodule WhosInBot.Mixfile do
  use Mix.Project

  def project do
    [
      app: :whos_in_bot,
      version: "0.1.0",
      elixir: "~> 1.9",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :nadia],
      mod: {WhosInBot.Application, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.1"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:nadia, "~> 0.3"},
      {:jason, "~> 1.1.2"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
