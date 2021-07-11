defmodule Json5.Decode.Backend.Yecc do
  @moduledoc """
  Decode Json5 string to Elixir term

  Does not support unicode map keys
  """

  import Json5.ECMA

  alias Json5.Error

  def parse(input, config \\ %{}) do
    with {:ok, tokens, _} <-
           input
           |> String.to_charlist()
           |> :lexer.string(),
         {:ok, ast} <- :parser.parse(tokens) do
      {:ok, to_term(ast, config)}
    end
  rescue
    e in Error -> {:error, e}
  end

  defp to_term({:string, _, charlist}, _) do
    charlist
    |> :string.replace([92, 13, 10], [])
    |> :string.replace([92, 10], [])
    |> :erlang.iolist_to_binary()
  end

  defp to_term({:key, _, charlist}, config) do
    key = List.to_string(charlist)

    if is_reserved_word(key),
      do: raise(Error, %{type: :reserved_key, input: key})

    do_key_term(key, config)
  end

  defp to_term({:map, _, key_value_list}, config) do
    Map.new(key_value_list, fn {key, value} ->
      {to_term(key, config), to_term(value, config)}
    end)
  end

  defp to_term({:list, _, list}, config) do
    Enum.map(list, &to_term(&1, config))
  end

  defp to_term({:null, _, nil}, _), do: nil
  defp to_term({:boolean, _, boolean}, _), do: boolean

  defp to_term({:hex_number, _, integer}, _) do
    Decimal.new(integer)
  end

  defp to_term({:number, _, charlist}, _) do
    charlist
    |> List.to_string()
    |> Decimal.new()
  end

  def do_key_term(key, %{object_key_existing_atom: true}) do
    String.to_existing_atom(key)
  end

  def do_key_term(key, %{object_key_function: object_key_function}) do
    object_key_function.(key)
  end

  def do_key_term(key, _), do: key
end
