defmodule GenServer.Proxy do
  @moduledoc """
  Invokes `call`, `cast` or `stop` in `GenServer` with a registered server.
  Will wait a bit if the server is not yet registered on restarts.
  """

  @doc """
  Converts `server_id` into a server name like a `via tuple`.

  ## Examples

      @impl GenServer.Proxy
      def server_name(game_name),
        do: {:via, Registry, {:registry, game_name}}

      @impl GenServer.Proxy
      def server_name(game_name),
        do: {:global, {GameServer, game_name}}
  """
  @callback server_name(server_id :: term) :: GenServer.name()

  @doc ~S'''
  Called when the server remains unregistered despite waiting a bit.

  ## Examples

      @impl GenServer.Proxy
      def server_unregistered(game_name),
        do: IO.puts("Game #{game_name} not started.")
  '''
  @callback server_unregistered(server_id :: term) :: term

  @doc """
  Either aliases `GenServer.Proxy` (this module) and requires the alias or
  imports `GenServer.Proxy`. In the latter case, you could instead simply
  `import GenServer.Proxy`.

  ## Examples

      use GenServer.Proxy, alias: Proxy

      use GenServer.Proxy

      import GenServer.Proxy
  """
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
  Makes a synchronous call to the registered server identified by `server_id`.
  Will wait a bit if the server is not yet registered on restarts.

  The given `module` (or by default `<caller's_module>.GenServerProxy`) must
  implement the 2 callbacks of `GenServer.Proxy` (this module).

  ## Examples

      # Assuming the following callback module:

      defmodule Game.Engine.GenServerProxy do
        @behaviour GenServer.Proxy

        @impl GenServer.Proxy
        def server_name(game_name),
          do: {:via, Registry, {:registry, game_name}}

        @impl GenServer.Proxy
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
        GenServer.Proxy.Caller.call(request, id, __MODULE__.GenServerProxy)
      end
    end
  end

  @doc """
  Sends an async request to the registered server identified by `server_id`.
  Will wait a bit if the server is not yet registered on restarts.

  The given `module` (or by default `<caller's_module>.GenServerProxy`) must
  implement the 2 callbacks of `GenServer.Proxy` (this module).
  """
  defmacro cast(request, server_id, module \\ nil) do
    if module do
      quote bind_quoted: [request: request, id: server_id, module: module] do
        GenServer.Proxy.Caster.cast(request, id, module)
      end
    else
      quote bind_quoted: [request: request, id: server_id] do
        GenServer.Proxy.Caster.cast(request, id, __MODULE__.GenServerProxy)
      end
    end
  end

  @doc """
  Synchronously stops the registered server identified by `server_id`.
  Will wait a bit if the server is not yet registered on restarts.

  The given `module` (or by default `<caller's_module>.GenServerProxy`) must
  implement the 2 callbacks of `GenServer.Proxy` (this module).
  """
  defmacro stop(reason, server_id, module \\ nil) do
    if module do
      quote bind_quoted: [reason: reason, id: server_id, module: module] do
        GenServer.Proxy.Stopper.stop(reason, id, module)
      end
    else
      quote bind_quoted: [reason: reason, id: server_id] do
        GenServer.Proxy.Stopper.stop(reason, id, __MODULE__.GenServerProxy)
      end
    end
  end
end
