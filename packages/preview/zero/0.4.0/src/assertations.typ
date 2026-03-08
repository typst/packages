
/// Check that a given value is one of the given string options
/// and prints a suitable error message suggesting the possible
/// values. 
#let assert-option(
  /// Value to check -> any
  value, 
  /// Name of the parameter -> str
  name, 
  /// Possible options -> array
  options
) = {
  if value not in options {
    options = options.map(x => "\"" + x + "\"")
    if options.len() == 2 {
      options = options.join(" or ")
    } else {
      options = options.slice(0, -1).join(", ") + ", or " + options.last()
    }
    assert(
      false, message: "Expected " + options + " for `" + name + "`, got " + "\"" + value + "\""
    )
  }
}


/// Checks that a given set of `arguments` contains only named
/// arguments contained in `dict`. Otherwise, the function panicks
/// with a suitable error message. 
#let assert-settable-args(args, dict, name: none) = {
  if args.pos().len() != 0 {
    let message = "Unexpected argument: " + repr(args.pos().first())
    if name != none {
      message += " in `" + name + "`"
    }
    assert(false, message: message)
  }
  for (arg, _) in args.named() {
    if arg in dict { continue }
    let message = "Unexpected argument: " + arg
    if name != none {
      message += " in `" + name + "`"
    }
    assert(false, message: message)
  }
}
