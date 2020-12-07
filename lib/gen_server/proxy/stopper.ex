defmodule GenServer.Proxy.Stopper do
  use PersistConfig

  alias GenServer.Proxy.{Log, Timer}

  @timeout get_env(:timeout)
  @times get_env(:times)

  @spec stop(term, term, module) :: :ok | {:error, term}
  def stop(reason, server_id, module) do
    server = module.server_name(server_id)

    try do
      GenServer.stop(server, reason)
    catch
      :exit, error ->
        unregistered = {:stop, server, @timeout, @times, error, __ENV__}
        :ok = Log.error(:unregistered, unregistered)
        Timer.wait(server, error)

        try do
          GenServer.stop(server, reason)
        catch
          :exit, error ->
            :ok = Log.error(:unregistered, {:stop, server, error, __ENV__})
            module.server_unregistered(server_id)
            {:error, error}
        end
    end
  end
end
