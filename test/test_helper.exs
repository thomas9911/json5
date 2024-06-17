opts =
  if System.otp_release() |> String.to_integer() |> Kernel.>=(26) do
    # formatting of maps changed in OTP 26,
    # so for now just test the lower versions in doctest.
    # the unittest do check both formats
    [exclude: [:doctest]]
  else
    []
  end

ExUnit.start(opts)
