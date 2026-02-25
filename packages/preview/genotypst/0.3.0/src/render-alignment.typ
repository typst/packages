#import "constants.typ": _dark-gray, _medium-gray, _yellow
#import "utils.typ": _flat-to-2d, resolve-matrix-name
#import "@preview/tiptoe:0.4.0": (
  line as _tiptoe-line, straight as _tiptoe-straight,
)

#let _alignment-plugin = plugin("alignment.wasm")

/// Private: Validates and cleans a sequence string.
///
/// Removes all whitespace characters (spaces, tabs, newlines) and converts to uppercase.
/// This allows users to input sequences with whitespace for readability.
///
/// - seq (str): The sequence to validate.
/// - name (str): Name for error messages (e.g., "seq-1").
/// -> str
#let _validate-sequence(seq, name) = {
  assert(type(seq) == str, message: name + " must be a string.")
  let cleaned = upper(seq.replace(regex("\\s"), ""))
  assert(cleaned.len() > 0, message: name + " must not be empty.")
  cleaned
}

/// Private: Validates scoring parameters and returns canonical matrix name if applicable.
///
/// - matrix (str, none): Scoring matrix name.
/// - match-score (int, none): Match score.
/// - mismatch-score (int, none): Mismatch score.
/// -> str, none (canonical matrix name if using matrix)
#let _validate-scoring-params(matrix, match-score, mismatch-score) = {
  // Mutual exclusivity
  assert(
    not (matrix != none and (match-score != none or mismatch-score != none)),
    message: "Cannot use both 'matrix' and 'match-score'/'mismatch-score' - they are mutually exclusive.",
  )

  // At least one scoring method
  assert(
    matrix != none or (match-score != none and mismatch-score != none),
    message: "Provide either 'matrix' or both 'match-score' and 'mismatch-score'.",
  )

  // Matrix name resolution (case-insensitive)
  if matrix != none {
    let canonical = resolve-matrix-name(matrix)
    assert(
      canonical != none,
      message: "Unknown scoring matrix: '" + matrix + "'.",
    )
    canonical
  }
}

/// Private: Validates the gap penalty parameter.
///
/// - gap-penalty (int, none): The gap penalty value.
/// -> none
#let _validate-gap-penalty(gap-penalty) = {
  assert(gap-penalty != none, message: "gap-penalty is required.")
  assert(type(gap-penalty) == int, message: "gap-penalty must be an integer.")
  assert(
    gap-penalty <= 0,
    message: "gap-penalty must be non-positive, got " + str(gap-penalty) + ".",
  )
}

/// Private: Validates the alignment mode parameter.
///
/// - mode (str): The alignment mode.
/// -> none
#let _validate-mode(mode) = {
  assert(
    mode in ("global", "local"),
    message: "mode must be 'global' or 'local'.",
  )
}

/// Private: Builds the JSON configuration dictionary for WASM.
///
/// - canonical-matrix (str, none): Canonical matrix name.
/// - match-score (int, none): Match score.
/// - mismatch-score (int, none): Mismatch score.
/// - gap-penalty (int): Gap penalty.
/// - mode (str): Alignment mode.
/// -> dictionary
#let _build-config(
  canonical-matrix,
  match-score,
  mismatch-score,
  gap-penalty,
  mode,
) = {
  let config = (
    gap_open: gap-penalty,
    gap_extend: gap-penalty,
    mode: mode,
  )

  if canonical-matrix != none {
    config.insert("matrix", canonical-matrix)
  } else {
    config.insert("match_score", match-score)
    config.insert("mismatch_score", mismatch-score)
  }

  config
}

/// Private: Calls the alignment WASM plugin and parses the response.
///
/// - seq-1 (str): First sequence.
/// - seq-2 (str): Second sequence.
/// - config (dictionary): Configuration dictionary.
/// -> dictionary
#let _call-align-wasm(seq-1, seq-2, config) = {
  let config-json = json.encode(config)
  let result = _alignment-plugin.align(
    bytes(seq-1),
    bytes(seq-2),
    bytes(config-json),
  )
  json(result)
}


