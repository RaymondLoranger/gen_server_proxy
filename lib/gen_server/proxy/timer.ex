defmodule GenServer.Proxy.Timer do
  use PersistConfig

  alias GenServer.Proxy.Log

  @timeout get_env(:timeout)
  @times get_env(:times)

  @spec sleep(GenServer.name(), term) :: :ok
  def sleep(server, reason), do: sleep(server, reason, @times)

  ## Private functions

  # On restarts, wait if server not yet registered...
  @spec sleep(GenServer.name(), term, non_neg_integer) :: :ok
  defp sleep(server, reason, 0) do
    remains_unregistered_vars = {server, @timeout, @times, reason, __ENV__}
    :ok = Log.warn(:remains_unregistered, remains_unregistered_vars)
  end

  defp sleep(server, reason, times_left) do
    still_unregistered_vars = {server, @timeout, times_left, reason, __ENV__}
    :ok = Log.info(:still_unregistered, still_unregistered_vars)
    Process.sleep(@timeout)

    case GenServer.whereis(server) do
      pid when is_pid(pid) ->
        times = @times - times_left + 1
        now_registered_vars = {server, @timeout, times, reason, pid, __ENV__}
        :ok = Log.info(:now_registered, now_registered_vars)

      nil ->
        sleep(server, reason, times_left - 1)
    end
  end
end
