// ===========================================================================
// staunton - chess diagrams for Typst.
//
// Public API. Layers underneath (see src/):
//   position model  : fen.typ
//   rules engine    : engine.typ  (pseudo-legal -> legality filter)
//   SAN             : san.typ
//   PGN parsing     : pgn.typ     (Phase A: cheap, no engine)
//   navigation      : game.typ    (Phase B: engine on demand)
//   presentation    : style.typ + board.typ
// All front doors (FEN strings, manual pieces, PGN games) funnel into one
// renderer + one #figure wrapper.
// ===========================================================================

// Public re-exports are curated: only the names documented as supported API are
// re-exported cleanly. Names lib needs internally but does NOT support as public
// API are imported with an `_`-prefixed alias, so the clean name is absent from
// this module's surface (Typst 0.15 has no real export privacy, so this is the
// convention). Everything else stays reachable via a deep `src/...` import.
#import "src/coords.typ": parse-square, is-dark-square, square-name as _square-name
#import "src/pieces.typ": piece-content, svg-piece-set, named-piece-set, with-fallback
#import "src/variants.typ": variant-spec as _variant-spec, char-to-piece as _char-to-piece, define-variant
#import "src/fen.typ": parse-fen, starting-fen, position-fen as _position-fen
#import "src/chess960.typ": chess960-start-fen
#import "src/engine.typ": legal-moves, apply, in-check, checked-king-square as _checked-king-square
#import "src/san.typ": chess-moves
#import "src/pgn.typ": parse-pgn, movetext
#import "src/game.typ": mainline, position-after, game-result, move-san, move-node, move-quality-mark as _move-quality-mark, with-nags, with-comments, with-variation, game-start, game-variant
// The text core lives in src/notation.typ; lib defines `notation` /
// `chess-notation` on top so they can also embed diagrams (which needs the
// lib-level `chess-diagram`).
#import "src/notation.typ": notation as _notation-text

// NOTE on reading external files: there is intentionally no `read-pgn(path)`
// wrapper. Typst's `read` resolves paths relative to the file the call appears
// in, so a wrapper here would resolve relative to this library, not your
// document. Read in your own file instead:  parse-pgn(read("game.pgn")).
#import "src/style.typ": (
  default-style, style-keys, set-chess-defaults, set-piece-set, chess-style,
  default-board-style, default-diagram-style, board-style-keys, diagram-style-keys,
  board-non-default-keys,
  diagram-style-state, set-board-defaults, set-diagram-defaults,
  default-table-style, table-style-state, table-style-keys, set-table-defaults,
  default-i18n-style, i18n-style-state, i18n-style-keys, set-lang,
  default-pgn-style, pgn-style-state, pgn-style-keys, set-pgn-defaults,
)
#import "src/i18n.typ": ui-string as _ui-string
#import "src/board.typ": render-board as _render-board
#import "src/annotations.typ": interpret-comment as _interpret-comment
#import "src/tournament.typ": (
  games-by-event, standings, standings-table,
  crosstable, crosstable-table, progress, progress-table, chess-table-kind,
)

// Distinct figure kind so chess diagrams get their own counter and can be
// collected with  #outline(target: figure.where(kind: "chess")).
#let chess-kind = "chess"

// Parse the "string" position form into (squares, cols, rows). Accepts a single
// multi-line string, a raw block (```...```), or an array of row strings. The
// FIRST line is the TOP rank (read top-down, like FEN); "." is an empty square;
// upper case = white, lower case = black (resolved via the variant). All
// non-blank rows must have the same length (rectangular boards only).
#let _parse-position-string(input, variant) = {
  let lines = if type(input) == array { input }
    else if type(input) == str { input.split("\n") }
    else if type(input) == content and input.func() == raw { input.text.split("\n") }
    else { panic("position(): string form expects a string, a raw block, or row strings") }
  lines = lines.map(l => l.trim()).filter(l => l != "")
  assert(lines.len() > 0, message: "position(): empty position string")
  let rows = lines.len()
  let cols = lines.first().clusters().len()
  let squares = (:)
  for (i, ln) in lines.enumerate() {
    let cells = ln.clusters()
    assert(cells.len() == cols, message: "position(): row " + str(i + 1) + " has " + str(cells.len()) + " columns, expected " + str(cols) + " (board must be rectangular)")
    let row = rows - 1 - i   // first line is the top rank
    for (col, ch) in cells.enumerate() {
      if ch == "." { continue }
      squares.insert(_square-name(col, row), _char-to-piece(ch, variant: variant))
    }
  }
  (squares: squares, cols: cols, rows: rows)
}

