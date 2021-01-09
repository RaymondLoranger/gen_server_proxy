# GenServer Proxy

Invokes `call`, `cast` or `stop` in `GenServer` with a registered server name.
Will wait a bit if the server name is not yet registered on restarts.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `gen_server_proxy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gen_server_proxy, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/gen_server_proxy](https://hexdocs.pm/gen_server_proxy).

