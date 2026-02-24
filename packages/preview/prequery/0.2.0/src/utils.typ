#let boolean-input(name) = {
  let bools = ("true": true, "false": false)

  let value = sys.inputs.at(name, default: "false")
  assert(value in bools, message: "--input " + name + "=... must be set to true or false if present")
  bools.at(value)
}
