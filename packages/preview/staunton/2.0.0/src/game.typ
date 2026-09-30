// ===========================================================================
// Game navigation (engine resolution, on demand).
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
//     `into` is OPTIONAL and defaults to 0, so a move with a single variation
//     -- the common case -- is addressed by `(at: "2w")` alone. The hop above
//     may equally be written (line: ( (at: "2w"), (at: "2b") ), at: "3w").
//
// Ply numbering: after White's move m -> ply 2m-1; after Black's -> ply 2m.
// ===========================================================================

#import "fen.typ": parse-fen, starting-fen
#import "san.typ": san-to-move
#import "engine.typ": apply
#import "pgn.typ": movetext, _movetext-tree, _normalize-nodes, _tokenize
#import "chess960.typ": chess960-start-fen
#import "annotations.typ": nag-symbol, interpret-comment, glyph-to-nag, quality-nag-codes
#import "coords.typ": _ply-of-locator, _default-start

// PGN-numbered locator -> local 1-based ply, given the game's `start` (shared
// arithmetic lives in coords.typ; `start` defaults to a standard game so this
// stays the old move-1-relative arithmetic when no start is passed).
#let _ply-of(loc, start: _default-start) = _ply-of-locator(loc, start: start)

/// The starting position of a game — from its `FEN` tag if present, else from a
/// Chess960 position-number tag (`FRCPosition` / `Chess960Position`), else the
/// standard start. The start must be declared exactly one way: giving BOTH a
/// `FEN` and a position number is a hard error (they are redundant and can
/// conflict), and two position-number tags that disagree are rejected too.
/// Honours the PGN `SetUp` tag: `[SetUp "1"]` declares a custom start, so one of
/// those sources is then required. This is also the entry point for Chess960
/// games, whose start rides on the `FEN` tag (with X-FEN castling) or a position
/// number; see `game-variant`.
///
/// - game (dictionary): a parsed game (from `game`).
/// -> dictionary
#let game-start(game) = {
  let has-fen = "FEN" in game.tags
  let numtags = ("FRCPosition", "Chess960Position").filter(t => t in game.tags)
  // A start may be declared as a FEN OR a position number, never both.
  assert(not (has-fen and numtags.len() > 0),
    message: "PGN: give the start as either a [FEN] or a Chess960 position number ([FRCPosition]/[Chess960Position]), not both")
  // Two number tags are allowed only if they agree.
  assert(numtags.len() < 2 or int(game.tags.at("FRCPosition")) == int(game.tags.at("Chess960Position")),
    message: "PGN: [FRCPosition] and [Chess960Position] disagree on the start position number")

  if has-fen { return parse-fen(game.tags.at("FEN")) }
  if numtags.len() > 0 { return parse-fen(chess960-start-fen(int(game.tags.at(numtags.first())))) }
  assert(game.tags.at("SetUp", default: "0") != "1",
    message: "PGN: [SetUp \"1\"] declares a custom start position but no [FEN] or position-number tag is present")
  parse-fen(starting-fen)
}

/// The chess variant of a game, recognised from the PGN `Variant` tag:
/// `"chess960"` for `[Variant "Chess960"]` / `[Variant "Fischerrandom"]` (and
/// spelling/spacing variants like `"Fischer Random"`), otherwise `"standard"`.
/// Not an engine switch — Chess960 games use the same rules engine; only the
/// start position and (generalised) castling differ.
///
/// - game (dictionary): a parsed game (from `game`).
/// -> str
#let game-variant(game) = {
  let v = game.tags.at("Variant", default: none)
  if v == none { return "standard" }
  let norm = lower(v).replace(regex("[^a-z0-9]"), "")
  if norm == "chess960" or norm == "fischerrandom" or norm == "fischerandom" { "chess960" } else { "standard" }
}

/// The mainline of a game as an array of SAN strings (the game as played).
///
/// - game (dictionary): a parsed game (from `game`).
/// -> array
#let mainline(game) = movetext(game).map(n => n.san)

