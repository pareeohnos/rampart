defmodule Rampart.Mixfile do
  use Mix.Project

  def project do
    [app: :rampart,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     elixirc_paths: elixirc_paths(Mix.env)]
  end

  def application do
    [applications: [:logger],
     mod: { Rampart, [] }]
  end

  defp deps do
    [
      { :plug, "~> 1.0" }
    ]
  end


  defp elixirc_paths(:test) do 
    ["lib", "test/support"]
  end

  defp elixirc_paths(_env), do: ["lib"]
end
