///! Selector matching and format application.
///!
///! Selectors are uniform across every directive, and every predicate takes one
///! argument: Typst closures fail on arity mismatch, and `row => ..` is what
///! people write. Row position travels on the reserved `_index` key instead of
///! a second parameter.

#import "../data.typ": column
#import "../parts/substitutions.typ": is-missing, is-zero
#import "../theme/options.typ": option
#import "../utils/errors.typ": check, fail, fail-type
#import "nanoplot.typ": nanoplot-cell, shared-domain

// One entry per field a selector addresses, so a directive is answered in the
// words of the field the caller wrote. A note is matched through `matches-row`
// and a synthetic row, so it took the rows wording and pointed the caller at
// `row.units`, which `cells-source-notes` does not take.
#let SELECTOR-FIELDS = (
  columns: (
    expected: "auto, a name, an array of names, or a predicate",
    hint: "Write \"units\", (\"units\", \"price\"), or name => name != \"units\".",
  ),
  rows: (
    expected: "auto, an index, an array of indices, or a predicate",
    hint: "Write 0, (0, 2), or row => row.units > 100.",
  ),
  notes: (
    expected: "auto, a note position, an array of positions, or a predicate",
    hint: "Notes are numbered from zero, in the order the footer prints them.",
  ),
)

#let fail-selector(field, selector) = {
  let (expected, hint) = SELECTOR-FIELDS.at(field)
  fail-type(field, "selector", selector, expected, hint: hint)
}

#let matches-column(selector, name) = {
  if selector == auto {
    true
  } else if type(selector) == str {
    selector == name
  } else if type(selector) == array {
    name in selector
  } else if type(selector) == function {
    selector(name)
  } else {
    fail-selector("columns", selector)
  }
}

// `field` names what the selector addresses. Notes ride this matcher on a
// synthetic row carrying only `_index`, and say so, so a bad note selector is
// not reported as a bad row selector.
#let matches-row(selector, row, field: "rows") = {
  if selector == auto {
    true
  } else if type(selector) == int {
    row._index == selector
  } else if type(selector) == array {
    row._index in selector
  } else if type(selector) == function {
    selector(row)
  } else {
    fail-selector(field, selector)
  }
}

// Group and spanner labels are selected by equality rather than by name: a group
// label comes from the data or from `table-row-group`, and a spanner label is
// content written by hand. Both live here because two places read them, the
// location DSL and the summary directives, and each had its own reading. The
// summaries coerced every numeric selector to a string, so a group labelled with
// the integer 3 answered to a style and not to a summary, and the two disagreed
// about which group they meant.
#let matches-label(selector, label) = {
  if selector == auto {
    true
  } else if type(selector) == array {
    selector.any(candidate => matches-label(candidate, label))
  } else if type(selector) == function {
    selector(label)
  } else if type(label) == str and type(selector) in (int, float) {
    // A group derived from a numeric column carries its label as a string, so a
    // numeric selector matches the label it obviously means. A label that is
    // itself a number is compared as one.
    str(selector) == label
  } else {
    selector == label
  }
}

// What a selector spells out, as against what it filters for. A name that does
// not resolve is a typo and is reported; `auto` and a predicate match nothing in
// silence, since a table built from filtered data legitimately has fewer rows on
// some renderings than on others. Every directive that names something draws the
// line here, so the location DSL and the format directives cannot disagree.
// What a selector spells out is held to the kind the field reads. An array of
// the wrong kind used to be filtered instead: an index written among the column
// names was dropped, so the directive landed on fewer columns than the caller
// wrote and said nothing about why.
//
// A value that is neither the kind, an array, `auto` nor a predicate is refused
// here rather than left to the matchers. They see one candidate at a time, so a
// table with no notes, no rows or no columns never ran them and the selector
// went unread. Whether a selector is usable does not depend on what the table
// turned out to hold, and an empty part is where a caller has least to go on.
//
// That holds for every selector a directive carries: the columns, the rows, and
// every selector of the location DSL. The rows of a format, a substitution, a
// colour directive and a group are matched a row at a time, so `_validate` reads
// each of them through `check-selector` or `check-rows` below.
//
// The whole selector is reported rather than the one element, since that is what
// was written, and the message is the one the matchers give. `field` is carried
// for the same reason `matches-row` carries it: the kind alone cannot tell a
// note position from a row index.
#let named(selector, kind, field: auto) = {
  if type(selector) == kind { return (selector,) }
  let named-field = if field != auto { field } else if kind == str { "columns" } else { "rows" }
  if type(selector) != array {
    if selector == auto or type(selector) == function { return () }
    fail-selector(named-field, selector)
  }
  if selector.all(candidate => type(candidate) == kind) { return selector }
  fail-selector(named-field, selector)
}

