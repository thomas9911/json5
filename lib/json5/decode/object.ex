defmodule Json5.Decode.Object do
  @moduledoc """
  Documentation for `Json5`.
  """
  import Combine.Parsers.Base
  import Combine.Parsers.Text
  import Json5.Decode.Helper
  require Unicode.Set

  alias Json5.Decode

  require Json5.ECMA

  def object(config \\ %{}) do
    either(
      pipe(
        [
          ignore_whitespace(),
          char("{"),
          ignore_whitespace(),
          char("}"),
          ignore_whitespace()
        ],
        fn _ -> %{} end
      ),
      pipe(
        [
          ignore_whitespace(),
          ignore(char("{")),
          ignore_whitespace(),
          json5_member_list(config),
          ignore_whitespace(),
          ignore(char("}")),
          ignore_whitespace()
        ],
        fn [expr] -> Map.new(expr) end
      )
    )
  end

  defp json5_member_list(config) do
    pair_left(json5_members(config), option(char(",")))
  end

  defp json5_members(config) do
    sep_by1(json5_member(config), ignored_comma())
  end

  defp json5_member(config) do
    pipe(
      [
        ignore_whitespace(),
        json5_member_name(),
        ignore_whitespace(),
        ignore(char(":")),
        ignore_whitespace(),
        lazy_json5_value(),
        ignore_whitespace()
      ],
      &cast_json5_member(&1, config)
    )
  end

  defp json5_member_name() do
    either(
      ecma_identifier(),
      Decode.String.string()
    )

    # string("test") 
    # ecma_identifier()
  end

  defp ecma_identifier() do
    if_not(ecma_reserved_word(), ecma_identifier_name())
  end

  defp ecma_reserved_word() do
    choice(Enum.map(Json5.ECMA.reserved_words(), &string/1))
  end

  # defp ecma_reserved_word() do
  #   choice([
  #     Decode.Null.null(),
  #     Decode.Boolean.boolean(),
  #     ecma_keyword(),
  #     ecma_future_keyword()
  #   ])
  # end

  # defp ecma_keyword() do
  #   choice([
  #     string("break"),
  #     string("do"),
  #     string("instanceof"),
  #     string("typeof"),
  #     string("case"),
  #     string("else"),
  #     string("new"),
  #     string("var"),
  #     string("catch"),
  #     string("finally"),
  #     string("return"),
  #     string("void"),
  #     string("continue"),
  #     string("for"),
  #     string("switch"),
  #     string("while"),
  #     string("debugger"),
  #     string("function"),
  #     string("this"),
  #     string("with"),
  #     string("default"),
  #     string("if"),
  #     string("throw"),
  #     string("delete"),
  #     string("in"),
  #     string("try")
  #   ])
  # end

  # defp ecma_future_keyword() do
  #   choice([
  #     string("class"),
  #     string("enum"),
  #     string("extends"),
  #     string("super"),
  #     string("const"),
  #     string("export"),
  #     string("import")
  #   ])
  # end

  defp ecma_identifier_name() do
    pipe(
      [
        ecma_identifier_start(),
        take_while(&Json5.ECMA.is_unicode_identifier_letter/1)
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

  defp cast_json5_member([key, value], %{object_key_function: func})
       when is_function(func, 1) do
    {func.(key), value}
  end

  defp cast_json5_member([key, value], %{object_key_existing_atom: true}) do
    {String.to_existing_atom(key), value}
  end

  defp cast_json5_member([key, value], %{object_key_atom: true}) do
    {String.to_atom(key), value}
  end

  defp cast_json5_member([key, value], _) do
    {key, value}
  end

  #   defp ecma_unicode_digit() do
  #     satisfy(char(), &Unicode.digits?/1)
  #   end

  #   defp json5_punctuation do
  #     one_of(char(), ["{", "}", "[", "]", ":", ","])
  #   end
end