// Normalise one square's piece value into canonical (kind, color). Accepts:
//   * a piece letter   "K" / "k"          (case selects color, variant abbrev)
//   * (kind: .., color: ..) where `kind` is the long name ("king") OR the
//     single-letter abbreviation ("k"), case-insensitive; `color` is
//     "white"/"black" (case-insensitive).
#let _normalize-piece(value, variant) = {
  if type(value) == str { return _char-to-piece(value, variant: variant) }
  assert(
    type(value) == dictionary and "kind" in value and "color" in value,
    message: "position(): each piece must be a letter (\"K\") or (kind: .., color: ..); got " + repr(value),
  )
  let spec = _variant-spec(variant)
  let k = lower(value.kind)
  let kind = if k in spec.abbr { spec.abbr.at(k) } else if spec.kinds.contains(k) { k } else {
    panic("position(): unknown piece kind " + repr(value.kind) + " for variant \"" + spec.name + "\" (kinds: " + repr(spec.kinds) + ")")
  }
  let color = lower(value.color)
  assert(color == "white" or color == "black", message: "position(): color must be \"white\" or \"black\", got " + repr(value.color))
  (kind: kind, color: color)
}

// Normalise a user-supplied `castling` dict to the rook-file model: a boolean
// `true` becomes the standard rook file for that side (`cols-1` king-side, `0`
// queen-side), `false` becomes `none`; an integer file is kept as-is. Keeps
// `position(.., castling: (white-king: true))` working after the model change.
#let _normalize-castling(c, cols) = {
  if type(c) != dictionary { return c }
  let out = (:)
  for (k, v) in c {
    out.insert(k, if v == true { if k.ends-with("king") { cols - 1 } else { 0 } } else if v == false { none } else { v })
  }
  out
}

/// Build a `position` — the data a board draws — from manual placement. (A single
/// string containing `/` is treated as a FEN and delegated to `parse-fen`.)
/// Positional arguments place the pieces; named arguments set the metadata.
///
/// Pieces are given as a *squares dict* — `(e1: "K", d8: (kind: "q", color:
/// "black"))`, a piece being a bare letter (UPPER white, lower black) or a
/// `(kind, color)` with a long or abbreviated kind — or in the *string form*, one
/// rank per line (or per positional string), `.` for an empty square.
///
/// - ..args (arguments): the piece placement (positional), plus named metadata —
///   `variant` (default `"standard"`), `turn`, `castling`, `en-passant`,
///   `halfmove`, `fullmove`, and `cols` / `rows` (default: from the variant, or
///   counted in the string form).
/// -> dictionary
#let position(..args) = {
  let opts = args.named()
  let variant = opts.at("variant", default: "standard")
  let spec = _variant-spec(variant)
  let pos = args.pos()
  assert(pos.len() >= 1, message: "position(): expected at least one positional argument")

  // FEN auto-detect: a single string/raw positional that contains "/" is a FEN
  // (rank separators), so delegate to parse-fen. This keeps position(fen),
  // board(fen) and chess-moves(fen, ..) consistent. The string ROW form never
  // uses "/", so there is no clash. (parse-fen sets turn/castling/etc itself.)
  if pos.len() == 1 {
    let p0 = pos.first()
    let fen-text = if type(p0) == str { p0 }
      else if type(p0) == content and p0.func() == raw { p0.text } else { none }
    if fen-text != none and fen-text.contains("/") { return parse-fen(fen-text) }
  }

  let squares = (:)
  let cols = opts.at("cols", default: auto)
  let rows = opts.at("rows", default: auto)

  // string form: either several positional row strings, or one string/raw/
  // array-of-strings positional.
  let str-input = if pos.len() > 1 { pos }
    else if type(pos.first()) == str or (type(pos.first()) == content and pos.first().func() == raw) { pos.first() }
    else if type(pos.first()) == array and pos.first().len() > 0 and type(pos.first().first()) == str { pos.first() }
    else { none }

  if str-input != none {
    let r = _parse-position-string(str-input, variant)
    squares = r.squares
    if cols == auto { cols = r.cols }
    if rows == auto { rows = r.rows }
  } else {
    let p = pos.first()
    if cols == auto { cols = spec.cols }
    if rows == auto { rows = spec.rows }
    if type(p) == dictionary {
      if "squares" in p {
        squares = p.squares   // already a built position: take its canonical squares
      } else {
        for (sq, val) in p {
          let _ = parse-square(sq, cols: cols, rows: rows) // validate the square name
          squares.insert(lower(sq), _normalize-piece(val, variant))
        }
      }
    } else if type(p) == array {
      panic("position(): the array-of-(kind,color,square) form was removed; use a squares dict, e.g. (e1: (kind: \"king\", color: \"white\")) or (e1: \"K\"), or the string form")
    } else {
      panic("position(): expected a squares dict, a string, a raw block, or row strings; got " + repr(type(p)))
    }
  }

  (
    variant: variant, cols: cols, rows: rows, squares: squares,
    turn: opts.at("turn", default: "w"),
    castling: _normalize-castling(opts.at("castling", default: (:)), cols),
    en-passant: opts.at("en-passant", default: none),
    halfmove: opts.at("halfmove", default: 0),
    fullmove: opts.at("fullmove", default: 1),
  )
}

