// ===========================================================================
// Human-readable move notation.
//
// Games carry SAN strings verbatim from the PGN (canonical English: "Nf3",
// "O-O", "exd5", "e8=Q+"). So figurine output and language-aware piece letters
// are a pure STRING TRANSFORM on existing SAN -- no engine needed. (Generating
// SAN from positions/moves would need a move->SAN encoder, which does not exist
// yet; this module only FORMATS SAN we already hold.)
//
// `notation` is the variant-agnostic formatter. The public, variant-named sugar
// `chess-notation` (mirroring board/diagram, chess-moves) lives in lib.typ, layered
// on top so it can also embed diagrams. A future `xiangqi-notation` would be a
// different formatter entirely.
//
// Source forms (consistent with `chess-moves`):
//   * a parsed game            -> its mainline SAN;
//   * a move-text string       -> tokenised with `_split-movetext`;
//   * a SAN array              -> used directly.
// `from`/`to` are diagram-after-style mainline locators ("12w"/"12b"), inclusive;
// defaults are first/last move. (Variation-line ranges are not supported yet.)
// ===========================================================================

#import "san.typ": _split-movetext
#import "pgn.typ": movetext
#import "i18n.typ": notation-langs, lang-piece-chars
#import "game.typ": mainline, game-result
#import "annotations.typ": interpret-comment, nag-symbol
#import "style.typ": default-pgn-style, pgn-style-state

// The only uppercase letters that denote a piece in SAN -> kind. Files (a-h),
// ranks, "x", "+", "#", "O-O" and NAGs are never piece letters and pass through.
#let _letter-to-kind = (K: "king", Q: "queen", R: "rook", B: "bishop", N: "knight")

// Figurine glyphs are color-aware: White's moves use the OUTLINE ("white")
// chess symbols U+2654..2658, Black's the SOLID ("black") ones U+265A..265E, so
// the side to move reads off the figurine itself (not just the move number).
// (Some fonts render the outline glyphs lighter than the solid ones.)
#let _fig-white = (king: "\u{2654}", queen: "\u{2655}", rook: "\u{2656}", bishop: "\u{2657}", knight: "\u{2658}")
#let _fig-black = (king: "\u{265A}", queen: "\u{265B}", rook: "\u{265C}", bishop: "\u{265D}", knight: "\u{265E}")

// "12w" -> ply 23 ; "12b" -> ply 24 (same convention as game.typ locators).
#let _ply-of(loc) = {
  assert(type(loc) == str and loc.len() >= 2, message: "notation: bad move locator: " + repr(loc))
  let color = loc.slice(loc.len() - 1)
  let num = int(loc.slice(0, loc.len() - 1))
  if color == "w" { 2 * num - 1 } else if color == "b" { 2 * num }
  else { panic("notation: move locator must end in 'w' or 'b': " + loc) }
}

// One piece letter rendered as the language letter, or the color-aware figurine
// glyph (`white` selects the outline vs solid set).
#let _piece-out(letter, chars, figurine, white) = {
  let kind = _letter-to-kind.at(letter)
  if figurine { (if white { _fig-white } else { _fig-black }).at(kind) }
  else { chars.at(kind) }
}

// Transform one canonical (English) SAN token: substitute the leading piece
// letter and any promotion letter (after "="); leave everything else untouched.
// `white` is the side that played the move (for color-aware figurines).
#let _localize-san(san, chars, figurine, white) = {
  if san == "" { return "" }
  let cs = san.clusters()
  let out = ""
  let i = 0
  if _letter-to-kind.keys().contains(cs.at(0)) {
    out += _piece-out(cs.at(0), chars, figurine, white)
    i = 1
  }
  while i < cs.len() {
    let ch = cs.at(i)
    if ch == "=" and i + 1 < cs.len() and _letter-to-kind.keys().contains(cs.at(i + 1)) {
      out += "=" + _piece-out(cs.at(i + 1), chars, figurine, white)
      i += 2
    } else {
      out += ch
      i += 1
    }
  }
  out
}

