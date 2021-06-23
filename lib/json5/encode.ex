defmodule Json5.Encode do
  @moduledoc """
  Documentation for `Json5`.
  """
  require Decimal
  require Json5.ECMA

  alias Json5.Encode

  defguardp is_to_string(input)
            when input in [true, false] or is_float(input) or is_integer(input) or
                   Decimal.is_decimal(input)

  def dump(input, config \\ %{}) do
    case do_dump(input, config) do
      {:error, error} -> {:error, error}
      other -> {:ok, other}
    end
  end

  def do_dump(nil, _) do
    "null"
  end

  def do_dump(input, _) when is_to_string(input) do
    to_string(input)
  end

  def do_dump(input, %{double_quote_string: true}) when is_binary(input) do
    "\"#{input}\""
  end

  def do_dump(input, _) when is_binary(input) do
    "'#{input}'"
  end

  def do_dump(input, config) when is_list(input) do
    Encode.Array.dump(input, config)
  end

  def do_dump(input, config) when is_map(input) and not is_struct(input) do
    Encode.Object.dump(input, config)
  end

  def do_dump(input, _) do
    {:error,
     Json5.Encode.Error.exception(%{type: :invalid_input, input: input})}
  end
end