/// The Chess960 / Fischer Random starting *position* for a position number
/// (0–959), via Scharnagl's numbering scheme — a ready-to-draw position (feed it
/// to `chess960-board` / `chess960-diagram`, or `to-fen` it). `518` is the
/// standard start. The companion `chess960-start-fen` returns the FEN string.
///
/// - n (int): the position number, 0–959.
/// -> dictionary
#let chess960-start(n) = parse-fen(chess960-start-fen(n))

// Normalise the many accepted `source` forms into (squares, cols, rows) for
// rendering. The geometry comes from the position model: a FEN
// string is parsed for its geometry, a position dict carries `cols`/`rows`, and
// a bare squares dict defaults to standard 8x8.
#let _to-board(source) = {
  if type(source) == str {
    let p = parse-fen(source)
    (squares: p.squares, cols: p.cols, rows: p.rows)
  } else if type(source) == dictionary and "squares" in source {
    (squares: source.squares, cols: source.at("cols", default: 8), rows: source.at("rows", default: 8))
  } else if type(source) == dictionary {
    (squares: source, cols: 8, rows: 8)
  } else {
    panic("board(): source must be a FEN string, a position, or a squares dict")
  }
}

// The full position behind `source` when it is ANALYZABLE by the rules engine
// (standard chess only, and only when a `turn` is known) -- else `none`. Used to
// auto-locate the in-check king. A bare squares dict (no `turn`) and any
// non-standard variant deliberately return `none`, so the in-check glow never
// fires on fairy/variant boards.
#let _analyzable-position(source) = {
  let pos = if type(source) == str { parse-fen(source) }
    else if type(source) == dictionary and "squares" in source and "turn" in source { source }
    else { none }
  if pos == none { return none }
  // In-check detection is pure geometry (attack rays), so it is valid for any
  // variant that shares the 8×8 board + standard piece moves. Today that is only
  // "standard"; when chess960 lands as its own variant, add it here (the move
  // ENGINE stays standard-only, but the glow does not need the engine). Every
  // other/unknown variant — and by extension arbitrary teaching diagrams that are
  // not real chess — must NOT be auto-glowed, so we bail. (Prompt 28 §1.1.)
  if pos.at("variant", default: "standard") != "standard" { return none }
  pos
}

// Shared board renderer: the actual draw, with the in-check
// auto-fill. `ov` is the resolved override dict. This is the internal seam that
// lets `diagram-after` inject the move-quality badge (which only it may do — see
// the public `board` guard below), while `board` itself forbids that key.
#let _board-internal(source, flip, ov) = {
  let b = _to-board(source)
  // In-check auto-fill: locate the side-to-move king in check and pass
  // it as `check-square`, unless the caller set one. Computed only for analyzable
  // positions; the glow itself is still gated by the `check` style switch.
  if "check-square" not in ov {
    let pos = _analyzable-position(source)
    if pos != none {
      let cs = _checked-king-square(pos)
      if cs != none { ov.insert("check-square", cs) }
    }
  }
  // Auto-seed the glyph fallback from a custom (fairy) variant's `glyphs:` map, so
  // `board(fairy-pos, piece-set: "unicode")` (and the same via `diagram-after`)
  // just works. A user-supplied `piece-glyphs` override wins per kind. Standard
  // positions carry a string variant, so this is a no-op for them.
  let v-glyphs = if type(source) == dictionary and "variant" in source and type(source.variant) == dictionary {
    _variant-spec(source.variant).glyphs
  } else { (:) }
  let merged = v-glyphs + ov.at("piece-glyphs", default: (:))
  if merged.len() > 0 { ov.insert("piece-glyphs", merged) }
  _render-board(b.squares, flip: flip, cols: b.cols, rows: b.rows, ..ov)
}

