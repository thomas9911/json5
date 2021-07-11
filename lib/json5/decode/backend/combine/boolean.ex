defmodule Json5.Decode.Backend.Combine.Boolean do
  @moduledoc """
  Documentation for `Json5`.
  """
  import Combine.Parsers.Base
  import Combine.Parsers.Text

  def boolean, do: either(boolean_true(), boolean_false())

  defp boolean_true do
    "true"
    |> string()
    |> label("true")
    |> map(fn _ -> true end)
  end

  defp boolean_false do
    "false"
    |> string()
    |> label("false")
    |> map(fn _ -> false end)
  end
end
