// layout.typ - Layout utility functions for chart sizing and label placement

/// Checks whether a text label fits inside a given rectangular area.
///
/// Uses a heuristic based on character width ratio to estimate text width.
///
/// - available-width (length): Width of the container
/// - available-height (length): Height of the container
/// - text-size (length): Font size of the label
/// - text-len (int): Number of characters in the label
/// -> bool
#let label-fits-inside(available-width, available-height, text-size, text-len) = {
  let estimated-width = text-size * 0.6 * text-len
  let estimated-height = text-size * 1.2
  estimated-width <= available-width and estimated-height <= available-height
}

/// Returns a skip factor N so that showing every Nth label maintains min-spacing.
///
/// - count (int): Total number of labels
/// - available-length (length): Total available length for all labels
/// - min-spacing (length): Minimum spacing between label centers
/// -> int
#let density-skip(count, available-length, min-spacing: 12pt) = {
  if count <= 0 { return 1 }
  let per-label = available-length / count
  if per-label >= min-spacing { 1 } else { calc.ceil(min-spacing / per-label) }
}

/// Computes a font size that fits within the available space.
///
/// Returns `min(base-size, max(min-size, available * ratio))`.
///
/// - available (length): Available space (width or height)
/// - base-size (length): Preferred/maximum font size
/// - min-size (length): Floor font size
/// - ratio (float): Fraction of available space to use
/// -> length
#let font-for-space(available, base-size, min-size: 4pt, ratio: 0.6) = {
  calc.min(base-size, calc.max(min-size, available * ratio))
}

/// Lays out items in a paged grid with automatic pagebreaks.
///
/// Groups items into pages of `cols × rows`, rendering each page as a grid
/// and inserting `#pagebreak()` between pages.
///
/// - items (array): Array of content items (charts, blocks, etc.)
/// - cols (int): Number of columns per page
/// - rows (int): Number of rows per page
/// - col-gutter (length): Horizontal gap between columns
/// - row-gutter (length): Vertical gap between rows
/// -> content
#let page-grid(items, cols: 2, rows: 4, col-gutter: 8pt, row-gutter: 4pt) = {
  let per-page = cols * rows
  let pages = calc.ceil(items.len() / per-page)
  for p in array.range(pages) {
    if p > 0 { pagebreak() }
    let start = p * per-page
    let end = calc.min(start + per-page, items.len())
    let page-items = items.slice(start, end)
    grid(
      columns: array.range(cols).map(_ => 1fr),
      column-gutter: col-gutter,
      row-gutter: row-gutter,
      ..page-items,
    )
  }
}

/// Places a label near a Cartesian point with quadrant-aware alignment.
///
/// Clamps the label position to stay within the given bounds rectangle.
/// Optionally draws a leader line from the original point to the displaced label.
///
/// - x (length): Original x position
/// - y (length): Original y position
/// - body (content): Label content to place
/// - bounds (dictionary): Dict with `left`, `right`, `top`, `bottom` keys
/// - box-width (length): Width of the label box
/// - leader (bool): Whether to draw a leader line
/// - leader-stroke (stroke): Stroke style for the leader line
/// -> content
#let place-cartesian-label(x, y, body, bounds, box-width: 40pt, leader: false, leader-stroke: 0.5pt + luma(140)) = {
  // Determine quadrant-aware offset: push label away from center
  let cx = (bounds.left + bounds.right) / 2
  let cy = (bounds.top + bounds.bottom) / 2

  let offset-x = if x >= cx { 8pt } else { -8pt - box-width }
  let offset-y = -12pt  // default: above the point

  // Compute displaced position
  let lx = x + offset-x
  let ly = y + offset-y

  // Clamp to bounds
  let lx = calc.max(bounds.left, calc.min(bounds.right - box-width, lx))
  let ly = calc.max(bounds.top, calc.min(bounds.bottom - 10pt, ly))

  // Leader line from original point to label anchor
  if leader {
    place(left + top,
      line(start: (x, y), end: (lx + box-width / 2, ly + 7pt), stroke: leader-stroke))
  }

  // Label
  place(left + top, dx: lx, dy: ly,
    box(width: box-width, align(center, body)))
}
