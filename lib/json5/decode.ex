defmodule Json5.Decode do
  @moduledoc """
  Decode Json5 string to Elixir term
  """

  def parse(input, config \\ %{}) do
    backend().parse(input, config)
  end

  defp backend do
    Json5.Decode.Backend.Combine
  end
end