/// The game result token: `"1-0"`, `"0-1"`, `"1/2-1/2"`, or `"*"`.
///
/// - game (dictionary): a parsed game (from `game`).
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
// pure call by its arguments, so repeated `_position-after` (or `board`/`diagram`
// drawn with `at:`) calls on the SAME game reuse this list instead of
// re-walking from the start every time --
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
/// The returned position is a plain position, identical to drawing it directly:
/// it carries no memory of the move it came from. To have `board`/`diagram`
/// draw that move's `%cal` / `%csl` annotations and its move-quality badge, hand
/// them the *game* itself together with `at:` (e.g. `diagram(game, at: locator)`)
/// rather than pre-resolving the position here.
///
/// - game (dictionary): a parsed game (from `game`).
/// - at (str, dictionary): the locator — a mainline `"30w"` / `"30b"`, or a
///   variation path dict `(line: (..hops..), at: "<move>")` — required.
/// -> dictionary
#let _position-after(game, at: none) = {
  assert(at != none, message: "_position-after: `at` is required")
  let locator = at
  let loc = if type(locator) == str { (line: (), at: locator) } else { locator }
  let start = game-start(game)

  // Fast path: a pure mainline locator just indexes into the (memoised) mainline
  // positions -- no re-walking, no extra generator runs across diagrams.
  if loc.at("line", default: ()).len() == 0 {
    let all = _mainline-positions(game)
    let target = _ply-of(loc.at("at"), start: start)
    assert(target >= 0 and target < all.len(), message: "locator out of range: addressed move past end of line")
    return all.at(target)
  }

  // Variations: walk the (nested) sub-lines. Not fast-tracked, but the common
  // mainline case above is.
  let line = movetext(game)
  let branch-ply = 1
  let pos = start

  for hop in loc.at("line", default: ()) {
    let target = _ply-of(hop.at("at"), start: start)
    let k = target - branch-ply // moves before the branch point
    assert(k >= 0 and k < line.len() + 1, message: "locator hop out of range at " + hop.at("at"))
    pos = _advance(pos, line, k)
    let node = line.at(k)
    let vars = node.at("variations", default: ())
    let into = hop.at("into", default: 0)
    assert(into < vars.len(), message: "no variation #" + str(into) + " at move " + hop.at("at"))
    line = vars.at(into)
    branch-ply = target
  }

  let target = _ply-of(loc.at("at"), start: start)
  let k = target - branch-ply + 1 // inclusive of the addressed move
  assert(k >= 0 and k <= line.len(), message: "locator out of range: addressed move past end of line")
  _advance(pos, line, k)
}


/// The full move node addressed by `locator` — its SAN plus `nags`, comments
/// (`comment-before` / `comment-after`) and `variations`. Used e.g. to recover
/// PGN `%cal` / `%csl` annotations for a diagram.
///
/// - game (dictionary): a parsed game (from `game`).
/// - at (str, dictionary): the locator — a mainline `"30w"` / `"30b"`, or a
///   variation path dict — required.
/// -> dictionary
#let move-node(game, at: none) = {
  assert(at != none, message: "move-node: `at` is required")
  let locator = at
  let loc = if type(locator) == str { (line: (), at: locator) } else { locator }
  let start = game-start(game)
  let line = movetext(game)
  let branch-ply = 1
  for hop in loc.at("line", default: ()) {
    let target = _ply-of(hop.at("at"), start: start)
    let k = target - branch-ply
    let node = line.at(k)
    line = node.at("variations").at(hop.at("into", default: 0))
    branch-ply = target
  }
  let k = _ply-of(loc.at("at"), start: start) - branch-ply
  assert(k >= 0 and k < line.len(), message: "move-node: locator addresses a move past the end of its line")
  line.at(k)
}

