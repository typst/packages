// ===========================================================================
// PGN parsing (Phase A: cheap, eager, no engine).
//
// `parse-pgn(input)` -> array of `game` dicts. One PGN string may contain many
// games. Parsing is LAZY in the movetext: `parse-pgn` eagerly extracts the
// roster (tags) and the verbatim movetext SUBSTRING per game, but does NOT build
// the move TREE. The tree (mainline spine plus recursive `variations`) is parsed
// on demand by `movetext(game)` -- memoised -- so:
//   * a tournament file read only for results/standings never tokenises movetext
//     (just the cheap roster scan), and
//   * extracting ONE game's moves out of a multi-game file parses only that
//     game's substring, not all of them.
// Engine resolution (resolved moves + positions) happens later still, in game.typ.
//
// Errors are HARD. Roster errors (malformed tag pairs, unterminated comments/
// tags) and a stray top-level ')' are caught EAGERLY at parse time. Deeper
// movetext-structure errors surface when `movetext(game)` is first called.
//
// A `game` is: (tags: dict, movetext-raw: str, result: str)
//   - movetext-raw: the game's movetext verbatim (comments/variations/NAGs and
//     all), available for direct inspection without parsing.
// A move `node` (from `movetext(game)`) is:
//   (san, nags: array, comment-before: none|str, comment-after: none|str,
//    variations: array<array<node>>)
// ===========================================================================

#let _results = ("1-0", "0-1", "1/2-1/2", "*")

// ---- token regexes (compiled ONCE, module level) --------------------------
// Master pattern alternatives (leftmost match wins, so a comment swallows any
// brackets it contains):
//   \[[^\]]*\]   tag      \{[^}]*\}   brace comment    ;[^\n]*   line comment
//   [()]         paren    [^\s()\[\]{};]+   word (san / nag / move number / result)
#let _token-re = regex("\[[^\]]*\]|\{[^}]*\}|;[^\n]*|[()]|[^\s()\[\]{};]+")
// Per-word classifiers, hoisted out of the tokenise loop (compiling these once
// instead of per token is a large win on big files).
#let _num-re = regex("^[0-9]+\.+$")
#let _glue-re = regex("^([0-9]+\.+)(.+)$")
#let _tag-re = regex("^\s*([A-Za-z0-9_]+)\s+\"(.*)\"\s*$")

// Normalise line endings; drop a leading BOM so it isn't read as a token.
#let _normalise(input) = input.replace("\r\n", "\n").replace("\r", "\n").replace("\u{feff}", "")

// ---- movetext tokeniser (per game, used lazily) ---------------------------
// Turns a movetext SUBSTRING into the token stream the tree parser consumes.
// (Tags never appear here -- they are split off eagerly in parse-pgn.)
#let _tokenize(s) = {
  let toks = ()
  for m in s.matches(_token-re) {
    let t = m.text
    if t.starts-with("{") {
      toks.push((type: "comment", value: t.slice(1, t.len() - 1)))
    } else if t.starts-with(";") {
      toks.push((type: "comment", value: t.slice(1).trim()))
    } else if t == "(" {
      toks.push((type: "open"))
    } else if t == ")" {
      toks.push((type: "close"))
    } else if t.starts-with("$") {
      toks.push((type: "nag", value: t.slice(1)))
    } else if _results.contains(t) {
      toks.push((type: "result", value: t))
    } else if t.match(_num-re) != none {
      toks.push((type: "num", value: t))
    } else {
      // possibly a move number glued to a move, e.g. "12.e4" or "12...Nf6"
      let g = t.match(_glue-re)
      if g != none {
        toks.push((type: "num", value: g.captures.at(0)))
        let rest = g.captures.at(1)
        if _results.contains(rest) { toks.push((type: "result", value: rest)) }
        else { toks.push((type: "san", value: rest)) }
      } else {
        toks.push((type: "san", value: t))
      }
    }
  }
  toks
}

// ---- recursive movetext parser -------------------------------------------
// Returns (nodes, next, result). `top` = top level (stop at result/next-tag/EOF);
// otherwise a variation (stop at the matching close paren).
//
// The move currently being assembled is held in the local `cur` and pushed to
// `nodes` only once it is complete (at the next move / close / result / EOF).
// Comments, NAGs and variations are therefore attached by mutating `cur` in
// place, instead of the old read-modify-write on `nodes.last()` (copy the dict
// out, edit it, write it back) -- fewer dict copies per token.
#let _parse-movetext(toks, start, n, top) = {
  let nodes = ()
  let i = start
  let result = none
  let pending-comment = none   // comment(s) before the FIRST move of this line
  let cur = none               // the move being assembled, or none before the first

  while i < n {
    let t = toks.at(i)
    if t.type == "result" {
      result = t.value
      i += 1
      break
    } else if t.type == "num" {
      i += 1
    } else if t.type == "comment" {
      if cur != none {
        cur.comment-after = if cur.comment-after == none { t.value } else { cur.comment-after + " " + t.value }
      } else {
        pending-comment = t.value
      }
      i += 1
    } else if t.type == "nag" {
      if cur != none { cur.nags.push(t.value) }
      i += 1
    } else if t.type == "open" {
      assert(cur != none, message: "malformed PGN: variation '(' without a preceding move")
      let sub = _parse-movetext(toks, i + 1, n, false)
      cur.variations.push(sub.nodes)
      i = sub.next
    } else if t.type == "close" {
      assert(not top, message: "malformed PGN: unexpected ')' outside a variation")
      i += 1
      break
    } else if t.type == "san" {
      if cur != none { nodes.push(cur) }
      cur = (
        san: t.value,
        nags: (),
        comment-before: pending-comment,
        comment-after: none,
        variations: (),
      )
      pending-comment = none
      i += 1
    } else {
      i += 1
    }
  }
  // Flush the last move being assembled (covers every exit: result, close, EOF).
  if cur != none { nodes.push(cur) }
  (nodes: nodes, next: i, result: result)
}

