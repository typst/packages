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

// Castling moves, fully validated (rights, empty squares, not through/into check).
#let _castling-moves(position) = {
  let board = position.squares
  let color = if position.turn == "w" { "white" } else { "black" }
  let opp = _other(color)
  let rank = if color == "white" { 0 } else { 7 }
  let moves = ()
  let king = _at(board, 4, rank)
  if king == none or king.kind != "king" or king.color != color { return moves }
  if is-square-attacked(board, 4, rank, opp) { return moves } // can't castle out of check
  let cr = position.castling
  let can-k = if color == "white" { cr.white-king } else { cr.black-king }
  let can-q = if color == "white" { cr.white-queen } else { cr.black-queen }
  // king-side
  if can-k and _at(board, 5, rank) == none and _at(board, 6, rank) == none {
    let rook = _at(board, 7, rank)
    if rook != none and rook.kind == "rook" and rook.color == color {
      if not is-square-attacked(board, 5, rank, opp) and not is-square-attacked(board, 6, rank, opp) {
        moves.push(_mv(4, rank, 6, rank, "king", color, kind: "castle-k"))
      }
    }
  }
  // queen-side
  if can-q and _at(board, 3, rank) == none and _at(board, 2, rank) == none and _at(board, 1, rank) == none {
    let rook = _at(board, 0, rank)
    if rook != none and rook.kind == "rook" and rook.color == color {
      if not is-square-attacked(board, 3, rank, opp) and not is-square-attacked(board, 2, rank, opp) {
        moves.push(_mv(4, rank, 2, rank, "king", color, kind: "castle-q"))
      }
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
  let placed = if move.kind == "promotion" { (kind: move.promotion, color: color) } else { (kind: move.piece, color: color) }
  board.insert(to-name, placed) // overwrites a normally-captured piece

  if move.kind == "castle-k" {
    board.remove(square-name(7, fr))
    board.insert(square-name(5, fr), (kind: "rook", color: color))
  } else if move.kind == "castle-q" {
    board.remove(square-name(0, fr))
    board.insert(square-name(3, fr), (kind: "rook", color: color))
  }

  // castling rights
  let cr = position.castling
  if move.piece == "king" {
    if color == "white" { cr.insert("white-king", false); cr.insert("white-queen", false) }
    else { cr.insert("black-king", false); cr.insert("black-queen", false) }
  }
  if move.piece == "rook" {
    if color == "white" and fc == 0 and fr == 0 { cr.insert("white-queen", false) }
    if color == "white" and fc == 7 and fr == 0 { cr.insert("white-king", false) }
    if color == "black" and fc == 0 and fr == 7 { cr.insert("black-queen", false) }
    if color == "black" and fc == 7 and fr == 7 { cr.insert("black-king", false) }
  }
  if move.capture == "rook" { // capturing a rook on its home square kills that right
    if tc == 0 and tr == 0 { cr.insert("white-queen", false) }
    if tc == 7 and tr == 0 { cr.insert("white-king", false) }
    if tc == 0 and tr == 7 { cr.insert("black-queen", false) }
    if tc == 7 and tr == 7 { cr.insert("black-king", false) }
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