// The position BEFORE the move addressed by `locator`, resolved against its
// SAN — the shared derivation behind both `move-destination` and `move-at`'s
// engine half, so there is one walk of the game tree, not two.
//
// - game (dictionary): a parsed game (from `game`).
// - locator (str, dictionary): a mainline `"30w"` / `"30b"`, or a variation
//   path dict `(line: (..hops..), at: "<move>")`.
// -> dictionary — the resolved move (`from`/`to`/`piece`/`color`/`capture`/
//   `kind`/`promotion`, as `san-to-move` gives).
#let _resolved-move(game, locator) = {
  let loc = if type(locator) == str { (line: (), at: locator) } else { locator }
  let start = game-start(game)
  let before = none
  let san = none
  // Mainline fast path: the position before ply p is the (memoised) position at
  // ply p-1; the SAN is that node's.
  if loc.at("line", default: ()).len() == 0 {
    let all = _mainline-positions(game)
    let target = _ply-of(loc.at("at"), start: start)
    assert(target >= 1 and target < all.len(), message: "move-destination: locator out of range")
    before = all.at(target - 1)
    san = movetext(game).at(target - 1).san
  } else {
    // Variations: walk to the branch line (as _position-after does), then advance
    // to just before the addressed move.
    let line = movetext(game)
    let branch-ply = 1
    let pos = start
    for hop in loc.at("line", default: ()) {
      let target = _ply-of(hop.at("at"), start: start)
      let k = target - branch-ply
      pos = _advance(pos, line, k)
      line = line.at(k).at("variations").at(hop.at("into", default: 0))
      branch-ply = target
    }
    let k = _ply-of(loc.at("at"), start: start) - branch-ply
    assert(k >= 0 and k < line.len(), message: "move-destination: locator addresses a move past the end of its line")
    before = _advance(pos, line, k)
    san = line.at(k).san
  }
  san-to-move(before, san)
}

/// The destination square (e.g. `"e5"`, or the king's `"g1"` for `O-O`) of the
/// move addressed by `locator`. Resolves the move's SAN against the position
/// *before* it, so it works for captures, castling and promotions. Standard-chess
/// only (uses the rules engine). Used to place the move-quality badge.
///
/// - game (dictionary): a parsed game (from `game`).
/// - locator (str, dictionary): a mainline `"30w"` / `"30b"`, or a variation
///   path dict `(line: (..hops..), at: "<move>")`.
/// -> str
#let move-destination(game, locator) = _resolved-move(game, locator).to

/// The move-quality badge data for the move at `locator`: a dict
/// `(square: <dest>, symbol: <! ? !! ?? !? ?!>)`, or `none` when the move carries
/// no quality mark. The symbol is sourced from the move's first quality NAG
/// (`$1`..`$6`, whether parsed from the PGN's SAN suffix, an explicit `$n`, or
/// set with `with-nags`). Other NAGs (position evals like `$14`) are ignored.
/// Used to place the badge; standard-chess only.
///
/// - game (dictionary): a parsed game (from `game`).
/// - locator (str, dictionary): a mainline `"30w"` / `"30b"`, or a variation
///   path dict `(line: (..hops..), at: "<move>")`.
/// -> dictionary | none
#let move-quality-mark(game, locator) = {
  let node = move-node(game, at: locator)
  let symbol = none
  for ng in node.at("nags", default: ()) {
    if quality-nag-codes.contains(ng) { symbol = nag-symbol(ng); break }
  }
  if symbol == none { return none }
  (square: move-destination(game, locator), symbol: symbol)
}

