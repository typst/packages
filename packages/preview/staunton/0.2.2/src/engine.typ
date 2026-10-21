// ===========================================================================
// Move generator & rules engine (pure Typst).
//
// Two-stage legal move generation:
//   1. `_pseudo-moves` + `_castling-moves` produce moves that respect piece
//      geometry, blockers, captures and the en-passant/castling preconditions,
//      but do NOT check whether the mover's own king is left in check.
//   2. `legal-moves` filters them: apply each move, then ask whether the
//      mover's king is attacked in the resulting position.
//
// The keystone is `is-square-attacked`, reused for king safety, check
// detection, castling-through-check, and (later) mate/stalemate.
//
// A `move` is:
//   (from: (col,row), to: (col,row), piece, color,
//    capture: none|kind, kind: "normal"|"double-push"|"en-passant"
//                              |"castle-k"|"castle-q"|"promotion",
//    promotion: none|kind)
// ===========================================================================

#import "coords.typ": square-name, parse-square

// Piece at (col,row) or `none`; `none` for off-board coordinates too.
#let _at(board, c, r) = {
  if c < 0 or c > 7 or r < 0 or r > 7 { return none }
  let n = square-name(c, r)
  if n in board { board.at(n) } else { none }
}

#let _other(color) = if color == "white" { "black" } else { "white" }

#let _mv(fc, fr, tc, tr, piece, color, capture: none, kind: "normal", promotion: none) = (
  from: (fc, fr), to: (tc, tr), piece: piece, color: color,
  capture: capture, kind: kind, promotion: promotion,
)

#let _knight-offsets = ((1,2),(2,1),(-1,2),(-2,1),(1,-2),(2,-1),(-1,-2),(-2,-1))
#let _orth-dirs = ((1,0),(-1,0),(0,1),(0,-1))
#let _diag-dirs = ((1,1),(1,-1),(-1,1),(-1,-1))

/// Is square (c,r) attacked by any piece of color `by`?
#let is-square-attacked(board, c, r, by) = {
  // pawns: a `by`-pawn attacks (c,r) from one rank "behind" (c,r)
  let pr = if by == "white" { r - 1 } else { r + 1 }
  for dc in (-1, 1) {
    let p = _at(board, c + dc, pr)
    if p != none and p.color == by and p.kind == "pawn" { return true }
  }
  // knights
  for (dc, dr) in _knight-offsets {
    let p = _at(board, c + dc, r + dr)
    if p != none and p.color == by and p.kind == "knight" { return true }
  }
  // adjacent king
  for dc in (-1, 0, 1) {
    for dr in (-1, 0, 1) {
      if dc == 0 and dr == 0 { continue }
      let p = _at(board, c + dc, r + dr)
      if p != none and p.color == by and p.kind == "king" { return true }
    }
  }
  // sliding: rook/queen orthogonally, bishop/queen diagonally
  for (dc, dr) in _orth-dirs {
    let cc = c + dc
    let rr = r + dr
    while cc >= 0 and cc <= 7 and rr >= 0 and rr <= 7 {
      let p = _at(board, cc, rr)
      if p != none {
        if p.color == by and (p.kind == "rook" or p.kind == "queen") { return true }
        break
      }
      cc += dc
      rr += dr
    }
  }
  for (dc, dr) in _diag-dirs {
    let cc = c + dc
    let rr = r + dr
    while cc >= 0 and cc <= 7 and rr >= 0 and rr <= 7 {
      let p = _at(board, cc, rr)
      if p != none {
        if p.color == by and (p.kind == "bishop" or p.kind == "queen") { return true }
        break
      }
      cc += dc
      rr += dr
    }
  }
  false
}

// Find the (col,row) of `color`'s king, or `none`.
#let _find-king(board, color) = {
  for (name, p) in board {
    if p.kind == "king" and p.color == color {
      let s = parse-square(name)
      return (s.col, s.row)
    }
  }
  none
}

/// Is `color`'s king currently in check in `position`?
///
/// - position (dictionary): the position to test.
/// - color (str): `"white"` or `"black"`.
/// -> bool
#let in-check(position, color) = {
  let k = _find-king(position.squares, color)
  if k == none { return false }
  is-square-attacked(position.squares, k.at(0), k.at(1), _other(color))
}

/// Square (e.g. `"e1"`) of the *side-to-move's* king when it is in check, else
/// `none`. This is the one king that can legally be in check, so it is what the
/// in-check indicator glows. Standard-chess only.
///
/// - position (dictionary): the position to test (needs `turn` + `squares`).
/// -> str | none
#let checked-king-square(position) = {
  let color = if position.turn == "w" { "white" } else { "black" }
  let k = _find-king(position.squares, color)
  if k == none { return none }
  if not is-square-attacked(position.squares, k.at(0), k.at(1), _other(color)) { return none }
  square-name(k.at(0), k.at(1))
}

