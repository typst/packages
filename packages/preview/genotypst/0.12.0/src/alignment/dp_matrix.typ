#import "../common/colors.typ": _medium-gray
#import "../common/strokes.typ": (
  _default-arrow-stroke, _default-cell-stroke, _default-path-arrow-stroke,
  _default-path-stroke,
)
#import "./alignment_coords.typ": (
  _parse-and-validate-coord, _parse-coord, _validate-path,
)
#import "@preview/tiptoe:0.4.0": (
  line as _tiptoe-line, straight as _tiptoe-straight,
)

/// Arrow tip shared by every traceback arrow
#let _arrow-tip = _tiptoe-straight.with(width: 550%, length: 375%)

/// Validates highlight entry shape, coordinates, and optional color.
///
/// - highlights (array): Highlight entries as `(row, col)` or
///   `(row, col, color)` arrays.
/// - max-row (int): Maximum allowed row index.
/// - max-col (int): Maximum allowed column index.
/// -> none
#let _validate-highlights(highlights, max-row, max-col) = {
  assert(type(highlights) == array, message: "highlights must be an array.")

  for (idx, highlight) in highlights.enumerate() {
    assert(
      type(highlight) == array
        and (highlight.len() == 2 or highlight.len() == 3),
      message: "Highlight at index "
        + str(idx)
        + " must be (row, col) or (row, col, color).",
    )

    let _ = _parse-and-validate-coord(
      highlight,
      max-row,
      max-col,
      "Highlight at index " + str(idx),
      allow-extra-array-items: true,
    )

    if highlight.len() == 3 {
      assert(
        type(highlight.at(2)) == color,
        message: "Highlight at index "
          + str(idx)
          + " color must be a color value.",
      )
    }
  }
}

/// Converts row/column coordinates to a row-major index.
///
/// - row (int): Zero-indexed row.
/// - col (int): Zero-indexed column.
/// - cols (int): Total number of columns.
/// -> int
#let _matrix-index(row, col, cols) = row * cols + col

/// Converts a row-major index back to row/column coordinates.
///
/// Inverse of `_matrix-index`; keep the two together so a layout change moves
/// both.
///
/// - idx (int): Row-major index.
/// - cols (int): Total number of columns.
/// -> dictionary with keys:
///   - row (int): Zero-indexed row.
///   - col (int): Zero-indexed column.
#let _matrix-coords(idx, cols) = (
  row: calc.div-euclid(idx, cols),
  col: calc.rem(idx, cols),
)

/// Validates dense row-major cell values.
///
/// - cell-values (array): Flat row-major cell values.
/// - expected-len (int): Expected number of entries.
/// -> none
#let _validate-dp-cell-values(cell-values, expected-len) = {
  assert(type(cell-values) == array, message: "cell-values must be an array.")
  assert(
    cell-values.len() == expected-len,
    message: "cell-values must contain exactly "
      + str(expected-len)
      + " row-major entries.",
  )
}

/// Validates dense row-major arrow bitmasks.
///
/// - arrows (array): Flat row-major direction bitmasks.
/// - rows (int): Total number of rows.
/// - cols (int): Total number of columns.
/// -> none
#let _validate-arrows(arrows, rows, cols) = {
  let expected-len = rows * cols
  assert(type(arrows) == array, message: "arrows must be an array.")
  assert(
    arrows.len() == expected-len,
    message: "arrows must contain exactly "
      + str(expected-len)
      + " row-major entries.",
  )

  // `assert`'s message is evaluated eagerly, so each check builds its message
  // only after failing; this loop runs once per matrix cell.
  for (idx, bits) in arrows.enumerate() {
    if type(bits) != int {
      assert(
        false,
        message: "Arrow bitmask at index " + str(idx) + " must be an integer.",
      )
    }
    if bits < 0 or bits > 7 {
      assert(
        false,
        message: "Arrow bitmask at index "
          + str(idx)
          + " must be between 0 and 7.",
      )
    }

    // Only the top row and first column can hold an out-of-bounds direction,
    // so interior cells skip the boundary checks entirely.
    let (row, col) = _matrix-coords(idx, cols)
    if row != 0 and col != 0 { continue }

    if row == 0 and bits.bit-and(2) != 0 {
      assert(
        false,
        message: "Arrow bitmask at index "
          + str(idx)
          + " cannot point up from the top row.",
      )
    }
    if col == 0 and bits.bit-and(4) != 0 {
      assert(
        false,
        message: "Arrow bitmask at index "
          + str(idx)
          + " cannot point left from the first column.",
      )
    }
    // The `continue` above already means this cell is on the top row or in the
    // first column, so a diagonal always leaves the matrix here.
    if bits.bit-and(1) != 0 {
      assert(
        false,
        message: "Arrow bitmask at index "
          + str(idx)
          + " cannot point diagonally outside the matrix boundary.",
      )
    }
  }
}

