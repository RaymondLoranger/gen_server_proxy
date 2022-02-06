defmodule GenServer.Proxy.Caster do
  use PersistConfig

  alias GenServer.Proxy.{Log, Timer}

  @timeout get_env(:timeout)
  @times get_env(:times)

  @spec cast(term, term, module) :: :ok | {:error, term}
  def cast(request, server_id, module) do
    server = module.server_name(server_id)

    try do
      GenServer.cast(server, request)
    catch
      :exit, reason ->
        unregistered = {:cast, server, @timeout, @times, reason, __ENV__}
        :ok = Log.warn(:unregistered, unregistered)
        Timer.wait(server, reason)

        try do
          GenServer.cast(server, request)
        catch
          :exit, reason ->
            :ok = Log.warn(:unregistered, {:cast, server, reason, __ENV__})
            module.server_unregistered(server_id)
            {:error, reason}
        end
    end
  end
end