/// Draw a bare board — no caption, no figure — the variant-agnostic drawing
/// primitive that every diagram builds on. The variant (if any) rides on
/// `source`; the variant-named wrappers (`chess-board`, a future `xiangqi-board`,
/// …) are thin sugar over this.
///
/// - source (str, dictionary): the position to draw — a *FEN string*, a
///   *position* dict (from `position` / `parse-fen`), or a bare *squares* dict
///   (`(e1: "K", …)`).
/// - flip (bool): show the board from Black's side. Per-call only — never a
///   document default.
/// - ..overrides (arguments): any board *style* option (`size`, `light`, `dark`,
///   `labels`, `label-mode`, `file-side`, `rank-side`, `piece-set`, `highlight`,
///   `arrows`, `grid`, …) — see #link(<board-options>)[Board style options].
/// -> content
#let board(source, flip: false, ..overrides) = {
  let ov = overrides.named()
  // Move-quality badges are tied to a MOVE, so they may only be
  // produced from a game — `diagram-after` derives the mark and injects it via
  // `_board-internal`. A bare position has no move, so setting `move-quality-mark`
  // here is a category error (it could otherwise badge an empty square).
  assert("move-quality-mark" not in ov,
    message: "move-quality badges are derived from a game move; set `move-quality: true` on `diagram-after` (or annotate the move with `with-nags`) — a bare `board`/`chess-board` cannot carry one")
  // Fairy glyph-fallback seeding now lives in `_board-internal`, the shared seam.
  _board-internal(source, flip, ov)
}

// Variant guard for the *-board / *-diagram wrappers: a position source must
// already be of the expected variant (catches e.g. chess-board(xiangqi-pos)).
#let _assert-variant(fname, variant, source) = {
  if type(source) == dictionary and "variant" in source {
    let got = if type(source.variant) == str { source.variant } else { "custom" }
    assert(source.variant == variant,
      message: fname + ": expected a \"" + variant + "\" position, got a \"" + got + "\" one")
  }
}

/// Standard western-chess board — the variant-named sugar over `board`, and the
/// everyday entry point. Identical rendering, but it documents the variant and
/// rejects a non-standard `source`. (Other variants get their own entry, e.g. a
/// future `xiangqi-board`.)
///
/// - source (str, dictionary): a standard-chess position — a FEN string, a
///   position dict, or a squares dict.
/// - flip (bool): show the board from Black's side.
/// - ..overrides (arguments): any board *style* option (as for `board`).
/// -> content
#let chess-board(source, flip: false, ..overrides) = {
  _assert-variant("chess-board", "standard", source)
  board(source, flip: flip, ..overrides.named())
}

/// Chess960 / Fischer Random board — the variant-named entry point for 960.
/// Rendering is identical to `chess-board` (960 shares the standard board,
/// pieces and position model); the distinct name documents intent and rejects a
/// genuinely different variant (e.g. a xiangqi position). The 960-ness of a
/// position lives in its (arbitrary) placement and generalised castling, not in
/// a separate piece set.
///
/// - source (str, dictionary): a Chess960 position — a FEN / X-FEN string, a
///   position dict, or a squares dict.
/// - flip (bool): show the board from Black's side.
/// - ..overrides (arguments): any board *style* option (as for `board`).
/// -> content
#let chess960-board(source, flip: false, ..overrides) = {
  _assert-variant("chess960-board", "standard", source)
  board(source, flip: flip, ..overrides.named())
}

/// Export a position as a FEN string — the inverse of `parse-fen`. Serialises
/// either a *position* dict directly, or a *game* at a locator. Standard 8×8
/// positions round-trip exactly.
///
/// - source (dictionary): a *position* dict, or a *game* (from `parse-pgn`).
/// - locator (str, dictionary): required when `source` is a game — which move's
///   position to serialise (a mainline `"12w"` or a path dict). Ignored for a
///   position.
/// -> str
#let to-fen(source, locator: none) = {
  assert(type(source) == dictionary, message: "to-fen: expected a position or a game dict")
  if "squares" in source { return _position-fen(source) }
  if "movetext-raw" in source {
    assert(locator != none, message: "to-fen: a game needs a locator (e.g. locator: \"12w\")")
    return _position-fen(position-after(source, locator))
  }
  panic("to-fen: source must be a position (has `squares`) or a game (has `movetext-raw`)")
}