/// Converts a directed edge to a stable integer lookup key.
///
/// - from-coord (dictionary): Edge start coordinate with `row` and `col`.
/// - to-coord (dictionary): Edge end coordinate with `row` and `col`.
/// - cols (int): Total number of columns.
/// - cell-count (int): Total number of cells in the matrix.
/// -> int
#let _edge-index(from-coord, to-coord, cols, cell-count) = (
  _matrix-index(from-coord.row, from-coord.col, cols) * cell-count
    + _matrix-index(to-coord.row, to-coord.col, cols)
)

/// Calculates cell center coordinates.
///
/// - row (int): Zero-indexed row.
/// - col (int): Zero-indexed column.
/// - label-col-width (length): Width of the left label column.
/// - label-row-height (length): Height of the top label row.
/// - cell-size (length): Size of each square cell.
/// -> dictionary with keys:
///   - x (length): Horizontal center coordinate.
///   - y (length): Vertical center coordinate.
#let _cell-center(row, col, label-col-width, label-row-height, cell-size) = {
  let x = label-col-width + col * cell-size + cell-size * 0.5
  let y = label-row-height + row * cell-size + cell-size * 0.5
  (x: x, y: y)
}

/// Creates a label cell for the header row and left column.
///
/// - content (content, none): Label content.
/// -> content
#let _label-cell(content) = grid.cell(stroke: none, inset: 0pt)[
  #if content != none { align(center + horizon)[#content] }
]

/// Determines the corner radius for a cell based on its position.
///
/// - row-idx (int): Zero-indexed row.
/// - col-idx (int): Zero-indexed column.
/// - last-row (int): Last row index.
/// - last-col (int): Last column index.
/// - corner-radius (length): Radius used at the outer corners.
/// -> dictionary, length
#let _get-cell-radius(row-idx, col-idx, last-row, last-col, corner-radius) = {
  // A 1x1 matrix matches every edge; the first match wins.
  if row-idx == 0 and col-idx == 0 {
    (top-left: corner-radius, rest: 0pt)
  } else if row-idx == 0 and col-idx == last-col {
    (top-right: corner-radius, rest: 0pt)
  } else if row-idx == last-row and col-idx == 0 {
    (bottom-left: corner-radius, rest: 0pt)
  } else if row-idx == last-row and col-idx == last-col {
    (bottom-right: corner-radius, rest: 0pt)
  } else {
    0pt
  }
}

