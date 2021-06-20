defmodule Json5.EncodeTest do
  use ExUnit.Case

  @valid [
    [:number, "1", 1],
    [:float, "3.14", 3.14],
    [:decimal, "1.2E+4", Macro.escape(Decimal.new("12e3"))],
    [:string, "'just some text'", "just some text"],
    [:array, "[1, 2, 3]", [1, 2, 3]],
    [:array, "[1, null, 'text']", [1, nil, "text"]],
    [:object, "{test: 1, }", Macro.escape(%{test: 1})],
    [:object, "{'new': 1, }", Macro.escape(%{new: 1})],
    [:object, "{'using spaces': 1, }", Macro.escape(%{"using spaces" => 1})],
    [
      :mixed_object,
      """
      {array: [1, 2, 3], nested: {more: 123, }, valid_key: true, 'using spaces': 1, }\
      """,
      Macro.escape(%{
        "using spaces" => 1,
        valid_key: true,
        nested: %{more: 123},
        array: [1, 2, 3]
      })
    ]
  ]

  for [prefix, expected, input] <- @valid do
    test "encode #{prefix} #{expected}" do
      assert {:ok, unquote(expected)} = Json5.encode(unquote(input))
    end
  end
end
