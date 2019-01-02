defmodule GenServer.Proxy.Timer do
  use PersistConfig

  alias GenServer.Proxy.Log

  @timeout Application.get_env(@app, :timeout)
  @times Application.get_env(@app, :times)

  @spec sleep(term, module, term) :: :ok
  def sleep(server_id, module, reason) do
    sleep(server_id, module, reason, @times)
  end

  ## Private functions

  # On restarts, wait if server not yet registered...
  @spec sleep(term, module, term, non_neg_integer) :: :ok
  defp sleep(server_id, _module, reason, 0) do
    Log.warn(:remains_unregistered, {server_id, @timeout, @times, reason})
  end

  defp sleep(server_id, module, reason, times_left) do
    Log.info(:still_unregistered, {server_id, @timeout, times_left, reason})
    Process.sleep(@timeout)

    case server_id |> module.server_name() |> GenServer.whereis() do
      nil ->
        times = @times - times_left + 1
        Log.info(:now_registered, {server_id, @timeout, times, reason})

      pid when is_pid(pid) ->
        sleep(server_id, reason, module, times_left - 1)
    end
  end
end