/// Builds logical grid cells for the background and text layers.
///
/// - top-clusters (array): Top header labels including the gap marker.
/// - left-clusters (array): Left header labels including the gap marker.
/// - cell-values (array, none): Flat row-major cell values.
/// - highlight-map (dictionary): Highlight fill colors keyed by row-major index.
/// - path-cell-set (dictionary): Membership map for path cells keyed by
///   row-major index.
/// - cell-stroke (stroke, none): Stroke for cell borders.
/// - cell-inset (length): Cell inset for the background and text boxes.
/// - corner-radius (length): Radius for outermost data-cell corners.
/// -> array: Logical grid cells with paired `bg` and `text` content.
#let _build-grid-cells(
  top-clusters,
  left-clusters,
  cell-values,
  highlight-map,
  path-cell-set,
  cell-stroke,
  cell-inset,
  corner-radius,
) = {
  let cells = ()
  let cols = top-clusters.len()
  let blank-cell = _label-cell(none)
  // Skip the per-cell `str(index)` entirely when nothing looks cells up.
  let needs-cell-key = highlight-map.len() > 0 or path-cell-set.len() > 0

  // Header row: empty top-left corner, then top sequence characters
  cells.push((bg: blank-cell, text: blank-cell))

  for char in top-clusters {
    cells.push((bg: blank-cell, text: _label-cell(char)))
  }

  // Calculate last row and column indices
  let last-row = left-clusters.len() - 1
  let last-col = top-clusters.len() - 1

  // Data rows: left label, then cell values
  for (row-idx, row-label) in left-clusters.enumerate() {
    cells.push((bg: blank-cell, text: _label-cell(row-label)))

    for col-idx in range(cols) {
      let index = _matrix-index(row-idx, col-idx, cols)
      // The empty key never matches a `str(index)` entry, so both lookups stay
      // unconditional while the `str` call is still skipped.
      let key = if needs-cell-key { str(index) } else { "" }
      let fill-color = highlight-map.at(key, default: none)
      let cell-radius = _get-cell-radius(
        row-idx,
        col-idx,
        last-row,
        last-col,
        corner-radius,
      )

      let text-content = if cell-values == none {
        []
      } else {
        let value = cell-values.at(index)
        if value == none {
          []
        } else if key in path-cell-set {
          align(center + horizon, strong[#value])
        } else {
          align(center + horizon)[#value]
        }
      }

      cells.push((
        bg: box(
          width: 100%,
          height: 100%,
          fill: fill-color,
          stroke: cell-stroke,
          radius: cell-radius,
          inset: cell-inset,
        )[],
        text: box(
          width: 100%,
          height: 100%,
          inset: cell-inset,
          text-content,
        ),
      ))
    }
  }

  cells
}

/// Renders the traceback path overlay.
///
/// - parsed-path (array): Parsed path coordinates in start-to-end order.
/// - path-stroke (stroke, none): Stroke for the traceback path line.
/// - label-col-width (length): Width of the left label column.
/// - label-row-height (length): Height of the top label row.
/// - cell-size (length): Size of each square cell.
/// -> content, none
#let _render-path(
  parsed-path,
  path-stroke,
  label-col-width,
  label-row-height,
  cell-size,
) = {
  if path-stroke == none or parsed-path.len() <= 1 {
    return
  }

  // Calculate path coordinates
  let path-coords = parsed-path.map(coord => {
    let center = _cell-center(
      coord.row,
      coord.col,
      label-col-width,
      label-row-height,
      cell-size,
    )
    (center.x, center.y)
  })

  // Draw continuous path through all points
  place(top + left, dx: 0pt, dy: 0pt, {
    let curve-components = (curve.move(path-coords.at(0)),)
    for i in range(1, path-coords.len()) {
      curve-components.push(curve.line(path-coords.at(i)))
    }

    curve(stroke: path-stroke, ..curve-components)
  })
}

/// Calculates arrow start and end positions based on direction.
///
/// - from-coord (dictionary): Edge start coordinate with `row` and `col`.
/// - to-coord (dictionary): Edge end coordinate with `row` and `col`.
/// - center-x (length): Midpoint x-position between the connected cells.
/// - center-y (length): Midpoint y-position between the connected cells.
/// - arrow-half-length (length): Half-length of the arrow shaft.
/// -> array: `(start-x, start-y, end-x, end-y)`.
#let _calculate-arrow-positions(
  from-coord,
  to-coord,
  center-x,
  center-y,
  arrow-half-length,
) = {
  if from-coord.row == to-coord.row {
    (
      center-x + arrow-half-length,
      center-y,
      center-x - arrow-half-length,
      center-y,
    )
  } else if from-coord.col == to-coord.col {
    (
      center-x,
      center-y + arrow-half-length,
      center-x,
      center-y - arrow-half-length,
    )
  } else {
    let dx-sign = if to-coord.col < from-coord.col { -1 } else { 1 }
    let dy-sign = if to-coord.row < from-coord.row { -1 } else { 1 }
    let diag-offset = arrow-half-length * 0.85
    (
      center-x - dx-sign * diag-offset,
      center-y - dy-sign * diag-offset,
      center-x + dx-sign * diag-offset,
      center-y + dy-sign * diag-offset,
    )
  }
}

/// Renders one arrow segment between two DP cells.
///
/// - from-coord (dictionary): Edge start coordinate with `row` and `col`.
/// - to-coord (dictionary): Edge end coordinate with `row` and `col`.
/// - arrow-stroke (stroke, none): Default arrow stroke. `none` hides the arrow.
/// - cell-size (length): Size of each square cell.
/// - label-col-width (length): Width of the left label column.
/// - label-row-height (length): Height of the top label row.
/// - path-edge-set (dictionary): Membership map for path edges keyed by
///   `_edge-index(...)`.
/// - path-arrow-stroke (stroke, none): Arrow stroke for edges on the highlighted
///   path. `none` hides the arrow.
/// - arrow-half-length (length): Half-length of the arrow shaft.
/// - cols (int): Total number of columns.
/// - cell-count (int): Total number of cells in the matrix.
/// -> content
#let _render-arrow(
  from-coord,
  to-coord,
  arrow-stroke,
  cell-size,
  label-col-width,
  label-row-height,
  path-edge-set,
  path-arrow-stroke,
  arrow-half-length,
  cols,
  cell-count,
) = {
  // Building the edge key is only worth it when there is a path to match.
  let edge-stroke = if path-edge-set.len() == 0 { arrow-stroke } else {
    let edge-key = str(_edge-index(from-coord, to-coord, cols, cell-count))
    if edge-key in path-edge-set { path-arrow-stroke } else { arrow-stroke }
  }
  if edge-stroke == none {
    return
  }

  let from-center = _cell-center(
    from-coord.row,
    from-coord.col,
    label-col-width,
    label-row-height,
    cell-size,
  )
  let to-center = _cell-center(
    to-coord.row,
    to-coord.col,
    label-col-width,
    label-row-height,
    cell-size,
  )

  let (start-x, start-y, end-x, end-y) = _calculate-arrow-positions(
    from-coord,
    to-coord,
    (from-center.x + to-center.x) / 2.0,
    (from-center.y + to-center.y) / 2.0,
    arrow-half-length,
  )

  place(top + left, dx: 0pt, dy: 0pt, {
    _tiptoe-line(
      start: (start-x, start-y),
      end: (end-x, end-y),
      stroke: edge-stroke,
      tip: _arrow-tip,
    )
  })
}