// Above-diagram "game info" line: "<White> – <Black> (<Year>)". Drawn only when
// BOTH players are known; the year is appended in parentheses when present. The
// auto line is bold by default (diagram-style `info-bold`); a user-supplied
// `game-info:` is left untouched.
#let _game-info-line(white, black, year, bold: true) = {
  if white == none or black == none { return none }
  let yr = if year == none { none } else if type(year) == int { str(year) } else { year }
  let txt = if yr == none { [#white #sym.dash.en #black] } else { [#white #sym.dash.en #black (#yr)] }
  if bold { strong(txt) } else { txt }
}

// Below-diagram default caption for a FEN source: position + side to move.
// Language-aware: the catalog `fen-caption` closure owns the wording/grammar.
// Must be called inside a `context` (it resolves the language).
#let _fen-caption(pos, lang) = (_ui-string(lang, "fen-caption"))(str(pos.fullmove), pos.turn)

// Below-diagram default caption for a PGN source: the last move played. The move
// reference ("5. Nf3" / "5... Nf3") is assembled here (notation convention,
// language-neutral); the catalog `pgn-caption` closure supplies the surrounding
// wording. Must be called inside a `context`.
#let _pgn-caption(game, locator, lang) = {
  let at = if type(locator) == str { locator } else { locator.at("at") }
  let color = at.slice(at.len() - 1)
  let num = at.slice(0, at.len() - 1)
  let prefix = if color == "w" { num + ". " } else { num + "... " }
  (_ui-string(lang, "pgn-caption"))(prefix + move-san(game, locator))
}

// Year extracted from a PGN "Date" tag ("1972.07.11" -> "1972").
#let _year-of(game) = {
  let d = game.tags.at("Date", default: none)
  if d == none { return none }
  let m = d.match(regex("^(\d{4})"))
  if m != none { m.captures.at(0) } else { none }
}

// PGN drawing annotations for a move's comment, via the shared comment
// interpreter (src/annotations.typ):
//   {[%cal Gf3e5,Bc6e5]}  -> arrows  (("f3","e5","G"), ("c6","e5","B"))
//   {[%csl Re5,Yc6]}      -> highlights (("e5","R"), ("c6","Y"))
// The color letters resolve later through the board's `annotation-colors` map.
// Returns (arrows, highlight).
#let _pgn-annotations(game, locator) = {
  let r = _interpret-comment(move-node(game, locator).at("comment-after", default: none))
  (r.arrows, r.highlights)
}


// Split a mixed named-argument dict three ways: board-style overrides, diagram-
// style overrides, and leftover #figure arguments.
#let _split-args(named) = {
  let board-ov = (:)
  let diagram-ov = (:)
  let fig-args = (:)
  for (k, v) in named {
    if board-style-keys.contains(k) { board-ov.insert(k, v) }
    else if diagram-style-keys.contains(k) { diagram-ov.insert(k, v) }
    else { fig-args.insert(k, v) }
  }
  (board-ov, diagram-ov, fig-args)
}

// `diagram` (defined just below `_assemble`) is the variant-agnostic figure
// wrapper; its tidy docstring lives directly above the `#let diagram` definition.
// Assemble a #figure around already-drawn board content `drawn`. The diagram
// style is read inside the figure BODY (a context), so the #figure itself stays
// a real, referenceable element. `drawn` may itself be context content (e.g. a
// pgn-gated board), which composes fine. Shared by `diagram` and `diagram-after`.
#let _assemble(drawn, white, black, year, game-info, below, diagram-ov, lang, fig-args) = {
  let body = context {
    let dst = default-diagram-style + diagram-style-state.get() + diagram-ov
    let above = if game-info != auto { game-info } else { _game-info-line(white, black, year, bold: dst.info-bold) }
    if above != none { align(center, stack(dir: ttb, spacing: dst.info-gap, above, drawn)) } else { drawn }
  }
  // Supplement: a per-call override is used verbatim (no context needed); else
  // resolve the document default in a context, where `auto` -> the language-aware
  // default ("Diagram"/"Diagramm"/...).
  let supp = if "supplement" in diagram-ov { diagram-ov.supplement } else {
    context {
      let s = (default-diagram-style + diagram-style-state.get()).supplement
      if s == auto { _ui-string(lang, "diagram-supplement") } else { s }
    }
  }
  // A caption-less diagram stays referenceable but unlisted: default `outlined`
  // to whether it carries a caption, so bare positions don't leave blank rows in
  // a chess-diagram outline. An explicit `outlined:` in fig-args still wins.
  figure(body, kind: chess-kind, supplement: supp, caption: below, ..((outlined: below != none) + fig-args))
}