// ---------------------------------------------------------------------------
// Move record
//
// `move-at` is the single public MOVE RECORD, the union of what the movetext
// node (`move-node`) and the engine (via `_resolved-move`) each know about a
// move, plus what's derived from those (`move-quality-mark`,
// `interpret-comment`). It is what `board`/`diagram` derive their overlay from
// when handed a game directly via `at:` (see `_resolve-at-source` in
// lib.typ), and it travels as its OWN value from there to the drawing seam —
// never attached to a position (earlier designs stashed it on the position as
// `_origin`, which meant a position could carry a badge with no game in the
// caller's hand at all — a category error this closes: a badge is now
// reachable only by handing over the game).
//
// `tags` is deliberately NOT part of the record — a roster belongs to the
// game, not to a move; callers that need it read `game.tags` directly.
///
/// The MOVE RECORD addressed by `at`: everything known about a single move,
/// from both the movetext (SAN, `nags`, `comment-before`/`comment-after`,
/// `variations`) and the rules engine (`from`/`to`/`piece`/`color`/`capture`/
/// `kind`/`promotion`, resolved against the position *before* the move), plus
/// what's derived from those (`quality`, `arrows`, `highlights`). Standard-chess
/// only (uses the rules engine).
///
/// - game (dictionary): a parsed game (from `game`).
/// - at (str, dictionary): the locator — a mainline `"30w"` / `"30b"`, or a
///   variation path dict `(line: (..hops..), at: "<move>")` — required.
/// -> dictionary | none — `none` for ply 0 (the position before any move).
#let move-at(game, at: none) = {
  assert(at != none, message: "move-at: `at` is required")
  let locator = at
  // Ply 0 is the position BEFORE any move — a legitimate thing to address, and
  // the one in-range locator with no move behind it. There is nothing to derive,
  // so it gets `none` rather than a panic out of `move-node` (which would
  // report the misleading "past the end of its line"). Genuinely out-of-range
  // locators still error, and with the right message: `_position-after` runs first
  // and asserts on them before we get here.
  let loc-at = if type(locator) == str { locator } else { locator.at("at") }
  if _ply-of(loc-at, start: game-start(game)) == 0 { return none }
  let node = move-node(game, at: locator)
  let mv = _resolved-move(game, locator)
  let anno = interpret-comment(node.at("comment-after", default: none))
  (
    san: node.san,
    nags: node.at("nags", default: ()),
    comment-before: node.at("comment-before", default: none),
    comment-after: node.at("comment-after", default: none),
    variations: node.at("variations", default: ()),
    from: mv.from,
    to: mv.to,
    piece: mv.piece,
    color: mv.color,
    capture: mv.capture,
    kind: mv.kind,
    promotion: mv.promotion,
    quality: move-quality-mark(game, locator),
    arrows: anno.arrows,
    highlights: anno.highlights,
    locator: locator,
  )
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
#let _update-in-line(line, branch-ply, hops, final, f, start: _default-start) = {
  if hops.len() == 0 {
    let k = _ply-of(final, start: start) - branch-ply
    assert(k >= 0 and k < line.len(), message: "locator addresses a move past the end of its line: " + final)
    line.at(k) = f(line.at(k))
    return line
  }
  let hop = hops.first()
  let target = _ply-of(hop.at("at"), start: start)
  let k = target - branch-ply
  assert(k >= 0 and k < line.len(), message: "locator hop out of range at " + hop.at("at"))
  let node = line.at(k)
  let vars = node.at("variations", default: ())
  let into = hop.at("into", default: 0)
  assert(into < vars.len(), message: "no variation #" + str(into) + " at move " + hop.at("at"))
  vars.at(into) = _update-in-line(vars.at(into), target, hops.slice(1), final, f, start: start)
  node.variations = vars
  line.at(k) = node
  line
}

// Update the node addressed by `locator` in the top-level `nodes` tree.
#let _update-node-at(nodes, locator, f, start: _default-start) = {
  let loc = if type(locator) == str { (line: (), at: locator) }
    else if type(locator) == dictionary { locator }
    else { panic("locator must be a mainline string or a path dict; got " + repr(locator)) }
  let final = loc.at("at", default: none)
  assert(final != none, message: "locator must address a move (its `at`)")
  _update-in-line(nodes, 1, loc.at("line", default: ()), final, f, start: start)
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
#let _norm-nag(v) = {
  if type(v) == str and v.starts-with("$") and v.len() > 1 { v.slice(1) }
  else if type(v) == str and v in glyph-to-nag { glyph-to-nag.at(v) }
  else { panic("with-nags: a NAG must be \"$n\" or one of ! ? !! ?? !? ?!; got " + repr(v)) }
}

/// Attach NAGs to addressed moves (mainline or inside variations), returning a
/// *new* game (the source is not mutated). Each value *replaces* that move's NAGs.
///
/// - game (dictionary): a parsed game (from `game`).
/// - nags (dictionary, array): the NAG map, as `(<locator>: <value>, ..)`, or
///   an array of `(locator, value)` pairs to reach moves inside variations —
///   required.
/// -> dictionary
#let with-nags(game, nags: none) = {
  assert(nags != none, message: "with-nags: `nags` is required")
  let overrides = nags
  assert(type(game) == dictionary and "movetext-raw" in game, message: "with-nags: first argument must be a parsed game (from game())")
  let nodes = movetext(game)
  let start = game-start(game)
  for (loc, val) in _overrides-pairs(overrides) {
    let codes = if type(val) == array { val.map(_norm-nag) } else { (_norm-nag(val),) }
    nodes = _update-node-at(nodes, loc, node => { node.nags = codes; node }, start: start)
  }
  _stash(game, nodes)
}