// Wrap a SAN string into a minimal move node (no nags/comments).
#let _bare-node(san) = (san: san, nags: (), comment-after: none)

// Resolve a source + from/to into (nodes, lo, hi) inclusive node indices. A game
// yields its real move nodes (carrying nags/comments); a SAN string/array yields
// bare nodes (so nags/comments are simply empty there).
#let _resolve-line(source, from, to) = {
  for loc in (from, to) {
    if loc != none and type(loc) != str {
      panic("notation: variation-line ranges are not supported yet; use mainline locators like \"12w\"")
    }
  }
  let nodes = if type(source) == str { _split-movetext(source).map(_bare-node) }
    else if type(source) == array {
      // A SAN array must hold move strings. The classic slip is passing
      // `parse-pgn(..)` (an ARRAY of games) instead of one game -- catch it with a
      // clear message pointing at `.first()`, rather than crashing deep inside.
      if source.any(e => type(e) != str) {
        let looks-like-games = source.any(e => type(e) == dictionary and "movetext-raw" in e)
        panic("notation: a SAN array must contain move strings, but got a non-string element" + if looks-like-games { " -- this looks like the array of games from `parse-pgn`; did you forget `.first()`?" } else { "" })
      }
      source.map(_bare-node)
    }
    else if type(source) == content and source.func() == raw { _split-movetext(source.text).map(_bare-node) }
    else if type(source) == dictionary and "movetext-raw" in source { movetext(source) }
    else if type(source) == dictionary and "squares" in source {
      panic("notation: a position has no move history; pass a game or a SAN source (string/array)")
    } else {
      panic("notation: source must be a game, a SAN move-text string, or a SAN array")
    }
  if nodes.len() == 0 { return (nodes: (), lo: 0, hi: -1) }
  let lo = if from == none { 0 } else { _ply-of(from) - 1 }
  let hi = if to == none { nodes.len() - 1 } else { _ply-of(to) - 1 }
  assert(lo >= 0 and lo < nodes.len(), message: "notation: `from` locator out of range")
  assert(hi >= lo and hi < nodes.len(), message: "notation: `to` locator out of range, or before `from`")
  (nodes: nodes, lo: lo, hi: hi)
}

// One move's text: number prefix + localized SAN + (NAG glyphs) + (comment prose).
// `ply` is 1-based (ply 1 = White's 1st move); `force` re-shows the move number
// even for a Black move (after a run start, a variation, or a comment).
#let _move-token(node, ply, force, opts) = {
  let white = calc.odd(ply)
  let num = ""
  if opts.move-numbers {
    let movenum = int((ply + 1) / 2)
    // No space after the number (real-world publication style): "1.e4", "3...Bc5".
    if white { num = str(movenum) + "." }
    else if force { num = str(movenum) + "..." }
  }
  let tok = num + _localize-san(node.san, opts.chars, opts.figurine, white)
  if opts.nags {
    for ng in node.at("nags", default: ()) { tok += nag-symbol(ng) }
  }
  if opts.comments {
    let t = interpret-comment(node.at("comment-after", default: none)).text
    if t != "" { tok += " " + t }
  }
  tok
}

// Inline renderer: a run of nodes from `start-ply`, with variations (when
// `opts.variations`) spliced in parentheses. A variation attached to a node is an
// alternative to THAT move, so it starts at the same ply. Returns a string, or --
// when `bold` (the top-level mainline, not variations) -- content with the
// mainline moves in `strong`; variations always render normally (bold: false).
#let _render-inline(nodes, start-ply, opts, bold: false) = {
  let parts = ()
  let force = true
  let ply = start-ply
  for node in nodes {
    let tok = _move-token(node, ply, force, opts)
    parts.push(if bold { strong(tok) } else { tok })
    force = false
    let vars = node.at("variations", default: ())
    if opts.variations and vars.len() > 0 {
      for sub in vars { parts.push("(" + _render-inline(sub, ply, opts) + ")") }
      force = true   // resumed move re-shows its number
    }
    ply += 1
  }
  parts.join(" ")
}

