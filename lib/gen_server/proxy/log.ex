defmodule GenServer.Proxy.Log do
  use File.Only.Logger
  use PersistConfig

  error :exit, {server_id, reason} do
    """
    \n'exit' caught...
    • Server: #{inspect(server_id, pretty: true)}
    • Reason:
      #{inspect(reason, pretty: true)}
    • App: #{Mix.Project.config()[:app]}
    • Library: #{@app}
    • Module: #{inspect(__MODULE__)}
    """
  end

  warn :remains_unregistered, {server_id, timeout, times, reason} do
    """
    \nServer remains unregistered...
    • Server: #{inspect(server_id, pretty: true)}
    • Waited: #{timeout} ms
    • Times: #{times}
    • Reason:
      #{inspect(reason, pretty: true)}
    • App: #{Mix.Project.config()[:app]}
    • Library: #{@app}
    • Module: #{inspect(__MODULE__)}
    """
  end

  info :still_unregistered, {server_id, timeout, times_left, reason} do
    """
    \nServer still unregistered...
    • Server: #{inspect(server_id, pretty: true)}
    • Waiting: #{timeout} ms
    • Times left: #{times_left}
    • Reason:
      #{inspect(reason, pretty: true)}
    • App: #{Mix.Project.config()[:app]}
    • Library: #{@app}
    • Module: #{inspect(__MODULE__)}
    """
  end

  info :now_registered, {server_id, timeout, times, reason, pid} do
    """
    \nServer now registered...
    • Server: #{inspect(server_id, pretty: true)}
    • Waited: #{timeout} ms
    • Times: #{times}
    • Reason:
      #{inspect(reason, pretty: true)}
    • PID: #{inspect(pid, pretty: true)}
    • App: #{Mix.Project.config()[:app]}
    • Library: #{@app}
    • Module: #{inspect(__MODULE__)}
    """
  end
end