// Pseudo-legal moves (no king-safety check), excluding castling.
#let _pseudo-moves(position) = {
  let board = position.squares
  let color = if position.turn == "w" { "white" } else { "black" }
  let opp = _other(color)
  let moves = ()
  for (name, p) in board {
    if p.color != color { continue }
    let s = parse-square(name)
    let c = s.col
    let r = s.row

    if p.kind == "pawn" {
      let dir = if color == "white" { 1 } else { -1 }
      let start-row = if color == "white" { 1 } else { 6 }
      let promo-row = if color == "white" { 7 } else { 0 }
      // single push
      if _at(board, c, r + dir) == none {
        if r + dir == promo-row {
          for promo in ("queen", "rook", "bishop", "knight") {
            moves.push(_mv(c, r, c, r + dir, "pawn", color, kind: "promotion", promotion: promo))
          }
        } else {
          moves.push(_mv(c, r, c, r + dir, "pawn", color))
          // double push
          if r == start-row and _at(board, c, r + 2 * dir) == none {
            moves.push(_mv(c, r, c, r + 2 * dir, "pawn", color, kind: "double-push"))
          }
        }
      }
      // captures (incl. en passant)
      for dc in (-1, 1) {
        let tc = c + dc
        let tr = r + dir
        if tc < 0 or tc > 7 { continue }
        let target = _at(board, tc, tr)
        if target != none and target.color == opp {
          if tr == promo-row {
            for promo in ("queen", "rook", "bishop", "knight") {
              moves.push(_mv(c, r, tc, tr, "pawn", color, capture: target.kind, kind: "promotion", promotion: promo))
            }
          } else {
            moves.push(_mv(c, r, tc, tr, "pawn", color, capture: target.kind))
          }
        } else if target == none and position.en-passant != none {
          let ep = parse-square(position.en-passant)
          if tc == ep.col and tr == ep.row {
            moves.push(_mv(c, r, tc, tr, "pawn", color, capture: "pawn", kind: "en-passant"))
          }
        }
      }

    } else if p.kind == "knight" {
      for (dc, dr) in _knight-offsets {
        let tc = c + dc
        let tr = r + dr
        if tc < 0 or tc > 7 or tr < 0 or tr > 7 { continue }
        let target = _at(board, tc, tr)
        if target == none or target.color == opp {
          moves.push(_mv(c, r, tc, tr, "knight", color, capture: if target != none { target.kind } else { none }))
        }
      }

    } else if p.kind == "king" {
      for dc in (-1, 0, 1) {
        for dr in (-1, 0, 1) {
          if dc == 0 and dr == 0 { continue }
          let tc = c + dc
          let tr = r + dr
          if tc < 0 or tc > 7 or tr < 0 or tr > 7 { continue }
          let target = _at(board, tc, tr)
          if target == none or target.color == opp {
            moves.push(_mv(c, r, tc, tr, "king", color, capture: if target != none { target.kind } else { none }))
          }
        }
      }

    } else {
      // sliding pieces
      let dirs = if p.kind == "rook" { _orth-dirs } else if p.kind == "bishop" { _diag-dirs } else { _orth-dirs + _diag-dirs }
      for (dc, dr) in dirs {
        let cc = c + dc
        let rr = r + dr
        while cc >= 0 and cc <= 7 and rr >= 0 and rr <= 7 {
          let target = _at(board, cc, rr)
          if target == none {
            moves.push(_mv(c, r, cc, rr, p.kind, color))
          } else {
            if target.color == opp {
              moves.push(_mv(c, r, cc, rr, p.kind, color, capture: target.kind))
            }
            break
          }
          cc += dc
          rr += dr
        }
      }
    }
  }
  moves
}

// Standard 960 castling destinations: king -> g/c file, rook -> f/d file. These
// hold for standard chess too (king e1->g1/c1, rook h1->f1 / a1->d1).
#let _KING-DEST = (castle-k: 6, castle-q: 2)
#let _ROOK-DEST = (castle-k: 5, castle-q: 3)

// Legality of one castle (rook-file model), generalised for Chess960: the king
// (file `kf`) and the castling rook (file `rf`) sit anywhere on rank `rank`; they
// swing to fixed files (`kdest`/`rdest`). Every square the king OR the rook
// traverses must be empty except for those two pieces themselves, and no square
// the king passes through (or lands on) may be attacked.
#let _castle-ok(board, color, opp, kf, rf, rank, kdest, rdest) = {
  let rook = _at(board, rf, rank)
  if rook == none or rook.kind != "rook" or rook.color != color { return false }
  let span(a, b) = range(calc.min(a, b), calc.max(a, b) + 1)
  for c in span(kf, kdest) + span(rf, rdest) {
    if c == kf or c == rf { continue }   // the king / rook may occupy their own squares
    if _at(board, c, rank) != none { return false }
  }
  for c in span(kf, kdest) {
    if is-square-attacked(board, c, rank, opp) { return false }  // includes "out of check" at kf
  }
  true
}