// ---- lazy movetext accessor ----------------------------------------------
// Parse a game's verbatim movetext substring into the move-node tree. Pure, so
// Typst memoises it: repeated calls for the same game (same raw string) reuse the
// result, and a game whose movetext is never touched is never parsed.
#let _movetext-tree(raw) = {
  let toks = _tokenize(raw)
  _parse-movetext(toks, 0, toks.len(), true).nodes
}

/// The parsed movetext tree (an array of move nodes) of a game — the mainline
/// spine with recursive `variations`. Built on demand from the game's raw
/// movetext and memoised, so deeper structure errors (e.g. a `(` without a
/// preceding move) surface here.
///
/// - game (dictionary): a parsed game (from `parse-pgn`).
/// -> array
#let movetext(game) = {
  // A game patched by the builders (`with-nags` / `with-comments` /
  // `with-variation`, game.typ) carries a precomputed node tree; honour it so the
  // change flows through every consumer (notation, position-after, ...). Unpatched
  // games build (and memoise) from the raw text.
  let pre = game.at("movetext-nodes", default: none)
  if pre != none { pre } else { _movetext-tree(game.movetext-raw) }
}

// ---- normalise input (string or raw block) -------------------------------
#let _as-text(input) = {
  if type(input) == str { input }
  else if type(input) == content and input.func() == raw { input.text }
  else { panic("parse-pgn: expected a string or a raw block (`#raw(..)` or ```...```), got " + repr(type(input))) }
}

/// Parse PGN text into an array of games. The roster (tags), result, and the
/// verbatim movetext substring are extracted eagerly; the move tree is parsed
/// lazily on first use via `movetext(game)`, so a document that shows only a few
/// positions never parses the rest.
///
/// - input (str, content): the PGN source — a string, or a raw block
///   (```` ```…``` ````) / `#raw(..)`.
/// -> array
#let parse-pgn(input) = {
  let s = _normalise(_as-text(input))

  // Unterminated tag / comment: an opener with no closer before end-of-input.
  // (End-anchored, so a `[`/`{` that IS closed later never matches.)
  assert(s.match(regex("\{[^}]*$")) == none, message: "malformed PGN: unterminated comment (missing '}')")
  assert(s.match(regex("\[[^\]]*$")) == none, message: "malformed PGN: unterminated tag (missing ']')")

  // One master-regex scan over the whole file, WITH positions. We use it only to
  // split games (roster vs movetext spans); movetext is sliced out verbatim and
  // parsed later. Comment-safe: a `{...}` or `[%evp ...]` inside movetext is one
  // token, so it can never be mistaken for a roster tag.
  let ms = s.matches(_token-re)
  let n = ms.len()
  let games = ()
  let i = 0

  while i < n {
    // --- roster: a leading run of tag tokens ---
    let tags = (:)
    while i < n and ms.at(i).text.starts-with("[") {
      let full = ms.at(i).text
      let inner = full.slice(1, full.len() - 1)   // "[" and "]" are 1 byte each
      let tm = inner.match(_tag-re)
      assert(tm != none, message: "malformed PGN tag pair: [" + inner + "]")
      tags.insert(tm.captures.at(0), tm.captures.at(1))
      i += 1
    }

    // --- movetext: tokens up to the next roster tag (or EOF) ---
    // We do not build the tree here; we only need the verbatim span, the result,
    // and an eager top-level paren-balance check (so a stray ')' fails at parse
    // time, matching the documented contract).
    let mv-start = if i < n { ms.at(i).start } else { 0 }
    let mv-end = s.len()
    let last-end = none
    let depth = 0
    let result = none
    while i < n and not ms.at(i).text.starts-with("[") {
      let t = ms.at(i).text
      if t == "(" { depth += 1 }
      else if t == ")" {
        assert(depth > 0, message: "malformed PGN: unexpected ')' outside a variation")
        depth -= 1
      } else if _results.contains(t) { result = t }
      last-end = ms.at(i).end
      i += 1
    }
    if i < n { mv-end = ms.at(i).start }
    else if last-end != none { mv-end = last-end }

    let raw = if last-end == none { "" } else { s.slice(mv-start, mv-end).trim() }

    games.push((
      tags: tags,
      movetext-raw: raw,
      result: if result != none { result } else { tags.at("Result", default: "*") },
    ))
  }

  assert(games.len() > 0, message: "no games found in PGN input")
  games
}
