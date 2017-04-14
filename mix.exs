defmodule Rampart.Mixfile do
  use Mix.Project

  def project do
    [app: :rampart,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger],
     mod: { Rampart, [] }]
  end

  defp deps do
    []
  end
end
