defmodule GenServer.Proxy.Caster do
  use PersistConfig

  alias GenServer.Proxy
  alias GenServer.Proxy.{Log, Timer}

  @timeout get_env(:timeout)
  @times get_env(:times)

  @spec cast(Proxy.server_id(), term, module) :: :ok | {:error, term}
  def cast(server_id, request, module) do
    server = module.server_name(server_id)

    try do
      GenServer.cast(server, request)
    catch
      :exit, reason ->
        failed = {:cast, 2, server, @timeout, @times, reason, __ENV__}
        :ok = Log.warn(:failed, failed)
        :ok = Timer.wait(server)

        try do
          GenServer.cast(server, request)
        catch
          :exit, reason ->
            :ok = Log.warn(:failed_again, {:cast, 2, server, reason, __ENV__})
            module.server_unregistered(server_id)
            {:error, reason}
        end
    end
  end
end
