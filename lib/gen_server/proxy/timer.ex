defmodule GenServer.Proxy.Timer do
  use PersistConfig

  alias GenServer.Proxy.Log

  @timeout Application.get_env(@app, :timeout)
  @times Application.get_env(@app, :times)

  @spec sleep(GenServer.name(), term) :: :ok
  def sleep(server, reason) do
    sleep(server, reason, @times)
  end

  ## Private functions

  # On restarts, wait if server not yet registered...
  @spec sleep(GenServer.name(), term, non_neg_integer) :: :ok
  defp sleep(server, reason, 0) do
    Log.warn(:remains_unregistered, {server, @timeout, @times, reason})
  end

  defp sleep(server, reason, times_left) do
    Log.info(:still_unregistered, {server, @timeout, times_left, reason})
    Process.sleep(@timeout)

    case GenServer.whereis(server) do
      pid when is_pid(pid) ->
        times = @times - times_left + 1
        Log.info(:now_registered, {server, @timeout, times, reason, pid})

      nil ->
        sleep(server, reason, times_left - 1)
    end
  end
end
