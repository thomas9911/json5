defmodule Json5.Decode.Backend.Combine do
  @moduledoc """
  Decode Json5 string to Elixir term
  """
  import Combine.Parsers.Base
  import Json5.Decode.Backend.Combine.Helper

  alias Json5.Decode.Backend.Combine.Array
  alias Json5.Decode.Backend.Combine.Boolean
  alias Json5.Decode.Backend.Combine.Null
  alias Json5.Decode.Backend.Combine.Number
  alias Json5.Decode.Backend.Combine.Object
  alias Json5.Decode.Backend.Combine.String

  def parse(input, config \\ %{}) do
    case Combine.parse(input, parser(config)) do
      {:error, error} -> {:error, error}
      [val] -> {:ok, val}
    end
  end

  def parser(config) do
    ignore_whitespace()
    |> json5_value(config)
    |> ignore_whitespace()
    |> eof()
  end

  def json5_value(prev \\ nil, config \\ %{}) do
    choice(prev, [
      json5_null(),
      json5_boolean(),
      json5_string(),
      json5_number(),
      json5_array(),
      json5_object(config)
    ])
  end

  defp json5_null, do: Null.null()
  defp json5_boolean, do: Boolean.boolean()
  defp json5_string, do: String.string()
  defp json5_number, do: Number.number()
  defp json5_array, do: Array.array()
  defp json5_object(config), do: Object.object(config)
end
