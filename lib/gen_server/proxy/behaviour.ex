defmodule GenServer.Proxy.Behaviour do
  @callback server_name(server_id :: term) :: GenServer.name()
  @callback server_unregistered(server_id :: term) :: term
end
