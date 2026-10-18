// ===========================================================================
// PGN parsing (Phase A: cheap, eager, no engine).
//
// `games(input)` -> array of `game` dicts. One PGN string may contain many
// games. Parsing is LAZY in the movetext: `games` eagerly extracts the
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

#import "annotations.typ": glyph-to-nag, quality-nag-codes
#import "i18n.typ": notation-langs, normalize-san

// Split a trailing run of `!`/`?` off a SAN token, but ONLY when the ENTIRE
// run is exactly one of the six recognised glyphs (! ? !! ?? !? ?!) AND
// something remains in front of it -- e.g. "Nf6??" -> ("Nf6", "??"),
// "Qh7#!!" -> ("Qh7#", "!!"), "Nf3" -> ("Nf3", ""). Anything else (a longer
// or unrecognised run like "!!!" or "?!?", or a standalone glyph token with
// nothing in front) is left COMPLETELY untouched -- parsing stays lossless
// per docs/manual.typ rather than guessing at a partial strip that would
// produce a nonsense SAN. A trailing `+`/`#` is part of SAN proper and is
// never touched (the run only ever consumes `!`/`?`).
#let _split-quality-suffix(san) = {
  let s = san
  let suf = ""
  while s.len() > 0 and ("!", "?").contains(s.slice(s.len() - 1)) {
    suf = s.slice(s.len() - 1) + suf
    s = s.slice(0, s.len() - 1)
  }
  if s.len() > 0 and suf in glyph-to-nag { (san: s, suffix: suf) }
  else { (san: san, suffix: "") }
}

// Finalize a move node once it's fully assembled (no more NAGs will be added):
// resolve the pending suffix-derived quality NAG against any EXPLICIT quality
// NAG ($1..$6) already collected. An explicit NAG wins and the suffix glyph is
// discarded (never doubled); otherwise the suffix's code is inserted at the
// front of `nags`, so it renders before positional-assessment NAGs.
#let _finalize-quality-nag(node) = {
  let suf-code = node.at("_suffix-nag", default: none)
  let nags = node.nags
  if suf-code != none and not nags.any(c => quality-nag-codes.contains(c)) {
    nags = (suf-code,) + nags
  }
  (
    san: node.san,
    nags: nags,
    comment-before: node.comment-before,
    comment-after: node.comment-after,
    variations: node.variations,
  )
}

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
// (Tags never appear here -- they are split off eagerly in games().)
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
  // Highest WHITE move number seen on this line, to catch two games that ran
  // together with neither a roster nor a result to separate them (the one case
  // no separator can detect: "1. e4 e5\n\n1. d4 d5" is a legal-looking line in
  // which d4 becomes White's third move).
  //
  // Suspicious = the number DROPS, or returns to 1. A plain REPEAT above 1 is
  // deliberately allowed: `2. Nf3 (2. d4) 2. Nc6` writes Black's move number
  // without the ellipsis PGN asks for, which is non-standard but common in
  // exported and hand-edited files. Rejecting it would hard-error a document
  // that used to render -- a false positive is worse here than the silent
  // merge we are guarding against, because it has no workaround short of
  // editing the source. `1. e4 1. e5` in that style is genuinely ambiguous
  // with two concatenated games, and is read as the latter.
  //
  // Only `N.` counts -- `N...` is a black-continuation marker, legitimately
  // repeating the number after a variation, and variations restart numbering
  // by design (hence `top` only).
  let last-white = none

  while i < n {
    let t = toks.at(i)
    if t.type == "result" {
      result = t.value
      i += 1
      break
    } else if t.type == "num" {
      if top {
        let digits = t.value.replace(".", "")
        if t.value.len() - digits.len() == 1 {
          let num = int(digits)
          // Not `assert(..)`: its `message:` argument is evaluated EAGERLY, on
          // every passing call too, which both costs a string build per move
          // number and would `str(none)`-error on the very first one.
          if last-white != none and (num < last-white or num == 1) {
            panic(
              "malformed PGN: movetext goes back to move " + str(num) + " after move "
                + str(last-white) + " has already been played. Two games appear to have run "
                + "together: separate them by terminating each game with a result token "
                + "(1-0, 0-1, 1/2-1/2, *) or by giving each one a tag roster.",
            )
          }
          last-white = num
        }
      }
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
      if cur != none { nodes.push(_finalize-quality-nag(cur)) }
      let split = _split-quality-suffix(t.value)
      cur = (
        san: split.san,
        nags: (),
        comment-before: pending-comment,
        comment-after: none,
        variations: (),
        _suffix-nag: glyph-to-nag.at(split.suffix, default: none),
      )
      pending-comment = none
      i += 1
    } else {
      i += 1
    }
  }
  // Flush the last move being assembled (covers every exit: result, close, EOF).
  if cur != none { nodes.push(_finalize-quality-nag(cur)) }
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

// Recursively convert every node's `san` (mainline and nested variations) from
// `lang` to canonical English SAN, so nothing downstream of `movetext(..)` ever
// sees a language. Pure (memoisable): a fresh dict per node/variation, keyed off
// the same inputs each call.
#let _normalize-nodes(nodes, lang) = {
  nodes.map(node => (
    san: normalize-san(node.san, lang),
    nags: node.nags,
    comment-before: node.comment-before,
    comment-after: node.comment-after,
    variations: node.variations.map(v => _normalize-nodes(v, lang)),
  ))
}

