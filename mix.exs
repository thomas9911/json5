defmodule Json5.MixProject do
  use Mix.Project

  def project do
    [
      app: :json5,
      version: "0.3.0",
      elixir: "~> 1.10",
      description: "Json5 in Elixir",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      package: package(),
      source_url: "https://github.com/thomas9911/json5"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:benchee, ">= 0.0.0", only: :dev, runtime: false},
      {:jason, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:eflame, "~> 1.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:combine, "~> 0.10"},
      {:unicode, "~> 1.19"},
      {:unicode_set, "~> 1.4"},
      {:decimal, "~> 2.0.0"}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/thomas9911/json5"}
    ]
  end
end
