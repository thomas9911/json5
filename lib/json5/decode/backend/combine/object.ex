defmodule Json5.Decode.Backend.Combine.Object do
  @moduledoc """
  Documentation for `Json5`.
  """
  import Combine.Parsers.Base
  import Combine.Parsers.Text
  import Json5.Decode.Backend.Combine.Helper

  alias Json5.Decode.Backend.Combine.String, as: Json5String
  alias Json5.ECMA

  require Json5.ECMA

  def object(config \\ %{}) do
    object_new_function = Map.get(config, :object_new_function, &Map.new/1)

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
        fn [expr] -> object_new_function.(expr) end
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

  defp json5_member_name do
    either(
      ecma_identifier(),
      Json5String.string()
    )
  end

  defp ecma_identifier do
    if_not(ecma_reserved_word(), ECMA.ecma_identifier_name())
  end

  defp ecma_reserved_word do
    choice(Enum.map(ECMA.reserved_words(), &string/1))
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
end