/// Private: Converts a bitmask to an array of arrow tuples for a single cell.
///
/// Bitmask encoding: bit 0 (1) = diagonal, bit 1 (2) = up, bit 2 (4) = left.
///
/// - bits (int): Bitmask value.
/// - i (int): Row index.
/// - j (int): Column index.
/// -> array
#let _bitmask-to-arrows(bits, i, j) = {
  let arrows = ()
  // Bit 0 (1) = diagonal
  if calc.rem(calc.quo(bits, 1), 2) == 1 and i > 0 and j > 0 {
    arrows = arrows + (((i, j), (i - 1, j - 1)),)
  }
  // Bit 1 (2) = up
  if calc.rem(calc.quo(bits, 2), 2) == 1 and i > 0 {
    arrows = arrows + (((i, j), (i - 1, j)),)
  }
  // Bit 2 (4) = left
  if calc.rem(calc.quo(bits, 4), 2) == 1 and j > 0 {
    arrows = arrows + (((i, j), (i, j - 1)),)
  }
  arrows
}

/// Private: Converts a flat bitmask array to a 2D array of arrow tuples.
///
/// Each cell contains an array of (from, to) tuples representing arrows.
/// Bitmask encoding: bit 0 (1) = diagonal, bit 1 (2) = up, bit 2 (4) = left.
///
/// - bitmasks (array): Flat array of bitmasks.
/// - rows (int): Number of rows.
/// - cols (int): Number of columns.
/// -> array
#let _bitmasks-to-arrows-2d(bitmasks, rows, cols) = {
  range(rows).map(i => range(cols).map(j => {
    let bits = bitmasks.at(i * cols + j)
    _bitmask-to-arrows(bits, i, j)
  }))
}

/// Private: Transforms the WASM response to the final output format.
///
/// - wasm-result (dictionary): Raw result from WASM plugin.
/// - original-seq-1 (str): Original (cleaned) first sequence.
/// - original-seq-2 (str): Original (cleaned) second sequence.
/// - mode (str): Alignment mode.
/// - canonical-matrix (str, none): Canonical matrix name.
/// - match-score (int, none): Match score.
/// - mismatch-score (int, none): Mismatch score.
/// - gap-penalty (int): Gap penalty.
/// -> dictionary
#let _transform-result(
  wasm-result,
  original-seq-1,
  original-seq-2,
  mode,
  canonical-matrix,
  match-score,
  mismatch-score,
  gap-penalty,
) = {
  let dp = wasm-result.dp_matrix
  let rows = dp.rows
  let cols = dp.cols

  // Convert flat arrays to 2D
  let values-2d = _flat-to-2d(dp.scores, rows, cols)
  let arrows-2d = _bitmasks-to-arrows-2d(dp.arrows, rows, cols)

  // Convert traceback paths
  let traceback-paths = wasm-result.traceback_paths.map(path => path.map(
    coord => (coord.at(0), coord.at(1)),
  ))

  // Determine if there's a valid alignment
  let has-alignment = wasm-result.alignments.len() > 0

  (
    seq-1: original-seq-1,
    seq-2: original-seq-2,
    score: wasm-result.alignment_score,
    mode: mode,
    scoring: (
      matrix: canonical-matrix,
      match-score: match-score,
      mismatch-score: mismatch-score,
      gap-penalty: gap-penalty,
    ),
    alignments: wasm-result.alignments,
    traceback-paths: traceback-paths,
    dp-matrix: (
      rows: rows,
      cols: cols,
      values: values-2d,
      arrows: arrows-2d,
    ),
    has-alignment: has-alignment,
  )
}

