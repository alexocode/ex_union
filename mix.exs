defmodule ExUnion.MixProject do
  use Mix.Project

  @github "https://github.com/sascha-wolf/ex_union"

  def project do
    [
      app: :ex_union,
      version: version(),
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      test_coverage: [tool: ExCoveralls],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: dialyzer(),

      # Docs
      name: "ExUnion",
      source_url: @github,
      homepage_url: @github,

      # Hex
      description: description(),
      docs: docs(),
      package: package(),
      version: version()
    ]
  end

  defp elixirc_paths(:dev), do: ["examples", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "check.all": ["format --check-formatted", "credo", "dialyzer"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # No Runtime
      {:credo, ">= 1.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},

      # Test
      {:excoveralls, "~> 0.13", only: :test}
    ]
  end

  defp dialyzer do
    [
      # ignore_warnings: "dialyzer/ignore.exs",
      plt_file: {:no_warn, ".dialyzer/dialyzer.plt"}
    ]
  end

  #######
  # Hex #
  #######

  def description do
    "Tagged Unions for Elixir. Just that."
  end

  @extras Path.wildcard("pages/**/*.md")
  def docs do
    [
      main: "ExUnion",
      source_ref: "v#{version()}",
      source_url: @github,
      extras: @extras,
      groups_for_modules: []
    ]
  end

  def package do
    [
      files: ["lib", "mix.exs", "CHANGELOG*", "LICENSE*", "README*", "version"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @github
      },
      maintainers: ["Sascha Wolf <swolf.dev@gmail.com>"]
    ]
  end

  @version_file "version"
  def version do
    cond do
      File.exists?(@version_file) ->
        @version_file
        |> File.read!()
        |> String.trim()

      System.get_env("REQUIRE_VERSION_FILE") == "true" ->
        exit("Version file (`#{@version_file}`) doesn't exist but is required!")

      true ->
        "0.0.0-dev"
    end
  end
end