// Block renderer: variations break onto their own line(s), indented one level per
// nesting depth AND wrapped in parentheses (like the inline style). Returns an
// array of (level, text) lines. A run's own moves sit at `level`; each nested
// variation recurses at `level + 1` with `wrap: true`. When `wrap` is set (a
// variation, not the mainline) the body is bracketed: "(" opens the first line;
// ")" closes the last OWN-level line, or stands on its own line at `level` when
// the variation ends with a (deeper) nested variation.
#let _block-lines(nodes, start-ply, level, wrap, opts) = {
  let lines = ()
  let buf = ()
  let force = true
  let ply = start-ply
  for node in nodes {
    buf.push(_move-token(node, ply, force, opts))
    force = false
    let vars = node.at("variations", default: ())
    if opts.variations and vars.len() > 0 {
      lines.push((level, buf.join(" ")))
      buf = ()
      for sub in vars { lines += _block-lines(sub, ply, level + 1, true, opts) }
      force = true
    }
    ply += 1
  }
  if buf.len() > 0 { lines.push((level, buf.join(" "))) }
  if wrap {
    let (l0, t0) = lines.first()
    lines.at(0) = (l0, "(" + t0)                        // open on the first line
    let (ln, tn) = lines.last()
    if ln == level { lines.at(lines.len() - 1) = (ln, tn + ")") }  // close on last own line
    else { lines.push((level, ")")) }                   // ...or a standalone close
  }
  lines
}

