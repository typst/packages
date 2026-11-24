// ===========================================================================
// SAN (Standard Algebraic Notation) resolution.
//
// `san-to-move(position, san)` interprets one SAN token against a position by
// matching it to exactly one of the position's *legal* moves. This is why a
// full legal generator is required: disambiguation in SAN is only omitted when
// a single move is legal (e.g. the other candidate is pinned).
//
// A move that matches zero legal moves is illegal/unresolvable -> hard error.
// A move that matches more than one is ambiguous -> hard error.
// ===========================================================================

#import "coords.typ": parse-square, file-letters, rank-digits
#import "engine.typ": legal-moves, apply, in-check
#import "fen.typ": parse-fen, starting-fen

#let _promo-map = (Q: "queen", R: "rook", B: "bishop", N: "knight")
#let _piece-map = (K: "king", Q: "queen", R: "rook", B: "bishop", N: "knight")

// Strip trailing check/mate/annotation symbols (+ # ! ?).
#let _clean(san) = {
  let s = san
  while s.len() > 0 and ("+", "#", "!", "?").contains(s.slice(s.len() - 1)) {
    s = s.slice(0, s.len() - 1)
  }
  s
}

/// Resolve a SAN string against a position's legal moves, returning the concrete
/// move dict. Illegal or ambiguous SAN is a hard error.
///
/// - position (dictionary): the position to resolve the move in.
/// - san (str): a SAN token, e.g. `"Nf3"`, `"exd5"`, `"O-O"`, `"e8=Q+"`.
/// -> dictionary
#let san-to-move(position, san) = {
  let color = if position.turn == "w" { "white" } else { "black" }
  let legal = legal-moves(position)
  let s = _clean(san)
  assert(s.len() > 0, message: "empty SAN token")

  // castling (check the longer pattern first)
  if s == "O-O-O" or s == "0-0-0" {
    let cand = legal.filter(m => m.kind == "castle-q")
    assert(cand.len() == 1, message: "illegal queen-side castling \"" + san + "\" for " + color)
    return cand.first()
  }
  if s == "O-O" or s == "0-0" {
    let cand = legal.filter(m => m.kind == "castle-k")
    assert(cand.len() == 1, message: "illegal king-side castling \"" + san + "\" for " + color)
    return cand.first()
  }

  // promotion suffix "=Q"
  let promo = none
  if s.contains("=") {
    let parts = s.split("=")
    assert(parts.len() == 2 and parts.at(1).len() >= 1, message: "malformed promotion in SAN: " + san)
    s = parts.at(0)
    let pl = parts.at(1).slice(0, 1)
    assert(_promo-map.keys().contains(pl), message: "invalid promotion piece in SAN: " + san)
    promo = _promo-map.at(pl)
  }

  let cs = s.clusters()
  assert(cs.len() >= 2, message: "unparseable SAN: " + san)
  // destination is the trailing "<file><rank>"
  let dest = cs.at(cs.len() - 2) + cs.at(cs.len() - 1)
  let dsq = parse-square(dest) // hard error if not a valid square

  let prefix = cs.slice(0, cs.len() - 2)
  let piece = "pawn"
  let idx = 0
  if prefix.len() > 0 and _piece-map.keys().contains(prefix.at(0)) {
    piece = _piece-map.at(prefix.at(0))
    idx = 1
  }
  // remaining prefix chars: optional from-file, from-rank, and 'x'
  let from-file = none
  let from-rank = none
  for ch in prefix.slice(idx) {
    if file-letters.contains(ch) {
      from-file = file-letters.position(x => x == ch)
    } else if rank-digits.contains(ch) {
      from-rank = int(ch) - 1
    } else if ch == "x" {
      // capture indicator; not needed for matching
    } else {
      assert(false, message: "unexpected character '" + ch + "' in SAN: " + san)
    }
  }

  let cand = legal.filter(m =>
    m.piece == piece
      and m.to == dest
      and (from-file == none or file-letters.position(x => x == m.from.slice(0, 1)) == from-file)
      and (from-rank == none or int(m.from.slice(1)) - 1 == from-rank)
  )
  // a non-promotion SAN must not match promotion moves, and vice versa
  cand = if promo == none {
    cand.filter(m => m.kind != "promotion")
  } else {
    cand.filter(m => m.kind == "promotion" and m.promotion == promo)
  }

  assert(cand.len() != 0, message: "illegal or unresolvable move \"" + san + "\" for " + color)
  assert(cand.len() == 1, message: "ambiguous move \"" + san + "\" matches " + str(cand.len()) + " legal moves")
  cand.first()
}

