defmodule GenServer.Proxy.Timer do
  use PersistConfig

  alias GenServer.Proxy.Log

  @timeout get_env(:timeout)
  @times get_env(:times)

  @spec wait(GenServer.name(), term) :: :ok
  def wait(server, reason), do: wait(server, reason, @times)

  ## Private functions

  # On restarts, wait if server not yet registered...
  @spec wait(GenServer.name(), term, non_neg_integer) :: :ok
  defp wait(server, reason, 0) do
    remains_unregistered = {server, @timeout, @times, reason, __ENV__}
    :ok = Log.warn(:remains_unregistered, remains_unregistered)
  end

  defp wait(server, reason, times_left) do
    Process.sleep(@timeout)
    times_left = times_left - 1

    case GenServer.whereis(server) do
      pid when is_pid(pid) ->
        times = @times - times_left
        now_registered = {server, @timeout, times, reason, pid, __ENV__}
        :ok = Log.warn(:now_registered, now_registered)

      nil ->
        still_unregistered = {server, @timeout, times_left, reason, __ENV__}
        :ok = Log.warn(:still_unregistered, still_unregistered)
        wait(server, reason, times_left)
    end
  end
end
