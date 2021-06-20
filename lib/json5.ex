defmodule Json5 do
  @moduledoc """
  Documentation for `Json5`.
  """

  def decode(text, opts \\ []) do
    Json5.Decode.parse(text, Map.new(opts))
  end

  def decode!(text, opts \\ []) do
    {:ok, result} = Json5.Decode.parse(text, Map.new(opts))
    result
  end

  def encode(text, opts \\ []) do
    Json5.Encode.dump(text, Map.new(opts))
  end
end
