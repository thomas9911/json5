defmodule Json5.Encode.Error do
  defexception [:type, :input]

  @impl true
  def exception(%{type: type, input: input}) do
    case type do
      :invalid_input -> :ok
      _ -> raise ArgumentError
    end

    %__MODULE__{type: type, input: input}
  end

  @impl true
  def message(%__MODULE__{type: type}) do
    case type do
      :invalid_input -> "unable to format input"
      _ -> "something went wrong"
    end
  end
end
