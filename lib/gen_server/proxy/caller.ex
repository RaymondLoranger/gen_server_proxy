defmodule GenServer.Proxy.Caller do
  use PersistConfig

  alias GenServer.Proxy
  alias GenServer.Proxy.{Log, Timer}

  @timeout get_env(:timeout)
  @times get_env(:times)

  @spec call(Proxy.server_id(), term, timeout, module) :: term | {:error, term}
  def call(server_id, request, timeout, module) do
    server = module.server_name(server_id)

    try do
      GenServer.call(server, request, timeout)
    catch
      # Reason is typically {:killed | :noproc, mfargs},
      # where mfargs is {GenServer, :call, [server, request, timeout]}.
      # Whatever the reason, we wait expecting OTP to fix the issue...
      :exit, reason ->
        failed = {:call, 3, server, @timeout, @times, reason, __ENV__}
        :ok = Log.warn(:failed, failed)
        :ok = Timer.wait(server)

        try do
          GenServer.call(server, request, timeout)
        catch
          :exit, reason ->
            :ok = Log.warn(:failed_again, {:call, 3, server, reason, __ENV__})
            module.server_unregistered(server_id)
            {:error, reason}
        end
    end
  end
end
