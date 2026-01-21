#let get-num(arg) = if type(arg) == label {
    ref(arg)
  } else if type(arg) == int {
    context counter("example").get().first() + arg
  }

/// Typesets an example reference in parentheses.
/// Accepts labels and integers for relative references.
/// Automatically handles plural references
/// such as (1-3) and (1a-c) -> content
#let ex-ref(
  /// One to two arguments.
  /// Can be either labels or integers.
  /// Integers are used for relative reference:
  /// 0 means the last example, 1 means the next, etc. -> label | int
  ..args,
  /// Text on the left, e.g. "e.g. " -> content
  left: none,
  /// Text on the right, e.g. " etc." -> content
  right: none,
  ) = {
  // first ref
  [(#left#get-num(args.at(0))]
  // second ref
  if args.pos().len() > 1 {
    // hide the digit part of a subexample ref
    show regex("\d+[a-z]+"): m => {
      show regex("\d+"): n => []
      m
    }
    [\-#get-num(args.at(1))]
  }
  [#right)]
}
