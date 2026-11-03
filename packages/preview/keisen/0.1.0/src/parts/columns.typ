///! Column labels, order, and visibility.

// Named arguments read as the columns they label: columns-label(mass: [Mass]).
#let columns-label(..pairs) = (
  kind: "labels",
  labels: pairs.named(),
)

// Names are written one per argument, and an array contributes the names it
// holds, so `columns-hide(("units", "price"))` says what `columns-hide("units",
// "price")` says. Every `columns:` selector takes an array and so does the
// serialised `hidden` key, so an array is the natural thing to write here. It
// used to be neither read nor refused: it reached the error builder, which
// added it to a string and died on a line of this package.
#let _positional-names(arguments) = {
  let names = ()
  for argument in arguments {
    if type(argument) == array { names += argument } else { names.push(argument) }
  }
  names
}

// Hidden columns leave the rendered table but stay in the data, so predicates
// and formatters can still read them.
#let columns-hide(..columns) = (
  kind: "hide",
  columns: _positional-names(columns.pos()),
)

// Reordering is recorded here and resolved in src/spec/order.typ once every
// directive has landed, so a move reads the same wherever it is written.
//
// `before` and `after` name one column rather than a list, so neither reads an
// array the way the positional names do.
#let columns-move(..columns, before: none, after: none) = (
  kind: "move",
  columns: _positional-names(columns.pos()),
  before: before,
  after: after,
)

// Widths are given per column; anything unnamed sizes itself. A fraction is
// resolved by Typst against the table's own width.
#let columns-width(widths) = (
  kind: "width",
  widths: widths,
)

// One column built from several. `pattern` takes one argument per source, in
// `from` order, and receives their formatted content: the combine stage sits
// after formatting, which is what makes `(estimate, error) => [#estimate
// (#error)]` read the way it is written.
//
// The result takes the place of the first of its sources, so it sits where the
// reader was already looking, and the sources are hidden rather than dropped:
// they stay readable by predicates and formatters.
#let columns-combine(into, from, pattern, label: auto, hide-sources: true) = (
  kind: "combine",
  into: into,
  from: from,
  pattern: pattern,
  label: label,
  hide-sources: hide-sources,
)

// Alignment may be direction-relative (start, end) or absolute; the default is
// inferred per column from the data.
#let columns-align(alignment, columns: auto) = (
  kind: "align",
  alignment: alignment,
  columns: columns,
)
