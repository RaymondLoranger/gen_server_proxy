defmodule GenServer.Proxy.Behaviour do
  @callback server_name(String.t()) :: GenServer.name()
  @callback server_unregistered(String.t()) :: term
  @callback server_pid(String.t()) :: pid
end
