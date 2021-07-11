defmodule Json5.Decode.Backend.Combine.Number do
  @moduledoc """
  Documentation for `Json5`.
  """
  import Combine.Parsers.Base
  import Combine.Parsers.Text

  def number do
    either(ecma_hex_integer_literal(), ecma_decimal_literal())
  end

  defp ecma_hex_integer_literal do
    pipe(
      [
        ignore(either(string("0x"), string("0X"))),
        many1(hex_digit())
      ],
      fn chars ->
        chars
        |> Enum.join()
        |> String.to_integer(16)
        |> Decimal.new()
      end
    )
  end

  def ecma_decimal_literal do
    both(
      option(either(char("-"), char("+"))),
      choice([
        ecma_decimal_literal_1(),
        ecma_decimal_literal_2(),
        ecma_decimal_literal_3()
      ]),
      &negate_or_not/2
    )
  end

  def ecma_decimal_literal_1 do
    pipe(
      [
        integer(),
        char("."),
        option(ecma_decimal_digits()),
        option(ecma_exponent_part())
      ],
      &combine_integer/1
    )
  end

  def ecma_decimal_literal_2 do
    pipe(
      [char("."), ecma_decimal_digits(), option(ecma_exponent_part())],
      &combine_integer_with_expontent_leading_dot/1
    )
  end

  def ecma_decimal_literal_3 do
    both(
      integer(),
      option(ecma_exponent_part()),
      &combine_integer_with_expontent/2
    )
  end

  defp ecma_decimal_digits(prev \\ nil) do
    # nearly the same as integer but also leading zeroes
    prev |> many1(digit()) |> map(&Enum.join/1)
  end

  defp ecma_exponent_part do
    both(either(char("e"), char("E")), ecma_signed_integer(), &"#{&1}#{&2}")
  end

  defp ecma_signed_integer(prev \\ nil) do
    both(prev, option(either(char("-"), char("+"))), integer(), &prepend_sign/2)
  end

  defp combine_integer([int, ".", nil, nil]), do: Decimal.new(int)

  defp combine_integer([int, ".", decimal, nil]),
    do: Decimal.new("#{int}.#{decimal}")

  defp combine_integer([int, ".", nil, exponent]),
    do: Decimal.new("#{int}#{exponent}")

  defp combine_integer([int, ".", decimal, exponent]),
    do: Decimal.new("#{int}.#{decimal}#{exponent}")

  defp combine_integer_with_expontent_leading_dot([".", digits, nil]) do
    Decimal.new("0.#{digits}")
  end

  defp combine_integer_with_expontent_leading_dot([".", digits, exponent]) do
    combine_integer_with_expontent("0.#{digits}", exponent)
  end

  defp combine_integer_with_expontent(number, nil), do: Decimal.new(number)

  defp combine_integer_with_expontent(number, exponent) do
    Decimal.new("#{number}#{exponent}")
  end

  defp prepend_sign(nil, integer), do: to_string(integer)
  defp prepend_sign(sign, integer), do: "#{sign}#{integer}"

  defp negate_or_not(nil, decimal), do: decimal
  defp negate_or_not("+", decimal), do: decimal
  defp negate_or_not("-", decimal), do: Decimal.negate(decimal)
end
