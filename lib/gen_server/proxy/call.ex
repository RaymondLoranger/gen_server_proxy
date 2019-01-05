defmodule GenServer.Proxy.Call do
  alias GenServer.Proxy.{Log, Timer}

  @spec call(term, term, module) :: term | :ok
  def call(request, server_id, module) do
    server_id |> module.server_name() |> GenServer.call(request)
  catch
    :exit, reason ->
      Log.error(:exit, {server_id, reason})
      Timer.sleep(server_id, module, reason)

      try do
        server_id |> module.server_name() |> GenServer.call(request)
      catch
        :exit, reason ->
          Log.error(:exit, {server_id, reason})
          module.server_unregistered(server_id)
          :ok
      end
  end
end
