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
) = context {
  let config = state("eggs-config").get()
  assert(config != none, message: "`show: eggs` must be used before `ex-ref`")

  let get-ref-or-num(arg) = {
    if type(arg) == label {
      ref(arg)
    } else if type(arg) == int {
      numbering(config.ref-pattern, counter(config.counter-name).get().first() + arg)
    }
  }

  // first ref
  [(#left#get-ref-or-num(args.at(0))]
  // second ref
  if args.pos().len() > 1 {
    show ref: it => {
      let val = counter(config.counter-name).at(it.element.location())
      if val.len() > 1 {
        numbering(config.second-sub-ref-pattern, val.at(1))
      } else {
        numbering(config.ref-pattern, ..val)
      }
    }
    [\-#get-ref-or-num(args.at(1))]
  }
  [#right)]
}
