defmodule GenServer.Proxy do
  @moduledoc """
  Invokes the following functions with a GenServer registered via a server ID:

  - `GenServer.call/3`
  - `GenServer.cast/2`
  - `GenServer.stop/3`

  Will wait a bit if the GenServer is not yet registered on restarts.
  """

  @typedoc "Server ID"
  @type server_id :: term

  @doc """
  Called to convert the `server_id` into a server name.

  ## Examples

      @impl GenServer.Proxy
      def server_name(game_name),
        do: {:via, Registry, {:registry, game_name}}

      @impl GenServer.Proxy
      def server_name(game_name),
        do: {:global, {GameServer, game_name}}
  """
  @callback server_name(server_id) :: GenServer.name()

  @doc ~S'''
  Called when the server remains unregistered despite waiting a bit.
  Should serve to print a relevant message about the failed request.
  This callback is overridable i.e. it has a default implementation.

  ## Examples

      @impl GenServer.Proxy
      def server_unregistered(game_name),
        do: :ok = IO.puts("Game #{game_name} not started.")
  '''
  @callback server_unregistered(server_id) :: term

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
        def server_unregistered(_server_id), do: :ok
        defoverridable server_unregistered: 1
      end
    else
      quote do
        import unquote(__MODULE__)
        def server_unregistered(_server_id), do: :ok
        defoverridable server_unregistered: 1
      end
    end
  end

  @doc ~S'''
  Makes a synchronous call to the GenServer registered via `server_id`.
  Will wait a bit if the GenServer is not yet registered on restarts.

  The given `module` (or by default `<caller's_module>.GenServerProxy`) must
  implement callback `c:GenServer.Proxy.server_name/1`.

  ## Examples

      # Assuming the following callback module:

      defmodule Game.Engine.GenServerProxy do
        @behaviour GenServer.Proxy

        @impl GenServer.Proxy
        def server_name(game_name),
          do: {:via, Registry, {:registry, game_name}}

        @impl GenServer.Proxy
        def server_unregistered(game_name),
          do: :ok = IO.puts("Game #{game_name} not started.")
      end

      # We could use the call macro like so:

      defmodule Game.Engine do
        use GenServer.Proxy

        def summary(game_name), do: call(game_name, :summary)
        ...
      end
  '''
  defmacro call(server_id, request, timeout \\ 5000, module \\ nil) do
    if module do
      quote bind_quoted: [
              server_id: server_id,
              request: request,
              timeout: timeout,
              module: module
            ] do
        GenServer.Proxy.Caller.call(server_id, request, timeout, module)
      end
    else
      quote bind_quoted: [
              server_id: server_id,
              request: request,
              timeout: timeout
            ] do
        GenServer.Proxy.Caller.call(
          server_id,
          request,
          timeout,
          __MODULE__.GenServerProxy
        )
      end
    end
  end

  @doc """
  Sends an async request to the GenServer registered via `server_id`.
  Will wait a bit if the GenServer is not yet registered on restarts.

  The given `module` (or by default `<caller's_module>.GenServerProxy`) must
  implement callback `c:GenServer.Proxy.server_name/1`.
  """
  defmacro cast(server_id, request, module \\ nil) do
    if module do
      quote bind_quoted: [
              server_id: server_id,
              request: request,
              module: module
            ] do
        GenServer.Proxy.Caster.cast(server_id, request, module)
      end
    else
      quote bind_quoted: [server_id: server_id, request: request] do
        GenServer.Proxy.Caster.cast(
          server_id,
          request,
          __MODULE__.GenServerProxy
        )
      end
    end
  end

  @doc """
  Synchronously stops the GenServer registered via `server_id`.
  Will wait a bit if the GenServer is not yet registered on restarts.

  The given `module` (or by default `<caller's_module>.GenServerProxy`) must
  implement callback `c:GenServer.Proxy.server_name/1`.
  """
  defmacro stop(
             server_id,
             reason \\ :normal,
             timeout \\ :infinity,
             module \\ nil
           ) do
    if module do
      quote bind_quoted: [
              server_id: server_id,
              reason: reason,
              timeout: timeout,
              module: module
            ] do
        GenServer.Proxy.Stopper.stop(server_id, reason, timeout, module)
      end
    else
      quote bind_quoted: [
              server_id: server_id,
              reason: reason,
              timeout: timeout
            ] do
        GenServer.Proxy.Stopper.stop(
          server_id,
          reason,
          timeout,
          __MODULE__.GenServerProxy
        )
      end
    end
  end
end
