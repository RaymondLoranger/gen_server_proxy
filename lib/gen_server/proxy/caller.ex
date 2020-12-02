defmodule GenServer.Proxy.Caller do
  alias GenServer.Proxy.{Log, Timer}

  @spec call(term, term, module) :: term | {:error, term}
  def call(request, server_id, module) do
    server = module.server_name(server_id)

    try do
      GenServer.call(server, request)
    catch
      :exit, reason ->
        :ok = Log.error(:exit, {server, reason, __ENV__})
        Timer.sleep(server, reason)

        try do
          GenServer.call(server, request)
        catch
          :exit, reason ->
            :ok = Log.error(:exit, {server, reason, __ENV__})
            module.server_unregistered(server_id)
            {:error, reason}
        end
    end
  end
end
