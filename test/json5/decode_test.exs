defmodule Json5.DecodeTestHelper do
  defmacro decimal(input) do
    quote do
      Macro.escape(Decimal.new(unquote(input)))
    end
  end
end

defmodule Json5.DecodeTest do
  use ExUnit.Case, async: true
  import Json5.DecodeTestHelper

  @backends [Json5.Decode.Backend.Combine, Json5.Decode.Backend.Yecc]

  @valid [
    [:null, nil, "null"],
    [:boolean, false, "false"],
    [:boolean, true, "true"],
    ["string single quote", "some text", "'some text'"],
    ["string double quote", "some text", "\"some text\""],
    ["empty string single quote", "", "''"],
    ["empty string double quote", "", "\"\""],
    ["string unicode", "ūňĭčŏďē text", "\"ūňĭčŏďē text\""],
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
    [:array, [], " []   "],
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
      :comment,
      Macro.escape(%{
        "test" => []
      }),
      """
      {
      "test": [
        // {
        // "test2": "",
        // "test3": "",
        // },
        ]
      }
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
    [:object, Macro.escape(%{}), "  {} "],
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
      Macro.escape(%{"document" => "world"}),
      "{document: 'world'}"
    ],
    [
      :object,
      Macro.escape(%{"truestatement" => "true"}),
      "{truestatement: 'true'}"
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
    ],
    [
      :odd_object,
      Macro.escape(%{
        "$_" => Decimal.new(1),
        "_$" => Decimal.new(2),
        ~S"a\u200C" => Decimal.new(3)
      }),
      ~S"{$_:1,_$:2,a\u200C:3}"
    ]
  ]

  for backend <- @backends do
    @backend backend
    describe "backend: #{@backend |> Module.split() |> Enum.at(-1)}" do
      test "example" do
        text = File.read!("test/support/examples/minimal.json5")

        assert {:ok,
                %{
                  "andIn" => ["arrays"],
                  "andTrailing" => Decimal.new(8_675_309),
                  "backwardsCompatible" => "with JSON",
                  "hexadecimal" =>
                    "decaf" |> String.to_integer(16) |> Decimal.new(),
                  "leadingDecimalPoint" => Decimal.new("0.8675309"),
                  "lineBreaks" => ~S"Look, Mom! No \\n's!",
                  "positiveSign" => Decimal.new(1),
                  "singleQuotes" => "I can use \"double quotes\" here",
                  "trailingComma" => "in objects",
                  "unquoted" => "and you can quote me on that"
                }} == Json5.decode(text, backend: @backend)
      end

      for [prefix, expected, input] <- @valid do
        test "decode #{prefix} #{input}" do
          assert {:ok, unquote(expected)} =
                   Json5.decode(unquote(input), backend: @backend)
        end
      end

      test "invalid keyword key" do
        input = "{new: 1}"
        sanity_check = "{test: 1}"

        assert {:ok, _} = Json5.decode(sanity_check, backend: @backend)
        assert {:error, _} = Json5.decode(input, backend: @backend)
      end

      test "invalid keyword key (extra spaces)" do
        input = "{do   : 1}"
        sanity_check = "{test: 1}"

        assert {:ok, _} = Json5.decode(sanity_check, backend: @backend)
        assert {:error, _} = Json5.decode(input, backend: @backend)
      end

      test "invalid future keyword key" do
        input = "{const: 1}"
        sanity_check = "{test: 1}"

        assert {:ok, _} = Json5.decode(sanity_check, backend: @backend)
        assert {:error, _} = Json5.decode(input, backend: @backend)
      end

      test "invalid boolean key" do
        input = "{true: 1}"
        sanity_check = "{test: 1}"

        assert {:ok, _} = Json5.decode(sanity_check, backend: @backend)
        assert {:error, _} = Json5.decode(input, backend: @backend)
      end

      test "decode existing atom object" do
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
                 Json5.decode(input,
                   object_key_existing_atom: true,
                   backend: @backend
                 )
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
                 Json5.decode(input,
                   object_key_atom: true,
                   backend: @backend
                 )
      end

      test "decode object with object new function" do
        input = """
        {
          test: 1,
          other: null,
        }
        """

        expected = [
          {"test", Decimal.new(1)},
          {"other", nil}
        ]

        assert {:ok, expected} ==
                 Json5.decode(input,
                   object_new_function: &Enum.to_list/1,
                   backend: @backend
                 )
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
                   object_key_function: fn key -> "prefix_#{key}" end,
                   backend: @backend
                 )
      end
    end
  end

  test "decode invalid input" do
    assert {:error, %Json5.Error{type: :reserved_key} = exception} =
             Json5.decode("{const: 1}", backend: Json5.Decode.Backend.Yecc)

    assert "found a reserved word, 'const'" == Exception.message(exception)
  end

  test "default backend works" do
    assert {:ok, ["testing"]} == Json5.decode("['testing']")
  end

  test "decode! works" do
    assert ["testing"] == Json5.decode!("['testing']")
  end
end
