defmodule Json5.Error do
  defexception [:type, :input]

  @impl true
  def exception(%{type: type, input: input}) do
    case type do
      :invalid_input -> :ok
      :reserved_key -> :ok
      _ -> raise ArgumentError
    end

    %__MODULE__{type: type, input: input}
  end

  @impl true
  def message(%__MODULE__{type: type, input: input}) do
    case type do
      :invalid_input -> "unable to format input"
      :reserved_key -> "found a reserved word, '#{input}'"
      _ -> "something went wrong"
    end
  end
end