/// Performs pairwise sequence alignment using dynamic programming.
///
/// Aligns two sequences using either a scoring matrix (e.g., BLOSUM62) or
/// custom match/mismatch scores. Returns alignment results including the
/// DP matrix, traceback paths, and aligned sequences.
///
/// Sequences are automatically cleaned: whitespace is removed and characters
/// are converted to uppercase. This allows input like "ACG TGC\nAAA".
///
/// Available scoring matrices: BLOSUM30, BLOSUM40, BLOSUM50, BLOSUM62, BLOSUM70,
/// BLOSUM80, BLOSUM90, BLOSUM100, PAM1, PAM10, PAM40, PAM80, PAM120, PAM160,
/// PAM250, EDNAFULL. Matrix names are case-insensitive.
///
/// - seq-1 (str): First sequence to align.
/// - seq-2 (str): Second sequence to align.
/// - matrix (str, none): Scoring matrix name (e.g., "BLOSUM62"). Mutually exclusive with match/mismatch scores (default: none).
/// - match-score (int, none): Score for matching characters. Required if matrix is none (default: none).
/// - mismatch-score (int, none): Score for mismatching characters. Required if matrix is none (default: none).
/// - gap-penalty (int): Gap penalty, must be non-positive.
/// - mode (str): Alignment mode: "global" or "local" (default: "global").
/// -> dictionary
#let align-seq-pair(
  seq-1,
  seq-2,
  matrix: none,
  match-score: none,
  mismatch-score: none,
  gap-penalty: none,
  mode: "global",
) = {
  // Validate and clean inputs
  let cleaned-seq-1 = _validate-sequence(seq-1, "seq-1")
  let cleaned-seq-2 = _validate-sequence(seq-2, "seq-2")
  let canonical-matrix = _validate-scoring-params(
    matrix,
    match-score,
    mismatch-score,
  )
  _validate-gap-penalty(gap-penalty)
  _validate-mode(mode)

  // Build config and call WASM
  let config = _build-config(
    canonical-matrix,
    match-score,
    mismatch-score,
    gap-penalty,
    mode,
  )
  let wasm-result = _call-align-wasm(cleaned-seq-1, cleaned-seq-2, config)

  // Transform and return result
  _transform-result(
    wasm-result,
    cleaned-seq-1,
    cleaned-seq-2,
    mode,
    canonical-matrix,
    match-score,
    mismatch-score,
    gap-penalty,
  )
}

/// Private: Parse coordinates from dictionary or array format.
#let _parse-coord(coord) = {
  if type(coord) == dictionary {
    (row: coord.row, col: coord.col)
  } else {
    (row: coord.at(0), col: coord.at(1))
  }
}

/// Private: Validate that the path is valid for the given sequences.
///
/// Checks that coordinates are within bounds and that the path is monotonic
/// (only moves down, right, or diagonally down-right with unit steps).
///
/// - path (array): Path coordinates as array of (row, col) tuples.
/// - seq1-len (int): Length of the first sequence.
/// - seq2-len (int): Length of the second sequence.
/// -> none
#let _validate-path(path, seq1-len, seq2-len) = {
  assert(path.len() >= 1, message: "Path must contain at least one coordinate.")

  let prev-coord = none
  for (idx, coord) in path.enumerate() {
    let parsed = _parse-coord(coord)

    // Validate bounds (0-indexed, valid range is 0 to seq-len)
    assert(
      parsed.row >= 0 and parsed.row <= seq1-len,
      message: "Row coordinate "
        + str(parsed.row)
        + " out of bounds [0, "
        + str(seq1-len)
        + "].",
    )
    assert(
      parsed.col >= 0 and parsed.col <= seq2-len,
      message: "Column coordinate "
        + str(parsed.col)
        + " out of bounds [0, "
        + str(seq2-len)
        + "].",
    )

    // Validate monotonicity (path can only move down, right, or diagonal down-right)
    if prev-coord != none {
      let row-delta = parsed.row - prev-coord.row
      let col-delta = parsed.col - prev-coord.col

      assert(
        row-delta >= 0 and col-delta >= 0,
        message: "Path must be monotonic: step from ("
          + str(prev-coord.row)
          + ", "
          + str(prev-coord.col)
          + ") to ("
          + str(parsed.row)
          + ", "
          + str(parsed.col)
          + ") is invalid.",
      )
      assert(
        row-delta <= 1 and col-delta <= 1,
        message: "Path steps must be unit steps: step from ("
          + str(prev-coord.row)
          + ", "
          + str(prev-coord.col)
          + ") to ("
          + str(parsed.row)
          + ", "
          + str(parsed.col)
          + ") is too large.",
      )
      assert(
        row-delta + col-delta > 0,
        message: "Path cannot have duplicate consecutive coordinates at ("
          + str(parsed.row)
          + ", "
          + str(parsed.col)
          + ").",
      )
    }

    prev-coord = parsed
  }
}

