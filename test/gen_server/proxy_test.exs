defmodule GenServer.ProxyTest.GenServerProxy do
  @behaviour GenServer.Proxy

  @impl GenServer.Proxy
  @spec server_name(String.t()) :: GenServer.name()
  def server_name(stack_name) do
    {:global, stack_name}
  end

  @impl GenServer.Proxy
  @spec server_unregistered(String.t()) :: :ok
  def server_unregistered(stack_name) do
    :ok = IO.puts("Stack '#{stack_name}' not started.")
  end
end

defmodule Stack do
  use GenServer

  @impl GenServer
  def init(elements) do
    initial_state = String.split(elements, ",", trim: true)
    {:ok, initial_state}
  end

  @impl GenServer
  def handle_call(:pop, _from, state) do
    [to_caller | new_state] = state
    {:reply, to_caller, new_state}
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
    test "Fails if server unregistered" do
      call = fn game_name, request, timeout ->
        try do
          call(game_name, request, timeout)
        catch
          :exit, reason -> reason
        end
      end

      capture =
        fn -> self() |> send(call.("haystack", {:guess, "a"}, 5001)) end
        |> CaptureIO.capture_io()

      mfargs = {GenServer, :call, [{:global, "haystack"}, {:guess, "a"}, 5001]}
      reason = {:noproc, mfargs}
      assert capture == "Stack 'haystack' not started.\n"
      assert_received ^reason
    end

    test "makes a synchronous call" do
      use GenServer.Proxy

      alias GenServer.ProxyTest.GenServerProxy, as: Proxy

      spawn(fn ->
        :timer.sleep(30)
        name = Proxy.server_name("stack")
        {:ok, _pid} = GenServer.start_link(Stack, "hello,world", name: name)
      end)

      assert "hello" == call("stack", :pop)
    end
  end
end