// The reading on its own, for a field whose elements nothing then walks. A
// caller that has something to do with the positions loops over `named`
// instead.
#let check-selector(selector, kind, field: auto) = {
  let _ = named(selector, kind, field: field)
}

// A row the data does not have, in one reading for every directive that
// addresses rows. The location DSL and `table-row-group` each wrote it out, so
// the two could drift apart.
#let check-rows(scope, selector, count) = {
  for position in named(selector, int) {
    check(
      position >= 0 and position < count,
      scope,
      "row " + repr(position) + " is not in the data",
      hint: "Rows are numbered from zero, and this table has " + str(count) + " of them.",
    )
  }
}

// The last matching directive wins for a given cell, which makes "format the
// column, then override a few rows" read in the order it is written. Formatters
// always see the raw value, never an already-formatted one, so replacing rather
// than composing is safe.
// Substitutions are tested before formatting, so a gap never reaches a
// formatter that would refuse it, and a substituted cell is opaque content.
#let _substitution(substitutions, name, row, value) = {
  let chosen = none
  for directive in substitutions {
    if not matches-column(directive.columns, name) { continue }
    if not matches-row(directive.rows, row) { continue }
    let applies = if directive.test == "missing" { is-missing(value) } else { is-zero(value) }
    if applies { chosen = directive }
  }
  chosen
}

// Which columns hold nanoplots, so the parts that aggregate can leave them out:
// a series of readings has no total, no mean, and no minimum.
#let nanoplot-columns(formats, columns) = {
  columns.filter(name => formats.any(directive => (
    "nanoplot" in directive and matches-column(directive.columns, name)
  )))
}

// A nanoplot is the one formatter whose output depends on the rest of the
// column, so its cell function is built here, where the column is: the domain
// spans the values below rather than arriving as an argument nobody can check.
// The formatter a directive stands for, given the theme it is rendered under.
//
// A number directive carries how to build its formatter rather than the
// formatter itself, since `group-separator: auto`, `decimal-separator: auto` and
// `rounding: auto` are answered by "number-group-separator",
// "number-decimal-separator" and "number-rounding" on the theme, which does not
// exist when the directive is written. Body cells and summary cells both come
// through here, so both read the same conventions.
#let formatter-for(directive, options) = {
  // A summary takes a bare formatter function as well as a directive, and a
  // function is already the thing a directive is unwrapped into.
  if type(directive) == function { return directive }
  if "family" not in directive { return directive.function }
  (directive.family)((
    group: option(options, "number-group-separator"),
    decimal: option(options, "number-decimal-separator"),
    rounding: option(options, "number-rounding"),
  ))
}

// A cell inset side, held to a plain length: a ratio or a relative length has
// nothing to be a share of here, and an array or a function is not an inset a
// width can be taken from.
#let _inset-length(inset, value) = {
  check(
    type(value) == length,
    "cell-inset",
    "a table with a nanoplot column needs an inset given as a length",
    value: inset,
    hint: "Give a length or a dictionary of lengths, such as (x: 0.5em).",
  )
  value
}

// The left and right shares of a cell inset, following Typst: a side wins over
// `x`, which wins over `rest`, and a side nothing names keeps the table's own
// 5pt, as the table it is handed to does. Read only for a nanoplot column, so a
// table without one keeps whatever inset it had.
#let _horizontal-inset(inset) = {
  if type(inset) != dictionary { return (left: _inset-length(inset, inset), right: _inset-length(inset, inset)) }
  let side(name) = _inset-length(inset, inset.at(name, default: inset.at("x", default: inset.at("rest", default: 5pt))))
  (left: side("left"), right: side("right"))
}

// Every nanoplot directive naming a column, in the order they were written.
#let nanoplot-directives(formats, name) = formats.filter(directive => (
  "nanoplot" in directive and matches-column(directive.columns, name)
))

// The column width when no `columns-width` names it: the plot plus the inset on
// both sides, so the cell is as wide as the plot asked for. Several directives
// can name one column, and the column holds the widest plot. Widths in mixed
// units cannot be ordered outside `context`, so one is wider only when it is no
// narrower in either unit.
#let nanoplot-track(directive, inset) = {
  let (left, right) = _horizontal-inset(inset)
  directive.nanoplot.width + left + right
}

