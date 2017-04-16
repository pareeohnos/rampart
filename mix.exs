defmodule Rampart.Mixfile do
  use Mix.Project

  def project do
    [
      app: :rampart,
      version: "0.1.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env),
    
      description: description(),
      package: package()
    ]
  end

  def application do
    [applications: [:logger],
     mod: { Rampart, [] }]
  end

  defp deps do
    [
      { :plug, "~> 1.0" },
      { :ex_doc, "~> 0.15", only: :dev }
    ]
  end


  defp elixirc_paths(:test) do 
    ["lib", "test/support"]
  end

  defp elixirc_paths(_env), do: ["lib"]

  defp description do
    """
    A simple yet flexible authorization library for Plug applications.
    """
  end

  defp package do
    [
      maintainers: ["Adrian Hooper"],
      licenses: ["MIT"],
      links: %{ "GitHub" => "https://github.com/pareeohnos/rampart" },
      files: ~w(mix.exs README.md lib)
    ]
  end
end
