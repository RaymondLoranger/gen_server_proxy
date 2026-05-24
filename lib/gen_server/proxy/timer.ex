defmodule GenServer.Proxy.Timer do
  use PersistConfig

  alias GenServer.Proxy
  alias GenServer.Proxy.Log

  @timeout get_env(:timeout)
  @times get_env(:times)

  # On restarts, wait if GenServer was killed or is not yet registered.
  # Note this is an assumption as the GenServer may have never started.
  @spec wait(GenServer.name(), Proxy.server_id(), module, non_neg_integer) ::
          :ok
  def wait(_server, _server_id, _module, 0) do
    :ok
  end

  def wait(server, server_id, module, times_left) do
    Process.sleep(@timeout)
    times_left = times_left - 1

    case GenServer.whereis(server) do
      # Note there is no guarantee the returned PID is alive, as a
      # process could terminate immediately after it is looked up.
      pid when is_pid(pid) ->
        times = @times - times_left
        now_registered = {server, @timeout, times, pid, __ENV__}
        :ok = Log.notice(:now_registered, now_registered)

      nil ->
        log(server, server_id, module, times_left)
        wait(server, server_id, module, times_left)
    end
  end

  ## Private functions

  @spec log(GenServer.name(), Proxy.server_id(), module, non_neg_integer) :: :ok
  defp log(server, server_id, module, 0) do
    module.server_unregistered(server_id)
    remains_unregistered = {server, @timeout, @times, __ENV__}
    :ok = Log.error(:remains_unregistered, remains_unregistered)
  end

  defp log(server, _server_id, _module, times_left) do
    still_unregistered = {server, @timeout, times_left, __ENV__}
    :ok = Log.warning(:still_unregistered, still_unregistered)
  end
end
