defmodule Json5.Decode.Array do
  @moduledoc """
  Documentation for `Json5`.
  """
  import Combine.Parsers.Base
  import Combine.Parsers.Text
  import Json5.Decode.Helper

  def array do
    either(
      pipe(
        [
          ignore_whitespace(),
          char("["),
          ignore_whitespace(),
          char("]"),
          ignore_whitespace()
        ],
        fn _ -> [] end
      ),
      pipe(
        [
          ignore_whitespace(),
          ignore(char("[")),
          ignore_whitespace(),
          array_items(),
          ignore_whitespace(),
          ignore(char("]")),
          ignore_whitespace()
        ],
        fn [expr] -> expr end
      )
    )
  end

  defp array_items do
    pair_left(array_item(), option(char(",")))
  end

  defp array_item do
    sep_by1(lazy_json5_value(), ignored_comma())
  end
end
