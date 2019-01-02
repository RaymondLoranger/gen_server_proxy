defmodule GenServer.Proxy do
  defmacro __using__(_options) do
    quote do
      require unquote(__MODULE__)
      alias unquote(__MODULE__)
    end
  end

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
