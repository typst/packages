// Shared private coordinate and path validation helpers for alignment modules.

/// Parses coordinates from array format.
///
/// - coord (array): Coordinate as `(row, col)`.
/// -> dictionary
#let _parse-coord(coord) = {
  (row: coord.at(0), col: coord.at(1))
}

/// Parses and validates coordinate format, type, and bounds.
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
  // `assert`'s message is evaluated eagerly, so every check here builds its
  // message only once it has already failed; this runs per path coordinate.
  if type(coord) != array {
    assert(false, message: coord-context + " must be a coordinate array.")
  }

  if allow-extra-array-items {
    if coord.len() < 2 {
      assert(
        false,
        message: coord-context + " array must contain at least row and col.",
      )
    }
  } else if coord.len() != 2 {
    assert(
      false,
      message: coord-context + " array must contain exactly row and col.",
    )
  }

  let parsed = _parse-coord(coord)
  if type(parsed.row) != int {
    assert(false, message: coord-context + " row must be an integer.")
  }
  if type(parsed.col) != int {
    assert(false, message: coord-context + " col must be an integer.")
  }
  if parsed.row < 0 or parsed.row > max-row {
    assert(
      false,
      message: coord-context
        + " row "
        + str(parsed.row)
        + " out of bounds [0, "
        + str(max-row)
        + "].",
    )
  }
  if parsed.col < 0 or parsed.col > max-col {
    assert(
      false,
      message: coord-context
        + " col "
        + str(parsed.col)
        + " out of bounds [0, "
        + str(max-col)
        + "].",
    )
  }

  parsed
}

/// Validates that a start-to-end path is valid for the given grid bounds.
///
/// Checks that coordinates are within bounds and that the path is monotonic in
/// start-to-end order (only moves down, right, or diagonally down-right with
/// unit steps). Public traceback inputs that arrive in end-to-start order must
/// be reversed before calling this helper.
///
/// - path (array): Path coordinates as `(row, col)` arrays in start-to-end order.
/// - max-row (int): Maximum allowed row index.
/// - max-col (int): Maximum allowed column index.
/// -> array: The parsed coordinates, in the same order as `path`.
#let _validate-path(path, max-row, max-col) = {
  assert(type(path) == array, message: "path must be an array.")
  assert(path.len() >= 1, message: "Path must contain at least one coordinate.")

  let parsed-path = ()
  let prev-coord = none
  for (idx, coord) in path.enumerate() {
    let parsed = _parse-and-validate-coord(
      coord,
      max-row,
      max-col,
      "Path coordinate at index " + str(idx),
    )

    // Validate monotonicity (path can only move down, right, or diagonal
    // down-right). Messages are built only once a step has already failed.
    if prev-coord != none {
      let row-delta = parsed.row - prev-coord.row
      let col-delta = parsed.col - prev-coord.col
      let step = if (
        row-delta >= 0
          and col-delta >= 0
          and row-delta <= 1
          and col-delta <= 1
          and row-delta + col-delta > 0
      ) {
        none
      } else {
        (
          "("
            + str(prev-coord.row)
            + ", "
            + str(prev-coord.col)
            + ") to ("
            + str(parsed.row)
            + ", "
            + str(parsed.col)
            + ")"
        )
      }

      if step != none {
        if row-delta < 0 or col-delta < 0 {
          assert(
            false,
            message: "Path must be monotonic: step from "
              + step
              + " is invalid. Renderer inputs expect traceback paths in end-to-start order (as returned by align-seq-pair).",
          )
        }
        if row-delta > 1 or col-delta > 1 {
          assert(
            false,
            message: "Path steps must be unit steps: step from "
              + step
              + " is too large.",
          )
        }
        assert(
          false,
          message: "Path cannot have duplicate consecutive coordinates at ("
            + str(parsed.row)
            + ", "
            + str(parsed.col)
            + ").",
        )
      }
    }

    parsed-path.push(parsed)
    prev-coord = parsed
  }

  parsed-path
}