/// Renders all arrows from row-major arrow bitmasks.
///
/// - arrows (array, none): Flat row-major direction bitmasks.
/// - rows (int): Total number of rows.
/// - cols (int): Total number of columns.
/// - arrow-stroke (stroke, none): Default arrow stroke. `none` hides the arrow.
/// - cell-size (length): Size of each square cell.
/// - label-col-width (length): Width of the left label column.
/// - label-row-height (length): Height of the top label row.
/// - path-edge-set (dictionary): Membership map for path edges keyed by
///   `_edge-index(...)`.
/// - path-arrow-stroke (stroke, none): Arrow stroke for edges on the highlighted
///   path. `none` hides the arrow.
/// - arrow-length-scale (int, float): Positive multiplier for arrow length.
/// -> content, none
#let _render-arrows(
  arrows,
  rows,
  cols,
  arrow-stroke,
  cell-size,
  label-col-width,
  label-row-height,
  path-edge-set,
  path-arrow-stroke,
  arrow-length-scale,
) = {
  if arrows == none { return }
  if arrow-stroke == none and path-arrow-stroke == none { return }

  let cell-count = rows * cols
  let arrow-half-length = cell-size * 0.215 * arrow-length-scale

  for (idx, bits) in arrows.enumerate() {
    // Most cells carry no arrows; skip them before building anything.
    if bits == 0 { continue }

    let from-coord = _matrix-coords(idx, cols)
    let (row, col) = from-coord

    for (bit, row-delta, col-delta) in ((1, -1, -1), (2, -1, 0), (4, 0, -1)) {
      if (
        bits.bit-and(bit) != 0 and row + row-delta >= 0 and col + col-delta >= 0
      ) {
        _render-arrow(
          from-coord,
          (row: row + row-delta, col: col + col-delta),
          arrow-stroke,
          cell-size,
          label-col-width,
          label-row-height,
          path-edge-set,
          path-arrow-stroke,
          arrow-half-length,
          cols,
          cell-count,
        )
      }
    }
  }
}