#let widest-nanoplot(directives) = directives.fold(none, (widest, directive) => {
  if widest == none { return directive }
  let difference = directive.nanoplot.width - widest.nanoplot.width
  if difference.abs >= 0pt and difference.em >= 0 { directive } else { widest }
})

// What the plot may draw in, given the column's `columns-width` entry, or
// `auto` when it has none. A column width includes the inset, so a width that is
// not a fixed length, or that leaves nothing inside the inset, cannot hold a
// plot.
#let _WIDTH-HINT = "Give it in em or pt, wider than twice the cell inset."

// `auto` is how the grammar says "no value", so an entry of `auto` cannot be
// handed over as the value to report; it is written into the problem clause
// instead, which reads the same.
#let _check-fixed-width(given) = {
  if type(given) == length { return }
  fail(
    "columns-width",
    "a nanoplot column needs a fixed width" + if given == auto { "; got auto" } else { "" },
    value: given,
    hint: _WIDTH-HINT,
  )
}

#let content-width(directive, given, inset) = {
  let (left, right) = _horizontal-inset(inset)
  if given == auto { return directive.nanoplot.width }
  _check-fixed-width(given)
  let content = given - left - right
  // A width in em and the inset in pt (or the reverse) cannot be ordered outside
  // `context`, so only a width that is no wider in either unit is refused.
  check(
    content.abs > 0pt or content.em > 0,
    "columns-width",
    "a nanoplot column is narrower than its cell inset",
    value: given,
    hint: _WIDTH-HINT,
  )
  content
}

// The content width of a column, from its `columns-width` entry. An entry of
// `auto` names the column and gives it no width, which is not the same as
// naming nothing.
#let _column-content-width(directive, widths, name, inset) = {
  if name in widths { _check-fixed-width(widths.at(name)) }
  content-width(directive, widths.at(name, default: auto), inset)
}

#let _formatter(directive, values, options, width) = {
  if "nanoplot" not in directive { return formatter-for(directive, options) }
  let nanoplot = directive.nanoplot
  nanoplot-cell(nanoplot, shared-domain(values, nanoplot.plot.readings, given: nanoplot.domain), width)
}

#let apply-formats(rows, formats, name, substitutions: (), options: (:), widths: (:)) = {
  let values = column(rows, name)
  // Which directives name this column does not vary by row, and a nanoplot's
  // domain does not vary by cell, so both are settled once for the column.
  let applicable = formats.filter(directive => matches-column(directive.columns, name))
  let inset = option(options, "cell-inset")
  let formatters = applicable.map(directive => _formatter(
    directive,
    values,
    options,
    if "nanoplot" in directive { _column-content-width(directive, widths, name, inset) },
  ))

  rows.map(row => {
    let value = row.at(name, default: none)

    let substitution = _substitution(substitutions, name, row, value)
    if substitution != none { return substitution.replacement }

    let chosen = none
    for (position, directive) in applicable.enumerate() {
      if matches-row(directive.rows, row) { chosen = position }
    }
    // A cell formatter is handed the row it sits in; every other formatter sees
    // the value alone, because that is what people write.
    if chosen == none {
      value
    } else if applicable.at(chosen).cell {
      (formatters.at(chosen))(row)
    } else {
      (formatters.at(chosen))(value)
    }
  })
}

// The axes a column asks for, one `(top, bottom)` pair per column. The directive
// is the one the column's track is sized from, and the domain and the content
// width are the ones `apply-formats` hands the cells, so an axis lines up with
// the plots under it. A column with no readings has no domain, hence no axis.
#let column-axes(spec) = {
  let inset = option(spec.options, "cell-inset")
  spec.columns.map(name => {
    let none-drawn = (top: none, bottom: none)
    let directive = widest-nanoplot(nanoplot-directives(spec.formats, name))
    if directive == none { return none-drawn }
    let nanoplot = directive.nanoplot
    if nanoplot.plot.axis == none { return none-drawn }
    let domain = shared-domain(column(spec.data, name), nanoplot.plot.readings, given: nanoplot.domain)
    if domain == none { return none-drawn }
    let width = _column-content-width(directive, spec.widths, name, inset)
    let draw(side) = {
      let drawn = (nanoplot.plot.axis)(domain: domain, width: width, side: side)
      check(
        type(drawn) in (content, str, type(none)),
        "format-nanoplot",
        "axis must return content or none",
        value: drawn,
        hint: "Return none for no axis on that side.",
      )
      drawn
    }
    (top: draw("top"), bottom: draw("bottom"))
  })
}