/// A board wrapped in a `#figure` — the variant-agnostic diagram, and the generic
/// primitive under `chess-diagram` (and a future `xiangqi-diagram`). Draws an
/// automatic "White – Black (Year)" line above when both players are known, and a
/// default caption below for a FEN source ("Position at move N, X to play").
///
/// - source (str, dictionary): a FEN string, a position dict, or a bare board
///   dict.
/// - white (str, none): white player's name, for the automatic info line.
/// - black (str, none): black player's name.
/// - event (str, none): event name (carried; not shown by default).
/// - year (int, str, none): year, appended to the info line in parentheses.
/// - caption (auto, content, none): the figure caption; `auto` is the
///   source-specific default (a FEN gets "Position at move N…"; a position or
///   board dict gets none).
/// - game-info (auto, content, none): the above-board line; `auto` is the
///   automatic player line — pass your own content, or `none` to drop it.
/// - flip (bool): show the board from Black's side (per-diagram only).
/// - lang (auto, str): language for the supplement; `auto` follows the document.
/// - ..args (arguments): board *style* options go to the renderer; anything else
///   is forwarded to `#figure` (e.g. `placement: top`).
/// -> content
#let diagram(
  source,
  white: none,
  black: none,
  event: none,
  year: none,
  caption: auto,
  game-info: auto,
  flip: false,
  lang: auto,
  ..args,
) = {
  let (board-ov, diagram-ov, fig-args) = _split-args(args.named())
  let below = if caption != auto { caption } else if type(source) == str {
    let pos = parse-fen(source)
    context _fen-caption(pos, lang)
  } else { none }
  let drawn = board(source, flip: flip, ..board-ov)
  _assemble(drawn, white, black, year, game-info, below, diagram-ov, lang, fig-args)
}

/// Standard western-chess diagram — the variant-named sugar over `diagram` and
/// the everyday entry point. Same behaviour, but it documents the variant and
/// rejects a non-standard `source`.
///
/// - source (str, dictionary): a standard-chess position (FEN, position dict, or
///   squares dict).
/// - ..args (arguments): everything `diagram` accepts (players, `caption`,
///   `game-info`, `flip`, `lang`, style options, and `#figure` arguments).
/// -> content
#let chess-diagram(source, ..args) = {
  _assert-variant("chess-diagram", "standard", source)
  diagram(source, ..args)
}

/// Chess960 / Fischer Random diagram — the variant-named sugar over `diagram` for
/// 960. Same behaviour and rendering as `chess-diagram`; the name documents the
/// variant and rejects a genuinely different one. Pair with `game-variant` to
/// pick this entry point when a parsed game is Chess960.
///
/// - source (str, dictionary): a Chess960 position (FEN / X-FEN, position dict,
///   or squares dict).
/// - ..args (arguments): everything `diagram` accepts (players, `caption`,
///   `game-info`, `flip`, `lang`, style options, and `#figure` arguments).
/// -> content
#let chess960-diagram(source, ..args) = {
  _assert-variant("chess960-diagram", "standard", source)
  diagram(source, ..args)
}

/// A chess diagram for the position at `locator` within a parsed game. Players
/// and year default to the game's roster tags (so the info line is automatic) and
/// the caption defaults to "Position after move …" (the move played).
///
/// When the resolved PGN-handling `annotations` switch is on, `%cal` / `%csl`
/// drawing annotations in the move's comment become arrows / highlights, merged
/// with any passed explicitly.
///
/// - game (dictionary): a parsed game (from `parse-pgn`).
/// - locator (str, dictionary): which position — a mainline `"30w"` / `"30b"` or
///   a variation path dict.
/// - white (auto, str, none): white player; `auto` uses the game's `White` tag.
/// - black (auto, str, none): black player; `auto` uses the `Black` tag.
/// - year (auto, int, str, none): year; `auto` uses the `Date` tag.
/// - caption (auto, content, none): `auto` is "Position after move …".
/// - annotations (auto, bool): process `%cal` / `%csl` into arrows / highlights;
///   `auto` consults `set-pgn-defaults` (off by default).
/// - flip (bool): show the board from Black's side.
/// - game-info (auto, content, none): the above-board line (as for `diagram`).
/// - lang (auto, str): language for the supplement; `auto` follows the document.
/// - ..args (arguments): board *style* options and `#figure` arguments.
/// -> content
#let diagram-after(game, locator, white: auto, black: auto, year: auto, caption: auto, annotations: auto, flip: false, game-info: auto, lang: auto, ..args) = {
  let pos = position-after(game, locator)
  let cap = if caption != auto { caption } else { context _pgn-caption(game, locator, lang) }
  let w = if white != auto { white } else { game.tags.at("White", default: none) }
  let b = if black != auto { black } else { game.tags.at("Black", default: none) }
  let y = if year != auto { year } else { _year-of(game) }

  let (board-ov, diagram-ov, fig-args) = _split-args(args.named())
  let explicit-arrows = board-ov.at("arrows", default: ())
  let explicit-highlight = board-ov.at("highlight", default: ())
  let base-ov = (:)
  for (k, v) in board-ov { if k != "arrows" and k != "highlight" { base-ov.insert(k, v) } }
  let (anno-arrows, anno-highlight) = _pgn-annotations(game, locator)
  // Move-quality badge: this game path is the ONLY producer — the
  // badge is derived from the addressed move's assessment (its quality NAG or a
  // literal `!`/`?` suffix) and placed on the move's destination square, gated by
  // the `move-quality` style switch. Callers cannot set `move-quality-mark`
  // themselves (a bare position has no move); `board` rejects that key, so we
  // inject the derived mark through `_board-internal`. (The in-check glow is
  // auto-filled inside `_board-internal`, since `pos` is an analyzable position.)
  assert("move-quality-mark" not in base-ov,
    message: "diagram-after derives the move-quality badge from the move itself; do not pass `move-quality-mark`")
  let mq = _move-quality-mark(game, locator)

  // Draw the board inside a context so the `annotations` switch can read the
  // pgn-handling document default -- while the #figure (built by `_assemble`)
  // stays a real, referenceable element.
  let drawn = context {
    let process = if annotations != auto { annotations } else { (default-pgn-style + pgn-style-state.get()).annotations }
    let arr = explicit-arrows + (if process { anno-arrows } else { () })
    let hl = explicit-highlight + (if process { anno-highlight } else { () })
    let ov = base-ov
    ov.insert("arrows", arr)
    ov.insert("highlight", hl)
    if mq != none { ov.insert("move-quality-mark", mq) }
    _board-internal(pos, flip, ov)
  }
  _assemble(drawn, w, b, y, game-info, cap, diagram-ov, lang, fig-args)
}

