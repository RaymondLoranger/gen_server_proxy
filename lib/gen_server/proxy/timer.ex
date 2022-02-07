defmodule GenServer.Proxy.Timer do
  use PersistConfig

  alias GenServer.Proxy.Log

  @timeout get_env(:timeout)
  @times get_env(:times)

  @spec wait(GenServer.name()) :: :ok
  def wait(server), do: wait(server, @times)

  ## Private functions

  # On restarts, wait if GenServer was killed or is not yet registered...
  @spec wait(GenServer.name(), non_neg_integer) :: :ok
  defp wait(_server, 0) do
    :ok
  end

  defp wait(server, times_left) do
    Process.sleep(@timeout)
    times_left = times_left - 1

    case GenServer.whereis(server) do
      # Note there is no guarantee the returned pid is alive,
      # as a process could terminate immediately after it is looked up.
      pid when is_pid(pid) ->
        times = @times - times_left
        now_registered = {server, @timeout, times, pid, __ENV__}
        :ok = Log.warn(:now_registered, now_registered)

      nil ->
        still_unregistered = {server, @timeout, times_left, __ENV__}
        :ok = Log.warn(:still_unregistered, still_unregistered)
        wait(server, times_left)
    end
  end
end
