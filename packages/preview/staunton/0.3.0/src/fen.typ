// ===========================================================================
// Forsyth-Edwards Notation (FEN) parsing.
//
// A FEN string has up to six space-separated fields:
//   1. piece placement   (mandatory) - 8 ranks "/"-separated, rank 8 FIRST,
//                                       each rank file a->h; digits = empties.
//   2. side to move       w | b           (default w)
//   3. castling rights    KQkq | subset | file letters | -   (default -)
//   4. en passant target  e3 | -             (default none)
//   5. halfmove clock     int               (default 0)
//   6. fullmove number    int               (default 1)
//
// We are strict about the mandatory placement field (clear errors beat silent
// wrong diagrams in a publishing workflow) but lenient about trailing fields:
// a placement-only or 4-field FEN is accepted with sensible defaults.
//
// Field 3 also accepts X-FEN (Chess960): a rook's file letter (A-H / a-h) names
// the castling rook when KQkq would be ambiguous; rights are stored as rook file
// indices (see the castling helpers below). Output is strict X-FEN — the e.p.
// target is emitted only when a capture is actually available.
//
// Output: a `position` dict consumed by the renderer (only `board` is needed
// for drawing; the rest is carried for later move-generation / display).
// ===========================================================================

#import "coords.typ": square-name, parse-square, file-letter
#import "pieces.typ": fen-piece, kind-letters

// ---- castling helpers (rook-file model) -----------------------------------
// Castling rights are stored per side as the *rook's file index* (0..cols-1) or
// `none` for "no right". This subsumes standard chess (rooks on a/h) and
// Chess960 / X-FEN (rook on any file), so the engine needs no variant branch.
// The `king`/`queen` key still names the SIDE (king-side = rook on the h-side of
// the king; queen-side = a-side).

// (col, row) of `color`'s king in a squares dict, or `none`.
#let _find-king-cr(board, color) = {
  for (name, p) in board {
    if p.kind == "king" and p.color == color {
      let s = parse-square(name)
      return (s.col, s.row)
    }
  }
  none
}

// Ascending list of the file indices of `color`'s rooks on row `row`.
#let _rook-cols-on(board, color, row) = {
  let cols = ()
  for (name, p) in board {
    if p.kind == "rook" and p.color == color {
      let s = parse-square(name)
      if s.row == row { cols.push(s.col) }
    }
  }
  cols.sorted()
}

// File index (0..7) of a lowercase castling file letter a..h, or `none`.
#let _castle-file-index(lo) = {
  ("a", "b", "c", "d", "e", "f", "g", "h").position(x => x == lo)
}

// Parse the FEN castling field into the rook-file model. `K`/`Q`/`k`/`q` resolve
// to the OUTERMOST rook on that side of the king (X-FEN convention); an explicit
// file letter (`A`..`H` / `a`..`h`) names that rook directly. Unresolvable
// tokens (no matching rook/king) are silently skipped.
#let _parse-castling(cs, board) = {
  let out = (white-king: none, white-queen: none, black-king: none, black-queen: none)
  if cs == "-" or cs == "" { return out }
  let kings = (white: _find-king-cr(board, "white"), black: _find-king-cr(board, "black"))
  for ch in cs.clusters() {
    let color = if ch == upper(ch) { "white" } else { "black" }
    let king = kings.at(color)
    if king == none { continue }
    let lo = lower(ch)
    if lo == "k" {
      let r = _rook-cols-on(board, color, king.at(1)).filter(c => c > king.at(0))
      if r.len() > 0 { out.insert(color + "-king", r.last()) }
    } else if lo == "q" {
      let r = _rook-cols-on(board, color, king.at(1)).filter(c => c < king.at(0))
      if r.len() > 0 { out.insert(color + "-queen", r.first()) }
    } else {
      let col = _castle-file-index(lo)
      if col != none {
        out.insert(color + "-" + (if col > king.at(0) { "king" } else { "queen" }), col)
      }
    }
  }
  out
}

// Strict en-passant test (for X-FEN output): a recorded e.p. target is only
// emitted if the side to move actually has a pawn positioned to capture onto it.
// This is the X-FEN "strict" rule; we use the pawn-attack form (a friendly pawn
// sits beside the just-double-pushed enemy pawn), which is what most tools emit.
// An e.p. target on rank 3 means Black is to move (White just pushed) and the
// capturing black pawns would stand on rank 4 beside the target file; symmetric
// for rank 6 / White to move.
#let _ep-capturable(squares, turn, ep) = {
  if ep == none { return false }
  let s = parse-square(ep)
  let cr = if turn == "w" { s.row - 1 } else { s.row + 1 }   // rank of a capturing pawn
  let want = if turn == "w" { "white" } else { "black" }
  for dc in (-1, 1) {
    let c = s.col + dc
    if c < 0 or c > 7 { continue }
    let p = squares.at(square-name(c, cr), default: none)
    if p != none and p.kind == "pawn" and p.color == want { return true }
  }
  false
}

// Serialise the rook-file castling model back to an (X-)FEN field. Emits the
// conventional letter (K/Q/k/q) when the castling rook is the OUTERMOST rook of
// its color on that side of the king (so standard positions stay `KQkq`), and
// the rook's file letter otherwise (the promotion-rook ambiguity). A legacy
// boolean `true` is read as the standard file for that side.
#let _castling-str(position) = {
  let c = position.at("castling", default: (:))
  let sq = position.squares
  let cols = position.at("cols", default: 8)
  let out = ""
  for (color, side, letter) in (("white", "king", "K"), ("white", "queen", "Q"), ("black", "king", "k"), ("black", "queen", "q")) {
    let rf = c.at(color + "-" + side, default: none)
    if rf == true { rf = if side == "king" { cols - 1 } else { 0 } }
    if rf == none or rf == false { continue }
    let king = _find-king-cr(sq, color)
    if king == none { out += letter; continue }
    let rooks = _rook-cols-on(sq, color, king.at(1))
    let outer = if side == "king" {
      let r = rooks.filter(x => x > king.at(0))
      if r.len() > 0 { r.last() } else { none }
    } else {
      let r = rooks.filter(x => x < king.at(0))
      if r.len() > 0 { r.first() } else { none }
    }
    if outer != none and rf == outer { out += letter }
    else { out += (if color == "white" { upper(file-letter(rf)) } else { file-letter(rf) }) }
  }
  if out == "" { "-" } else { out }
}

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
  let castling = _parse-castling(cs, board)

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
  let cstr = _castling-str(position)
  let ep = position.at("en-passant", default: none)
  // Strict X-FEN: only record the e.p. target when a capture is actually on.
  let epstr = if ep == none or not _ep-capturable(squares, turn, ep) { "-" } else { ep }
  let half = position.at("halfmove", default: 0)
  let full = position.at("fullmove", default: 1)

  placement + " " + turn + " " + cstr + " " + epstr + " " + str(half) + " " + str(full)
}
