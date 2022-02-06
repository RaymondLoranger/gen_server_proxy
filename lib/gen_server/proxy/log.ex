defmodule GenServer.Proxy.Log do
  use File.Only.Logger

  warn :unregistered, {fun, server, reason, env} do
    """
    \n'GenServer.#{fun}/2' failed: server unregistered...
    • Server: #{inspect(server) |> maybe_break(10)}
    • Reason: #{inspect(reason) |> maybe_break(10)}
    #{from(env, __MODULE__)}
    """
  end

  warn :unregistered, {fun, server, timeout, times, reason, env} do
    """
    \n'GenServer.#{fun}/2' failed: server unregistered...
    • Server: #{inspect(server) |> maybe_break(10)}
    • Waiting: #{timeout} ms
    • Times left: #{times}
    • Reason: #{inspect(reason) |> maybe_break(10)}
    #{from(env, __MODULE__)}
    """
  end

  warn :remains_unregistered, {server, timeout, times, reason, env} do
    """
    \nServer remains unregistered...
    • Server: #{inspect(server) |> maybe_break(10)}
    • Waited: #{timeout} ms
    • Times: #{times}
    • Issue remaining 'unresolved': #{inspect(reason) |> maybe_break(32)}
    #{from(env, __MODULE__)}
    """
  end

  warn :still_unregistered, {server, timeout, times_left, reason, env} do
    """
    \nServer still unregistered...
    • Server: #{inspect(server) |> maybe_break(10)}
    • Waited: #{timeout} ms
    • Times left: #{times_left}
    • Issue still 'unresolved': #{inspect(reason) |> maybe_break(28)}
    #{from(env, __MODULE__)}
    """
  end

  warn :now_registered, {server, timeout, times, reason, pid, env} do
    """
    \nServer now registered...
    • Server: #{inspect(server) |> maybe_break(10)}
    • Server PID: #{inspect(pid)}
    • Waited: #{timeout} ms
    • Times: #{times}
    • Issue now 'resolved': #{inspect(reason) |> maybe_break(24)}
    #{from(env, __MODULE__)}
    """
  end
end
