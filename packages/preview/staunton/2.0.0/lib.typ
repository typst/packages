// ===========================================================================
// staunton - chess diagrams for Typst.
//
// Public API. Layers underneath (see src/):
//   position model  : fen.typ
//   rules engine    : engine.typ  (pseudo-legal -> legality filter)
//   SAN             : san.typ
//   PGN parsing     : pgn.typ     (cheap, no engine)
//   navigation      : game.typ    (engine on demand)
//   presentation    : style.typ + board.typ
// All front doors (FEN strings, manual pieces, PGN games) funnel into one
// renderer + one #figure wrapper.
// ===========================================================================

// Public re-exports are curated: only the names documented as supported API are
// re-exported cleanly. Names lib needs internally but does NOT support as public
// API are imported with an `_`-prefixed alias, so the clean name is absent from
// this module's surface (Typst 0.15 has no real export privacy, so this is the
// convention). Everything else stays reachable via a deep `src/...` import.
#import "src/coords.typ": parse-square, is-dark-square, square-name as _square-name, _index-of-locator, _locator-of-index, _default-start
#import "src/pieces.typ": piece-content, svg-piece-set, named-piece-set, with-fallback
#import "src/variants.typ": variant-spec as _variant-spec, char-to-piece as _char-to-piece, define-variant
// `parse-fen` is NOT public API -- `position(fen)` is the one spelling
// (it auto-detects a FEN by the "/" and delegates here). It keeps an underscore
// alias because lib and src both still need it internally: src/ cannot call
// `position`, which lives here, without a circular import.
#import "src/fen.typ": parse-fen as _parse-fen, starting-fen, position-fen as _position-fen
#import "src/chess960.typ": chess960-start-fen
#import "src/engine.typ": legal-moves, apply, in-check, checked-king-square as _checked-king-square
#import "src/san.typ": play, move-to-san
#import "src/pgn.typ": games, game, movetext
#import "src/game.typ": mainline, _position-after, move-at, game-result, with-nags, with-comments, with-line, game-start, game-variant
// The text core lives in src/notation.typ; lib defines `notation` on top so
// it can also embed diagrams (which needs the lib-level `diagram`).
#import "src/notation.typ": notation as _notation-text

