small = """
{
    "test": "testing"
}

"""

medium  = File.read!("./bench/data.json")

Benchee.run(
  %{
    "jason" => fn input -> Jason.decode!(input) end,
    "json5 combine" => fn input -> Json5.decode!(input, backend: Json5.Decode.Backend.Combine) end,
    "json5 yecc" => fn input -> Json5.decode!(input, backend: Json5.Decode.Backend.Yecc) end,
  },
  inputs: %{
    "Small" => small,
    "Medium" => medium
  }
)
