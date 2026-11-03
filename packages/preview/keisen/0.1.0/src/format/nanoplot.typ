///! Nanoplot protocol and shared domains.
///!
///! The core owns the protocol, the domain, and the cell box. A nanoplot is
///! drawn by whichever function is passed as `plot`, and src/format/renderers.typ
///! provides three drawn with native Typst primitives.
///!
///! The domain spans every row in the column, because comparability down the
///! column is the whole point of a nanoplot: sparklines scaled per cell say
///! nothing. It is computed from the column being formatted rather than taken
///! as an argument, so a directive cannot be handed one column's readings and
///! aimed at another.

#import "../utils/errors.typ": check, fail, fail-type

#let _values-of(value) = {
  if type(value) != array { return () }
  value
    .filter(entry => type(entry) in (int, float, decimal))
    .map(entry => float(entry))
}

// The domain across every row of the column, so each cell draws on the same
// scale. An explicit domain overrides it.
#let shared-domain(values, given: auto) = {
  if given != auto { return given }
  let numbers = values.map(_values-of).flatten()
  if numbers.len() == 0 { return none }
  (calc.min(..numbers), calc.max(..numbers))
}

// The cell formatter, built once the column's domain is known. `apply-formats`
// is what knows it, since it is what holds the column.
#let nanoplot-cell(options, domain) = value => {
  let numbers = _values-of(value)
  if numbers.len() == 0 { return [] }
  box(
    width: options.width,
    height: options.height,
    baseline: options.baseline,
    (options.plot)(numbers, domain: domain, width: options.width, height: options.height),
  )
}

#let format-nanoplot(
  columns,
  rows: auto,
  plot: none,
  width: 4em,
  height: 0.8em,
  baseline: 15%,
  domain: auto,
) = {
  if type(plot) != function {
    fail-type(
      "format-nanoplot",
      "plot",
      plot,
      "a renderer function",
      hint: "Pass nanoplot-line, nanoplot-bar, nanoplot-points, or a renderer of the same shape.",
    )
  }
  // A fractional width would have to be resolved inside the cell with layout(),
  // which forbids page breaking there; em and pt need no such thing.
  for (name, size) in (("width", width), ("height", height)) {
    check(
      type(size) != fraction,
      "format-nanoplot",
      name + " cannot be a fraction",
      value: size,
      hint: "Give it in em or pt: resolving a fraction inside a cell forbids page breaking there.",
    )
  }

  (
    kind: "format",
    columns: columns,
    rows: rows,
    scope: "format-nanoplot",
    nanoplot: (plot: plot, width: width, height: height, baseline: baseline, domain: domain),
    // A plot is drawn from the column's values, not from the row around them.
    cell: false,
    // Every other format directive carries a formatter, and the paths that
    // aggregate a column reach for it. A column of readings has nothing to
    // aggregate, so this says so rather than returning a plot of a total.
    function: value => fail(
      "format-nanoplot",
      "a column of nanoplots cannot be summarised",
      value: value,
      hint: "Name the other columns in summary-rows: aggregating series of readings has no meaning.",
    ),
  )
}
