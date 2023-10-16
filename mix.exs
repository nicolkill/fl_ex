defmodule FlEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :fl_ex,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "fl_ex",
      description: "Lightweight and easy to use API micro-framework.",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      source_url: "https://github.com/nicolkill/fl_ex",
      docs: [
        extras: ["README.md"]
      ]
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
      {:plug, "~> 1.14"},
      {:plug_cowboy, "~> 2.0"},
      {:httpoison, "~> 2.0", only: :test, runtime: false},
      {:jason, "~> 1.2"}
    ]
  end

  defp package do
    [
      name: "fl_ex",
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/nicolkill/fl_ex"},
    ]
  end
end
