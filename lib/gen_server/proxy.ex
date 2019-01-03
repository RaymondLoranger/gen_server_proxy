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
  The default callback `module` is `<caller's module>.Callback`.

  ## Examples

      # Assuming the following callback module:

      defmodule Game.Engine.Callback do
        @behaviour GenServer.Proxy.Behaviour

        @impl GenServer.Proxy.Behaviour
        def server_name(game_name),
          do: {:via, Registry, {:registry, game_name}}

        @impl GenServer.Proxy.Behaviour
        def server_unregistered(game_name),
          do: IO.puts("Game #{game_name} not started.")
      end

      # We could use the 'call' macro like so:

      defmodule Game.Engine do
        use GenServer.Proxy

        def summary(game_name), do: call(:summary, game_name)
        ...
      end
  '''
  defmacro call(request, server_id, module \\ nil) do
    if module do
      quote bind_quoted: [request: request, server_id: server_id] do
        GenServer.Proxy.Call.call(request, server_id, unquote(module))
      end
    else
      quote bind_quoted: [request: request, server_id: server_id] do
        GenServer.Proxy.Call.call(request, server_id, __MODULE__.Callback)
      end
    end
  end

  defmacro cast(request, server_id, module \\ nil) do
    if module do
      quote bind_quoted: [request: request, server_id: server_id] do
        GenServer.Proxy.Cast.cast(request, server_id, unquote(module))
      end
    else
      quote bind_quoted: [request: request, server_id: server_id] do
        GenServer.Proxy.Cast.cast(request, server_id, __MODULE__.Callback)
      end
    end
  end

  defmacro stop(reason, server_id, module \\ nil) do
    if module do
      quote bind_quoted: [reason: reason, server_id: server_id] do
        GenServer.Proxy.Stop.stop(reason, server_id, unquote(module))
      end
    else
      quote bind_quoted: [reason: reason, server_id: server_id] do
        GenServer.Proxy.Stop.stop(reason, server_id, __MODULE__.Callback)
      end
    end
  end
end
