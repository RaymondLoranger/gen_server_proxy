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
      :exit, exit_reason ->
        not_registered = {server, @timeout, @times, exit_reason, __ENV__}
        :ok = Log.error(:unregistered, not_registered)
        Timer.wait(server, exit_reason)

        try do
          GenServer.stop(server, reason)
        catch
          :exit, exit_reason ->
            :ok = Log.error(:unregistered, {server, exit_reason, __ENV__})
            module.server_unregistered(server_id)
            {:error, exit_reason}
        end
    end
  end
end