/// Renders a dynamic programming matrix for sequence alignment visualization.
///
/// Supports optional cell highlighting, traceback path overlay, and arrow
/// indicators for alignment directions.
///
/// - seq-1 (str): Sequence displayed on the left as row labels.
/// - seq-2 (str): Sequence displayed on top as column labels.
/// - cell-values (array, none): Flat row-major cell values.
///   Must contain `(len(seq-1) + 1) * (len(seq-2) + 1)` entries when provided.
///   Entries may be any Typst value; individual `none` entries render as empty
///   cells (default: none).
/// - highlights (array): Cell highlights as `(row, col)` or `(row, col, color)` arrays (default: ()).
/// - highlight-color (color): Default color for highlighted cells (default: light gray).
/// - path (array, none): Traceback path as `(row, col)` arrays, in end-to-start order (default: none).
/// - path-stroke (stroke, none): Stroke for the traceback path line. `none` hides it (default: 18pt semi-transparent yellow, round caps and joins).
/// - path-cell-bold (bool): Whether cell values in path cells are rendered in bold (default: true).
/// - arrows (array, none): Flat row-major array with one integer per DP cell
///   (default: none). Pass `none` or `()` to disable arrows. Each integer is
///   a direction bitmask using `1 = diagonal`, `2 = up`, and `4 = left`.
///   Combine bits when multiple optimal predecessors exist, so `3` means
///   diagonal+up and `7` means all three directions.
/// - arrow-stroke (stroke, none): Stroke for arrows. `none` hides them (default: 0.75pt medium gray, round caps).
/// - highlight-path-arrows (bool): Whether arrows on the path use a different stroke (default: true).
/// - path-arrow-stroke (stroke, none): Stroke for arrows on the traceback path. `none` hides them (default: 0.75pt dark gray, round caps).
/// - arrow-length-scale (int, float): Positive multiplier for arrow length (default: 1).
/// - cell-size (length): Size of each square cell (default: 34pt).
/// - cell-stroke (stroke, none): Stroke for cell borders. `none` hides them (default: 0.75pt medium gray).
/// -> content
#let render-dp-matrix(
  seq-1,
  seq-2,
  cell-values: none,
  highlights: (),
  highlight-color: _medium-gray.lighten(75%),
  path: none,
  path-stroke: _default-path-stroke,
  path-cell-bold: true,
  arrows: none,
  arrow-stroke: _default-arrow-stroke,
  highlight-path-arrows: true,
  path-arrow-stroke: _default-path-arrow-stroke,
  arrow-length-scale: 1,
  cell-size: 34pt,
  cell-stroke: _default-cell-stroke,
) = {
  assert(type(seq-1) == str, message: "seq-1 must be a string.")
  assert(type(seq-2) == str, message: "seq-2 must be a string.")
  assert(
    type(arrow-length-scale) == int or type(arrow-length-scale) == float,
    message: "arrow-length-scale must be an integer or a float.",
  )
  assert(
    arrow-length-scale > 0,
    message: "arrow-length-scale must be greater than 0.",
  )

  let seq1-raw-clusters = seq-1.clusters()
  let seq2-raw-clusters = seq-2.clusters()
  let expected-rows = seq1-raw-clusters.len() + 1
  let expected-cols = seq2-raw-clusters.len() + 1
  let expected-len = expected-rows * expected-cols
  let arrows = if arrows == none {
    none
  } else {
    assert(type(arrows) == array, message: "arrows must be an array.")
    if arrows.len() == 0 { none } else { arrows }
  }
  if cell-values != none {
    _validate-dp-cell-values(cell-values, expected-len)
  }
  if arrows != none {
    _validate-arrows(arrows, expected-rows, expected-cols)
  }

  let top-clusters = ("–",) + seq2-raw-clusters
  let left-clusters = ("–",) + seq1-raw-clusters

  let max-row = left-clusters.len() - 1
  let max-col = top-clusters.len() - 1

  _validate-highlights(highlights, max-row, max-col)

  // `_validate-path` wants start-to-end order, but everything downstream
  // (`_edge-index`, the arrow directions) is keyed on end-to-start order, so
  // the validated coordinates are reversed back.
  let parsed-path = if path == none { () } else {
    _validate-path(path.rev(), max-row, max-col).rev()
  }

  let highlight-map = (:)
  for h in highlights {
    let coord = _parse-coord(h)
    let key = str(_matrix-index(coord.row, coord.col, expected-cols))

    // Preserve existing behavior: first matching highlight wins.
    if not (key in highlight-map) {
      highlight-map.insert(key, h.at(2, default: highlight-color))
    }
  }

  let path-cell-set = (:)
  if cell-values != none and path-cell-bold {
    for coord in parsed-path {
      path-cell-set.insert(
        str(_matrix-index(coord.row, coord.col, expected-cols)),
        true,
      )
    }
  }

  let path-edge-set = (:)
  if arrows != none and highlight-path-arrows and parsed-path.len() > 1 {
    for i in range(parsed-path.len() - 1) {
      path-edge-set.insert(
        str(_edge-index(
          parsed-path.at(i),
          parsed-path.at(i + 1),
          expected-cols,
          expected-len,
        )),
        true,
      )
    }
  }

  let label-scale = 0.65
  let cell-inset = 5pt
  let corner-radius = 3pt

  let label-col-width = cell-size * label-scale
  let label-row-height = cell-size * label-scale

  let grid-cells = _build-grid-cells(
    top-clusters,
    left-clusters,
    cell-values,
    highlight-map,
    path-cell-set,
    cell-stroke,
    cell-inset,
    corner-radius,
  )

  let column-widths = (label-col-width,) + ((cell-size,) * top-clusters.len())
  let row-heights = (label-row-height,) + ((cell-size,) * left-clusters.len())

  let bg-grid = grid(
    columns: column-widths,
    rows: row-heights,
    stroke: none,
    inset: 0pt,
    ..grid-cells.map(cell => cell.bg)
  )

  let text-grid = grid(
    columns: column-widths,
    rows: row-heights,
    stroke: none,
    inset: 0pt,
    ..grid-cells.map(cell => cell.text)
  )

  block(breakable: false, {
    bg-grid

    _render-path(
      parsed-path,
      path-stroke,
      label-col-width,
      label-row-height,
      cell-size,
    )

    place(top + left, dx: 0pt, dy: 0pt, text-grid)

    _render-arrows(
      arrows,
      expected-rows,
      expected-cols,
      arrow-stroke,
      cell-size,
      label-col-width,
      label-row-height,
      path-edge-set,
      path-arrow-stroke,
      arrow-length-scale,
    )
  })
}
