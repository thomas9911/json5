# Json5

Json5 in elixir.

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

For full examples and options go to the moduledocs:
[https://hexdocs.pm/json5](https://hexdocs.pm/json5/Json5.html)

## Installation

If [available in Hex](https://hex.pm/packages/json5), the package can be installed
by adding `json5` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:json5, "~> 0.1.0"}
  ]
end
```

## Note

This library is now quite slow. So only use it when you really need json5 or for input that is only loaded once (for instance configuration).
