defmodule GenServer.ProxyTest.GenServerProxy do
  @behaviour GenServer.Proxy

  @impl GenServer.Proxy
  @spec server_name(String.t()) :: GenServer.name()
  def server_name(game_name) do
    {:global, game_name}
  end

  @impl GenServer.Proxy
  @spec server_unregistered(String.t()) :: :ok
  def server_unregistered(game_name) do
    :ok = IO.puts("Game '#{game_name}' not started.")
  end
end

defmodule GenServer.ProxyTest do
  use ExUnit.Case, async: true
  use GenServer.Proxy

  # Allows to capture IO...
  alias ExUnit.CaptureIO
  alias GenServer.Proxy

  doctest Proxy

  describe "Proxy.call/3" do
    test "returns {:error, reason}" do
      call = fn game_name, request, timeout ->
        try do
          call(game_name, request, timeout)
        catch
          :exit, reason -> reason
        end
      end

      capture =
        fn -> self() |> send(call.("sky-fall", {:guess, "a"}, 5001)) end
        |> CaptureIO.capture_io()

      mfargs = {GenServer, :call, [{:global, "sky-fall"}, {:guess, "a"}, 5001]}
      reason = {:noproc, mfargs}
      assert capture == "Game 'sky-fall' not started.\n"
      assert_received ^reason
    end
  end
end
