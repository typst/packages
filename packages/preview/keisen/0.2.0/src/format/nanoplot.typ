///! Nanoplot protocol and shared domains.
///!
///! The core owns the protocol, the domain, and the cell box. A nanoplot is
///! drawn by whichever renderer is passed as `plot`, and src/format/renderers.typ
///! provides four drawn with native Typst primitives. A renderer is a dictionary
///! of `draw`, `readings` and `axis`, and the core never looks inside a cell
///! value: `readings` is how a renderer says which numbers it contains.
///!
///! The domain spans every row in the column, because comparability down the
///! column is the whole point of a nanoplot: sparklines scaled per cell say
///! nothing. It is computed from the column being formatted rather than taken
///! as an argument, so a directive cannot be handed one column's readings and
///! aimed at another.

#import "../utils/errors.typ": check, fail, fail-type

#let values-of(value) = {
  if type(value) != array { return () }
  value
    .filter(entry => type(entry) in (int, float, decimal))
    .map(entry => float(entry))
}

// A renderer's readings of one cell value. The renderer may be written in a
// document, so what it returns is checked before the core counts or spans it.
#let _readings-of(readings, value) = {
  let numbers = readings(value)
  check(
    type(numbers) == array and numbers.all(entry => type(entry) in (int, float, decimal)),
    "format-nanoplot",
    "readings must return an array of numbers",
    value: numbers,
    hint: "Return () for a value the renderer cannot read.",
  )
  numbers
}

// The domain across every row of the column, so each cell draws on the same
// scale. An explicit domain overrides it.
#let shared-domain(values, readings, given: auto) = {
  if given != auto { return given }
  let numbers = values.map(value => _readings-of(readings, value)).flatten()
  if numbers.len() == 0 { return none }
  (calc.min(..numbers), calc.max(..numbers))
}

// The cell formatter, built once the column's domain is known. `apply-formats`
// is what knows it, since it is what holds the column.
#let nanoplot-cell(options, domain, width) = value => {
  if _readings-of(options.plot.readings, value).len() == 0 { return [] }
  box(
    width: width,
    height: options.height,
    baseline: options.baseline,
    (options.plot.draw)(value, domain: domain, width: width, height: options.height),
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
  let is-renderer = (
    type(plot) == dictionary
      and plot.at("kind", default: none) == "nanoplot-renderer"
      and ("draw", "readings", "axis").all(key => key in plot)
  )
  if not is-renderer {
    fail-type(
      "format-nanoplot",
      "plot",
      plot,
      "a nanoplot renderer",
      hint: "Call the renderer, as in nanoplot-line(), or pass a dictionary with kind: \"nanoplot-renderer\".",
    )
  }
  // The keys are there, but a dictionary merged over a renderer can replace
  // any of them with something that cannot be called.
  for name in ("draw", "readings") {
    if type(plot.at(name)) != function {
      fail-type(
        "format-nanoplot",
        name,
        plot.at(name),
        "a function",
        hint: "Give a function of the cell value, or call the renderer as it ships.",
      )
    }
  }
  if plot.axis != none and type(plot.axis) != function {
    fail-type(
      "format-nanoplot",
      "axis",
      plot.axis,
      "none or a function",
      hint: "Give none for no axis.",
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
  // The column is sized from the plot width, so it is a fixed length: a
  // percentage has no column width to be a share of until the column has one.
  if type(width) != length {
    fail-type("format-nanoplot", "width", width, "a length", hint: "Give it in em or pt.")
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
