///! Selector matching and format application.
///!
///! Selectors are uniform across every directive, and every predicate takes one
///! argument: Typst closures fail on arity mismatch, and `row => ..` is what
///! people write. Row position travels on the reserved `_index` key instead of
///! a second parameter.

#import "../data.typ": column
#import "../parts/substitutions.typ": is-missing, is-zero
#import "../theme/options.typ": option
#import "../utils/errors.typ": check, fail-type
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

#let _formatter(directive, values, options) = {
  if "nanoplot" not in directive { return formatter-for(directive, options) }
  nanoplot-cell(directive.nanoplot, shared-domain(values, given: directive.nanoplot.domain))
}

#let apply-formats(rows, formats, name, substitutions: (), options: (:)) = {
  let values = column(rows, name)
  // Which directives name this column does not vary by row, and a nanoplot's
  // domain does not vary by cell, so both are settled once for the column.
  let applicable = formats.filter(directive => matches-column(directive.columns, name))
  let formatters = applicable.map(directive => _formatter(directive, values, options))

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
