defmodule GenServer.Proxy.Stopper do
  alias GenServer.Proxy.{Log, Timer}

  @spec stop(term, term, module) :: :ok | {:error, term}
  def stop(reason, server_id, module) do
    server = module.server_name(server_id)

    try do
      GenServer.stop(server, reason)
    catch
      :exit, exit_reason ->
        :ok = Log.error(:exit, {server, exit_reason, __ENV__})
        Timer.sleep(server, exit_reason)

        try do
          GenServer.stop(server, reason)
        catch
          :exit, exit_reason ->
            :ok = Log.error(:exit, {server, exit_reason, __ENV__})
            module.server_unregistered(server_id)
            {:error, reason}
        end
    end
  end
end
