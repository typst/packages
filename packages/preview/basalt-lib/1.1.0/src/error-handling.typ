#let check-required-argument(
  func,
  arg,
  arg-name,
  arg-type,
  hint: str,
) = {
  let check(
    func,
    arg,
    arg-name,
    arg-type,
    hint: str,
  ) = {
    if type(arg) != arg-type {
      panic(
        "`" + arg-name + "`" +
        " is a required argument for `" + repr(func) + "`" +
        " of type `" + repr(arg-type) + "`." +
        " Got instead `" + repr(arg) + "`" +
        " of type `" + repr(type(arg)) + "`." +
        if type(hint) == str {
          " Hint: " + hint
        } else {
          ""
        }
      )
    }
  }
  check(check-required-argument, func, "func", function)
  check(check-required-argument, arg-name, "arg-name", str)
  check(check-required-argument, arg-type, "arg-type", type)
  check(func, arg, arg-name, arg-type, hint: hint)
}
