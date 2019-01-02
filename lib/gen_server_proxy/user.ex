defmodule GenServer.Proxy.User do
  @callback server_name(server_id :: String.t()) :: GenServer.name()
  @callback server_unregistered(server_id :: String.t()) :: term
end
