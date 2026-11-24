///! Data-driven colour across a column.

#import "../data.typ": column
#import "../format/apply.typ": matches-row
#import "../utils/colour.typ": fraction-of, readable-on, sample-palette
#import "../utils/errors.typ": check

// `palette` is a positional argument for the same reason `columns` is on the
// format family: a positional parameter cannot carry a default.
// A palette entry may be written as a hex string, which reads better in a
// document than rgb() around every stop.
#let _colour(value) = if type(value) == str { rgb(value) } else { value }

#let data-colour(
  palette,
  columns: auto,
  rows: auto,
  domain: auto,
  target: "fill",
  missing: none,
  reverse: false,
) = {
  let stops = if type(palette) == array { palette.map(_colour) } else { (_colour(palette),) }
  check(
    stops.len() > 0,
    "data-colour",
    "the palette is empty",
    hint: "Give at least one colour, or two for a gradient.",
  )
  (
  kind: "colour",
  palette: stops,
  columns: columns,
  rows: rows,
  domain: domain,
  target: target,
  missing: missing,
  reverse: reverse,
  )
}

// The domain spans every matching row in the column, not each group separately:
// per-group scaling is one data-colour per group with a rows predicate, which
// keeps one rule rather than adding an option.
#let _domain(directive, rows, name) = {
  if directive.domain != auto { return directive.domain }
  let values = column(rows.filter(row => matches-row(directive.rows, row)), name)
    .filter(value => type(value) in (int, float, decimal))
    .map(value => if type(value) == decimal { float(value) } else { value })
  if values.len() == 0 { return none }
  (calc.min(..values), calc.max(..values))
}

// Styles for one column, keyed by row position, so the caller merges them into
// the style index like any other source of cell styling.
#let colour-styles(directive, rows, name) = {
  // A column the scale can place nothing in has no domain, and every matching
  // row in it is a gap: `_domain` reads the same rows this loop does, so a
  // column with a domain of none holds no number for the loop to place. The
  // missing colour still applies, which is why there is no early return here.
  let domain = _domain(directive, rows, name)

  let styles = (:)
  for row in rows {
    if not matches-row(directive.rows, row) { continue }
    let value = row.at(name, default: none)
    if type(value) not in (int, float, decimal) {
      if directive.missing != none {
        styles.insert(
          str(row._index),
          if directive.target == "fill" {
            (fill: directive.missing, text: (fill: readable-on(directive.missing)))
          } else {
            (text: (fill: directive.missing))
          },
        )
      }
      continue
    }

    let number = if type(value) == decimal { float(value) } else { value }
    let fraction = fraction-of(number, domain.first(), domain.last())
    if directive.reverse { fraction = 1.0 - fraction }
    let colour = sample-palette(directive.palette, fraction)

    styles.insert(
      str(row._index),
      if directive.target == "fill" {
        // Text contrast is chosen rather than left to chance: a dark fill under
        // black text is unreadable, and nothing else would notice.
        (fill: colour, text: (fill: readable-on(colour)))
      } else {
        (text: (fill: colour))
      },
    )
  }
  styles
}
