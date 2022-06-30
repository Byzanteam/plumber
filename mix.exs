defmodule Plumber.MixProject do
  use Mix.Project

  def project do
    [
      app: :plumber,
      version: "0.1.0",
      elixir: "~> 1.13",
      deps: deps(),
      test_coverage: [
        summary: [threshold: 80]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps() do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end
