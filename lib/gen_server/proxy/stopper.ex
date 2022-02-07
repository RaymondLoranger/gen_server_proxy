defmodule GenServer.Proxy.Stopper do
  use PersistConfig

  alias GenServer.Proxy
  alias GenServer.Proxy.{Log, Timer}

  @timeout get_env(:timeout)
  @times get_env(:times)

  @spec stop(Proxy.server_id(), term, timeout, module) :: :ok | {:error, term}
  def stop(server_id, reason, timeout, module) do
    server = module.server_name(server_id)

    try do
      GenServer.stop(server, reason, timeout)
    catch
      :exit, cause ->
        failed = {:stop, 3, server, @timeout, @times, cause, __ENV__}
        :ok = Log.warn(:failed, failed)
        :ok = Timer.wait(server)

        try do
          GenServer.stop(server, reason, timeout)
        catch
          :exit, cause ->
            :ok = Log.warn(:failed_again, {:stop, 3, server, cause, __ENV__})
            module.server_unregistered(server_id)
            {:error, cause}
        end
    end
  end
end
