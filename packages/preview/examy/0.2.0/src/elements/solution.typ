#import "../types.typ": *
#import "../constants.typ": SHOW_SOLUTIONS_OVERRIDE
#import "../config.typ": config

/// Whether or not solutions should be shown given the current configuration and command-line overrides.
#let show_solutions(get) = {
  if SHOW_SOLUTIONS_OVERRIDE != none {
    SHOW_SOLUTIONS_OVERRIDE
  } else {
    get(config).show-solutions
  }
}

/// API documentation for this module's exports, consumed by
/// docs/generate-api.typ (keyed by export name). Kept next to the
/// signatures — update both together. `solution` needs no argument docs
/// here: elembic elements are introspected.
#let DOCS = (
  solution: (kind: "element"),
  "show-solutions": (
    desc: "Returns the effective show-solutions setting: the `--input show-solutions=..` command-line override if given, otherwise `config`'s value. Use it to conditionally render content that `#solution[..]` cannot wrap (e.g. one curve of a plot).",
    args: (
      (
        name: "get",
        type: "function",
        required: true,
        doc: "The accessor provided by `e.get(get => ..)`.",
      ),
    ),
  ),
)

/// (Conditionally) show a solution for a question/part/subpart.
#let solution = e.element.declare(
  "solution",
  prefix: PREFIX,
  doc: "Declare a solution to a question, part, or subpart; this is only rendered if the config option to show solutions is enabled.",
  display: it => {
    e.get(get => {
      if show_solutions(get) != false {
        let solution-background-color = get(config).solution-background-color
        let solution-text-color = get(config).solution-text-color
        show: it_ => {
          if it.boxed {
            // show: pad.with(-3pt)
            box(fill: solution-background-color, width: auto, inset: 3pt, text(
              fill: solution-text-color,
              it_,
            ))
          } else {
            text(fill: solution-text-color, it_)
          }
        }
        it.body
      }
    })
  },
  fields: (
    e.field("body", content, doc: "The solution content", required: true),
    e.field("boxed", bool, doc: "Whether to put the solution in a box", default: true),
  ),
)
