defmodule TelemetryDocs.MixProject do
  use Mix.Project

  @version "0.1.0"
  @repo_url "https://github.com/whatyouhide/telemetry_docs"

  def project do
    [
      app: :telemetry_docs,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Tests
      test_coverage: [tool: ExCoveralls],

      # Hex
      package: package(),
      description:
        "Generates Markdown documentation from structured telemetry event definitions.",

      # Docs
      docs: [
        main: "TelemetryDocs",
        source_ref: "v#{@version}",
        source_url: @repo_url
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli do
    [
      preferred_envs: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_options, "~> 1.0"},
      {:ex_doc, "~> 0.40", only: :dev},
      {:excoveralls, "~> 0.18.5", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["Andrea Leopardi"],
      licenses: ["MIT"],
      links: %{"GitHub" => @repo_url, "Sponsor" => "https://github.com/sponsors/whatyouhide"}
    ]
  end
end
