defmodule OracleClientLib.MixProject do
  use Mix.Project

  def project do
    [
      app: :oracle_client_lib,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {OracleClientLib.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:slipstream, "~> 1.0"},
      {:jason, "~> 1.1"}
    ]
  end
end
