defmodule GenServer.Proxy.Cast do
  alias GenServer.Proxy.{Log, Timer}

  @spec cast(term, term, module) :: :ok
  def cast(request, server_id, module) do
    server = module.server_name(server_id)

    try do
      GenServer.cast(server, request)
    catch
      :exit, reason ->
        Log.error(:exit, {server, reason})
        Timer.sleep(server, reason)

        try do
          GenServer.cast(server, request)
        catch
          :exit, reason ->
            Log.error(:exit, {server, reason})
            module.server_unregistered(server_id)
            :ok
        end
    end
  end
end
