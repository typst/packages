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

// Module-level O(1) file-letter index (avoids the `.position` scan that
// `parse-square` does). Internal use only.
#let _file-index = (a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9, k: 10, l: 11, m: 12, n: 13, o: 14, p: 15, q: 16, r: 17, s: 18, t: 19, u: 20, v: 21, w: 22, x: 23, y: 24, z: 25)

// Fast (col, row) for a TRUSTED, well-formed square name -- no validation, no
// regex. For internal call sites whose square names are guaranteed well-formed
// (produced by `square-name` / the position layer), not user input. Callers
// handling user-supplied square strings must keep using `parse-square`, which
// validates and gives proper error messages.
#let _square-index(square, cols: 8, rows: 8) = {
  let s = lower(square)
  (col: _file-index.at(s.first()), row: int(s.slice(1)) - 1)
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

// ---------------------------------------------------------------------------
// Move locator <-> ply conversion.
//
// A mainline locator is "12w" / "12b" (move number + side), and its numbers are
// the game's OWN PGN numbering -- which need not start at move 1, White to
// move: a `[FEN]` start can begin at any move number, on either side (see
// `game-start`'s `fullmove`/`turn`). So every conversion here takes an optional
// `start` (a `(fullmove: <int>, turn: "w"|"b")` dict, as `game-start` returns)
// and is expressed relative to it; the default is a standard game (move 1,
// White to move), for which this is exactly the old move-1-relative
// arithmetic -- after White's move m -> ply 2m-1; after Black's -> ply 2m.
// This is the ONE place this arithmetic lives; game.typ, notation.typ and
// lib.typ all import it rather than re-deriving it.
// ---------------------------------------------------------------------------

#let _default-start = (fullmove: 1, turn: "w")

// A locator's ply on the ABSOLUTE PGN-numbering scale (as if the game began at
// move 1, White to move) -- "30w" -> 59 ; "30b" -> 60. Not offset by a game's
// actual start; only `_start-ply` and the wrappers below use this directly.
#let _raw-ply-of-locator(loc) = {
  assert(type(loc) == str and loc.len() >= 2, message: "bad move locator: " + repr(loc))
  let color = loc.slice(loc.len() - 1)
  let num = int(loc.slice(0, loc.len() - 1))
  if color == "w" { 2 * num - 1 }
  else if color == "b" { 2 * num }
  else { panic("move locator must end in 'w' or 'b': " + loc) }
}

// The absolute-scale ply of a game's very first recorded move, given its
// `start` -- e.g. a FEN starting "b ... 12" (Black to move, move 12) has its
// first move at raw ply 24.
#let _start-ply(start) = _raw-ply-of-locator(str(start.fullmove) + start.turn)

// A PGN-numbered locator ("30w"/"30b", using the game's OWN numbering) -> the
// LOCAL 1-based ply -- i.e. position within the game's own recorded move list,
// matching `movetext(game)`'s indices (ply 1 = the first recorded move). For
// the default `start` this is the same value as the old move-1-relative
// arithmetic.
#let _ply-of-locator(loc, start: _default-start) = _raw-ply-of-locator(loc) - _start-ply(start) + 1

// Locator -> 0-based ply index (index = ply - 1).
#let _index-of-locator(loc, start: _default-start) = _ply-of-locator(loc, start: start) - 1

// Inverse of `_index-of-locator`: 0-based ply index -> "12w"/"12b" (in the
// game's own PGN numbering).
#let _locator-of-index(i, start: _default-start) = {
  let ply = i + 1
  let raw = ply + _start-ply(start) - 1
  str(int((raw + 1) / 2)) + (if calc.odd(raw) { "w" } else { "b" })
}

// Local 1-based ply -> raw (absolute-scale) ply, given `start`.
#let _raw-ply-of-local(ply, start: _default-start) = ply + _start-ply(start) - 1

// Local 1-based ply -> the move number printed in notation ("24." / "24...").
#let _movenum-of-ply(ply, start: _default-start) = int((_raw-ply-of-local(ply, start: start) + 1) / 2)

// Whether a local 1-based ply is White's (for notation's number-vs-dots choice
// and the color-aware figurine glyph) -- ply 1 is White's only when the game
// itself starts on White's move.
#let _ply-is-white(ply, start: _default-start) = calc.odd(_raw-ply-of-local(ply, start: start))
