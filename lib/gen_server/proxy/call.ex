defmodule GenServer.Proxy.Call do
  alias GenServer.Proxy.{Log, Timer}

  @spec call(term, term, module) :: term | :ok
  def call(request, server_id, module) do
    server = module.server_name(server_id)

    try do
      GenServer.call(server, request)
    catch
      :exit, reason ->
        Log.error(:exit, {server, reason})
        Timer.sleep(server, reason)

        try do
          GenServer.call(server, request)
        catch
          :exit, reason ->
            Log.error(:exit, {server, reason})
            module.server_unregistered(server_id)
            {:error, reason}
        end
    end
  end
end