// NOTE on reading external files: there is intentionally no `read-pgn(path)`
// wrapper. Typst's `read` resolves paths relative to the file the call appears
// in, so a wrapper here would resolve relative to this library, not your
// document. Read in your own file instead:  game(read("game.pgn")).
#import "src/style.typ": (
  set-chess-defaults, set-piece-set,
  board-style-state as _board-style-state,
  default-board-style, default-diagram-style, board-style-keys, diagram-style-keys,
  board-non-default-keys,
  diagram-style-state, set-board-defaults, set-diagram-defaults,
  default-table-style, table-style-state, table-style-keys, set-table-defaults,
  default-i18n-style, i18n-style-state, i18n-style-keys, set-lang,
  default-pgn-style, pgn-style-state, pgn-style-keys, set-pgn-defaults,
  color-theme, board-theme,
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
/// string containing `/` is treated as a FEN and delegated to the internal FEN parser.)
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
  // (rank separators), so delegate to the FEN parser. This keeps position(fen),
  // board(fen) and play(fen, ..) consistent. The string ROW form never
  // uses "/", so there is no clash. (it sets turn/castling/etc itself.)
  if pos.len() == 1 {
    let p0 = pos.first()
    let fen-text = if type(p0) == str { p0 }
      else if type(p0) == content and p0.func() == raw { p0.text } else { none }
    if fen-text != none and fen-text.contains("/") { return _parse-fen(fen-text) }
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

// `chess960-start-fen(n)` carries Scharnagl's numbering; build the position
// directly with `position(chess960-start-fen(n))`.

// Normalise the many accepted `source` forms into (squares, cols, rows) for
// rendering. The geometry comes from the position model: a FEN
// string is parsed for its geometry, a position dict carries `cols`/`rows`, and
// a bare squares dict defaults to standard 8x8.
#let _to-board(source) = {
  if type(source) == str {
    let p = _parse-fen(source)
    (squares: p.squares, cols: p.cols, rows: p.rows)
  } else if type(source) == dictionary and "squares" in source {
    (squares: source.squares, cols: source.at("cols", default: 8), rows: source.at("rows", default: 8))
  } else if type(source) == dictionary {
    // Bare squares dict: keys are USER input (a documented `source` form), so
    // validate + canonicalise them here, once per board -- `parse-square`
    // restores the trim / case-fold / bounds-check that the fast (unvalidated)
    // `_square-index` used by the piece-drawing hot loop relies on upstream.
    let sq = (:)
    for (name, piece) in source {
      let p = parse-square(name)
      sq.insert(_square-name(p.col, p.row), piece)
    }
    (squares: sq, cols: 8, rows: 8)
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
  let pos = if type(source) == str { _parse-fen(source) }
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

// Fold a move's context into the resolved board overrides: the move's %cal/%csl
// annotations (gated by `process`) and its move-quality badge. `mv-context` is
// `none` for a FEN string, a hand-built position, an `apply` result, or a game
// drawn with no `at:` — anything with no move behind it.
//
// Deliberately PURE and context-free — the caller resolves `process` — because
// this is the only machine-checkable seam for the merge. A rendered board is not
// queryable (`query(selector(rect))` errors), and a `diagrams: true` notation
// result is a context closure whose equality ignores captured values, so
// "annotations appear once, not twice" cannot be asserted downstream of here.
// `last-move`/`last-move-color` are the RESOLVED style values (board default ⊕
// document default ⊕ per-call override), passed in rather than read from state
// here -- this function stays pure/context-free, exactly like `process`.
#let _apply-origin(ov, mv-context, process, last-move: none, last-move-color: auto) = {
  if mv-context == none { return ov }
  let ov = ov
  if process {
    // Explicit caller arrows first, derived ones appended.
    ov.insert("arrows", ov.at("arrows", default: ()) + mv-context.arrows)
    ov.insert("highlight", ov.at("highlight", default: ()) + mv-context.highlights)
  }
  // The badge is NOT gated by `annotations`: that switch governs %cal/%csl
  // comment processing, and a quality mark is a property of the move itself.
  if mv-context.quality != none { ov.insert("move-quality-mark", mv-context.quality) }
  // Auto-mark the move that produced this position. `last-move-color: auto`
  // is passed straight through as the entry's `color:` -- `_resolve-anno-color`
  // treats `auto` as "use the arrow/highlight default base", which is exactly
  // the shared visual language this is meant to match.
  if last-move == "arrow" {
    ov.insert("arrows", ov.at("arrows", default: ())
      + ((from: mv-context.from, to: mv-context.to, color: last-move-color),))
  } else if last-move == "squares" {
    // `shape` deliberately omitted so the document's `highlight-shape` applies.
    ov.insert("highlight", ov.at("highlight", default: ())
      + ((square: mv-context.from, color: last-move-color), (square: mv-context.to, color: last-move-color)))
  }
  ov
}

// Resolve `source`/`at` into a `(position, context)` pair. `context` is the
// move's record (`move-at`, see src/game.typ) when `source` is a
// game and `at:` names a move — `none` otherwise. The context travels as its
// own value alongside the position from here on; it is never attached TO the
// position (a position dict never carries move data — that would let a
// hand-built or forwarded position forge a badge it has no move behind).
//
// `_resolve-at-source` is also called directly by `diagram` (for the caption /
// roster-tag defaults, which need the context before the drawing seam below
// even runs) — that is a second CALL, not a second implementation of anything;
// it is pure and idempotent, so calling it twice on the same `(source, at)`
// just derives the same value twice.
#let _resolve-at-source(source, at) = {
  let is-game = type(source) == dictionary and "movetext-raw" in source
  if at != none {
    assert(is-game,
      message: "`at:` requires a game — a position already identifies its own move; pass the game (not the position) together with `at:` to select a move within it")
    (_position-after(source, at: at), move-at(source, at: at))
  } else {
    assert(not is-game,
      message: "a game needs `at:` naming which move to draw (e.g. `board(game, at: \"12w\")` or `diagram(game, at: \"12w\")`)")
    (source, none)
  }
}

