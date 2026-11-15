///! Decimal alignment of formatted values.
///!
///! A column of numbers reads as a column only when the separators line up.
///! The package measures the formatted fragments rather than the cells: `measure`
///! assumes infinite space and ignores the column tracks a table imposes
///! (typst/typst#3943), so a cell measurement would not be the width the cell
///! ends up with, while a run of digits is unbreakable and measures exactly.
///!
///! Each numeric cell becomes a right-aligned integer box, the separator, and a
///! left-aligned fraction box, every box being the column's widest.

// The widest rendering of each slot in a column, measured with the text
// settings in force where the table sits.
#let column-metrics(slots) = {
  let numbers = slots.filter(value => (
    type(value) == dictionary and value.at("kind", default: none) == "number"
  ))
  if numbers.len() == 0 { return none }

  let widest(render) = {
    let widths = numbers.map(value => measure(render(value)).width)
    if widths.len() == 0 { 0pt } else { calc.max(..widths) }
  }

  (
    lead: widest(value => [#(value.sign)] + if value.prefix == none { [] } else { value.prefix }),
    integer: widest(value => [#(value.integer)]),
    separator: widest(value => [#(value.separator)]),
    fraction: widest(value => [#(value.fraction)]),
    exponent: widest(value => if value.exponent == none { [] } else { value.exponent }),
    trail: widest(value => if value.suffix == none { [] } else { value.suffix }),
  )
}

// One cell, padded to the column metrics. Anything that is not a formatted
// number is opaque: a substitution or a bespoke formatter follows the column
// alignment instead.
#let align-slots(value, metrics) = {
  if metrics == none { return value }
  if type(value) != dictionary or value.at("kind", default: none) != "number" { return value }

  let lead = [#(value.sign)] + if value.prefix == none { [] } else { value.prefix }
  let exponent = if value.exponent == none { [] } else { value.exponent }
  let trail = if value.suffix == none { [] } else { value.suffix }

  // The slots are absolute, not direction-relative, and the run is pinned to
  // ltr: a number reads left to right in every script, including the
  // right-to-left ones. Without the pin, right-to-left text lays these boxes
  // out in reverse and 1256.750 renders as 750.256 1.
  //
  // Written as a sequence rather than a `+` chain: a leading `+` on a new line
  // parses as a unary operator on content.
  text(dir: ltr, {
    box(width: metrics.lead, align(right, lead))
    box(width: metrics.integer, align(right, [#(value.integer)]))
    box(width: metrics.separator, align(center, [#(value.separator)]))
    box(width: metrics.fraction, align(left, [#(value.fraction)]))
    box(width: metrics.exponent, align(left, exponent))
    box(width: metrics.trail, align(left, trail))
  })
}
