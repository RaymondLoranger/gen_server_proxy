defmodule GenServer.Proxy.Log do
  use File.Only.Logger

  warn :failed, {fun, arity, server, timeout, times, reason, env} do
    """
    \n'GenServer.#{fun}/#{arity}' failed...
    • Server: #{inspect(server) |> maybe_break(10)}
    • Reason: #{inspect(reason) |> maybe_break(10)}
    • Waiting: #{timeout} ms
    • Times: #{times}
    #{from(env, __MODULE__)}
    """
  end

  warn :failed_again, {fun, arity, server, reason, env} do
    """
    \n'GenServer.#{fun}/#{arity}' failed again...
    • Server: #{inspect(server) |> maybe_break(10)}
    • Reason: #{inspect(reason) |> maybe_break(10)}
    #{from(env, __MODULE__)}
    """
  end

  warn :unregistered, {server, timeout, times_left, env} do
    """
    \nServer unregistered...
    • Server: #{inspect(server) |> maybe_break(10)}
    • Waited: #{timeout} ms
    • Times left: #{times_left}
    #{from(env, __MODULE__)}
    """
  end

  warn :registered, {server, timeout, times, pid, env} do
    """
    \nServer registered...
    • Server: #{inspect(server) |> maybe_break(10)}
    • Server PID: #{inspect(pid)}
    • Waited: #{timeout} ms
    • Times: #{times}
    #{from(env, __MODULE__)}
    """
  end
end
