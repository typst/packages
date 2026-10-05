#import "../prelude.typ": *
#import "../constants.typ": SHOW_SOLUTIONS_OVERRIDE
#import "../config.typ": config, solution_colors

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
        let colors = solution_colors(get)
        show: it_ => {
          if it.boxed {
            // A width other than `auto` must use a block: a full-width *inline*
            // box would be pushed onto a line of its own, splitting any text
            // around it (and stretching a justified line before it).
            // `width: none` means "not chosen": the context decides. `_fill-width`
            // is how an enclosing element (`answer-box`) asks for the full width,
            // so an explicit `width` — from an argument *or* a set rule, at any
            // scope — still wins over it.
            let w = if it.width != none { it.width } else if it._fill-width { 100% } else { auto }
            let wrap = if w == auto { box.with(width: auto) } else { block.with(width: w) }
            wrap(fill: colors.background, inset: 3pt, text(
              fill: colors.color,
              it_,
            ))
          } else {
            text(fill: colors.color, it_)
          }
        }
        it.body
      }
    })
  },
  fields: (
    e.field("body", content, doc: "The solution content", required: true),
    e.field("boxed", bool, doc: "Whether to put the solution in a box", default: true),
    e.field(
      "width",
      e.types.option(e.types.union(auto, relative)),
      doc: "Width of the solution box. `auto` shrink-wraps it to its content; `none` lets the context choose (`answer-box` fills its width for a solution standing alone in a paragraph, otherwise it shrink-wraps).",
      default: none,
    ),
    // Internal: how `answer-box` asks a solution standing alone in a paragraph
    // to fill its width. Kept off the public API (`internal` is what
    // docs/generate-api.typ filters on) because it is a channel between the
    // two elements, not a knob for documents: authors choose a width with
    // `width`, which takes precedence over this.
    e.field(
      "_fill-width",
      bool,
      doc: "Whether an unset `width` should fill the container instead of shrink-wrapping.",
      default: false,
      internal: true,
    ),
  ),
)
