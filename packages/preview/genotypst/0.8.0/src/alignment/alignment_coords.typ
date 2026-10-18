// Shared private coordinate and path validation helpers for alignment modules.

/// Private: Parse coordinates from array format.
///
/// - coord (array): Coordinate as `(row, col)`.
/// -> dictionary
#let _parse-coord(coord) = {
  (row: coord.at(0), col: coord.at(1))
}

/// Private: Parse and validate coordinate format, type, and bounds.
///
/// - coord (array): Coordinate array.
/// - max-row (int): Maximum allowed row index.
/// - max-col (int): Maximum allowed column index.
/// - coord-context (str): Context label for error messages.
/// - allow-extra-array-items (bool): Whether trailing items are allowed.
/// -> dictionary
#let _parse-and-validate-coord(
  coord,
  max-row,
  max-col,
  coord-context,
  allow-extra-array-items: false,
) = {
  assert(
    type(coord) == array,
    message: coord-context + " must be a coordinate array.",
  )

  if allow-extra-array-items {
    assert(
      coord.len() >= 2,
      message: coord-context + " array must contain at least row and col.",
    )
  } else {
    assert(
      coord.len() == 2,
      message: coord-context + " array must contain exactly row and col.",
    )
  }

  let parsed = _parse-coord(coord)
  assert(
    type(parsed.row) == int,
    message: coord-context + " row must be an integer.",
  )
  assert(
    type(parsed.col) == int,
    message: coord-context + " col must be an integer.",
  )
  assert(
    parsed.row >= 0 and parsed.row <= max-row,
    message: coord-context
      + " row "
      + str(parsed.row)
      + " out of bounds [0, "
      + str(max-row)
      + "].",
  )
  assert(
    parsed.col >= 0 and parsed.col <= max-col,
    message: coord-context
      + " col "
      + str(parsed.col)
      + " out of bounds [0, "
      + str(max-col)
      + "].",
  )

  parsed
}

/// Private: Validate that the path is valid for the given grid bounds.
///
/// Checks that coordinates are within bounds and that the path is monotonic
/// (only moves down, right, or diagonally down-right with unit steps).
///
/// - path (array): Path coordinates as `(row, col)` arrays.
/// - max-row (int): Maximum allowed row index.
/// - max-col (int): Maximum allowed column index.
/// -> none
#let _validate-path(path, max-row, max-col) = {
  assert(type(path) == array, message: "path must be an array.")
  assert(path.len() >= 1, message: "Path must contain at least one coordinate.")

  let prev-coord = none
  for (idx, coord) in path.enumerate() {
    let parsed = _parse-and-validate-coord(
      coord,
      max-row,
      max-col,
      "Path coordinate at index " + str(idx),
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
          + ") is invalid. Renderer inputs expect traceback paths in end-to-start order (as returned by align-seq-pair).",
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
