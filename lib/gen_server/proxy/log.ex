defmodule GenServer.Proxy.Log do
  use File.Only.Logger

  error :unregistered, {fun, server, reason, env} do
    """
    \n'GenServer.#{fun}/2' failed: server unregistered...
    • Inside function:
      #{fun(env)}
    • Server:
      #{inspect(server)}
    • Reason:
      #{inspect(reason)}
    #{from()}
    """
  end

  error :unregistered, {fun, server, timeout, times, reason, env} do
    """
    \n'GenServer.#{fun}/2' failed: server unregistered...
    • Inside function:
      #{fun(env)}
    • Server:
      #{inspect(server)}
    • Waiting: #{timeout} ms
    • Times left: #{times}
    • Reason:
      #{inspect(reason)}
    #{from()}
    """
  end

  warn :remains_unregistered, {server, timeout, times, reason, env} do
    """
    \nServer remains unregistered...
    • Inside function:
      #{fun(env)}
    • Server:
      #{inspect(server)}
    • Waited: #{timeout} ms
    • Times: #{times}
    • Issue remaining 'unresolved':
      #{inspect(reason)}
    #{from()}
    """
  end

  info :still_unregistered, {server, timeout, times_left, reason, env} do
    """
    \nServer still unregistered...
    • Inside function:
      #{fun(env)}
    • Server:
      #{inspect(server)}
    • Waited: #{timeout} ms
    • Times left: #{times_left}
    • Issue still 'unresolved':
      #{inspect(reason)}
    #{from()}
    """
  end

  info :now_registered, {server, timeout, times, reason, pid, env} do
    """
    \nServer now registered...
    • Inside function:
      #{fun(env)}
    • Server:
      #{inspect(server)}
    • Server PID: #{inspect(pid)}
    • Waited: #{timeout} ms
    • Times: #{times}
    • Issue now 'resolved':
      #{inspect(reason)}
    #{from()}
    """
  end
end
