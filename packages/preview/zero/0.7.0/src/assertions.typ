
/// Check that a given value is one of the given string options
/// and prints a suitable error message suggesting the possible
/// values.
#let assert-option(
  /// Value to check -> any
  value,
  /// Name of the parameter -> str
  name,
  /// Possible options -> array
  options,
) = {
  if value not in options {
    options = options.map(option => "\"" + option + "\"")
    if options.len() == 2 {
      options = options.join(" or ")
    } else {
      options = options.slice(0, -1).join(", ") + ", or " + options.last()
    }
    assert(
      false,
      message: "Expected "
        + options
        + " for `"
        + name
        + "`, got "
        + "\""
        + value
        + "\"",
    )
  }
}


/// Checks that a given set of `arguments` contains only named
/// arguments contained in `possible-names`. Otherwise, the function panics
/// with a suitable error message.
#let assert-settable-args(
  /// Arguments to test.
  /// -> argument
  args,
  /// Supported argument names as an array or strings or keys of a dictionary.
  /// -> array | dictionary
  possible-names,
  /// Enhances the error message with a suitable name of the calling function.
  /// -> str
  name: none,
) = {
  if args.pos().len() != 0 {
    assert(
      false,
      message: "Unexpected positional argument: "
        + repr(args.pos().first())
        + if name != none { " in `" + name + "`" },
    )
  }
  for (arg-name, _) in args.named() {
    if arg-name in possible-names { continue }
    let message = "Unexpected named argument: \"" + arg-name + "\""
    if name != none {
      message += " in `" + name + "`"
    }
    assert(false, message: message)
  }
}


#let assert-no-fixed(args) = {
  return
  if "fixed" in args.named() {
    let value = str(args.at("fixed"))
    assert(
      false,
      message: "The parameter `fixed` has been removed. Instead use `exponent (fixed: "
        + value
        + "`) instead of `fixed: "
        + value
        + "`",
    )
  }
}
