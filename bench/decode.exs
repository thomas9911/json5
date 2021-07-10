small = """
{
    "test": "testing"
}

"""

medium  = File.read!("./bench/data.json")

Benchee.run(
  %{
    "jason" => fn input -> Jason.decode!(input) end,
    "json5" => fn input -> Json5.decode!(input) end
  },
  inputs: %{
    "Small" => small,
    "Medium" => medium
  }
)


# Benchee.run(
#   %{
#     "json5" => fn input -> Json5.decode!(input) end
#   },
#   inputs: %{
#     "Medium" => medium
#   }
# )