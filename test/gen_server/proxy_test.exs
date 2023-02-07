defmodule GenServer.ProxyTest.GenServerProxy do
  @behaviour GenServer.Proxy

  @spec server_name(String.t()) :: GenServer.name()
  def server_name(game_name) do
    {:global, game_name}
  end

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
      capture =
        fn ->
          try do
            self() |> send(call("Hangman", {:guess, "a"}, 5001))
          catch
            :exit, reason -> self() |> send({:bad_call, reason})
          end
        end
        |> CaptureIO.capture_io()

      mfargs = {GenServer, :call, [{:global, "Hangman"}, {:guess, "a"}, 5001]}
      reason = {:noproc, mfargs}
      assert capture == "Game 'Hangman' not started.\n"
      assert_received {:bad_call, ^reason}
    end
  end
end