// Move-quality badges are tied to a MOVE. The legitimate way in is a game
// handed to `board`/`diagram` with `at:` (folded in by `_resolve-draw`, via
// `_board-internal`) — never a caller-supplied mark, which could badge an
// arbitrary or empty square. Shared by `board` and `diagram`, which both call
// `_board-internal` directly with their raw `source`/`at`.
#let _assert-no-quality-mark(ov) = assert("move-quality-mark" not in ov,
  message: "move-quality badges are derived from a game move; draw `board(game, at: locator)` (or `diagram(game, at: locator)`) and the badge comes with it (annotate the move with `with-nags` if the PGN has no `!`/`?`) — a bare position has no move to badge")

// The ONE seam from `(source, at, ov)` to what actually reaches the renderer:
// resolves `source`/`at` (`_resolve-at-source`) and folds the resulting move
// context into `ov` (`_apply-origin`), in a single pure call. `_board-internal`
// — the only production caller — routes through this rather than doing the
// resolve-then-fold itself, so there is no second place that could thread the
// context through incorrectly (or drop it): the same call a test makes IS the
// call production makes. Returns a dict so a test can read `.position`/`.ov`
// without depending on tuple order.
#let _resolve-draw(source, at, ov, process, last-move: none, last-move-color: auto) = {
  let (position, mv-context) = _resolve-at-source(source, at)
  (position: position, ov: _apply-origin(ov, mv-context, process, last-move: last-move, last-move-color: last-move-color))
}

// Shared board renderer: the actual draw, with the in-check auto-fill and the
// move-context fold. `ov` is the resolved override dict. Both `board` and
// (through it) `diagram` funnel here, which is why `_resolve-draw` is called at
// this one seam — every drawing entry point gets it, and none of them needs the
// game itself beyond passing `source`/`at` through unresolved.
#let _board-internal(source, at, flip, ov, annotations: auto) = context {
  // `annotations` gates the %cal/%csl fold only (see `_apply-origin`); resolved
  // here because it needs `pgn-style-state`, which requires this context.
  let process = if annotations != auto { annotations } else {
    (default-pgn-style + pgn-style-state.get()).annotations
  }
  // `last-move`/`last-move-color` need `board-style-state`, which requires this
  // context -- resolved here, exactly like `process`, and threaded through as
  // plain values so `_apply-origin` stays pure.
  // No `_expand-themes(..)` here, unlike the parallel resolution in
  // render-board: `color-theme-keys` (style.typ) is only `light`/`dark`/
  // `pattern`/`brightness`/`contrast`, so no theme can contribute a
  // `last-move`/`last-move-color` policy key. Revisit if that ever changes.
  let lm-style = default-board-style + _board-style-state.get() + ov
  let resolved = _resolve-draw(source, at, ov, process,
    last-move: lm-style.last-move, last-move-color: lm-style.last-move-color)
  let pos = resolved.position
  let ov = resolved.ov
  let b = _to-board(pos)
  // In-check auto-fill: locate the side-to-move king in check and pass
  // it as `check-square`, unless the caller set one. Computed only for analyzable
  // positions; the glow itself is still gated by the `check` style switch -- so
  // skip the (attack-ray) detection work entirely unless the resolved `check`
  // flag (per-call override ⊕ document default ⊕ built-in default) is true.
  if "check-square" not in ov {
    let check-on = ov.at("check", default: _board-style-state.get().at("check", default: default-board-style.check))
    if check-on {
      let apos = _analyzable-position(pos)
      if apos != none {
        let cs = _checked-king-square(apos)
        if cs != none { ov.insert("check-square", cs) }
      }
    }
  }
  // Auto-seed the glyph fallback from a custom (fairy) variant's `glyphs:` map, so
  // `board(fairy-pos, piece-set: "unicode")` just works. A user-supplied
  // `piece-glyphs` override wins per kind. Standard positions carry a string
  // variant, so this is a no-op for them.
  let v-glyphs = if type(pos) == dictionary and "variant" in pos and type(pos.variant) == dictionary {
    _variant-spec(pos.variant).glyphs
  } else { (:) }
  let merged = v-glyphs + ov.at("piece-glyphs", default: (:))
  if merged.len() > 0 { ov.insert("piece-glyphs", merged) }
  _render-board(b.squares, flip: flip, cols: b.cols, rows: b.rows, ..ov)
}

