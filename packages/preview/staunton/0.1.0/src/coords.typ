// ===========================================================================
// Coordinate system & square addressing.
//
// We use algebraic square names ("a1" .. "h8", and beyond for larger boards) .
// Internally a square is a pair of zero-based integer indices:
//
//   col : file a..  ->  0..   (a = 0, b = 1, ...),  increases left -> right
//   row : rank 1..  ->  0..   (rank 1 = 0),         increases bottom -> top
//
// The board geometry (number of files `cols` and ranks `rows`) is NOT fixed at
// 8x8: it is passed in, so the same addressing serves standard chess (8x8),
// Xiangqi (9x10), and other rectangular layouts. Files extend a..z (up to 26);
// ranks may be multi-digit (e.g. "a10"). Standard chess is the default geometry.
//
// IMPORTANT off-by-one zone: Typst's drawing origin is the TOP-left and the
// y-axis points DOWN, while chess rank 1 is at the BOTTOM. The screen flip is
// therefore  dy = (rows - 1 - row) * square_size  and lives ONLY in the
// renderer. This module always speaks in chess-native (col, row).
// ===========================================================================

// The file alphabet (a..z); `file-letter(col)` indexes into it. Up to 26 files
// covers every board geometry we care about.
#let _file-alphabet = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z")

/// The standard 8×8 file letters `("a", …, "h")` — kept for the (8×8) renderer
/// and callers that want the classic set.
#let file-letters = ("a", "b", "c", "d", "e", "f", "g", "h")
#let rank-digits = ("1", "2", "3", "4", "5", "6", "7", "8")

/// The file letter for a zero-based column index (`0` → `"a"`, `25` → `"z"`).
///
/// - col (int): the column index (0–25).
/// -> str
#let file-letter(col) = {
  assert(0 <= col and col < _file-alphabet.len(), message: "col out of range 0.." + str(_file-alphabet.len() - 1) + ": " + repr(col))
  _file-alphabet.at(col)
}

/// Parse an algebraic square name into zero-based indices, bounds-checked against
/// the board geometry. One leading file letter (a–z) plus a 1+ digit rank;
/// capitalisation does not matter (`"E4"` = `"e4"`). Returns `(col, row)`.
///
/// - square (str): the square name, e.g. `"e4"`.
/// - cols (int): board width (default `8`).
/// - rows (int): board height (default `8`).
/// -> dictionary
#let parse-square(square, cols: 8, rows: 8) = {
  assert(type(square) == str, message: "square must be a string like \"e4\", got: " + repr(square))
  let s = lower(square).trim()
  let m = s.match(regex("^([a-z])([0-9]+)$"))
  assert(m != none, message: "invalid square name \"" + square + "\" (expected a file letter then a rank number, e.g. \"e4\")")
  let col = _file-alphabet.position(c => c == m.captures.at(0))
  let row = int(m.captures.at(1)) - 1
  assert(col != none and col < cols, message: "file out of range in \"" + square + "\" (board has " + str(cols) + " files)")
  assert(0 <= row and row < rows, message: "rank out of range in \"" + square + "\" (board has " + str(rows) + " ranks)")
  (col: col, row: row)
}

/// Inverse of `parse-square`: `(col, row)` → `"e4"`. Geometry-agnostic (the
/// indices already encode the position); validates only against the 26-file
/// alphabet.
///
/// - col (int): zero-based column index.
/// - row (int): zero-based row index.
/// -> str
#let square-name(col, row) = {
  assert(0 <= row, message: "row must be >= 0: " + repr(row))
  file-letter(col) + str(row + 1)
}

/// Is the square dark? `a1` = `(0, 0)` is a dark square in standard orientation.
///
/// - col (int): zero-based column index.
/// - row (int): zero-based row index.
/// -> bool
#let is-dark-square(col, row) = calc.even(col + row)
