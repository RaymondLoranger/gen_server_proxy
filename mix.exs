defmodule GenServer.Proxy.MixProject do
  use Mix.Project

  def project do
    [
      app: :gen_server_proxy,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      name: "GenServer Proxy",
      source_url: source_url(),
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp source_url do
    "https://github.com/RaymondLoranger/gen_server_proxy"
  end

  defp description do
    """
    Performs a GenServer call, cast or stop. Will wait a bit if the server is not yet registered on restarts.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "config/persist*.exs"],
      maintainers: ["Raymond Loranger"],
      licenses: ["MIT"],
      links: %{"GitHub" => source_url()}
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
      {:mix_tasks,
       github: "RaymondLoranger/mix_tasks", only: :dev, runtime: false},
      {:file_only_logger, "~> 0.1"},
      {:persist_config, "~> 0.1"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
