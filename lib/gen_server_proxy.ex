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

  @doc """
  Performs a GenServer call.
  Will wait a bit if the server is not yet registered on restarts.

  ## Examples

      use GenServer.Proxy

      def summary(game_name), do: call(:summary, game_name)
  """
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
