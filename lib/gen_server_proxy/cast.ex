defmodule GenServer.Proxy.Cast do
  alias GenServer.Proxy.{Log, Timer}

  @spec cast(term, term, module) :: :ok
  def cast(request, server_id, module) do
    server_id |> module.server_name() |> GenServer.cast(request)
  catch
    :exit, reason ->
      Log.error(:exit, {reason})
      Timer.sleep(server_id, module, reason)

      try do
        server_id |> module.server_name() |> GenServer.cast(request)
      catch
        :exit, reason ->
          Log.error(:exit, {reason})
          module.server_unregistered(server_id)
          :ok
      end
  end
end
