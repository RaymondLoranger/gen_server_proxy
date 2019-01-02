defmodule GenServer.Proxy.Agent do
  use PersistConfig

  alias GenServer.Proxy.Log

  @timeout Application.get_env(@app, :timeout)
  @times Application.get_env(@app, :times)

  @spec call(term, String.t(), module) :: term | :ok
  def call(request, server_id, module) do
    server_id |> module.server_name() |> GenServer.call(request)
  catch
    :exit, reason ->
      Log.error(:exit, {reason})
      wait_and_call(request, server_id, module, reason)
  end

  @spec stop(term, String.t(), module) :: :ok
  def stop(reason, server_id, module) do
    server_id |> module.server_name() |> GenServer.stop(reason)
  catch
    :exit, exit_reason ->
      Log.error(:exit, {exit_reason})
      wait_and_stop(reason, server_id, module, exit_reason)
  end

  ## Private functions

  @spec wait_and_call(term, String.t(), module, term) :: term | :ok
  defp wait_and_call(request, server_id, module, reason) do
    :ok = wait(server_id, module, reason, @times)
    server_id |> module.server_name() |> GenServer.call(request)
  catch
    :exit, reason ->
      Log.error(:exit, {reason})
      module.server_unregistered(server_id)
      :ok
  end

  @spec wait_and_stop(term, String.t(), module, term) :: :ok
  defp wait_and_stop(reason, server_id, module, exit_reason) do
    :ok = wait(server_id, module, exit_reason, @times)
    server_id |> module.server_name() |> GenServer.stop(reason)
  catch
    :exit, exit_reason ->
      Log.error(:exit, {exit_reason})
      module.server_unregistered(server_id)
      :ok
  end

  # On restarts, wait if name not yet registered...
  @spec wait(String.t(), module, term, non_neg_integer) :: :ok
  defp wait(server_id, _module, reason, 0) do
    Log.warn(:remains_unregistered, {server_id, @timeout, @times, reason})
  end

  defp wait(server_id, module, reason, times_left) do
    Log.info(:still_unregistered, {server_id, @timeout, times_left, reason})
    Process.sleep(@timeout)

    case server_id |> module.server_name() |> GenServer.whereis() do
      nil ->
        times = @times - times_left + 1
        Log.info(:now_registered, {server_id, @timeout, times, reason})

      pid when is_pid(pid) ->
        wait(server_id, reason, module, times_left - 1)
    end
  end
end