// Render indices [lo, hi] of `nodes` per `opts`, where `start-ply` is the ply of
// `nodes.at(lo)` (ply 1 for a mainline from the start; the branch ply for a
// variation sub-line). `tail` is an optional result token. `variation-style:
// "inline"` yields a string; `"block"` yields content.
#let _render(nodes, lo, hi, start-ply, opts, tail) = {
  let has-tail = tail != none and tail != "" and tail != "*"
  if hi < lo { return if has-tail { tail } else { "" } }
  let slice = nodes.slice(lo, hi + 1)
  if opts.variation-style == "block" {
    let lines = _block-lines(slice, start-ply, 0, false, opts)
    if has-tail and lines.len() > 0 {
      let (lvl, txt) = lines.last()
      lines.at(lines.len() - 1) = (lvl, txt + " " + tail)
    }
    return stack(dir: ttb, spacing: 0.5em,
      ..lines.map(((lvl, txt)) => pad(left: lvl * opts.indent,
        if opts.bold-mainline and lvl == 0 { strong(txt) } else { txt })))
  }
  let body = _render-inline(slice, start-ply, opts, bold: opts.bold-mainline)
  if has-tail { body = if type(body) == str { body + " " + tail } else { [#body #tail] } }
  body
}

// Navigate a variation path to the addressed sub-line and its start ply. `path`
// is a path locator (dict `(line: (..hops..), at: ..)` -- the `at` is ignored
// here, only the hops matter) or the bare hops array. Each hop `(at:, into:)`
// descends into that move's variation `into`. Returns `(nodes, start-ply)`; the
// sub-line's first move is at ply = the branch ply (the annotated move's ply).
#let _resolve-variation-line(game, path) = {
  assert(
    type(game) == dictionary and "movetext-raw" in game,
    message: "notation: `line:` needs a parsed game (variations live only in games)",
  )
  let hops = if type(path) == dictionary { path.at("line", default: ()) }
    else if type(path) == array { path }
    else { panic("notation: `line:` must be a path locator dict or a hops array; got " + repr(path)) }
  let line = movetext(game)
  let branch-ply = 1
  for hop in hops {
    let target = _ply-of(hop.at("at"))
    let k = target - branch-ply
    assert(k >= 0 and k < line.len(), message: "notation: `line:` hop out of range at " + hop.at("at"))
    let vars = line.at(k).at("variations", default: ())
    let into = hop.at("into")
    assert(into < vars.len(), message: "notation: no variation #" + str(into) + " at move " + hop.at("at"))
    line = vars.at(into)
    branch-ply = target
  }
  (nodes: line, start-ply: branch-ply)
}

/// Render move notation from a game (mainline), a move-text string, or a SAN
/// array. `from`/`to` are inclusive mainline locators ("12w"/"12b"); omit for the
/// whole line. `line` addresses a specific *variation* to render on its own
/// (a path locator / hops array like `diagram-after`'s; `from`/`to`/`result` do not
/// apply). Options: `figurine` (glyphs instead of letters), `lang`
/// (`auto` -> the document language via `set-lang`; a code like "de"; or the
/// string "auto" to follow `#set text(lang: ..)`; unknown -> en),
/// `move-numbers`, `result` (append the game result), `variations` /
/// `variation-style`. `nags` / `comments` / `variations` / `bold-mainline`
/// (default `auto`) consult the document `set-pgn-defaults`: `nags` / `comments`
/// / `variations` are off by default, `bold-mainline` is on. When everything
/// resolves without document state the result is a plain string; otherwise
/// (including a bold mainline) it is content.
#let notation(source, from: none, to: none, line: none, figurine: false, lang: auto, nags: auto, comments: auto, variations: auto, variation-style: "inline", bold-mainline: auto, move-numbers: true, result: false) = {
  assert(variation-style in ("inline", "block"), message: "notation: variation-style must be \"inline\" or \"block\"; got " + repr(variation-style))
  // Which nodes to render: a mainline slice, or a variation sub-line addressed by
  // `line`. `start-ply` is the ply of the first rendered node.
  let nodes = ()
  let lo = 0
  let hi = -1
  let start-ply = 1
  let tail = none
  if line != none {
    let v = _resolve-variation-line(source, line)   // (nodes, start-ply)
    nodes = v.nodes
    hi = v.nodes.len() - 1
    start-ply = v.start-ply
    // `result` is a game-level token -- not appended to a variation.
  } else {
    let r = _resolve-line(source, from, to)
    nodes = r.nodes
    lo = r.lo
    hi = r.hi
    start-ply = r.lo + 1
    if result and type(source) == dictionary and "movetext-raw" in source { tail = game-result(source) }
  }
  let mk-opts = (chars, rn, rc, rv, rb) => (
    figurine: figurine, chars: chars, move-numbers: move-numbers,
    nags: rn, comments: rc, variations: rv, bold-mainline: rb,
    variation-style: variation-style, indent: 1.2em,
  )
  // `lang: auto` (the VALUE) consults the document `set-lang` setting; `lang:
  // "auto"` follows `#set text(lang:)`; an explicit code needs no document state.
  // `nags`/`comments`/`variations`/`bold-mainline: auto` consult `set-pgn-defaults`.
  let lang-needs-state = lang == auto or lang == "auto"
  let needs-state = lang-needs-state or nags == auto or comments == auto or variations == auto or bold-mainline == auto
  if needs-state {
    context {
      let pg = default-pgn-style + pgn-style-state.get()
      let rn = if nags != auto { nags } else { pg.nags }
      let rc = if comments != auto { comments } else { pg.comments }
      let rv = if variations != auto { variations } else { pg.variations }
      let rb = if bold-mainline != auto { bold-mainline } else { pg.bold-mainline }
      let chars = lang-piece-chars(lang)
      _render(nodes, lo, hi, start-ply, mk-opts(chars, rn, rc, rv, rb), tail)
    }
  } else {
    let chars = notation-langs.at(lang, default: notation-langs.en)
    _render(nodes, lo, hi, start-ply, mk-opts(chars, nags, comments, variations, bold-mainline), tail)
  }
}