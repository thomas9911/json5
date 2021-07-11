defmodule Json5 do
  @moduledoc """
  Convert Json5 to Elixir term and back
  """

  @doc """
  parse json5 input as elixir type.

  To keep the precision of the given numbers the integers and floats are cast to `Decimal`

  options:
  - object_key_function: (binary) -> any
    - use given function to format the object key
  - object_key_existing_atom: boolean
    - format the object key with `String.to_existing_atom/1`
  - object_key_atom: boolean
    - format the object key with `String.to_atom/1`
    - if none of the above options are set return the key as a binary (String.t())
  - object_new_function: ({any, any}) -> any
    - function to create a map from the list of parsed tuples, by default uses `Map.new/1`
  - backend: [`Json5.Decode.Backend.Combine`, `Json5.Decode.Backend.Yecc`]
    - select the backend to be used (Defaults to Combine). 
    - The Combine backend is coded with the json5 spec (with unicode) in mind, but a lot slower (about 2000x slower than `Jason`)
    - The Yecc backend is a lot faster (about 6x slower than `Jason`) but not that rigorous based on the json5 spec. It is just written to make the existing tests work.

  ```elixir
  iex> Json5.decode("{array: [1, 2, 3], map: {'null': null, test: 1, }, }")
  {:ok, %{
    "map" => %{
      "test" => Decimal.new(1), 
      "null" => nil
    }, 
    "array" => [
      Decimal.new(1), 
      Decimal.new(2), 
      Decimal.new(3)
    ]
  }}
  ```

  """
  def decode(text, opts \\ []) do
    Json5.Decode.parse(text, Map.new(opts))
  end

  @doc """
  Same as `decode/2` but raises on error
  """
  def decode!(text, opts \\ []) do
    {:ok, result} = Json5.Decode.parse(text, Map.new(opts))
    result
  end

  @doc """
  Encode elixir input as json5. Contains some simple formatting options

  options:
    - pretty: boolean
    - compact: boolean


  ```elixir
  iex> Json5.encode(%{map: %{test: 1, null: nil}, array: [1,2,3]})
  {:ok, "{array: [1, 2, 3], map: {'null': null, test: 1, }, }"}
  iex> Json5.encode(%{map: %{test: 1, null: nil}, array: [1,2,3]}, pretty: true)
  {:ok, \"\"\"
    {
      array: [
        1,
        2,
        3,
      ],
      map: {
        'null': null,
        test: 1,
      },
    }
    \"\"\"}
  iex> Json5.encode(%{map: %{test: 1, null: nil}, array: [1,2,3]}, compact: true)
  {:ok, "{array:[1,2,3],map:{'null':null,test:1}}"}
  ```
  """
  def encode(input, opts \\ []) do
    Json5.Encode.dump(input, Map.new(opts))
  end

  @doc """
  Same as `encode/2` but raises on error
  """
  def encode!(input, opts \\ []) do
    {:ok, result} = encode(input, Map.new(opts))
    result
  end
end
