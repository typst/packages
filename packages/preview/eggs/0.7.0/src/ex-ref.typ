#import "@preview/elembic:1.1.1" as e

#import "utils.typ": prefix
#import "example.typ": example, subexample


// apply `ref-pattern` numbering to a list of numbers
// if trim-start, only use the lowest-level number
#let format-num(nums, pattern, trim-start: false) = {
  if trim-start and nums.len() > 1 {
    numbering(pattern, nums.at(-1))
  } else {
    numbering(pattern, ..nums)
  }
}

// return the formatted number of a single example
// from a label, element, or relative number
#let format-ref-or-num(it, is-second: false) = context {

  if type(it) == int {
    e.get(get => {
      let ex = get(example)

      // format relative number
      let pattern = if is-second {
        ex.second-sub-ref-pattern
      } else {
        ex.ref-pattern
      }
      format-num((ex._counter.get().first() + it,), pattern, trim-start: false)
    })

  } else {
    // format reference, either as a label or as an element
    let elem = if type(it) == label {
      query(it).at(0)
    } else {
      it
    }
    let loc = elem.location()
    let fields = e.fields(elem)

    let pattern = if is-second and e.func(elem) == subexample {
      fields.second-sub-ref-pattern
    } else {
      fields.ref-pattern
    }

    format-num(fields._counter.at(loc), pattern, trim-start: is-second)

  }
}


#let ex-ref = e.element.declare(
  "ex-ref",
  prefix: prefix,
  doc: "An example reference in parentheses. Accepts labels and integers for relative references. Automatically handles plural references such as (1-3) and (1a-c).",

  fields: (
    e.field("first", e.types.union(int, label, example, subexample), required: true),
    e.field("second", e.types.option(e.types.union(int, label, example, subexample))),
    e.field("left", content, doc: "Text on the left, e.g. \"e.g. \"."),
    e.field("right", content, doc: "Text on the right, e.g. \" etc.\"."),

    e.field("ref-pattern", str, default: "1a", doc: "Format for relative references. A 2-level numbering pattern."),
  ),
  
  parse-args: (default-parser, fields: none, typecheck: none) => (args, include-required: false) => {
    if args.pos().len() > 2 or args.pos().len() < 0 {
      return (false, "ex-ref takes from 1 to 2 positional arguments.")
    }

    let args = if include-required {
      arguments(args.pos().at(0), second: args.pos().at(1, default: none), ..args.named())
    } else if args.pos() == () {
      args
    } else {
      return (false, "element 'sunk': unexpected positional arguments\n  hint: these can only be passed to the constructor")
    }

    default-parser(args, include-required: include-required)
  },

  display: it => [
    
  ]

)


/// Typesets an example reference in parentheses.
/// - ..args (label | int):
///   One to two arguments.
///   Can be labels or integers (or elements, but you probably won't need it).
///   Integers are used for relative reference:
///   0 means the last example, 1 means the next, etc.
///
///   *Required*
///
/// - left (content): Text on the left, e.g. "e.g. "
///
///   *Default*: none
///
/// - right (content): Text on the right, e.g. " etc."
///
///   *Default*: none
/// 
/// -> content
#let ex-ref(
  ..args,
  left: none,
  right: none,
) = {
  // validate references
  show ref: it => {
    assert(it.element != none, message: "label " + repr(it.target) + " does not exist in the document")
    it
  }

  // format a reference or a number
  // if reference, with the config at its element
  // either for a label or for a relative integer
  // if last, only use the lowest-level number, and `sub-ref-pattern`

  // first ref
  [(#left#format-ref-or-num(args.at(0))]
  // second ref
  if args.pos().len() > 1 {
    [\-#format-ref-or-num(args.at(1), is-second: true)]
  }
  [#right)]
}

#let parse-ref(it) = {
  if (
    type(it.element) == content
    and e.func(it.element) in (example, subexample)
  ) {
    let suppl = it.supplement
    // TODO (maybe): implement left and right
    if suppl != auto and "target" in suppl.fields() {
      return ex-ref(it.element, suppl.target)
    }
    return ex-ref(it.element)
  } else {
    it
  }
  
}
