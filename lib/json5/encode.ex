defmodule Json5.Encode do
  @moduledoc """
  Documentation for `Json5`.
  """
  require Decimal
  require Json5.ECMA

  defguardp is_to_string(input)
            when input in [true, false] or is_float(input) or is_integer(input) or
                   Decimal.is_decimal(input)

  def dump(input, config \\ %{}) do
    case do_dump(input, config) do
      {:error, error} -> {:error, error}
      other -> {:ok, other}
    end
  end

  defp do_dump(nil, _) do
    "null"
  end

  defp do_dump(input, _) when is_to_string(input) do
    to_string(input)
  end

  defp do_dump(input, %{double_quote_string: true}) when is_binary(input) do
    "\"#{input}\""
  end

  defp do_dump(input, _) when is_binary(input) do
    "'#{input}'"
  end

  defp do_dump(input, %{pretty: true} = config) when is_list(input) do
    inner = Enum.map_join(input, ", ", &do_dump(&1, config))
    "[#{inner}]"
  end

  defp do_dump(input, config) when is_list(input) do
    inner = Enum.map_join(input, ", ", &do_dump(&1, config))
    "[#{inner}]"
  end

  defp do_dump(input, %{pretty: true} = config) when is_map(input) do
    level = Map.get(config, :level, 0)

    inner =
      Enum.map_join(input, "\n", fn {key, value} ->
        encoded_key = encode_key(key, config)
        config = Map.update(config, :level, 1, &(&1 + 1))
        "#{encoded_key}: #{do_dump(value, config)},"
      end)

    inner = "#{String.duplicate(" ", (level + 1) * 2)}#{inner}"
    end_tag = "#{String.duplicate(" ", level * 2)}}"
    "{\n#{inner}\n#{end_tag}"
  end

  defp do_dump(input, config) when is_map(input) do
    inner =
      Enum.map_join(input, fn {key, value} ->
        encoded_key = encode_key(key, config)
        "#{encoded_key}: #{do_dump(value, config)}, "
      end)

    "{#{inner}}"
  end

  defp encode_key(input, config) when is_binary(input) or is_atom(input) do
    input = to_string(input)
    double_quote_string = Map.get(config, :double_quote_string, false)

    case {Json5.ECMA.valid_identifier?(input), double_quote_string} do
      {true, _} -> input
      {false, false} -> "'#{input}'"
      {false, true} -> "\"#{input}\""
    end
  end
end
