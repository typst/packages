// ===========================================================================
// Forsyth-Edwards Notation (FEN) parsing.
//
// A FEN string has up to six space-separated fields:
//   1. piece placement   (mandatory) - 8 ranks "/"-separated, rank 8 FIRST,
//                                       each rank file a->h; digits = empties.
//   2. side to move       w | b           (default w)
//   3. castling rights    KQkq | subset | -   (default -)
//   4. en passant target  e3 | -             (default none)
//   5. halfmove clock     int               (default 0)
//   6. fullmove number    int               (default 1)
//
// We are strict about the mandatory placement field (clear errors beat silent
// wrong diagrams in a publishing workflow) but lenient about trailing fields:
// a placement-only or 4-field FEN is accepted with sensible defaults.
//
// Output: a `position` dict consumed by the renderer (only `board` is needed
// for drawing; the rest is carried for later move-generation / display).
// ===========================================================================

#import "coords.typ": square-name
#import "pieces.typ": fen-piece, kind-letters

/// Parse a FEN string into a `position` dict — the inverse of `to-fen`. The
/// result carries the board (square name → `(kind, color)`) plus the side to
/// move, castling rights, en-passant target, and the halfmove / fullmove clocks.
///
/// - fen (str): a FEN record, e.g.
///   `"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"`.
/// -> dictionary
#let parse-fen(fen) = {
  assert(type(fen) == str, message: "FEN must be a string, got: " + repr(fen))
  let parts = fen.trim().split(regex("\s+")).filter(p => p != "")
  assert(parts.len() >= 1, message: "empty FEN string")

  // ---- field 1: piece placement -----------------------------------------
  let ranks = parts.at(0).split("/")
  assert(
    ranks.len() == 8,
    message: "FEN placement must have 8 ranks separated by '/', got " + str(ranks.len()) + ": " + parts.at(0),
  )

  let board = (:)
  for (i, rank-str) in ranks.enumerate() {
    let rank-num = 8 - i        // i = 0 is rank 8 (FEN lists top rank first)
    let row = rank-num - 1
    let col = 0
    for ch in rank-str.clusters() {
      if ch.match(regex("^[1-8]$")) != none {
        col += int(ch)
      } else {
        assert(col < 8, message: "rank " + str(rank-num) + " overflows 8 files: " + rank-str)
        board.insert(square-name(col, row), fen-piece(ch))
        col += 1
      }
    }
    assert(col == 8, message: "rank " + str(rank-num) + " does not fill 8 files (got " + str(col) + "): " + rank-str)
  }

  // ---- fields 2-6: optional, with defaults ------------------------------
  let turn = if parts.len() > 1 { parts.at(1) } else { "w" }
  assert(turn == "w" or turn == "b", message: "side to move must be 'w' or 'b', got: " + turn)

  let cs = if parts.len() > 2 { parts.at(2) } else { "-" }
  let castling = (
    white-king: cs.contains("K"),
    white-queen: cs.contains("Q"),
    black-king: cs.contains("k"),
    black-queen: cs.contains("q"),
  )

  let ep = if parts.len() > 3 and parts.at(3) != "-" { lower(parts.at(3)) } else { none }
  let halfmove = if parts.len() > 4 { int(parts.at(4)) } else { 0 }
  let fullmove = if parts.len() > 5 { int(parts.at(5)) } else { 1 }

  (
    variant: "standard",
    cols: 8,
    rows: 8,
    squares: board,
    turn: turn,
    castling: castling,
    en-passant: ep,
    halfmove: halfmove,
    fullmove: fullmove,
  )
}

/// The standard chess starting position, as a FEN string constant (handy as the
/// `source` for `chess-moves`, `parse-fen`, `board`, …).
#let starting-fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

// FEN letter for a piece: kind letter, upper for white, lower for black.
#let _piece-fen-char(piece) = {
  let l = kind-letters.at(piece.kind)
  if piece.color == "white" { upper(l) } else { lower(l) }
}

/// Encode a `position` dict back into a FEN string (the inverse of `parse-fen`).
/// Geometry-aware — it uses the position's `cols` / `rows`, so it also serialises
/// larger-than-8×8 boards — and tolerant of positions built by `position()`
/// (empty `castling`, `en-passant` `none`). Standard 8×8 positions round-trip
/// exactly with `parse-fen`.
///
/// - position (dictionary): a position dict (from `position` / `parse-fen`).
/// -> str
#let position-fen(position) = {
  assert(type(position) == dictionary and "squares" in position,
    message: "position-fen: expected a position dict (with `squares`)")
  let cols = position.at("cols", default: 8)
  let rows = position.at("rows", default: 8)
  let squares = position.squares

  // field 1: piece placement, rank `rows` first (top) down to rank 1.
  let rank-strs = ()
  for row in range(rows - 1, -1, step: -1) {
    let s = ""
    let empty = 0
    for col in range(cols) {
      let name = square-name(col, row)
      if name in squares {
        if empty > 0 { s += str(empty); empty = 0 }
        s += _piece-fen-char(squares.at(name))
      } else {
        empty += 1
      }
    }
    if empty > 0 { s += str(empty) }
    rank-strs.push(s)
  }
  let placement = rank-strs.join("/")

  // fields 2-6
  let turn = position.at("turn", default: "w")
  let c = position.at("castling", default: (:))
  let cstr = ""
  if c.at("white-king", default: false) { cstr += "K" }
  if c.at("white-queen", default: false) { cstr += "Q" }
  if c.at("black-king", default: false) { cstr += "k" }
  if c.at("black-queen", default: false) { cstr += "q" }
  if cstr == "" { cstr = "-" }
  let ep = position.at("en-passant", default: none)
  let epstr = if ep == none { "-" } else { ep }
  let half = position.at("halfmove", default: 0)
  let full = position.at("fullmove", default: 1)

  placement + " " + turn + " " + cstr + " " + epstr + " " + str(half) + " " + str(full)
}
