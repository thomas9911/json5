defmodule Json5.Encode.Object do
  @moduledoc """
  Documentation for `Json5`.
  """
  require Decimal
  require Json5.ECMA

  alias Json5.Encode

  def dump(input, %{pretty: true} = config) when is_map(input) do
    do_dump(input, config, "\n", " ", " ", "\n")
  end

  def dump(input, %{compact: true} = config) when is_map(input) do
    do_dump(input, config, "", "", "", "", "")
  end

  def dump(input, config) when is_map(input) do
    do_dump(input, config, "", "", " ", " ")
  end

  defp do_dump(
         input,
         config,
         newline,
         indent,
         colon_padding,
         comma_padding,
         postfix_character \\ ","
       ) do
    level = Map.get(config, :level, 0)

    inner =
      Enum.map_join(
        input,
        ",#{comma_padding}",
        &object_line(&1, config, level, indent, colon_padding)
      )

    Enum.join([
      "{",
      newline,
      inner,
      postfix_character,
      comma_padding,
      String.duplicate(indent, level * 2),
      "}",
      put_newline(level, newline)
    ])
  end

  defp put_newline(0, newline), do: newline
  defp put_newline(_, _), do: ""

  defp object_line(
         {key, value},
         config,
         level,
         indent,
         colon_padding
       ) do
    encoded_key = encode_key(key, config)
    config = Map.update(config, :level, 1, &(&1 + 1))

    Enum.join([
      String.duplicate(indent, (level + 1) * 2),
      encoded_key,
      ":",
      colon_padding,
      Encode.do_dump(value, config)
      # ",",
      # comma_padding
    ])
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