/// Private: Convert path coordinates to alignment operations.
///
/// - path (array): Path coordinates as array of (row, col) tuples.
/// -> array
#let _path-to-operations(path) = {
  let operations = ()

  for i in range(1, path.len()) {
    let prev = _parse-coord(path.at(i - 1))
    let curr = _parse-coord(path.at(i))

    let row-delta = curr.row - prev.row
    let col-delta = curr.col - prev.col

    if row-delta == 1 and col-delta == 1 {
      // Diagonal: match or mismatch
      operations.push("match-or-mismatch")
    } else if row-delta == 1 and col-delta == 0 {
      // Down: gap in seq2 (seq1 advances, seq2 doesn't)
      operations.push("gap-in-seq2")
    } else if row-delta == 0 and col-delta == 1 {
      // Right: gap in seq1 (seq2 advances, seq1 doesn't)
      operations.push("gap-in-seq1")
    }
  }

  operations
}

/// Private: Build the three alignment strings from sequences and operations.
///
/// - seq1 (str): First sequence.
/// - seq2 (str): Second sequence.
/// - path (array): Path coordinates.
/// - operations (array): Array of operation strings.
/// - gap-char (str): Character for gaps.
/// - match-char (str): Character for matches.
/// - mismatch-char (str): Character for mismatches.
/// - hide-unaligned (bool): Whether to hide unaligned characters entirely.
/// -> dictionary
#let _build-alignment-strings(
  seq1,
  seq2,
  path,
  operations,
  gap-char,
  match-char,
  mismatch-char,
  hide-unaligned,
) = {
  let seq1-chars = seq1.clusters()
  let seq2-chars = seq2.clusters()

  let first-coord = _parse-coord(path.at(0))
  let last-coord = _parse-coord(path.at(path.len() - 1))

  // Initialize result strings and unaligned mask
  let aligned1 = ""
  let match-line = ""
  let aligned2 = ""
  let unaligned-mask = ()

  // Handle leading unaligned region (local alignment starting after position 0)
  // Show unaligned characters if hide-unaligned is false
  if not hide-unaligned {
    // Add seq1 unaligned chars (rows before path starts)
    for i in range(first-coord.row) {
      aligned1 += seq1-chars.at(i)
      match-line += " "
      aligned2 += " "
      unaligned-mask.push(true)
    }

    // Add seq2 unaligned chars (cols before path starts)
    for j in range(first-coord.col) {
      aligned1 += " "
      match-line += " "
      aligned2 += seq2-chars.at(j)
      unaligned-mask.push(true)
    }
  }

  // Track current position in each sequence
  let seq1-pos = first-coord.row
  let seq2-pos = first-coord.col

  // Process each operation
  for op in operations {
    if op == "match-or-mismatch" {
      let char1 = seq1-chars.at(seq1-pos)
      let char2 = seq2-chars.at(seq2-pos)

      aligned1 += char1
      aligned2 += char2
      match-line += if char1 == char2 { match-char } else { mismatch-char }
      unaligned-mask.push(false)

      seq1-pos += 1
      seq2-pos += 1
    } else if op == "gap-in-seq1" {
      aligned1 += gap-char
      aligned2 += seq2-chars.at(seq2-pos)
      match-line += mismatch-char
      unaligned-mask.push(false)

      seq2-pos += 1
    } else if op == "gap-in-seq2" {
      aligned1 += seq1-chars.at(seq1-pos)
      aligned2 += gap-char
      match-line += mismatch-char
      unaligned-mask.push(false)

      seq1-pos += 1
    }
  }

  // Handle trailing unaligned region
  // Show unaligned characters if hide-unaligned is false
  if not hide-unaligned {
    // Add remaining seq1 characters
    while seq1-pos < seq1-chars.len() {
      aligned1 += seq1-chars.at(seq1-pos)
      match-line += " "
      aligned2 += " "
      unaligned-mask.push(true)
      seq1-pos += 1
    }

    // Add remaining seq2 characters
    while seq2-pos < seq2-chars.len() {
      aligned1 += " "
      match-line += " "
      aligned2 += seq2-chars.at(seq2-pos)
      unaligned-mask.push(true)
      seq2-pos += 1
    }
  }

  (
    aligned1: aligned1,
    match-line: match-line,
    aligned2: aligned2,
    unaligned-mask: unaligned-mask,
  )
}

