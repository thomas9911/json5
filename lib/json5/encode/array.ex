defmodule Json5.Encode.Array do
  @moduledoc """
  Documentation for `Json5`.
  """
  require Decimal
  require Json5.ECMA

  alias Json5.Encode

  def dump(input, %{pretty: true} = config) when is_list(input) do
    {level, config} =
      Map.get_and_update(config, :level, fn
        nil -> {0, 1}
        value -> {value, value + 1}
      end)

    inner =
      input
      |> Enum.map(&Encode.do_dump(&1, config))
      |> Enum.map_join(fn x ->
        "\n#{String.duplicate(" ", (level + 1) * 2)}#{x},"
      end)

    Enum.join([
      "[",
      inner,
      "\n",
      String.duplicate(" ", level * 2),
      "]",
      put_newline(level)
    ])
  end

  def dump(input, %{compact: true} = config) when is_list(input) do
    inner = Enum.map_join(input, ",", &Encode.do_dump(&1, config))
    "[#{inner}]"
  end

  def dump(input, config) when is_list(input) do
    inner = Enum.map_join(input, ", ", &Encode.do_dump(&1, config))
    "[#{inner}]"
  end

  defp put_newline(0), do: "\n"
  defp put_newline(_), do: ""
end
