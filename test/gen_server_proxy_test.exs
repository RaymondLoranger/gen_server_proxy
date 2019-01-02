defmodule GenServer.ProxyTest do
  use ExUnit.Case, async: true

  alias GenServer.Proxy

  doctest Proxy

  test "the truth" do
    assert 1 + 2 == 3
  end
end
