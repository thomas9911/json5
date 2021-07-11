defmodule Json5.Decode do
  @moduledoc """
  Decode Json5 string to Elixir term
  """

  def parse(input, config \\ %{}) do
    backend(config).parse(input, config)
  end

  defp backend(%{backend: backend}) do
    backend
  end

  defp backend(_) do
    Json5.Decode.Backend.Combine
  end
end
