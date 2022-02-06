defmodule GenServer.Proxy.Caller do
  use PersistConfig

  alias GenServer.Proxy.{Log, Timer}

  @timeout get_env(:timeout)
  @times get_env(:times)

  @spec call(term, term, module) :: term | {:error, term}
  def call(request, server_id, module) do
    server = module.server_name(server_id)

    try do
      GenServer.call(server, request)
    catch
      :exit, reason ->
        unregistered = {:call, server, @timeout, @times, reason, __ENV__}
        :ok = Log.warn(:unregistered, unregistered)
        Timer.wait(server, reason)

        try do
          GenServer.call(server, request)
        catch
          :exit, reason ->
            :ok = Log.warn(:unregistered, {:call, server, reason, __ENV__})
            module.server_unregistered(server_id)
            {:error, reason}
        end
    end
  end
end
