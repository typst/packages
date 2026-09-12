// ===========================================================================
// Game navigation (Phase B: engine resolution, on demand).
//
// Turns a parsed `game` (from pgn.typ) into positions. This is where the engine
// actually runs -- only when a diagram asks for a position, so a tournament
// file read only for results never reaches here.
//
// Locators address a point in the game:
//   * "30w" / "30b"  -- after White's / Black's 30th move (the mainline);
//   * a path dict     -- for (possibly nested) variations:
//       (line: ( (at: "2w", into: 0), (at: "2b", into: 0) ), at: "3w")
//     read as: from the mainline, at White's move 2 descend into variation 0,
//     then at Black's move 2 descend into variation 0, then take the position
//     after White's move 3.
//
// Ply numbering: after White's move m -> ply 2m-1; after Black's -> ply 2m.
// ===========================================================================

#import "fen.typ": parse-fen, starting-fen
#import "san.typ": san-to-move
#import "engine.typ": apply
#import "pgn.typ": movetext, _movetext-tree

// "30w" -> 59 ; "30b" -> 60
#let _ply-of(loc) = {
  assert(type(loc) == str and loc.len() >= 2, message: "bad move locator: " + repr(loc))
  let color = loc.slice(loc.len() - 1)
  let num = int(loc.slice(0, loc.len() - 1))
  if color == "w" { 2 * num - 1 }
  else if color == "b" { 2 * num }
  else { panic("move locator must end in 'w' or 'b': " + loc) }
}

/// The starting position of a game — from its `FEN` tag if present, else the
/// standard start.
///
/// - game (dictionary): a parsed game (from `parse-pgn`).
/// -> dictionary
#let game-start(game) = {
  if "FEN" in game.tags { parse-fen(game.tags.at("FEN")) } else { parse-fen(starting-fen) }
}

/// The mainline of a game as an array of SAN strings (the game as played).
///
/// - game (dictionary): a parsed game (from `parse-pgn`).
/// -> array
#let mainline(game) = movetext(game).map(n => n.san)

/// The game result token: `"1-0"`, `"0-1"`, `"1/2-1/2"`, or `"*"`.
///
/// - game (dictionary): a parsed game (from `parse-pgn`).
/// -> str
#let game-result(game) = game.result

// Apply SAN nodes line[0..k) to `pos`, returning the new position.
#let _advance(pos, line, k) = {
  let p = pos
  for j in range(k) {
    p = apply(p, san-to-move(p, line.at(j).san))
  }
  p
}

// All mainline positions: (start, after ply 1, after ply 2, ...). Each SAN is
// resolved once, so the move generator runs N times TOTAL here. Typst memoises a
// pure call by its arguments, so repeated `position-after` / `diagram-after` on the
// SAME game reuse this list instead of re-walking from the start every time --
// the "fast-track": O(N) once, then O(1) per mainline locator, rather than
// O(N*K) generator runs for K diagrams. (Legality is still proven the first time
// the list is built; PGN parsing itself never runs the engine.)
#let _mainline-positions(game) = {
  let pos = game-start(game)
  let out = (pos,)
  for node in movetext(game) {
    pos = apply(pos, san-to-move(pos, node.san))
    out.push(pos)
  }
  out
}

/// The position at a locator — handles the mainline and (nested) variations.
///
/// - game (dictionary): a parsed game (from `parse-pgn`).
/// - locator (str, dictionary): a mainline `"30w"` / `"30b"`, or a variation path
///   dict `(line: (..hops..), at: "<move>")`.
/// -> dictionary
#let position-after(game, locator) = {
  let loc = if type(locator) == str { (line: (), at: locator) } else { locator }

  // Fast path: a pure mainline locator just indexes into the (memoised) mainline
  // positions -- no re-walking, no extra generator runs across diagrams.
  if loc.at("line", default: ()).len() == 0 {
    let all = _mainline-positions(game)
    let target = _ply-of(loc.at("at"))
    assert(target >= 0 and target < all.len(), message: "locator out of range: addressed move past end of line")
    return all.at(target)
  }

  // Variations: walk the (nested) sub-lines. Not fast-tracked, but the common
  // mainline case above is.
  let line = movetext(game)
  let branch-ply = 1
  let pos = game-start(game)

  for hop in loc.at("line", default: ()) {
    let target = _ply-of(hop.at("at"))
    let k = target - branch-ply // moves before the branch point
    assert(k >= 0 and k < line.len() + 1, message: "locator hop out of range at " + hop.at("at"))
    pos = _advance(pos, line, k)
    let node = line.at(k)
    let vars = node.at("variations", default: ())
    let into = hop.at("into")
    assert(into < vars.len(), message: "no variation #" + str(into) + " at move " + hop.at("at"))
    line = vars.at(into)
    branch-ply = target
  }

  let target = _ply-of(loc.at("at"))
  let k = target - branch-ply + 1 // inclusive of the addressed move
  assert(k >= 0 and k <= line.len(), message: "locator out of range: addressed move past end of line")
  _advance(pos, line, k)
}

