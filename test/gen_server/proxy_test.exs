defmodule GenServer.ProxyTest.GenServerProxy do
  @behaviour GenServer.Proxy

  @spec server_name(String.t()) :: GenServer.name()
  def server_name(game_name) do
    {:global, game_name}
  end

  @spec server_unregistered(String.t()) :: :ok
  def server_unregistered(game_name) do
    :ok = IO.puts("Game #{game_name} not started.")
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
      capture =
        fn ->
          send(self(), call("SkyFall", {:hang_on, '007'}, 5001))
        end
        |> CaptureIO.capture_io()

      mfa = {GenServer, :call, [{:global, "SkyFall"}, {:hang_on, '007'}, 5001]}
      reason = {:noproc, mfa}
      assert capture == "Game SkyFall not started.\n"
      assert_received {:error, ^reason}
    end
  end
end
