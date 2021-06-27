defmodule Json5.Decode do
  @moduledoc """
  Decode Json5 string to Elixir term
  """
  import Combine.Parsers.Base
  import Json5.Decode.Helper

  alias Json5.Decode

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

  defp json5_null, do: Decode.Null.null()
  defp json5_boolean, do: Decode.Boolean.boolean()
  defp json5_string, do: Decode.String.string()
  defp json5_number, do: Decode.Number.number()
  defp json5_array, do: Decode.Array.array()
  defp json5_object(config), do: Decode.Object.object(config)
end
