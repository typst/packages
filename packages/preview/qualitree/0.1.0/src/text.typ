// Text fitting is the last resort for explicitly constrained dimensions.
// Automatic layout measures unscaled content first; strings remain literal.

#let _as-content(value) = if value == none { [] } else { [#value] }

// Constrain content to a cell without clipping or evaluating user strings.
// WHATs wrap first; short values and rotated labels shrink only when necessary.
#let _fit(body, w, h, anchor: center + horizon, wrap: false) = context {
  let body = if wrap { block(width: w, breakable: false, body) } else { box(body) }
  let extent = measure(body)
  let factor = calc.min(1, w / calc.max(0.01pt, extent.width), h / calc.max(0.01pt, extent.height))
  block(width: w, height: h, breakable: false, above: 0pt, below: 0pt,
    align(anchor, scale(factor * 100%, reflow: true, body)))
}

#let _cell(x, y, w, h, body, anchor: center + horizon, wrap: false, inset: 0.1cm) = {
  let inset = calc.min(inset, w / 2 - 0.01pt, h / 2 - 0.01pt)
  place(top + left, dx: x + inset, dy: y + inset,
    _fit(_as-content(body), w - 2 * inset, h - 2 * inset, anchor: anchor, wrap: wrap))
}

