defmodule Json5.DecodeTestHelper do
  defmacro decimal(input) do
    quote do
      Macro.escape(Decimal.new(unquote(input)))
    end
  end
end

defmodule Json5.DecodeTest do
  use ExUnit.Case
  import Json5.DecodeTestHelper

  @valid [
    [:null, nil, "null"],
    [:boolean, false, "false"],
    [:boolean, true, "true"],
    ["string single quote", "some text", "'some text'"],
    ["string double quote", "some text", "\"some text\""],
    ["number hex", decimal(2801), "0xaf1"],
    ["number hex", decimal(120_772), "0X1D7c4"],
    [:number, decimal(2801), "2801"],
    [:number, decimal("0.00002"), "2e-5"],
    [:number, decimal(".123"), ".123"],
    [:number, decimal(".123e+7"), "+.123e+7"],
    [:number, decimal("12.123e+7"), "12.123e+7"],
    [:number, decimal(-2801), "-2801"],
    [:number, decimal("-0.00002"), "-2e-5"],
    [:number, decimal("-.123"), "-.123"],
    [:number, decimal("-.123e+7"), "-.123e+7"],
    [:number, decimal("-12.123e+7"), "-12.123e+7"],
    [:array, [], "[]"],
    [:array, [nil], "[null]"],
    [:array, [decimal(1)], "[1]"],
    [:array, [], "[    ]"],
    [:array, [decimal(1), decimal(2), decimal(3)], "[1,2,3]"],
    [:array, [decimal(1), decimal(2), decimal(3)], "[1, 2, 3]"],
    [:array, [decimal(1), decimal(2), decimal(3)], "[1, 2, 3, ]"],
    [:array, [nil, decimal(2)], "[null, 2]"],
    [:array, [nil, decimal(2), "stuff"], "[null, 2 , 'stuff']"],
    [
      :array,
      [nil, decimal(2), "some text"],
      """

      [

       null, 2, 

      'some text']

      """
    ],
    [
      :array,
      [
        decimal(1),
        [decimal(2), [decimal(3), [decimal(4), nil]]]
      ],
      """
      [1, [2, [3, [4, null]]]]
      """
    ],
    [
      :comment,
      "text",
      """
      // hallo
      'text'
      """
    ],
    [
      :comment,
      [decimal(1), decimal(2)],
      """
      [1, 
      // wauw comment
      2]
      """
    ],
    [
      :multi_line_comment,
      [decimal(1), decimal(2)],
      """
      [1, 
      /*

      just some text

      and even more

      */
      2]
      """
    ],
    [
      :multi_line_comment,
      "stuff",
      """
      /*

      just some text

      and even more

      */
      "stuff"
      """
    ],
    [:object, Macro.escape(%{}), "{}"],
    [:object, Macro.escape(%{}), "{    }"],
    [:object, Macro.escape(%{"a" => Decimal.new(1)}), "{a : 1}"],
    [:object, Macro.escape(%{"test" => Decimal.new(1)}), "{test: 1}"],
    [
      :object,
      Macro.escape(%{"test" => Decimal.new(1), "text" => nil}),
      "{test: 1, 'text': null}"
    ],
    [
      :object,
      Macro.escape(%{
        "test" => Decimal.new(1),
        "text" => nil,
        "nested" => %{
          "more" => [Decimal.new(1), Decimal.new(2), Decimal.new(3)],
          "other" => Decimal.new(123)
        },
        "new" => "a keyword"
      }),
      """
      {
        test: 1, 
        'text': null,
        "nested": {
          other: 123,
          "more": [1, 2, 3]
        },
        "new": "a keyword"
      }
      """
    ]
  ]

  # test "example" do
  #   text = """
  #     {
  #       // comments
  #       unquoted: 'and you can quote me on that',
  #       singleQuotes: 'I can use "double quotes" here',
  #       lineBreaks: "Look, Mom! \
  #     No \\n's!",
  #       hexadecimal: 0xdecaf,
  #       leadingDecimalPoint: .8675309, andTrailing: 8675309.,
  #       positiveSign: +1,
  #       trailingComma: 'in objects', andIn: ['arrays',],
  #       "backwardsCompatible": "with JSON",
  #     }      
  #   """

  #   assert Json5.decode(text)
  #          |> IO.inspect()
  # end

  # test "boolean" do
  #   assert {:ok, false} = Json5.decode("false")
  #   assert {:ok, true} = Json5.decode("true")
  # end

  # test "null" do
  #   assert {:ok, nil} = Json5.decode("null")
  # end

  # test "string" do
  #   assert {:ok, "just some text"} = Json5.decode("'just some text'")

  #   assert {:ok, "just some text"} = Json5.decode("\"just some text\"")
  # end

  # test "number hex" do
  #   assert {:ok, Decimal.new(2801)} == Json5.decode("0xaf1")
  #   assert {:ok, Decimal.new(120_772)} == Json5.decode("0X1D7c4")
  # end

  # test "number" do
  #   assert {:ok, Decimal.new(2801)} == Json5.decode("2801")
  #   assert {:ok, Decimal.new("0.00002")} == Json5.decode("2e-5")
  #   assert {:ok, Decimal.new(".123")} == Json5.decode(".123")
  #   assert {:ok, Decimal.new(".123e+7")} == Json5.decode("+.123e+7")
  #   assert {:ok, Decimal.new("12.123e+7")} == Json5.decode("12.123e+7")
  # end

  # test "negative number" do
  #   assert {:ok, Decimal.new(-2801)} == Json5.decode("-2801")
  #   assert {:ok, Decimal.new("-0.00002")} == Json5.decode("-2e-5")
  #   assert {:ok, Decimal.new("-.123")} == Json5.decode("-.123")
  #   assert {:ok, Decimal.new("-.123e+7")} == Json5.decode("-.123e+7")
  #   assert {:ok, Decimal.new("-12.123e+7")} == Json5.decode("-12.123e+7")
  # end

  # test "array" do
  #   assert {:ok, []} = Json5.decode("[]")
  #   assert {:ok, [nil]} = Json5.decode("[null]")
  #   assert {:ok, [Decimal.new(1)]} == Json5.decode("[1]")
  #   assert {:ok, []} = Json5.decode("[    ]")

  #   assert {:ok, [Decimal.new(1), Decimal.new(2), Decimal.new(3)]} ==
  #            Json5.decode("[1,2,3]")

  #   assert {:ok, [Decimal.new(1), Decimal.new(2), Decimal.new(3)]} ==
  #            Json5.decode("[1, 2, 3]")

  #   assert {:ok, [Decimal.new(1), Decimal.new(2), Decimal.new(3)]} ==
  #            Json5.decode("[1, 2, 3, ]")

  #   assert {:ok, [nil, Decimal.new(2)]} == Json5.decode("[null, 2]")

  #   assert {:ok, [nil, Decimal.new(2), "stuff"]} ==
  #            Json5.decode("[null, 2 , 'stuff']")

  #   assert {:ok, [nil, Decimal.new(2), "some text"]} ==
  #            Json5.decode("[null, 2 , 'some text']")

  #   assert {:ok, [nil, Decimal.new(2), "some text"]} ==
  #            Json5.decode("""

  #            [

  #             null, 2, 

  #            'some text']

  #            """)

  #   assert {:ok,
  #           [
  #             Decimal.new(1),
  #             [Decimal.new(2), [Decimal.new(3), [Decimal.new(4), nil]]]
  #           ]} ==
  #            Json5.decode("""
  #            [1, [2, [3, [4, null]]]]
  #            """)
  # end

  for [prefix, expected, input] <- @valid do
    test "decode #{prefix} #{input}" do
      assert {:ok, unquote(expected)} = Json5.decode(unquote(input))
    end
  end

  test "invalid keyword key" do
    input = "{new: 1}"
    sanity_check = "{test: 1}"

    assert {:ok, _} = Json5.decode(sanity_check)
    assert {:error, _} = Json5.decode(input)
  end

  test "invalid future keyword key" do
    input = "{const: 1}"
    sanity_check = "{test: 1}"

    assert {:ok, _} = Json5.decode(sanity_check)
    assert {:error, _} = Json5.decode(input)
  end

  test "invalid boolean key" do
    input = "{true: 1}"
    sanity_check = "{test: 1}"

    assert {:ok, _} = Json5.decode(sanity_check)
    assert {:error, _} = Json5.decode(input)
  end

  test "decode atom object" do
    input = """
    {
      test: 1,
      other: null,
    }
    """

    expected = %{
      test: Decimal.new(1),
      other: nil
    }

    assert {:ok, expected} ==
             Json5.decode(input, object_key_existing_atom: true)
  end

  test "decode object with key function" do
    input = """
    {
      test: 1,
      other: null,
    }
    """

    expected = %{
      "prefix_test" => Decimal.new(1),
      "prefix_other" => nil
    }

    assert {:ok, expected} ==
             Json5.decode(input,
               object_key_function: fn key -> "prefix_#{key}" end
             )
  end
end