/// The parsed movetext tree (an array of move nodes) of a game — the mainline
/// spine with recursive `variations`. Built on demand from the game's raw
/// movetext and memoised, so deeper structure errors (e.g. a `(` without a
/// preceding move) surface here. Every node's `san` is normalized from
/// `game.lang` to canonical English SAN, so downstream code (engine, to-fen,
/// notation, export) never sees a language.
///
/// - game (dictionary): a parsed game (from `game`).
/// -> array
#let movetext(game) = {
  // A game patched by the builders (`with-nags` / `with-comments` /
  // `with-line`, game.typ) carries a precomputed node tree (already in
  // canonical English SAN); honour it so the change flows through every consumer
  // (notation, _position-after, ...). Unpatched games build (and memoise) from the
  // raw text, then normalize.
  let pre = game.at("movetext-nodes", default: none)
  if pre != none { pre } else { _normalize-nodes(_movetext-tree(game.movetext-raw), game.lang) }
}

// ---- normalise input (string or raw block) -------------------------------
#let _as-text(input) = {
  if type(input) == str { input }
  else if type(input) == content and input.func() == raw { input.text }
  else { panic("games: expected a string or a raw block (`#raw(..)` or ```...```), got " + repr(type(input))) }
}

/// Parse PGN text into an array of games. The roster (tags) is optional — bare
/// movetext like `1. e4 e5 *` parses fine and yields `tags: (:)`. The roster,
/// result, and the verbatim movetext substring are extracted eagerly; the move
/// tree is parsed lazily on first use via `movetext(game)`, so a document that
/// shows only a few positions never parses the rest. Always returns an array,
/// even for a single game — use `game(input)` when you know there is exactly one.
///
/// Games are separated by a *tag roster* or by a *result token* (`1-0`, `0-1`,
/// `1/2-1/2`, `*`); blank lines are not separators. A game whose move numbers
/// stop increasing is rejected rather than silently merged into the next one
/// — give each game a result token or a roster.
///
/// - input (str, content): the PGN source — a string, or a raw block
///   (```` ```…``` ````) / `#raw(..)`.
/// - lang (str): the language of the movetext's piece letters (e.g. `"de"` for
///   German `S` = knight). Never auto-detected -- see the manual. `movetext(game)`
///   converts to canonical English SAN using this code; the language is never
///   read again downstream.
/// -> array
#let games(input, lang: "en") = {
  assert(
    notation-langs.keys().contains(lang),
    message: "games: unknown language code \"" + lang + "\"; supported: " + notation-langs.keys().join(", "),
  )
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
  let out = ()
  let i = 0
  let prev-start = 0   // movetext start of the last game pushed (for trailer merges)

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

    // --- movetext: tokens up to the next roster tag, a result token, or EOF ---
    // We do not build the tree here; we only need the verbatim span, the result,
    // and an eager top-level paren-balance check (so a stray ')' fails at parse
    // time, matching the documented contract).
    //
    // A top-level result token TERMINATES the game, so bare (roster-less)
    // multi-game input splits too. A result inside a variation does not -- it is
    // malformed PGN, and stays the tree parser's error to report. A result inside
    // a comment is invisible here, because `{..}` tokenises as a single token.
    let mv-start = if i < n { ms.at(i).start } else { 0 }
    let mv-end = s.len()
    let last-end = none
    let depth = 0
    let result = none
    // Does this span hold anything that could be a MOVE? Used only to decide
    // whether a span is a game at all (see the trailer merge below); once true
    // we stop classifying, so the cost is a few tokens per game, not per token.
    let has-move = false
    while i < n and not ms.at(i).text.starts-with("[") {
      let t = ms.at(i).text
      if t == "(" { depth += 1 }
      else if t == ")" {
        assert(depth > 0, message: "malformed PGN: unexpected ')' outside a variation")
        depth -= 1
      } else if depth == 0 and _results.contains(t) {
        result = t
        last-end = ms.at(i).end
        i += 1
        break
      } else if not has-move and not t.starts-with("{") and not t.starts-with(";") and not t.starts-with("$") and t.match(_num-re) == none {
        has-move = true
      }
      last-end = ms.at(i).end
      i += 1
    }
    if i < n and ms.at(i).text.starts-with("[") { mv-end = ms.at(i).start }
    else if last-end != none { mv-end = last-end }

    let raw = if last-end == none { "" } else { s.slice(mv-start, mv-end).trim() }

    // A span with no roster AND no move is not a game -- it is a TRAILER: a
    // closing comment, a `;` banner, a stray duplicate result. Splitting on a
    // result token would otherwise turn every such tail into a phantom game,
    // and `game()` would reject an ordinary file that merely ends in a comment.
    // Merge it back into the game it follows, so movetext-raw stays verbatim.
    if tags.len() == 0 and not has-move and out.len() > 0 {
      let prev = out.pop()
      prev.movetext-raw = s.slice(prev-start, mv-end).trim()
      if result != none and prev.result == "*" { prev.result = result }
      out.push(prev)
      continue
    }
    prev-start = mv-start

    out.push((
      tags: tags,
      movetext-raw: raw,
      result: if result != none { result } else { tags.at("Result", default: "*") },
      lang: lang,
    ))
  }

  assert(out.len() > 0, message: "no games found in PGN input")
  out
}

/// Parse PGN text that holds exactly one game, and return that game's dictionary
/// directly (not wrapped in an array). The roster (tags) is optional, same as
/// `games(input)`. Errors if the input holds more than one game — use
/// `games(input)` to get all of them in that case.
///
/// - input (str, content): the PGN source — a string, or a raw block
///   (```` ```…``` ````) / `#raw(..)`.
/// - lang (str): the language of the movetext's piece letters; see `games`.
/// -> dictionary
#let game(input, lang: "en") = {
  let gs = games(input, lang: lang)
  assert(
    gs.len() == 1,
    message: "game(): input contains " + str(gs.len()) + " games; use games() to get all of them, or pass a single game",
  )
  gs.first()
}

