defmodule Mborg.Mixfile do
  use Mix.Project

  def project do
    [app: :mborg,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:elixir_ale, "~> 1.0"},
      {:ex_doc,     "~> 0.18.1"},
      {:earmark,    "~> 1.2.4"},
      {:joystick, "~> 0.2.0"},
      {:picam, "~> 0.2.0"}
    ]
  end
end
