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

  @impl GenServer
  def handle_cast({:push, element}, state) do
    new_state = [element | state]
    {:noreply, new_state}
  end
end

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

defmodule GenServer.ProxyTest do
  use ExUnit.Case, async: true
  use GenServer.Proxy

  # Allows to capture IO...
  alias ExUnit.CaptureIO
  alias GenServer.Proxy
  alias GenServer.ProxyTest.GenServerProxy

  doctest Proxy

  describe "Proxy.call/2,3" do
    test "Fails if server unregistered" do
      call = fn stack_name, request, timeout ->
        try do
          call(stack_name, request, timeout)
        catch
          :exit, reason -> reason
        end
      end

      capture =
        fn -> self() |> send(call.("stack1", :pop, 5001)) end
        |> CaptureIO.capture_io()

      mfargs = {GenServer, :call, [{:global, "stack1"}, :pop, 5001]}
      reason = {:noproc, mfargs}
      assert capture == "Stack 'stack1' not started.\n"
      assert_received ^reason
    end

    test "makes a synchronous call" do
      spawn(fn ->
        :timer.sleep(40)
        name = GenServerProxy.server_name("stack2")
        {:ok, _pid} = GenServer.start_link(Stack, "hello,world", name: name)
      end)

      assert call("stack2", :pop) == "hello"
      :timer.sleep(200)

      assert File.read!("./log/info.log") =~
               "[notice] \n" <>
                 """
                 Server now registered...
                 • Server: {:global, "stack2"}
                 """
    end
  end

  describe "Proxy.cast/2" do
    test "sends an async request" do
      name = GenServerProxy.server_name("stack3")
      {:ok, _pid} = GenServer.start_link(Stack, "hello,world", name: name)

      assert cast("stack3", {:push, "hey"}) == :ok
      assert call("stack3", :pop) == "hey"
      assert call("stack3", :pop) == "hello"
    end

    test "returns :ok even when server not started" do
      assert cast("stack4", {:push, "hey"}) == :ok
    end
  end

  describe "Proxy.stop/2,3" do
    test "Fails if server unregistered" do
      stop = fn stack_name, request, timeout ->
        try do
          stop(stack_name, request, timeout)
        catch
          :exit, reason -> reason
        end
      end

      capture =
        fn -> self() |> send(stop.("stack5", :shutdown, 5001)) end
        |> CaptureIO.capture_io()

      mfargs = {GenServer, :stop, [{:global, "stack5"}, :shutdown, 5001]}
      reason = {:noproc, mfargs}
      assert capture == "Stack 'stack5' not started.\n"
      assert_received ^reason
    end

    test "synchronously stops a GenServer" do
      spawn(fn ->
        :timer.sleep(40)
        name = GenServerProxy.server_name("stack6")
        {:ok, _pid} = GenServer.start_link(Stack, "hello,world", name: name)
      end)

      assert stop("stack6", :shutdown) == :ok
      :timer.sleep(200)

      assert File.read!("./log/info.log") =~
               "[notice] \n" <>
                 """
                 Server now registered...
                 • Server: {:global, "stack6"}
                 """

      assert GenServerProxy.server_name("stack6") |> GenServer.whereis() == nil
    end
  end
end