/// Attach text comments to addressed moves (mainline or inside variations),
/// returning a *new* game (the source is not mutated). Each comment *replaces* any
/// existing one and is set as the move's `comment-after` (what notation's
/// `comments` switch renders).
///
/// - game (dictionary): a parsed game (from `game`).
/// - comments (dictionary, array): the comment map, as `(<locator>: <text>, ..)`,
///   or an array of `(locator, text)` pairs to reach moves inside variations —
///   required.
/// -> dictionary
#let with-comments(game, comments: none) = {
  assert(comments != none, message: "with-comments: `comments` is required")
  let overrides = comments
  assert(type(game) == dictionary and "movetext-raw" in game, message: "with-comments: first argument must be a parsed game (from game())")
  let nodes = movetext(game)
  let start = game-start(game)
  for (loc, val) in _overrides-pairs(overrides) {
    assert(type(val) == str, message: "with-comments: a comment must be a string; got " + repr(type(val)))
    nodes = _update-node-at(nodes, loc, node => { node.insert("comment-after", val); node }, start: start)
  }
  _stash(game, nodes)
}

/// Add a line of moves to a game, returning a *new* game (the source is never
/// mutated). Which operation runs depends on `at`:
///
/// With `at` given, the moves are added as a variation (RAV) — an
/// *alternative* to the move at `at`, appended to that move's variations (its
/// `into` index is the previous count) and numbered from the move's ply at
/// render time.
///
/// With `at` omitted, the moves are appended to the *end of the mainline*,
/// continuing the game. The game's `result` (if decisive) is preserved
/// unchanged.
///
/// Legality is checked only if you later navigate into the line (e.g. by
/// drawing `board(game, at: ..)` on that variation, or on the continuation).
///
/// - game (dictionary): a parsed game (from `game`).
/// - at (none, str, dictionary): the move to branch at — a *mainline* locator
///   (`"3w"` / `"3b"`), or a *path* dict `(line: (..hops..), at: "<move>")` to
///   reach a move inside a (possibly nested) variation. If omitted (or given
///   as `none`), the moves continue the mainline instead of branching from it.
/// - moves (str, content): a PGN movetext fragment — a plain SAN run like
///   `"Bc4 Bc5"`, or richer text with nested `()`, `$n` NAGs and `{comments}`.
///   Must not contain a result token (`1-0`, `0-1`, `1/2-1/2`, `*`) — the
///   result is a game-level field carried from the source game.
/// -> dictionary
#let with-line(game, at: none, moves: none) = {
  assert(type(game) == dictionary and "movetext-raw" in game, message: "with-line: first argument must be a parsed game (from game())")
  assert(moves != none, message: "with-line: `moves` (a movetext fragment) is required")
  let text = if type(moves) == str { moves }
    else if type(moves) == content and moves.func() == raw { moves.text }
    else { panic("with-line: `moves` must be a movetext string or raw block; got " + repr(type(moves))) }
  assert(
    not _tokenize(text).any(t => t.type == "result"),
    message: "with-line: `moves` must not contain a result token (1-0, 0-1, 1/2-1/2, *) — "
      + "the result is a game-level field carried from the source game, not part of `moves:`",
  )
  let sub = _normalize-nodes(_movetext-tree(text), game.lang)
  assert(sub.len() > 0, message: "with-line: `moves` produced no moves")
  if at == none {
    _stash(game, movetext(game) + sub)
  } else {
    let nodes = _update-node-at(movetext(game), at, node => {
      let vars = node.at("variations", default: ())
      vars.push(sub)
      node.variations = vars
      node
    }, start: game-start(game))
    _stash(game, nodes)
  }
}