/// Draw a bare board — no caption, no figure. When `source` is a game drawn
/// via `at:`, the board keeps that move, so its `%cal` / `%csl` annotations and
/// its move-quality badge become available — both are off by default and are
/// drawn once enabled. A FEN string, a
/// hand-built position, or a plain position has no such history and is drawn
/// plain.
///
/// - source (str, dictionary): the position to draw — a *FEN string*, a
///   *position* dict (from `position`), a bare *squares* dict
///   (`(e1: "K", …)`), or a *game* (from `game` / `games`), paired with `at:`.
/// - flip (bool): show the board from Black's side. Per-call only — never a
///   document default.
/// - annotations (auto, bool): process the source position's `%cal` / `%csl`
///   comment annotations into arrows / highlights; `auto` consults
///   `set-pgn-defaults` (off by default). No effect without a game handed in
///   via `at:`.
/// - at (str, dictionary, none): when `source` is a *game*, which move to draw
///   — a mainline `"12w"` / `"12b"` or a variation path dict. Required with a
///   game; an error otherwise (a position already identifies its own move).
/// - ..overrides (arguments): any board *style* option (`size`, `light`, `dark`,
///   `labels`, `label-mode`, `file-side`, `rank-side`, `piece-set`, `highlight`,
///   `arrows`, `grid`, …) — see #link(<board-options>)[Board style options].
/// -> content
#let board(source, flip: false, annotations: auto, at: none, ..overrides) = {
  let ov = overrides.named()
  _assert-no-quality-mark(ov)
  // `source`/`at` go down unresolved: `_board-internal` resolves them itself
  // (via `_resolve-draw`), the one seam that also folds in the move context.
  _board-internal(source, at, flip, ov, annotations: annotations)
}

/// Export a position as a FEN string — the inverse of `position(fen)`. Serialises
/// either a *position* dict directly, or a *game* at a locator. Standard 8×8
/// positions round-trip exactly.
///
/// - source (dictionary): a *position* dict, or a *game* (from `game` / `games`).
/// - at (str, dictionary): required when `source` is a game — which move's
///   position to serialise (a mainline `"12w"` or a path dict). Ignored for a
///   position.
/// -> str
#let to-fen(source, at: none) = {
  assert(type(source) == dictionary, message: "to-fen: expected a position or a game dict")
  let loc = at
  if "squares" in source { return _position-fen(source) }
  if "movetext-raw" in source {
    assert(loc != none, message: "to-fen: a game needs a locator (e.g. at: \"12w\")")
    return _position-fen(_position-after(source, at: loc))
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

// Below-diagram default caption for a FEN source: whose turn it is. A bare FEN has
// no move history (and its move number is unreliable — an omitted field parses as
// 1), so the caption names only the side to move. Language-aware: the catalog
// `fen-caption` closure owns the wording. Must be called inside a `context`.
#let _fen-caption(pos, lang) = (_ui-string(lang, "fen-caption"))(pos.turn)

// Below-diagram default caption for a game-derived position: the last move
// played. The move reference ("5. Nf3" / "5... Nf3") is assembled here (notation
// convention, language-neutral); the catalog `pgn-caption` closure supplies the
// surrounding wording. Takes the locator and SAN straight from the position's
// provenance, so no game is needed. Must be called inside a `context`.
// The automatic "Position after 24. Nf3" caption. `quality` is the move's grade
// symbol (`!`, `??`, …) or `none`; it is appended to the move so a graded move
// reads "Position after 3... Nf6??".
//
// The grade belongs here and not only on the board: the move-quality BADGE is
// off by default (`move-quality: false`, src/style.typ), so for most documents
// the caption is the only place a grade appears at all.
//
// Both a literal "??" suffix in `san` and an equivalent `$4` NAG normalize to
// the same NAG, so both caption identically.
#let _pgn-caption(locator, san, quality, lang) = {
  let at = if type(locator) == str { locator } else { locator.at("at") }
  let color = at.slice(at.len() - 1)
  let num = at.slice(0, at.len() - 1)
  let prefix = if color == "w" { num + ". " } else { num + "... " }
  let grade = if quality != none { quality.symbol } else { "" }
  (_ui-string(lang, "pgn-caption"))(prefix + san + grade)
}

