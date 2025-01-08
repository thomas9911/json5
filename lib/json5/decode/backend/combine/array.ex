defmodule Json5.Decode.Backend.Combine.Array do
  @moduledoc """
  Documentation for `Json5`.
  """
  import Combine.Parsers.Base
  import Combine.Parsers.Text
  import Json5.Decode.Backend.Combine.Helper

  def array do
    between(
      ignore(sequence([ignore_whitespace(), char("[")])),
      either(
        pipe(
          [
            ignore_whitespace(),
            array_items(),
            ignore_whitespace()
          ],
          fn [expr] -> expr end
        ),
        map(ignore_whitespace(), fn _ -> [] end)
      ),
      ignore(sequence([ignore_whitespace(), char("]")]))
    )
  end

  defp array_items do
    pair_left(array_item(), option(char(",")))
  end

  defp array_item do
    sep_by1(lazy_json5_value(), ignored_comma())
  end
end
