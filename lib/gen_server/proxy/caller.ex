defmodule GenServer.Proxy.Caller do
  use PersistConfig

  alias GenServer.Proxy
  alias GenServer.Proxy.{Log, Timer}

  @timeout get_env(:timeout)
  @times get_env(:times)

  @doc """
  Makes a synchronous call to the GenServer registered via `server_id`.
  Will wait a bit if the GenServer is not yet registered on restarts.
  """
  @spec call(Proxy.server_id(), term, timeout, module) :: term
  def call(server_id, request, timeout, module) do
    server = module.server_name(server_id)

    try do
      GenServer.call(server, request, timeout)
    catch
      # Reason is typically {:killed | :noproc, mfargs},
      # where mfargs is {GenServer, :call, [server, request, timeout]}.
      # Whatever the reason, we wait, expecting OTP to fix the issue...
      :exit, reason ->
        failed = {:call, 3, server, @timeout, @times, reason, __ENV__}
        :ok = Log.warning(:failed, failed)
        :ok = Timer.wait(server, server_id, module, @times)
        GenServer.call(server, request, timeout)
    end
  end
end
