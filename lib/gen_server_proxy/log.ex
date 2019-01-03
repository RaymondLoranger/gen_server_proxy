defmodule GenServer.Proxy.Log do
  use File.Only.Logger

  error :exit, {reason} do
    """
    \n'exit' caught:
    • Reason:
    #{inspect(reason)}
    """
  end

  warn :remains_unregistered, {server_id, timeout, times, reason} do
    """
    \nServer #{inspect(server_id)} remains unregistered after:
    • Waiting: #{timeout} ms
    • Times: #{times}
    • Reason:
    #{inspect(reason)}
    """
  end

  info :still_unregistered, {server_id, timeout, times_left, reason} do
    """
    \nServer #{inspect(server_id)} still unregistered:
    • Waiting: #{timeout} ms
    • Times left: #{times_left}
    • Reason:
    #{inspect(reason)}
    """
  end

  info :now_registered, {server_id, timeout, times, reason} do
    """
    \nServer #{inspect(server_id)} now registered after:
    • Waiting: #{timeout} ms
    • Times: #{times}
    • Reason:
    #{inspect(reason)}
    """
  end
end