// Castling moves, fully validated (rights, empty path, not through/into check).
// Variant-agnostic: reads the rook's file from the rook-file castling model, so
// standard chess and Chess960 share this code path.
#let _castling-moves(position) = {
  let board = position.squares
  let color = if position.turn == "w" { "white" } else { "black" }
  let opp = _other(color)
  let moves = ()
  let king = _find-king(board, color)
  if king == none { return moves }
  let (kf, rank) = king
  let cr = position.castling
  for (side, kind) in (("king", "castle-k"), ("queen", "castle-q")) {
    let rf = cr.at(color + "-" + side, default: none)
    if rf == none or rf == false { continue }
    if rf == true { rf = if side == "king" { 7 } else { 0 } }
    if _castle-ok(board, color, opp, kf, rf, rank, _KING-DEST.at(kind), _ROOK-DEST.at(kind)) {
      moves.push(_mv(kf, rank, _KING-DEST.at(kind), rank, "king", color, kind: kind))
    }
  }
  moves
}

/// Apply a move to a position, returning the new position — pure (the input is
/// not mutated). Handles captures, en passant, castling (rook too), promotion,
/// castling-rights and en-passant-target updates, and the move clocks.
///
/// - position (dictionary): the position to move from.
/// - move (dictionary): a concrete move dict (e.g. from `san-to-move` or
///   `legal-moves`).
/// -> dictionary
#let apply(position, move) = {
  let board = position.squares
  let color = move.color
  let (fc, fr) = move.from
  let (tc, tr) = move.to
  let from-name = square-name(fc, fr)
  let to-name = square-name(tc, tr)

  board.remove(from-name)
  if move.kind == "en-passant" {
    // captured pawn sits beside the destination, on the mover's origin rank
    board.remove(square-name(tc, fr))
  }

  let cr = position.castling
  if move.kind == "castle-k" or move.kind == "castle-q" {
    // Atomic castle (Chess960-safe): remove both castling pieces, then place
    // both, so the king's and rook's squares may overlap/swap. The king is
    // already removed above; look the rook's file up from the rights model.
    let side = if move.kind == "castle-k" { "king" } else { "queen" }
    let rf = cr.at(color + "-" + side, default: none)
    if rf == none or rf == true or rf == false { rf = if side == "king" { 7 } else { 0 } }
    board.remove(square-name(rf, fr))
    board.insert(square-name(_KING-DEST.at(move.kind), fr), (kind: "king", color: color))
    board.insert(square-name(_ROOK-DEST.at(move.kind), fr), (kind: "rook", color: color))
  } else {
    let placed = if move.kind == "promotion" { (kind: move.promotion, color: color) } else { (kind: move.piece, color: color) }
    board.insert(to-name, placed) // overwrites a normally-captured piece
  }

  // castling rights (rook-file model: a right stores the rook's file, or none)
  if move.piece == "king" {
    cr.insert(color + "-king", none)
    cr.insert(color + "-queen", none)
  }
  if move.piece == "rook" {
    // a rook leaving its stored castling file (on its back rank) kills that right
    let home = if color == "white" { 0 } else { 7 }
    if fr == home {
      for side in ("king", "queen") { if cr.at(color + "-" + side, default: none) == fc { cr.insert(color + "-" + side, none) } }
    }
  }
  if move.capture == "rook" { // capturing a rook on its castling home square kills that right
    let opp = _other(color)
    let ohome = if opp == "white" { 0 } else { 7 }
    if tr == ohome {
      for side in ("king", "queen") { if cr.at(opp + "-" + side, default: none) == tc { cr.insert(opp + "-" + side, none) } }
    }
  }

  let ep = if move.kind == "double-push" { square-name(fc, int((fr + tr) / 2)) } else { none }
  let half = if move.piece == "pawn" or move.capture != none { 0 } else { position.halfmove + 1 }
  let full = if color == "black" { position.fullmove + 1 } else { position.fullmove }
  let turn = if position.turn == "w" { "b" } else { "w" }

  (
    variant: position.at("variant", default: "standard"),
    cols: position.at("cols", default: 8),
    rows: position.at("rows", default: 8),
    squares: board,
    turn: turn, castling: cr, en-passant: ep, halfmove: half, fullmove: full,
  )
}

/// All fully-legal moves for the side to move in `position`, as an array of move
/// dicts.
///
/// - position (dictionary): the position to generate moves for.
/// -> array
#let legal-moves(position) = {
  // The rules engine implements standard western chess only. Variant boards
  // (xiangqi, shatar, shogi, ...) need their own move generation; until then any
  // move analysis on a non-standard position is a hard error here, so the limit
  // lives in the engine (callers like chess-moves need no `variant` parameter).
  assert(position.at("variant", default: "standard") == "standard",
    message: "engine: move analysis supports only standard chess (got variant " + repr(position.at("variant", default: "standard")) + ")")
  let color = if position.turn == "w" { "white" } else { "black" }
  let opp = _other(color)
  let pseudo = _pseudo-moves(position) + _castling-moves(position)
  let legal = ()
  for m in pseudo {
    let after = apply(position, m)
    let k = _find-king(after.squares, color)
    if k == none { continue }
    if not is-square-attacked(after.squares, k.at(0), k.at(1), opp) {
      legal.push(m)
    }
  }
  legal
}
