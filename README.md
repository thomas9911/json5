# Json5

Json5 in elixir.

## NOTE

Currently the spec is not entirely implemented, for instance multiline string.

## Usage

```elixir
input = %{test: 1}
Json5.encode(input)
```

```elixir
input = """
{
  test: 1
}
"""
Json5.decode(input)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `json5` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:json5, "~> 0.0.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/json5](https://hexdocs.pm/json5).
