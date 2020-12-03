defmodule GenServer.Proxy.MixProject do
  use Mix.Project

  def project do
    [
      app: :gen_server_proxy,
      version: "0.1.18",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      name: "GenServer Proxy",
      source_url: source_url(),
      description: description(),
      package: package(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  defp source_url do
    "https://github.com/RaymondLoranger/gen_server_proxy"
  end

  defp description do
    """
    Makes a GenServer call to a registered server.
    Will wait a bit if the server is not yet registered on restarts.
    Also supports GenServer cast and GenServer stop.
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
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:file_only_logger, "~> 0.1"},
      {:mix_tasks,
       github: "RaymondLoranger/mix_tasks", only: :dev, runtime: false},
      {:persist_config, "~> 0.4", runtime: false}
    ]
  end
end
