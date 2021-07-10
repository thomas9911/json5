defmodule Json5.Decode.Helper do
  import Combine.Helpers
  import Combine.Parsers.Base
  import Combine.Parsers.Text

  alias Combine.ParserState
  alias Json5.Decode

  @multi_line_comment_regex ~R(\/\*[\s\S]*?\*\/)

  @elements [
    :remove_white_space,
    :single_line_comment,
    :multi_line_comment
  ]
  @ignore_tags for(
                 x <- @elements,
                 y <- @elements,
                 x != y,
                 do: [{__MODULE__, x, []}, {__MODULE__, y, []}]
               )
               |> List.flatten()
               |> Enum.dedup()

  @line_terminators [
    "\u{000A}",
    "\u{000D}",
    "\u{2028}",
    "\u{2029}"
  ]

  @line_terminator_chars '\u{000A}\u{000D}\u{2028}\u{2029}'

  defparser lazy(%ParserState{status: :ok} = state, generator) do
    generator.().(state)
  end

  defguard is_line_terminator(ch) when ch in @line_terminator_chars

  def lazy_json5_value() do
    lazy(fn -> Decode.json5_value() end)
  end

  def ignore_whitespace(prev \\ nil) do
    prev
    |> sequence(Enum.map(@ignore_tags, &apply/1))
    |> ignore()
  end

  def ignored_comma(prev \\ nil) do
    sequence(prev, [
      ignore_whitespace(),
      char(","),
      ignore_whitespace()
    ])
  end

  def remove_white_space do
    skip_many(satisfy(char(), &Unicode.Property.white_space?/1))
  end

  def single_line_comment do
    skip(
      sequence([
        string("//"),
        take_while(fn
          ch when is_line_terminator(ch) ->
            false

          _ ->
            true
        end),
        ecma_line_terminator()
      ])
    )
  end

  def multi_line_comment do
    skip(word_of(@multi_line_comment_regex))
  end

  def ecma_line_terminator do
    either(
      newline(),
      one_of(char(), @line_terminators)
    )
  end

  defp apply({module, func, args}), do: apply(module, func, args)
end
