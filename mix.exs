defmodule Json5.MixProject do
  use Mix.Project

  def project do
    [
      app: :json5,
      version: "0.0.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:combine, "~> 0.10"},
      {:ex_unicode, "~> 1.0"},
      {:unicode_set, "~> 0.13"},
      {:decimal, "~> 2.0.0"}
    ]
  end
end