/// Private: Calculate cell center coordinates.
#let _cell-center(row, col, label-col-width, label-row-height, cell-size) = {
  let x = label-col-width + col * cell-size + cell-size * 0.5
  let y = label-row-height + row * cell-size + cell-size * 0.5
  (x: x, y: y)
}

/// Private: Create a label cell (for header row and left column).
#let _label-cell(content) = grid.cell(stroke: none, inset: 0pt)[
  #if content != none { align(center + horizon)[#content] }
]

/// Private: Determine radius for a cell based on its position.
#let _get-cell-radius(row-idx, col-idx, last-row, last-col, corner-radius) = {
  let is-top = row-idx == 0
  let is-bottom = row-idx == last-row
  let is-left = col-idx == 0
  let is-right = col-idx == last-col

  if is-top and is-left {
    (top-left: corner-radius, rest: 0pt)
  } else if is-top and is-right {
    (top-right: corner-radius, rest: 0pt)
  } else if is-bottom and is-left {
    (bottom-left: corner-radius, rest: 0pt)
  } else if is-bottom and is-right {
    (bottom-right: corner-radius, rest: 0pt)
  } else {
    0pt
  }
}

/// Private: Build grid content arrays for background and text layers.
#let _build-grid-content(
  top-clusters,
  left-clusters,
  values,
  highlights,
  highlight-color,
  path,
  path-cell-bold,
  stroke-width,
  stroke-color,
  cell-inset,
  corner-radius,
) = {
  let bg-grid-content = ()
  let text-grid-content = ()

  // Helper to get highlight color for a cell
  let get-highlight-color(row, col) = {
    for h in highlights {
      let h-coord = _parse-coord(h)

      if h-coord.row == row and h-coord.col == col {
        if type(h) == dictionary {
          return if "color" in h { h.color } else { highlight-color }
        } else {
          return if h.len() > 2 { h.at(2) } else { highlight-color }
        }
      }
    }
    return none
  }

  // Helper to check if a cell should be bold (on the path)
  let is-bold-cell(row, col) = {
    if not path-cell-bold or path == none {
      return false
    }
    for p in path {
      let p-coord = _parse-coord(p)
      if p-coord.row == row and p-coord.col == col {
        return true
      }
    }
    return false
  }

  // Header row: empty top-left corner, then top sequence characters
  bg-grid-content = bg-grid-content + (_label-cell(none),)
  text-grid-content = text-grid-content + (_label-cell(none),)

  for char in top-clusters {
    bg-grid-content = bg-grid-content + (_label-cell(none),)
    text-grid-content = text-grid-content + (_label-cell(char),)
  }

  // Calculate last row and column indices
  let last-row = left-clusters.len() - 1
  let last-col = top-clusters.len() - 1

  // Data rows: left label, then values
  for (row-idx, row-label) in left-clusters.enumerate() {
    bg-grid-content = bg-grid-content + (_label-cell(none),)
    text-grid-content = text-grid-content + (_label-cell(row-label),)

    for (col-idx, value) in values.at(row-idx).enumerate() {
      let cell-content = if value == none {
        []
      } else {
        let content = if is-bold-cell(row-idx, col-idx) {
          strong[#value]
        } else {
          value
        }
        align(center + horizon)[#content]
      }

      let fill-color = get-highlight-color(row-idx, col-idx)
      let cell-radius = _get-cell-radius(
        row-idx,
        col-idx,
        last-row,
        last-col,
        corner-radius,
      )

      // Background layer: boxes with rounded corners and fills
      bg-grid-content = (
        bg-grid-content
          + (
            box(
              width: 100%,
              height: 100%,
              fill: fill-color,
              stroke: stroke-width + stroke-color,
              radius: cell-radius,
              inset: cell-inset,
            )[],
          )
      )

      // Text layer: only text, no fills
      text-grid-content = (
        text-grid-content
          + (
            box(
              width: 100%,
              height: 100%,
              inset: cell-inset,
            )[#cell-content],
          )
      )
    }
  }

  (bg: bg-grid-content, text: text-grid-content)
}

/// Private: Render path overlay.
#let _render-path(
  path,
  path-color,
  path-width,
  label-col-width,
  label-row-height,
  cell-size,
) = {
  if path == none or path.len() <= 1 {
    return
  }

  // Calculate path coordinates
  let path-coords = path.map(pt => {
    let coord = _parse-coord(pt)
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
    // Build curve: start at first point, then add lines to remaining points
    let curve-components = (curve.move(path-coords.at(0)),)
    for i in range(1, path-coords.len()) {
      curve-components = curve-components + (curve.line(path-coords.at(i)),)
    }

    curve(
      stroke: (
        paint: path-color,
        thickness: path-width,
        cap: "round",
        join: "round",
      ),
      ..curve-components,
    )
  })
}

/// Private: Check if an arrow is part of the traceback path.
#let _is-arrow-on-path(arrow-from, arrow-to, path) = {
  if path == none or path.len() < 2 {
    return false
  }
  // Path is ordered from end to start, so consecutive pairs are (from, to)
  for i in range(path.len() - 1) {
    let path-from = path.at(i)
    let path-to = path.at(i + 1)
    if (
      arrow-from.at(0) == path-from.at(0)
        and arrow-from.at(1) == path-from.at(1)
        and arrow-to.at(0) == path-to.at(0)
        and arrow-to.at(1) == path-to.at(1)
    ) {
      return true
    }
  }
  false
}

/// Private: Calculate arrow start and end positions based on direction.
#let _calculate-arrow-positions(
  from-coord,
  to-coord,
  center-x,
  center-y,
  arrow-half-length,
) = {
  if from-coord.row == to-coord.row {
    // Horizontal arrow (left)
    (
      center-x + arrow-half-length,
      center-y,
      center-x - arrow-half-length,
      center-y,
    )
  } else if from-coord.col == to-coord.col {
    // Vertical arrow (up)
    (
      center-x,
      center-y + arrow-half-length,
      center-x,
      center-y - arrow-half-length,
    )
  } else {
    // Diagonal arrow
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

/// Private: Render all arrows.
#let _render-arrows(
  arrows,
  arrow-color,
  cell-size,
  label-col-width,
  label-row-height,
  path,
  highlight-path-arrows,
  path-arrow-color,
) = {
  for (row-idx, row) in arrows.enumerate() {
    for (col-idx, cell-arrows) in row.enumerate() {
      for arrow in cell-arrows {
        let from-coord = (row: arrow.at(0).at(0), col: arrow.at(0).at(1))
        let to-coord = (row: arrow.at(1).at(0), col: arrow.at(1).at(1))

        // Determine arrow color
        let arr-color = arrow-color
        if (
          highlight-path-arrows
            and _is-arrow-on-path(arrow.at(0), arrow.at(1), path)
        ) {
          arr-color = path-arrow-color
        }

        // Calculate boundary position between the two cells
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

        let center-x = (from-center.x + to-center.x) / 2.0
        let center-y = (from-center.y + to-center.y) / 2.0
        let arrow-half-length = cell-size * 0.215

        let (start-x, start-y, end-x, end-y) = _calculate-arrow-positions(
          from-coord,
          to-coord,
          center-x,
          center-y,
          arrow-half-length,
        )

        // Draw arrow using tiptoe
        place(top + left, dx: 0pt, dy: 0pt, {
          _tiptoe-line(
            start: (start-x, start-y),
            end: (end-x, end-y),
            stroke: (
              paint: arr-color,
              thickness: 1pt,
              cap: "round",
            ),
            tip: _tiptoe-straight.with(width: 550%, length: 375%),
          )
        })
      }
    }
  }
}

/// Renders a dynamic programming matrix for sequence alignment visualization.
///
/// Creates a visual representation of a dynamic programming (DP) matrix with
/// optional cell highlighting, traceback path overlay, and arrow indicators for
/// alignment directions.
///
/// - seq-1 (str): Sequence displayed on the left as row labels.
/// - seq-2 (str): Sequence displayed on top as column labels.
/// - values (array): 2D array of matrix values (integers or none for empty cells).
/// - highlights (array): Cell highlights as (row, col) or (row, col, color) tuples (default: ()).
/// - highlight-color (color): Default color for highlighted cells (default: light gray).
/// - path (array, none): Traceback path as array of (row, col) tuples (default: none).
/// - path-color (color): Color for the path line (default: semi-transparent yellow).
/// - path-width (length): Width of the path line (default: 18pt).
/// - path-cell-bold (bool): Whether scores in cells on the path are rendered in bold (default: true).
/// - arrows (array): 2D matrix of arrows from alignment result. Each cell contains an array of arrow tuples ((from_row, from_col), (to_row, to_col)) (default: ()).
/// - arrow-color (color): Default color for arrows (default: medium gray).
/// - highlight-path-arrows (bool): Whether arrows on the path use a different color (default: true).
/// - path-arrow-color (color): Color for arrows on the traceback path (default: dark gray).
/// - cell-size (length): Size of each square cell (default: 34pt).
/// - stroke-width (length): Width of cell borders (default: 0.6pt).
/// - stroke-color (color): Color of cell borders (default: medium gray).
/// -> content
#let render-dp-matrix(
  seq-1,
  seq-2,
  values,
  highlights: (),
  highlight-color: _medium-gray.lighten(75%),
  path: none,
  path-color: _yellow.transparentize(50%),
  path-width: 18pt,
  path-cell-bold: true,
  arrows: (),
  arrow-color: _medium-gray,
  highlight-path-arrows: true,
  path-arrow-color: _dark-gray,
  cell-size: 34pt,
  stroke-width: 0.6pt,
  stroke-color: _medium-gray,
) = {
  // Cache cluster arrays to avoid repeated calls
  let seq1-raw-clusters = seq-1.clusters()
  let seq2-raw-clusters = seq-2.clusters()

  assert(values.len() > 0, message: "values must contain at least one row.")
  let value-cols = values.at(0).len()
  assert(
    values.len() == seq1-raw-clusters.len() + 1,
    message: "Matrix values must have "
      + str(seq1-raw-clusters.len() + 1)
      + " rows (seq-1 length + 1). Got "
      + str(values.len())
      + ".",
  )
  assert(
    value-cols == seq2-raw-clusters.len() + 1,
    message: "Matrix values must have "
      + str(seq2-raw-clusters.len() + 1)
      + " columns (seq-2 length + 1). Got "
      + str(value-cols)
      + ".",
  )

  let top-label-seq = "-" + seq-2
  let left-label-seq = "-" + seq-1

  let top-clusters = top-label-seq.clusters()
  let left-clusters = left-label-seq.clusters()

  // Validate inputs
  assert(
    values.len() == left-clusters.len(),
    message: "Number of matrix rows must match seq-1 label length.",
  )
  assert(
    values.all(row => row.len() == top-clusters.len()),
    message: "Number of matrix columns must match seq-2 label length.",
  )

  // Validate path if provided (path from align-seq-pair is end-to-start, so reverse for validation)
  if path != none {
    _validate-path(path.rev(), left-clusters.len() - 1, top-clusters.len() - 1)
  }

  // Constants for dimensions
  let label-scale = 0.65 // Label cells are 65% of data cell size
  let cell-inset = 5pt // Standard inset for data cells
  let corner-radius = 3pt // Radius for corner cells

  // Label dimensions (smaller than data cells)
  let label-col-width = cell-size * label-scale
  let label-row-height = cell-size * label-scale

  // Build grid content arrays
  let grid-content = _build-grid-content(
    top-clusters,
    left-clusters,
    values,
    highlights,
    highlight-color,
    path,
    path-cell-bold,
    stroke-width,
    stroke-color,
    cell-inset,
    corner-radius,
  )

  // Define column widths: first column is narrower for labels
  let column-widths = (label-col-width,) + ((cell-size,) * top-clusters.len())

  // Define row heights: first row is shorter for labels
  let row-heights = (label-row-height,) + ((cell-size,) * left-clusters.len())

  // Create background grid (only fills and borders)
  let bg-grid = grid(
    columns: column-widths,
    rows: row-heights,
    stroke: none,
    inset: 0pt,
    ..grid-content.bg
  )

  // Create text grid (only text, transparent)
  let text-grid = grid(
    columns: column-widths,
    rows: row-heights,
    stroke: none,
    inset: 0pt,
    ..grid-content.text
  )

  // If no overlays needed, combine both grids
  if path == none and arrows.len() == 0 {
    return block(breakable: false, {
      bg-grid
      place(top + left, dx: 0pt, dy: 0pt, text-grid)
    })
  }

  // Create container with overlays
  block(breakable: false, {
    // Layer 1: Background grid (borders and fills) - takes up space
    bg-grid

    // Layer 2: Path overlay (above backgrounds, below text)
    _render-path(
      path,
      path-color,
      path-width,
      label-col-width,
      label-row-height,
      cell-size,
    )

    // Layer 3: Text grid overlay (above path)
    place(top + left, dx: 0pt, dy: 0pt, text-grid)

    // Layer 4: Arrows overlay (on top of everything)
    _render-arrows(
      arrows,
      arrow-color,
      cell-size,
      label-col-width,
      label-row-height,
      path,
      highlight-path-arrows,
      path-arrow-color,
    )
  })
}

