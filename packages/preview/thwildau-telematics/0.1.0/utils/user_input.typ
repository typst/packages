#let user-input(
  var,
  path,
  example,
  check-dict: true
) = {
  assert(
    var != none,
    message: str(
      "\nMissing variable in configuration: "
        + path
        + "\n"
        + "For example: \t"
        + path
        + ": "
        + repr(example)
        + "\n"
        + "Please add the missing definition to your configuration of the thwildau-telematics template.",
    ),
  )

  // if given example is a dictionary, use recursion to check whole dictionary
  if check-dict and type(example) == dictionary {
    for key in example.keys() {
      user-input(
        var.at(key, default: none),
         path + "." + key,
         example.at(key),
      )
    }
  }
}

