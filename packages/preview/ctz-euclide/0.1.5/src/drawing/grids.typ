// ctz-euclide/src/drawing/grids.typ
// Grid and lattice positioning helpers for structured diagrams

#import "@preview/cetz:0.4.2" as cetz
#import "../util.typ"

// Note: Drawing functions receive cetz.draw as cetz-draw parameter

// =============================================================================
// TRIANGULAR GRID
// =============================================================================

/// Compute position in a triangular grid (Pascal's triangle layout)
/// Each row has one more element than the previous, centered horizontally.
/// - row: row number (0 = top)
/// - col: column within row (0 to row)
/// - h-spacing: horizontal spacing between adjacent cells
/// - v-spacing: vertical spacing between rows
/// - origin: grid origin point (default: (0, 0))
/// Returns: (x, y) coordinates
#let triangular-pos(row, col, h-spacing: 1.5, v-spacing: 1.2, origin: (0, 0)) = {
  (
    origin.at(0) + col * h-spacing - row * h-spacing / 2,
    origin.at(1) - row * v-spacing
  )
}

// Alias for backward compatibility
#let pascal-pos = triangular-pos

/// Compute binomial coefficient C(n, k)
#let binomial(n, k) = {
  if k < 0 or k > n { return 0 }
  if k == 0 or k == n { return 1 }
  let result = 1
  for i in range(1, k + 1) {
    result = result * (n - i + 1) / i
  }
  int(result)
}

// =============================================================================
// RECTANGULAR GRID
// =============================================================================

/// Compute position in a rectangular grid
/// - row: row number (0 = top)
/// - col: column number (0 = left)
/// - h-spacing: horizontal spacing
/// - v-spacing: vertical spacing
/// - origin: grid origin point (default: (0, 0))
/// Returns: (x, y) coordinates
#let grid-pos(row, col, h-spacing: 1, v-spacing: 1, origin: (0, 0)) = {
  (
    origin.at(0) + col * h-spacing,
    origin.at(1) - row * v-spacing
  )
}

// =============================================================================
// HEXAGONAL GRID
// =============================================================================

/// Compute position in a hexagonal (honeycomb) grid
/// - row: row number
/// - col: column number
/// - size: hexagon size (radius)
/// - pointy: true for pointy-top hexagons, false for flat-top
/// Returns: (x, y) coordinates
#let hex-pos(row, col, size: 1, pointy: true) = {
  if pointy {
    let x = size * calc.sqrt(3) * (col + 0.5 * calc.rem(row, 2))
    let y = -size * 1.5 * row
    (x, y)
  } else {
    let x = size * 1.5 * col
    let y = -size * calc.sqrt(3) * (row + 0.5 * calc.rem(col, 2))
    (x, y)
  }
}

// =============================================================================
// TRIANGULAR GRID DRAWING
// =============================================================================

/// Draw content at each cell of a triangular grid
/// - cetz-draw: cetz draw context
/// - rows: number of rows
/// - content-fn: function (row, col) => content to display at cell
/// - h-spacing, v-spacing: spacing parameters
/// - origin: grid origin
/// - text-size: font size
/// - text-color: color
#let draw-triangular-grid(
  cetz-draw,
  rows,
  content-fn,
  h-spacing: 1.5,
  v-spacing: 1.2,
  origin: (0, 0),
  text-size: 12pt,
  text-color: black,
) = {
  for row in range(rows) {
    for col in range(row + 1) {
      let p = triangular-pos(row, col, h-spacing: h-spacing, v-spacing: v-spacing, origin: origin)
      let c = content-fn(row, col)
      if c != none {
        cetz-draw.content(p, text(size: text-size, fill: text-color, c))
      }
    }
  }
}

/// Draw Pascal's triangle binomial values (convenience wrapper)
#let draw-pascal-values(
  cetz-draw,
  rows,
  h-spacing: 1.5,
  v-spacing: 1.2,
  text-size: 12pt,
  text-color: black,
) = {
  draw-triangular-grid(
    cetz-draw, rows,
    (n, k) => str(binomial(n, k)),
    h-spacing: h-spacing, v-spacing: v-spacing,
    text-size: text-size, text-color: text-color,
  )
}

/// Draw row labels for a triangular grid
/// - cetz-draw: cetz draw context
/// - rows: number of rows
/// - h-spacing, v-spacing: spacing parameters
/// - offset: horizontal offset from first column
/// - text-size: font size
/// - text-color: color
/// - format: function (row) => content for label
#let draw-row-labels(
  cetz-draw,
  rows,
  h-spacing: 1.5,
  v-spacing: 1.2,
  offset: -1.5,
  origin: (0, 0),
  text-size: 11pt,
  text-color: blue,
  format: n => $n = #n$,
) = {
  for n in range(rows) {
    let p = triangular-pos(n, 0, h-spacing: h-spacing, v-spacing: v-spacing, origin: origin)
    let label-pos = (p.at(0) + offset, p.at(1))
    cetz-draw.content(label-pos, text(size: text-size, fill: text-color, format(n)))
  }
}

// Alias for backward compatibility
#let draw-pascal-row-labels = draw-row-labels

/// Draw diagonal labels for a triangular grid
/// - cetz-draw: cetz draw context
/// - count: number of diagonals to label
/// - h-spacing, v-spacing: spacing parameters
/// - offset: (dx, dy) offset from diagonal position
/// - text-size: font size
/// - text-color: color
/// - angle: rotation angle for labels
/// - format: function (k) => content for label
#let draw-diagonal-labels(
  cetz-draw,
  count,
  h-spacing: 1.5,
  v-spacing: 1.2,
  offset: (0.5, 0.5),
  origin: (0, 0),
  text-size: 9pt,
  text-color: gray,
  angle: 45deg,
  format: k => $arrow.l k = #k$,
) = {
  for k in range(count) {
    let p = triangular-pos(k, k, h-spacing: h-spacing, v-spacing: v-spacing, origin: origin)
    let label-pos = (p.at(0) + offset.at(0), p.at(1) + offset.at(1))
    cetz-draw.content(label-pos, text(size: text-size, fill: text-color, format(k)), angle: angle)
  }
}

// Alias for backward compatibility
#let draw-pascal-diagonal-labels = draw-diagonal-labels

// =============================================================================
// RECTANGULAR GRID DRAWING
// =============================================================================

/// Draw content at each cell of a rectangular grid
/// - cetz-draw: cetz draw context
/// - rows, cols: grid dimensions
/// - content-fn: function (row, col) => content to display at cell
/// - h-spacing, v-spacing: spacing parameters
/// - origin: grid origin
/// - text-size: font size
/// - text-color: color
#let draw-rectangular-grid(
  cetz-draw,
  rows,
  cols,
  content-fn,
  h-spacing: 1.0,
  v-spacing: 1.0,
  origin: (0, 0),
  text-size: 12pt,
  text-color: black,
) = {
  for row in range(rows) {
    for col in range(cols) {
      let p = grid-pos(row, col, h-spacing: h-spacing, v-spacing: v-spacing, origin: origin)
      let c = content-fn(row, col)
      if c != none {
        cetz-draw.content(p, text(size: text-size, fill: text-color, c))
      }
    }
  }
}