/// Renders a formatted pairwise sequence alignment from alignment result data.
///
/// Creates a three-line display showing the first aligned sequence (with gaps),
/// match/mismatch indicators, and the second aligned sequence (with gaps).
/// The traceback path from `align-seq-pair` goes from end to start (high indices
/// to low), so it is automatically reversed before processing.
///
/// - seq-1 (str): First sequence (without gaps).
/// - seq-2 (str): Second sequence (without gaps).
/// - path (array): Traceback path as array of (row, col) tuples.
/// - gap-char (str): Character to display for gaps (default: "–").
/// - match-char (str): Character to display for matches (default: "│").
/// - mismatch-char (str): Character to display for mismatches (default: " ").
/// - hide-unaligned (bool): Hide unaligned characters entirely (default: false).
/// - unaligned-color (color, none): Color for unaligned characters (default: none, which uses the default text color).
/// -> content
#let render-pair-alignment(
  seq-1,
  seq-2,
  path,
  gap-char: "–",
  match-char: "│",
  mismatch-char: " ",
  hide-unaligned: false,
  unaligned-color: none,
) = {
  // Parse sequences
  let seq1-chars = seq-1.clusters()
  let seq2-chars = seq-2.clusters()

  // Validate inputs
  assert(type(seq-1) == str, message: "seq-1 must be a string.")
  assert(type(seq-2) == str, message: "seq-2 must be a string.")
  assert(seq1-chars.len() > 0, message: "seq-1 cannot be empty.")
  assert(seq2-chars.len() > 0, message: "seq-2 cannot be empty.")
  assert(type(path) == array, message: "path must be an array.")
  assert(path.len() > 0, message: "path cannot be empty.")

  // Reverse the path (traceback goes end-to-start, we need start-to-end)
  let reversed-path = path.rev()

  // Validate path
  _validate-path(reversed-path, seq1-chars.len(), seq2-chars.len())

  // Convert path to operations
  let operations = _path-to-operations(reversed-path)

  // Build alignment strings
  let result = _build-alignment-strings(
    seq-1,
    seq-2,
    reversed-path,
    operations,
    gap-char,
    match-char,
    mismatch-char,
    hide-unaligned,
  )

  // Render with regular font in fixed-width grid cells
  // Use context to get current text size
  context {
    // Calculate cell width based on current font size
    let char-width = measure(text("M")).width

    // Build grid content for each line, applying unaligned color if specified
    let unaligned-mask = result.unaligned-mask
    let mask-length = unaligned-mask.len()
    let has-unaligned-color = unaligned-color != none

    let make-line-cells(chars, apply-unaligned) = {
      chars
        .enumerate()
        .map(item => {
          let (i, char) = item
          let should-color = (
            apply-unaligned
              and has-unaligned-color
              and i < mask-length
              and unaligned-mask.at(i)
          )
          let content = if should-color {
            text(fill: unaligned-color)[#char]
          } else {
            char
          }
          align(center + horizon)[#content]
        })
    }

    let line1-cells = make-line-cells(result.aligned1.clusters(), true)
    let line2-cells = make-line-cells(result.match-line.clusters(), false)
    let line3-cells = make-line-cells(result.aligned2.clusters(), true)

    block(breakable: false, grid(
      columns: line1-cells.len() * (char-width,),
      rows: (text.size * 0.85, text.size * 1.5, text.size * 0.85),
      ..line1-cells,
      ..line2-cells,
      ..line3-cells,
    ))
  }
}
