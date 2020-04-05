defmodule GenServer.Proxy.Stop do
  alias GenServer.Proxy.{Log, Timer}

  @spec stop(term, term, module) :: :ok | {:error, term}
  def stop(reason, server_id, module) do
    server = module.server_name(server_id)

    try do
      GenServer.stop(server, reason)
    catch
      :exit, exit_reason ->
        Log.error(:exit, {server, exit_reason})
        Timer.sleep(server, exit_reason)

        try do
          GenServer.stop(server, reason)
        catch
          :exit, exit_reason ->
            Log.error(:exit, {server, exit_reason})
            module.server_unregistered(server_id)
            {:error, reason}
        end
    end
  end
end
