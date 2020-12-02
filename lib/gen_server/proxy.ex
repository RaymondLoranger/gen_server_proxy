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

  The given `module` (or by default `<caller's_module>.Callback`) must
  implement the 2 callbacks of `GenServer.Proxy.Behaviour`.

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

      # We could use the call macro like so:

      defmodule Game.Engine do
        use GenServer.Proxy

        def summary(game_name), do: call(:summary, game_name)
        ...
      end
  '''
  defmacro call(request, server_id, module \\ nil) do
    if module do
      quote bind_quoted: [request: request, id: server_id, module: module] do
        GenServer.Proxy.Caller.call(request, id, module)
      end
    else
      quote bind_quoted: [request: request, id: server_id] do
        GenServer.Proxy.Caller.call(request, id, __MODULE__.Callback)
      end
    end
  end

  defmacro cast(request, server_id, module \\ nil) do
    if module do
      quote bind_quoted: [request: request, id: server_id, module: module] do
        GenServer.Proxy.Caster.cast(request, id, module)
      end
    else
      quote bind_quoted: [request: request, id: server_id] do
        GenServer.Proxy.Caster.cast(request, id, __MODULE__.Callback)
      end
    end
  end

  defmacro stop(reason, server_id, module \\ nil) do
    if module do
      quote bind_quoted: [reason: reason, id: server_id, module: module] do
        GenServer.Proxy.Stopper.stop(reason, id, module)
      end
    else
      quote bind_quoted: [reason: reason, id: server_id] do
        GenServer.Proxy.Stopper.stop(reason, id, __MODULE__.Callback)
      end
    end
  end
end
