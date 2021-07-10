defmodule Json5.Decode.String do
  @moduledoc """
  Documentation for `Json5`.
  """
  import Combine.Parsers.Base
  import Combine.Parsers.Text
  alias Json5.Decode.Helper

  def string() do
    either(
      between(char("'"), json5_single_string_characters(), char("'")),
      between(char("\""), json5_double_string_characters(), char("\""))
    )
  end

  defp json5_single_string_characters(prev \\ nil) do
    prev
    |> many1(json5_single_string_character())
    |> map(&:erlang.iolist_to_binary/1)
  end

  defp json5_single_string_character() do
    if_not(char("'"), escape_new_line_char())
  end

  defp json5_double_string_characters(prev \\ nil) do
    prev
    |> many1(json5_double_string_character())
    |> map(&:erlang.iolist_to_binary/1)
  end

  defp json5_double_string_character() do
    if_not(char("\""), escape_new_line_char())
  end

  defp escape_new_line_char() do
    either(
      ignore(sequence([char("\\"), Helper.ecma_line_terminator()])),
      char()
    )
  end
end