/// The SAN of the move addressed by `locator` (e.g. `"O-O-O"`). Used to build
/// PGN-diagram captions.
///
/// - game (dictionary): a parsed game (from `parse-pgn`).
/// - locator (str, dictionary): a mainline `"30w"` / `"30b"`, or a variation path
///   dict.
/// -> str
#let move-san(game, locator) = {
  let loc = if type(locator) == str { (line: (), at: locator) } else { locator }
  let line = movetext(game)
  let branch-ply = 1
  for hop in loc.at("line", default: ()) {
    let target = _ply-of(hop.at("at"))
    let k = target - branch-ply
    let node = line.at(k)
    line = node.at("variations").at(hop.at("into"))
    branch-ply = target
  }
  let k = _ply-of(loc.at("at")) - branch-ply
  assert(k >= 0 and k < line.len(), message: "move-san: locator addresses a move past the end of its line")
  line.at(k).san
}

/// The full move node addressed by `locator` — its SAN plus `nags`, comments
/// (`comment-before` / `comment-after`) and `variations`. Used e.g. to recover
/// PGN `%cal` / `%csl` annotations for a diagram.
///
/// - game (dictionary): a parsed game (from `parse-pgn`).
/// - locator (str, dictionary): a mainline `"30w"` / `"30b"`, or a variation path
///   dict.
/// -> dictionary
#let move-node(game, locator) = {
  let loc = if type(locator) == str { (line: (), at: locator) } else { locator }
  let line = movetext(game)
  let branch-ply = 1
  for hop in loc.at("line", default: ()) {
    let target = _ply-of(hop.at("at"))
    let k = target - branch-ply
    let node = line.at(k)
    line = node.at("variations").at(hop.at("into"))
    branch-ply = target
  }
  let k = _ply-of(loc.at("at")) - branch-ply
  assert(k >= 0 and k < line.len(), message: "move-node: locator addresses a move past the end of its line")
  line.at(k)
}

// ===========================================================================
// Programmatic game building (Phase 1: annotate existing moves).
//
// Pure, stash-based transforms over the movetext node tree. Each returns a NEW
// game with the modified tree stashed as `movetext-nodes` (honoured by
// `movetext`, see pgn.typ), so the change flows through every consumer and the
// SOURCE game is never mutated. Moves are addressed by the same locators as
// navigation: a mainline string ("12w"/"12b") or a path dict
// `(line: (..hops..), at: "<move>")` for a move inside a (nested) variation.
// ===========================================================================

// Apply `f` to the node addressed by (hops, final) within `line`, whose first
// node is at ply `branch-ply`. Functional (immutable) update: returns a new line.
#let _update-in-line(line, branch-ply, hops, final, f) = {
  if hops.len() == 0 {
    let k = _ply-of(final) - branch-ply
    assert(k >= 0 and k < line.len(), message: "locator addresses a move past the end of its line: " + final)
    line.at(k) = f(line.at(k))
    return line
  }
  let hop = hops.first()
  let target = _ply-of(hop.at("at"))
  let k = target - branch-ply
  assert(k >= 0 and k < line.len(), message: "locator hop out of range at " + hop.at("at"))
  let node = line.at(k)
  let vars = node.at("variations", default: ())
  let into = hop.at("into")
  assert(into < vars.len(), message: "no variation #" + str(into) + " at move " + hop.at("at"))
  vars.at(into) = _update-in-line(vars.at(into), target, hops.slice(1), final, f)
  node.variations = vars
  line.at(k) = node
  line
}

// Update the node addressed by `locator` in the top-level `nodes` tree.
#let _update-node-at(nodes, locator, f) = {
  let loc = if type(locator) == str { (line: (), at: locator) }
    else if type(locator) == dictionary { locator }
    else { panic("locator must be a mainline string or a path dict; got " + repr(locator)) }
  let final = loc.at("at", default: none)
  assert(final != none, message: "locator must address a move (its `at`)")
  _update-in-line(nodes, 1, loc.at("line", default: ()), final, f)
}

// Normalise a builder's overrides into an array of (locator, value) pairs. The
// dict form ("12w": v, ...) is mainline-only (dict keys must be strings); the
// array-of-pairs form also reaches moves inside variations (a path-locator dict
// cannot be a dict key).
#let _overrides-pairs(overrides) = {
  if type(overrides) == dictionary { overrides.pairs() }
  else if type(overrides) == array { overrides }
  else { panic("overrides must be a dict of mainline locators or an array of (locator, value) pairs; got " + repr(type(overrides))) }
}