// Mainline locator "12w"/"12b" <-> 0-based ply index (ply = index+1; White's
// move m is ply 2m-1). Used to slice the movetext into text runs for embedding.
#let _index-of-loc(loc) = {
  let color = loc.slice(loc.len() - 1)
  let num = int(loc.slice(0, loc.len() - 1))
  (if color == "w" { 2 * num - 1 } else { 2 * num }) - 1
}
#let _loc-of-index(i) = {
  let ply = i + 1
  str(int((ply + 1) / 2)) + (if calc.odd(ply) { "w" } else { "b" })
}

// The text-only options forwarded to the notation core (i.e. minus the embedding
// switches `diagrams` / `annotations`, handled here).
#let _text-opts(named, keys) = {
  let o = (:)
  for k in keys { if k in named { o.insert(k, named.at(k)) } }
  o
}

/// Render move notation as text, and — when `diagrams` is on and the source is a
/// game — splice a `chess-diagram` into the flow after each move whose comment
/// carries a diagram marker (ChessBase `#` / `#[caption]`, Scid `[d]` / `[D]`,
/// `\diagram`, `%%diagram`). Embedded diagrams are made in a context, so they are
/// not individually referenceable. The variant-agnostic formatter under
/// `chess-notation`.
///
/// - source (dictionary, str, array): a parsed *game*, a *move-text string*, or a
///   *SAN array*.
/// - ..args (arguments): the formatting options — `from` / `to` (mainline slice),
///   `line` (render one variation), `figurine`, `lang`, `nags`, `comments`,
///   `variations`, `variation-style` (`"inline"` / `"block"`), `bold-mainline`,
///   `move-numbers`, `result`, and the embedding switches `diagrams` /
///   `annotations`. The `auto`-defaulting ones consult `set-pgn-defaults`.
/// -> content
#let notation(source, ..args) = {
  let named = args.named()
  let all-opts = ("from", "to", "line", "figurine", "lang", "nags", "comments", "variations", "variation-style", "bold-mainline", "move-numbers", "result")
  let accepted = all-opts + ("diagrams", "annotations")
  // Reject unknown named options up front (e.g. `show-variations` for `variations`);
  // otherwise a typo'd option is silently ignored and its effect just never happens.
  for k in named.keys() {
    assert(k in accepted, message: "notation: unknown option `" + k + "` (expected one of: " + accepted.join(", ") + ")")
  }
  // Validate range locators eagerly (not deferred behind the context below), so
  // a misuse errors even when the result is discarded.
  for loc in (named.at("from", default: none), named.at("to", default: none)) {
    if loc != none and type(loc) != str {
      panic("notation: variation-line ranges are not supported yet; use mainline locators like \"12w\"")
    }
  }
  let diag = named.at("diagrams", default: auto)
  let is-game = type(source) == dictionary and "movetext-raw" in source

  // No embedding possible/requested -> hand straight to the text core. A `line:`
  // render (a single variation) is text-only, so it bypasses diagram embedding.
  if diag == false or not is-game or named.at("line", default: none) != none {
    return _notation-text(source, .._text-opts(named, all-opts))
  }

  context {
    let pg = default-pgn-style + pgn-style-state.get()
    let do-diag = if diag != auto { diag } else { pg.diagrams }
    if not do-diag {
      _notation-text(source, .._text-opts(named, all-opts))
    } else {
      let nodes = movetext(source)
      let lo = if named.at("from", default: none) != none { _index-of-loc(named.from) } else { 0 }
      let hi = if named.at("to", default: none) != none { _index-of-loc(named.to) } else { nodes.len() - 1 }
      let process-anno = if named.at("annotations", default: auto) != auto { named.annotations } else { pg.annotations }
      let run-opts = _text-opts(named, ("figurine", "lang", "nags", "comments", "variations", "variation-style", "bold-mainline", "move-numbers"))

      let parts = ()
      let run-start = lo
      for idx in range(lo, hi + 1) {
        let info = _interpret-comment(nodes.at(idx).at("comment-after", default: none))
        if info.diagram != none {
          parts.push(_notation-text(source, from: _loc-of-index(run-start), to: _loc-of-index(idx), result: false, ..run-opts))
          let cap = if info.diagram.caption == none { none } else { [#info.diagram.caption] }
          let arr = if process-anno { info.arrows } else { () }
          let hl = if process-anno { info.highlights } else { () }
          parts.push(chess-diagram(position-after(source, _loc-of-index(idx)), caption: cap, arrows: arr, highlight: hl))
          run-start = idx + 1
        }
      }
      if run-start <= hi {
        parts.push(_notation-text(source, from: _loc-of-index(run-start), to: _loc-of-index(hi), result: false, ..run-opts))
      }
      let body = parts.map(c => [#c]).join()
      if named.at("result", default: false) { body = [#body #game-result(source)] }
      body
    }
  }
}

/// Standard western-chess notation — the variant-named sugar over `notation` and
/// the everyday entry point. Same behaviour, but it rejects a non-standard
/// `source` variant.
///
/// - source (dictionary, str, array): a parsed game, a move-text string, or a SAN
///   array (standard chess).
/// - ..args (arguments): everything `notation` accepts.
/// -> content
#let chess-notation(source, ..args) = {
  if type(source) == dictionary and source.at("variant", default: "standard") != "standard" {
    panic("chess-notation: expected standard chess; got variant " + repr(source.variant))
  }
  notation(source, ..args)
}

// Resolve an outline title: explicit per-call `title` wins; else the document
// `outline-title` (from the given style bucket); else the language-aware default.
// `title`/the document value may be `auto` (use localized) or any content/none.
#let _outline-title(title, doc-default, lang, key) = {
  let t = if title != auto { title } else { doc-default }
  // Only the localized default needs a context; a concrete title (including
  // `none`) is returned verbatim, so `title: none` truly drops the outline title
  // instead of leaving an empty title heading behind.
  if t == auto { context _ui-string(lang, key) } else { t }
}

/// An outline listing only chess *diagrams* (figures of kind `"chess"`).
///
/// - title (auto, content, none): the outline title; `auto` is the language-aware
///   "List of Diagrams" (or the document value from `set-diagram-defaults`).
/// - lang (auto, str): language for the default title; `auto` follows the
///   document.
/// - ..args (arguments): forwarded to `outline` (e.g. `depth`, `indent`).
/// -> content
#let chess-diagram-outline(title: auto, lang: auto, ..args) = context {
  let doc = (default-diagram-style + diagram-style-state.get()).outline-title
  outline(
    title: _outline-title(title, doc, lang, "diagram-outline-title"),
    target: figure.where(kind: chess-kind),
    ..args,
  )
}

/// An outline listing only chess *tables* (standings / cross-table / progress
/// figures of kind `"chess-table"`). Only tables that carry a `caption` appear.
///
/// - title (auto, content, none): the outline title; `auto` is the language-aware
///   "List of Tables" (or the document value from `set-table-defaults`).
/// - lang (auto, str): language for the default title; `auto` follows the
///   document.
/// - ..args (arguments): forwarded to `outline`.
/// -> content
#let chess-table-outline(title: auto, lang: auto, ..args) = context {
  let doc = (default-table-style + table-style-state.get()).outline-title
  outline(
    title: _outline-title(title, doc, lang, "table-outline-title"),
    target: figure.where(kind: chess-table-kind),
    ..args,
  )
}

/// Print both chess outlines back to back: diagrams first, then tables.
///
/// - diagram-title (auto, content, none): title for the diagram outline; `none`
///   drops it.
/// - table-title (auto, content, none): title for the table outline; `none` drops
///   it.
/// - lang (auto, str): language for the default titles; `auto` follows the
///   document.
/// - ..args (arguments): forwarded to both `outline`s.
/// -> content
#let chess-outlines(diagram-title: auto, table-title: auto, lang: auto, ..args) = {
  chess-diagram-outline(title: diagram-title, lang: lang, ..args)
  chess-table-outline(title: table-title, lang: lang, ..args)
}
