defmodule GenServer.Proxy.Caster do
  alias GenServer.Proxy

  @doc """
  Sends an asynchronous request to the GenServer registered via `server_id`.
  No need to wait for the GenServer to be registered as this is asynchronous.
  """
  @spec cast(Proxy.server_id(), term, module) :: :ok
  def cast(server_id, request, module) do
    server = module.server_name(server_id)
    GenServer.cast(server, request)
  end
end
