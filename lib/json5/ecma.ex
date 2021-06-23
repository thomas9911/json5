defmodule Json5.ECMA do
  @moduledoc """
  Define some ECMA constants
  """
  require Unicode.Set

  import Combine.Parsers.Base
  import Combine.Parsers.Text

  @reserved_names [
    # boolean
    "true",
    "false",
    # null
    "null",
    # ecma_keyword
    "break",
    "do",
    "instanceof",
    "typeof",
    "case",
    "else",
    "new",
    "var",
    "catch",
    "finally",
    "return",
    "void",
    "continue",
    "for",
    "switch",
    "while",
    "debugger",
    "function",
    "this",
    "with",
    "default",
    "if",
    "throw",
    "delete",
    "in",
    "try",
    # ecma_future_keyword
    "class",
    "enum",
    "extends",
    "super",
    "const",
    "export",
    "import"
  ]

  defguard is_reserved_word(input) when input in @reserved_names

  defguard is_unicode_identifier_letter(x)
           when Unicode.Set.match?(
                  x,
                  "[[:Lu:][:Ll:][:Lt:][:Lm:][:Lo:][:Nl:][:Mn:][:Mc:][:Nd:][:Pc:]]"
                )

  def reserved_words do
    @reserved_names
  end

  def reserved_word?(input) do
    input in @reserved_names
  end

  def valid_identifier?(input) do
    case Combine.parse(input, ecma_identifier_name() |> eof()) do
      {:error, _} -> false
      _ -> not is_reserved_word(input)
    end
  end

  def ecma_identifier_name() do
    pipe(
      [
        ecma_identifier_start(),
        take_while(&is_unicode_identifier_letter/1)
      ],
      &Enum.join/1
    )
  end

  defp ecma_identifier_start() do
    choice([
      ecma_unicode_letter(),
      char("$"),
      char("_")
    ])
  end

  defp ecma_unicode_letter() do
    satisfy(char(), fn ch ->
      (ch
       |> Unicode.category()
       |> Enum.at(0)) in [
        :Lu,
        :Ll,
        :Lt,
        :Lm,
        :Lo,
        :Nl
      ]
    end)
  end
end
