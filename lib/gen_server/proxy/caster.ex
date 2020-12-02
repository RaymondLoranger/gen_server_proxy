defmodule GenServer.Proxy.Caster do
  alias GenServer.Proxy.{Log, Timer}

  @spec cast(term, term, module) :: :ok | {:error, term}
  def cast(request, server_id, module) do
    server = module.server_name(server_id)

    try do
      GenServer.cast(server, request)
    catch
      :exit, reason ->
        :ok = Log.error(:exit, {server, reason, __ENV__})
        Timer.sleep(server, reason)

        try do
          GenServer.cast(server, request)
        catch
          :exit, reason ->
            :ok = Log.error(:exit, {server, reason, __ENV__})
            module.server_unregistered(server_id)
            {:error, reason}
        end
    end
  end
end