// Year extracted from a PGN "Date" tag ("1972.07.11" -> "1972"). Takes the raw
// tags dict (as carried in provenance), not a game — how a Date becomes a year is
// a presentation decision and stays here rather than in src/game.typ.
#let _year-of(tags) = {
  let d = tags.at("Date", default: none)
  if d == none { return none }
  let m = d.match(regex("^(\d{4})"))
  if m != none { m.captures.at(0) } else { none }
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
// pgn-gated board), which composes fine.
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
  // a diagram outline. An explicit `outlined:` in fig-args still wins.
  figure(body, kind: chess-kind, supplement: supp, caption: below, ..((outlined: below != none) + fig-args))
}

/// A board wrapped in a `#figure`. Draws an automatic "White – Black (Year)"
/// line above when both players are known, and a default caption below for a
/// FEN source ("White to move" / "Black to move").
///
/// When `source` is a game drawn via `at:`, the diagram keeps that move: the
/// players and year default to the game's roster tags, and the caption defaults
/// to "Position after 24. Nf3". The move's `%cal` / `%csl` annotations and
/// quality badge become available too — both are off by default and are drawn
/// once enabled.
///
/// - source (str, dictionary): a FEN string, a position dict, a bare board
///   dict, or a *game* (from `game` / `games`), paired with `at:`.
/// - white (auto, str, none): white player's name, for the automatic info line;
///   `auto` uses the source's game tags when it has any.
/// - black (auto, str, none): black player's name.
/// - event (str, none): event name (carried; not shown by default).
/// - year (auto, int, str, none): year, appended to the info line in parentheses.
/// - caption (auto, content, none): the figure caption; `auto` is the
///   source-specific default (a game-derived position gets "Position after …",
///   a FEN gets "White to move"; a bare position or board dict gets none).
/// - game-info (auto, content, none): the above-board line; `auto` is the
///   automatic player line — pass your own content, or `none` to drop it.
/// - flip (bool): show the board from Black's side (per-diagram only).
/// - annotations (auto, bool): process the source position's `%cal` / `%csl`
///   annotations into arrows / highlights; `auto` consults `set-pgn-defaults`.
/// - at (str, dictionary, none): when `source` is a *game*, which move to draw
///   — see `board`'s `at:`. Required with a game; an error otherwise.
/// - lang (auto, str): language for the supplement; `auto` follows the document.
/// - ..args (arguments): board *style* options go to the renderer; anything else
///   is forwarded to `#figure` (e.g. `placement: top`).
/// -> content
#let diagram(
  source,
  white: auto,
  black: auto,
  event: none,
  year: auto,
  caption: auto,
  game-info: auto,
  flip: false,
  annotations: auto,
  at: none,
  lang: auto,
  ..args,
) = {
  // Resolved here (in ADDITION to `_board-internal`'s own resolution below) only
  // for the caption / roster-tag defaults, which are decided before the drawing
  // seam runs — see the comment on `_resolve-at-source`. `source`/`at` themselves
  // are passed to `_board-internal` UNCHANGED so it can resolve (and fold the
  // context into the overrides) itself; passing the resolved position down
  // instead would make a game `source` fail `_board-internal`'s own resolution
  // (a plain position paired with a still-non-none `at` looks like misuse).
  let (_, mv-context) = _resolve-at-source(source, at)
  let (board-ov, diagram-ov, fig-args) = _split-args(args.named())
  // `move-at` doesn't carry `tags` (a roster belongs to the game, not a move):
  // read it straight from the game when `source` is one.
  let is-game = type(source) == dictionary and "movetext-raw" in source
  let tags = if is-game { source.at("tags", default: (:)) } else { (:) }
  let below = if caption != auto { caption }
    else if mv-context != none { context _pgn-caption(mv-context.locator, mv-context.san, mv-context.quality, lang) }
    else if type(source) == str {
      let pos = _parse-fen(source)
      context _fen-caption(pos, lang)
    } else { none }
  // `auto` means "take it from the source's game history if it has one";
  // an explicit `none` still suppresses.
  let white = if white != auto { white } else { tags.at("White", default: none) }
  let black = if black != auto { black } else { tags.at("Black", default: none) }
  let year = if year != auto { year } else { _year-of(tags) }
  // Same guard `board` applies, then straight to the shared seam (see
  // `_board-internal`) with the ORIGINAL `source`/`at` — not the resolved pair
  // derived just above.
  _assert-no-quality-mark(board-ov)
  let drawn = _board-internal(source, at, flip, board-ov, annotations: annotations)
  _assemble(drawn, white, black, year, game-info, below, diagram-ov, lang, fig-args)
}

