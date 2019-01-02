defmodule GenServer.Proxy do
  defmacro __using__(options) do
    alias = options[:alias]

    if alias do
      quote do
        alias unquote(__MODULE__), as: unquote(alias)
        require unquote(alias)
      end
    else
      quote do
        import unquote(__MODULE__)
      end
    end
  end

  @doc ~S'''
  Performs a GenServer call.
  Will wait a bit if the server is not yet registered on restarts.

  ## Examples

      # Assuming the following callback module:

      defmodule GenServer.Proxy.Callback do
        @behaviour GenServer.Proxy.Behaviour

        @impl GenServer.Proxy.Behaviour
        def server_name(game_name),
          do: {:via, Registry, {:registry, game_name}}

        @impl GenServer.Proxy.Behaviour
        def server_unregistered(game_name),
          do: IO.puts("Game #{game_name} not started.")
      end

      # We could use the call macro like so:

      use GenServer.Proxy

      def summary(game_name), do: call(:summary, game_name)
  '''
  defmacro call(request, server_id, module \\ __MODULE__.Callback) do
    quote do:
            GenServer.Proxy.Call.call(
              unquote(request),
              unquote(server_id),
              unquote(module)
            )
  end

  defmacro cast(request, server_id, module \\ __MODULE__.Callback) do
    quote do:
            GenServer.Proxy.Cast.cast(
              unquote(request),
              unquote(server_id),
              unquote(module)
            )
  end

  defmacro stop(request, server_id, module \\ __MODULE__.Callback) do
    quote do:
            GenServer.Proxy.Stop.stop(
              unquote(request),
              unquote(server_id),
              unquote(module)
            )
  end
end
