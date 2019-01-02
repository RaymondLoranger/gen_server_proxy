defmodule GenServer.Proxy.Stop do
  alias GenServer.Proxy.{Log, Timer}

  @spec stop(term, term, module) :: :ok
  def stop(reason, server_id, module) do
    server_id |> module.server_name() |> GenServer.stop(reason)
  catch
    :exit, reason ->
      Log.error(:exit, {reason})
      Timer.sleep(server_id, module, reason)

      try do
        server_id |> module.server_name() |> GenServer.stop(reason)
      catch
        :exit, reason ->
          Log.error(:exit, {reason})
          module.server_unregistered(server_id)
          :ok
      end
  end
end
