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
  let config-state = state("eggs-config")

  // validate references
  show ref: it => {
    assert(it.element != none, message: "label " + repr(it.target) + " does not exist in the document")
    it
  }

  // apply `ref-pattern` numbering to a list of numbers
  // if trim-start, only use the lowest-level number
  let format-num(nums, pattern, trim-start: false) = {
    if trim-start and nums.len() > 1 {
      numbering(pattern, nums.at(-1))
    } else {
      numbering(pattern, ..nums)
    }
  }

  // format a reference or a number
  // if reference, with the config at its element
  // either for a label or for a relative integer
  // if last, only use the lowest-level number, and `sub-ref-pattern`
  let format-ref-or-num(arg, last: false) = context {

    if type(arg) == label {
      let elem = query(arg).at(0)
      let loc = elem.location()
      let config = config-state.at(loc)
      assert(config != none, message: "`show: eggs` must be used before `ex-ref`")

      let pattern = if last and elem.kind == config.sub.figure-kind {
        config.second-sub-ref-pattern
      } else {
        config.ref-pattern
      }

      format-num(counter(config.counter-name).at(loc), pattern, trim-start: last)

    } else if type(arg) == int {
      let config = config-state.get()
      assert(config != none, message: "`show: eggs` must be used before `ex-ref`")

      let pattern = if last {
        config.second-sub-ref-pattern
      } else {
        config.ref-pattern
      }

      format-num((counter(config.counter-name).get().first() + arg,), pattern, trim-start: false)
    }
  }

  // first ref
  [(#left#format-ref-or-num(args.at(0))]
  // second ref
  if args.pos().len() > 1 {
    [\-#format-ref-or-num(args.at(1), last: true)]
  }
  [#right)]
}

#let parse-ref(it) = {
  if (
    type(it.element) == content
    and "kind" in it.element.fields()
    and (
      it.element.kind == "eggsample"
      or it.element.kind == "subeggsample"
    )
  ) {
    let suppl = it.supplement
    // TODO (maybe): implement left and right
    if suppl != auto and "target" in suppl.fields() {
      return ex-ref(it.target, suppl.target)
    }
    return ex-ref(it.target)
  } else {
    it
  }
  
}
