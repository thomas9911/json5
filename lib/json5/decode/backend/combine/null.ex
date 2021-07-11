defmodule Json5.Decode.Backend.Combine.Null do
  @moduledoc """
  Documentation for `Json5`.
  """
  import Combine.Parsers.Base
  import Combine.Parsers.Text

  def null do
    "null"
    |> string()
    |> label("null")
    |> map(fn _ -> nil end)
  end
end
