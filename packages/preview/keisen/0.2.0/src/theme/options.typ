///! Option dictionary and merging.
///!
///! A theme is an option dictionary, so a preset and a `table-options()` call
///! are the same kind of thing and compose by merging. Roughly forty curated
///! keys rather than one per conceivable property: an option nobody sets is a
///! maintenance cost with no reader.

#import "../utils/errors.typ": check

#let DEFAULTS = (
  // Table
  "table-font": none,
  "table-font-size": none,
  "table-align": start,
  // `auto` lets the table size itself to its content. Given a width, the columns
  // no columns-width names share whatever the named ones leave.
  "table-width": auto,
  "table-border-top": none,
  "table-border-bottom": none,
  "breakable": true,
  "infer-alignment": true,
  "decimal-align": true,
  // Vertical rules between columns and horizontal rules between rows, both off
  // by default: a table reads better ruled by part than ruled as a grid.
  "column-border": none,
  "row-border": none,
  // Header
  "header-title-size": 1.1em,
  "header-title-weight": "bold",
  "header-subtitle-size": 1em,
  "header-align": start,
  "header-border-bottom": none,
  // Column labels
  // `auto` follows the column beneath, which is what a label usually wants.
  "column-labels-align": auto,
  "column-labels-weight": "bold",
  "column-labels-size": 1em,
  "column-labels-border-top": none,
  "column-labels-border-bottom": none,
  "spanner-border-bottom": none,
  // Stub and groups
  "stub-weight": "regular",
  "stub-indent-step": 1em,
  "row-group-weight": "bold",
  "row-group-fill": none,
  "row-group-border-top": none,
  "row-group-repeat": true,
  // Body
  "row-striping": false,
  "row-striping-fill": luma(245),
  "cell-inset": 0.5em,
  "body-border-top": none,
  "body-border-bottom": none,
  // `auto` leaves the vertical placement to Typst, which puts a cell at the top
  // of its row. `horizon` centres each one against the tallest cell beside it,
  // which is what a row of unequal heights usually wants.
  "cell-vertical-align": auto,
  // Summaries
  "summary-weight": "bold",
  "summary-fill": none,
  "summary-border-top": none,
  "grand-summary-border-top": none,
  // Formatter defaults
  //
  // What a formatter uses where its own argument is `auto`, so a French or
  // German table sets its convention once rather than on every directive.
  "number-group-separator": sym.space.thin,
  "number-decimal-separator": ".",
  "number-rounding": "half-up",

  // Footer
  "footer-align": start,
  "footnote-marks": "numbers",
  "footnote-size": 0.8em,
  "source-note-size": 0.8em,
  "footer-border-top": none,
)

// One reading of "that is not an option", shared by a theme and by a
// table-options() call: a typo in either is reported rather than ignored.
// The caller holds `options` to a dictionary first, since the two paths differ
// on what a reader wrote and so on what the hint should say.
#let validate-options(options, scope) = {
  for name in options.keys() {
    check(
      name in DEFAULTS,
      scope,
      "unknown option " + name,
      hint: "See the reference for the option names this version reads.",
    )
  }
  options
}

#let table-options(..keys) = {
  check(
    keys.pos().len() == 0,
    "table-options",
    "options are named, not positional",
    hint: "Write table-options(row-striping: true).",
  )
  (kind: "options", options: validate-options(keys.named(), "table-options"))
}

// An option read through here always has a value, so the renderer never carries
// a default of its own.
#let option(options, name) = options.at(name, default: DEFAULTS.at(name))
