defmodule Json5.Decode.String do
  @moduledoc """
  Documentation for `Json5`.
  """
  import Combine.Parsers.Base
  import Combine.Parsers.Text

  def string() do
    either(
      # ignore(char("'"))
      # |> json5_single_string_characters()
      # |> ignore(char("'")),
      between(char("'"), json5_single_string_characters(), char("'")),
      between(char("\""), json5_double_string_characters(), char("\""))
      # ignore(char("\""))
      # |> json5_double_string_characters()
      # |> ignore(char("\""))
    )
  end

  defp json5_single_string_characters(prev \\ nil) do
    prev |> many1(json5_single_string_character()) |> map(&Enum.join/1)
  end

  defp json5_single_string_character() do
    if_not(char("'"), char())
  end

  defp json5_double_string_characters(prev \\ nil) do
    prev |> many1(json5_double_string_character()) |> map(&Enum.join/1)
  end

  defp json5_double_string_character() do
    if_not(char("\""), char())
  end
end
