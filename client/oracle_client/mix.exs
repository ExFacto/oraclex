defmodule OracleClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :oracle_client,
      releases: releases(),
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
      mod: {OracleClient, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:burrito, github: "burrito-elixir/burrito"},
      {:oracle_client_lib, path: "../oracle_client_lib"}
    ]
  end

  def releases do
    [
      oracle_client: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            macos_m1: [os: :darwin, cpu: :aarch64]
          ]
        ]
      ]
    ]
  end
end