// Mainline locator "12w"/"12b" <-> 0-based ply index, relative to a game's own
// starting move (`start`, a `game-start` dict; defaults to a standard game).
// Used to slice the movetext into text runs for embedding (shared arithmetic
// in coords.typ).
#let _index-of-loc(loc, start: _default-start) = _index-of-locator(loc, start: start)
#let _loc-of-index(i, start: _default-start) = _locator-of-index(i, start: start)

// The text-only options forwarded to the notation core (i.e. minus the embedding
// switches `diagrams` / `annotations`, handled here).
#let _text-opts(named, keys) = {
  let o = (:)
  for k in keys { if k in named { o.insert(k, named.at(k)) } }
  o
}

/// Render move notation as text, and — when `diagrams` is on and the source is a
/// game — splice a `diagram` into the flow after each move whose comment
/// carries a diagram marker (ChessBase `#` / `#[caption]`, Scid `[d]` / `[D]`,
/// `\diagram`, `%%diagram`). Embedded diagrams are made in a context, so they are
/// not individually referenceable.
///
/// - source (dictionary, str, array): a parsed *game*, a *move-text string*, or a
///   *SAN array*.
/// - ..args (arguments): the formatting options — `from` / `to` (mainline slice),
///   `line` (render one variation), `figurine`, `lang`, `nags`, `comments`,
///   `variations`, `variation-style` (`"inline"` / `"block"`), `bold-mainline`,
///   `move-numbers`, `spaced` (space after the move number, default on),
///   `result`, and the embedding switches `diagrams` / `annotations`. The
///   `auto`-defaulting ones consult `set-pgn-defaults`.
/// -> content
#let notation(source, ..args) = {
  let named = args.named()
  let all-opts = ("from", "to", "line", "figurine", "lang", "nags", "comments", "variations", "variation-style", "bold-mainline", "move-numbers", "spaced", "result")
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
      let numbering-start = game-start(source)
      let lo = if named.at("from", default: none) != none { _index-of-loc(named.from, start: numbering-start) } else { 0 }
      let hi = if named.at("to", default: none) != none { _index-of-loc(named.to, start: numbering-start) } else { nodes.len() - 1 }
      let process-anno = if named.at("annotations", default: auto) != auto { named.annotations } else { pg.annotations }
      let run-opts = _text-opts(named, ("figurine", "lang", "nags", "comments", "variations", "variation-style", "bold-mainline", "move-numbers", "spaced"))

      let parts = ()
      let run-start = lo
      for idx in range(lo, hi + 1) {
        let info = _interpret-comment(nodes.at(idx).at("comment-after", default: none))
        if info.diagram != none {
          parts.push(_notation-text(source, from: _loc-of-index(run-start, start: numbering-start), to: _loc-of-index(idx, start: numbering-start), result: false, ..run-opts))
          let cap = if info.diagram.caption == none { none } else { [#info.diagram.caption] }
          // An embedded diagram is an ORDINARY diagram: handing `source` (the
          // game) with `at:` gets the %cal/%csl and quality badge from `diagram`
          // itself, so nothing is re-derived here (deriving them again would
          // DOUBLE the arrows). The one argument choice specific to this context
          // is `game-info: none` — the reader is already inside this game's
          // movetext, often several times per page, so repeating the roster line
          // under each board is noise. It is a plain per-call argument any user
          // could pass, not a privileged path.
          parts.push(diagram(
            source,
            at: _loc-of-index(idx, start: numbering-start),
            caption: cap,
            game-info: none,
            annotations: process-anno,
          ))
          run-start = idx + 1
        }
      }
      if run-start <= hi {
        parts.push(_notation-text(source, from: _loc-of-index(run-start, start: numbering-start), to: _loc-of-index(hi, start: numbering-start), result: false, ..run-opts))
      }
      let body = parts.map(c => [#c]).join()
      if named.at("result", default: false) { body = [#body #game-result(source)] }
      body
    }
  }
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
#let diagram-outline(title: auto, lang: auto, ..args) = context {
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
#let table-outline(title: auto, lang: auto, ..args) = context {
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
#let outlines(diagram-title: auto, table-title: auto, lang: auto, ..args) = {
  diagram-outline(title: diagram-title, lang: lang, ..args)
  table-outline(title: table-title, lang: lang, ..args)
}
