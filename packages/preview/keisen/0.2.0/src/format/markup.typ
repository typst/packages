///! Typst markup held as text.
///!
///! Named for what it is: the string is Typst, not Markdown, and no parser of
///! another language is involved. This is what a generator emits when a cell
///! carries emphasis it could not express as content.

#import "../utils/errors.typ": fail-type
#import "number.typ": format

// `eval` cannot be attempted speculatively, since Typst has no `try`, so a
// string that is not valid markup is reported by Typst itself. The type is
// checked here, which is the part this package can answer for.
#let format-markup(columns, rows: auto) = format(
  columns,
  rows: rows,
  scope: "format-markup",
  value => {
    if type(value) == content { return value }
    if type(value) != str {
      fail-type(
        "format-markup",
        "value",
        value,
        "a string of Typst markup, or content",
        hint: "Write \"*Bolt*\" in the data, or [*Bolt*].",
      )
    }
    if value == "" { return [] }
    eval(value, mode: "markup")
  },
)
