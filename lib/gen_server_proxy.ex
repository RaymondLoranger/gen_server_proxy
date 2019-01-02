defmodule GenServer.Proxy do
  defmacro __using__(_options) do
    quote do
      require unquote(__MODULE__)
      alias unquote(__MODULE__)
    end
  end

  @doc """
  Performs a GenServer call.
  Will wait a bit if the server is not yet registered on restarts.

  ## Examples

      @behaviour GenServer.Proxy.User

      use GenServer.Proxy

      alias Buzzword.Bingo.Engine.{GameNotStarted, Server}

      @impl GenServer.Proxy.User
      def server_name(game_name), do: Server.via(game_name)

      @impl GenServer.Proxy.User
      def server_unregistered(game_name) do
        game_name |> GameNotStarted.message() |> IO.puts()
      end

      def summary(game_name) do
        Proxy.call(:summary, game_name)
      end
  """
  defmacro call(request, server_id, module \\ nil) do
    quote do
      module = if unquote(module), do: unquote(module), else: __MODULE__
      GenServer.Proxy.Agent.call(unquote(request), unquote(server_id), module)
    end
  end

  defmacro stop(reason, server_id, module \\ nil) do
    quote do
      module = if unquote(module), do: unquote(module), else: __MODULE__
      GenServer.Proxy.Agent.stop(unquote(reason), unquote(server_id), module)
    end
  end
end