// Invert `_piece-map` (name -> SAN letter), e.g. "knight" -> "N".
#let _piece-letter(piece) = {
  for (letter, name) in _piece-map {
    if name == piece { return letter }
  }
  panic("move-to-san: no SAN letter for piece kind " + repr(piece))
}

/// Encode a legal move as canonical English SAN, the inverse of `san-to-move`.
///
/// - position (dictionary): the position BEFORE the move.
/// - move (dictionary): a move dict as produced by `legal-moves(position)`.
/// -> str
#let move-to-san(position, move) = {
  let color = if position.turn == "w" { "white" } else { "black" }
  let legal = legal-moves(position)
  let matches(m) = (
    m.from == move.from and m.to == move.to
      and m.kind == move.kind and m.promotion == move.promotion
  )
  assert(
    legal.filter(matches).len() == 1,
    message: "move-to-san: not a legal move for " + color + ": " + repr(move),
  )

  let san = ""
  if move.kind == "castle-k" {
    san = "O-O"
  } else if move.kind == "castle-q" {
    san = "O-O-O"
  } else if move.piece == "pawn" {
    san = ""
    if move.capture != none {
      san += move.from.slice(0, 1) + "x"
    }
    san += move.to
    if move.kind == "promotion" {
      san += "=" + _piece-letter(move.promotion).clusters().at(0)
    }
  } else {
    let letter = _piece-letter(move.piece)
    let others = legal.filter(m =>
      m.piece == move.piece and m.to == move.to and m.from != move.from
    )
    let disambig = ""
    if others.len() > 0 {
      let same-file = others.filter(m => m.from.slice(0, 1) == move.from.slice(0, 1)).len() > 0
      let same-rank = others.filter(m => m.from.slice(1) == move.from.slice(1)).len() > 0
      if not same-file {
        disambig = move.from.slice(0, 1)
      } else if not same-rank {
        disambig = move.from.slice(1)
      } else {
        disambig = move.from
      }
    }
    san = letter + disambig + (if move.capture != none { "x" } else { "" }) + move.to
  }

  let opponent = if color == "white" { "black" } else { "white" }
  let next = apply(position, move)
  if in-check(next, opponent) {
    san += if legal-moves(next).len() == 0 { "#" } else { "+" }
  }
  san
}

// Tokenize free move text into a flat SAN list. Drops move numbers ("3." /
// "3..." and glued "3.e4" / "3...Nf6") and result tokens ("1-0", "*", ...).
// Comments {..}, NAGs ($n) and variations (..) are NOT supported here -- they
// raise an error (use `game` for full PGN movetext).
#let _results = ("1-0", "0-1", "1/2-1/2", "*")
#let _split-movetext(text) = {
  let out = ()
  for tok in text.split(regex("\s+")) {
    let t = tok.trim()
    if t == "" { continue }
    assert(
      not (t.contains("{") or t.contains("}") or t.contains("(") or t.contains(")") or t.starts-with(";") or t.starts-with("$")),
      message: "play: comments, NAGs and variations are not supported in move text (use game()); got " + repr(t),
    )
    if _results.contains(t) { continue }
    if t.match(regex("^[0-9]+\.+$")) != none { continue }   // bare move number
    let m = t.match(regex("^([0-9]+\.+)(.+)$"))               // glued "3.e4"/"3...Nf6"
    if m != none {
      let rest = m.captures.at(1)
      if not _results.contains(rest) { out.push(rest) }
    } else {
      out.push(t)
    }
  }
  out
}

/// Apply a run of moves to a position and return the *final* position
/// (renderable). Each move is resolved against the position's legal moves, so an
/// illegal or ambiguous move is a hard error naming the offending SAN token. The
/// variant is taken from `source`; non-standard variants error in the engine.
///
/// - source (none, str, dictionary): the starting point — `none` for the standard
///   start, a FEN string, or a position dict.
/// - moves (str, content, array): a move-text string, a raw block, or an array
///   of SAN strings — required.
/// -> dictionary
#let play(source, moves: none) = {
  assert(moves != none, message: "play: `moves` is required")
  let pos = if source == none { parse-fen(starting-fen) }
    else if type(source) == str { parse-fen(source) }
    else if type(source) == dictionary and "squares" in source { source }
    else { panic("play: source must be none, a FEN string, or a position; got " + repr(type(source))) }
  let sans = if type(moves) == array { moves }
    else if type(moves) == str { _split-movetext(moves) }
    else if type(moves) == content and moves.func() == raw { _split-movetext(moves.text) }
    else { panic("play: moves must be a SAN array, a move-text string, or a raw block; got " + repr(type(moves))) }
  for s in sans {
    pos = apply(pos, san-to-move(pos, s))
  }
  pos
}