#let _stash(game, nodes) = { let g = game; g.insert("movetext-nodes", nodes); g }

// NAG value -> stored code ("1".."n"). Accepts "$n" or a suffix glyph.
#let _glyph-to-code = ("!": "1", "?": "2", "!!": "3", "??": "4", "!?": "5", "?!": "6")
#let _norm-nag(v) = {
  if type(v) == str and v.starts-with("$") and v.len() > 1 { v.slice(1) }
  else if type(v) == str and v in _glyph-to-code { _glyph-to-code.at(v) }
  else { panic("with-nags: a NAG must be \"$n\" or one of ! ? !! ?? !? ?!; got " + repr(v)) }
}

/// Attach NAGs to addressed moves (mainline or inside variations), returning a
/// *new* game (the source is not mutated). Each value *replaces* that move's NAGs.
///
/// - game (dictionary): a parsed game (from `parse-pgn`).
/// - overrides (dictionary, array): a dict of mainline locators (`("12w": "!")`)
///   or an array of `(locator, value)` pairs (a locator may be a variation path
///   dict). A value is `"$n"`, a suffix glyph (`! ? !! ?? !? ?!`), or an array of
///   those.
/// -> dictionary
#let with-nags(game, overrides) = {
  assert(type(game) == dictionary and "movetext-raw" in game, message: "with-nags: first argument must be a parsed game (from parse-pgn)")
  let nodes = movetext(game)
  for (loc, val) in _overrides-pairs(overrides) {
    let codes = if type(val) == array { val.map(_norm-nag) } else { (_norm-nag(val),) }
    nodes = _update-node-at(nodes, loc, node => { node.nags = codes; node })
  }
  _stash(game, nodes)
}

/// Attach text comments to addressed moves (mainline or inside variations),
/// returning a *new* game (the source is not mutated). Each comment *replaces* any
/// existing one and is set as the move's `comment-after` (what notation's
/// `comments` switch renders).
///
/// - game (dictionary): a parsed game (from `parse-pgn`).
/// - overrides (dictionary, array): a dict of mainline locators or an array of
///   `(locator, text)` pairs (a locator may be a variation path dict); each
///   `text` is a plain string.
/// -> dictionary
#let with-comments(game, overrides) = {
  assert(type(game) == dictionary and "movetext-raw" in game, message: "with-comments: first argument must be a parsed game (from parse-pgn)")
  let nodes = movetext(game)
  for (loc, val) in _overrides-pairs(overrides) {
    assert(type(val) == str, message: "with-comments: a comment must be a string; got " + repr(type(val)))
    nodes = _update-node-at(nodes, loc, node => { node.insert("comment-after", val); node })
  }
  _stash(game, nodes)
}

/// Add a variation (RAV) as an *alternative* to the move at `at`, returning a
/// *new* game (the source is never mutated). The variation is appended to that
/// move's variations (its `into` index is the previous count) and numbered from
/// the move's ply at render time. Legality is checked only if you later navigate
/// into the line (e.g. via `diagram-after`).
///
/// - game (dictionary): a parsed game (from `parse-pgn`).
/// - at (str, dictionary): the move to branch at — a *mainline* locator
///   (`"3w"` / `"3b"`), or a *path* dict `(line: (..hops..), at: "<move>")` to
///   reach a move inside a (possibly nested) variation.
/// - moves (str, content): a PGN movetext fragment — a plain SAN run like
///   `"Bc4 Bc5"`, or richer text with nested `()`, `$n` NAGs and `{comments}`.
/// -> dictionary
#let with-variation(game, at: none, moves: none) = {
  assert(type(game) == dictionary and "movetext-raw" in game, message: "with-variation: first argument must be a parsed game (from parse-pgn)")
  assert(at != none, message: "with-variation: `at` (a move locator) is required")
  assert(moves != none, message: "with-variation: `moves` (a movetext fragment) is required")
  let text = if type(moves) == str { moves }
    else if type(moves) == content and moves.func() == raw { moves.text }
    else { panic("with-variation: `moves` must be a movetext string or raw block; got " + repr(type(moves))) }
  let sub = _movetext-tree(text)
  assert(sub.len() > 0, message: "with-variation: `moves` produced no moves")
  let nodes = _update-node-at(movetext(game), at, node => {
    let vars = node.at("variations", default: ())
    vars.push(sub)
    node.variations = vars
    node
  })
  _stash(game, nodes)
}

// NOTE: the old `line(start, moves)` (apply a SAN array, return every
// intermediate position) was removed in the prompt-13 streamline. To play a run
// of moves and get the FINAL position, use `chess-moves` (src/san.typ).
