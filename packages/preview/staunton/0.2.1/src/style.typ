// ===========================================================================
// Styling: presentation config, kept separate from game/position data.
//
// There are five style buckets:
//   * BOARD style   -- everything the board renderer draws: square colors,
//     labels, piece set, highlights, grid, arrows, ...  Consumed by `board()` /
//     `render-board`.
//   * DIAGRAM style -- the #figure wrapper around a board: the above game-info
//     line (bold? gap?) and the figure supplement. Consumed by `chess-diagram`.
//   * TABLE style   -- the #figure wrapper around a tournament table (supplement,
//     outline title, title gap). Consumed by the `*-table` renderers.
//   * I18N          -- the document language for all language-aware strings.
//   * PGN handling  -- which embedded PGN extras are interpreted at render time.
//
// Each bucket has a factory default dict, a document-order state, and a setter.
// Resolution merges three layers (later wins):
//   factory default  ⊕  document default (state)  ⊕  per-call override
//
// NOTE: board flipping is intentionally NOT a style field. It is a per-diagram
// decision (pass `flip: true`), so it cannot be set as a document default.
// ===========================================================================

#import "pieces.typ": default-white-fill, default-black-fill, default-piece-fonts, default-piece-set

// Shared base color for the default highlight fill AND the default arrow color
// (arrows default to the highlight color). The transparency
// is applied separately by the renderer via `highlight-transparency` /
// `arrow-transparency`, so this base is stored fully opaque.
#let default-highlight-base = rgb(60, 130, 90)
// "border" mode label themes: the "brown" and "dark" themes.
#let border-brown = rgb("#2c1d0e")        // very dark brown band
#let border-creme = rgb("#f3ecd8")        // creme-white labels (brown theme)
#let border-dark = rgb("#2b2b2b")         // charcoal band (dark-mode theme)
#let border-dark-label = rgb("#e8e8e8")   // light-grey labels (dark theme)

// ---- board style ----------------------------------------------------------
#let default-board-style = (
  size: auto,                 // auto | length | ratio
  light: rgb("#f0d9b5"),
  dark: rgb("#b58863"),
  labels: true,
  // Board labels use their own sans-serif, independent of the document/diagram
  // font. The default leads with Arial (present on Windows & macOS) and falls
  // back to Typst's embedded "DejaVu Sans Mono" (always available), so a stock
  // install draws labels without "unknown font family" warnings. Override with a
  // single family or a fallback list, e.g. `label-font: "Segoe UI"`.
  label-font: ("Arial", "DejaVu Sans Mono"),
  label-mode: "on-square",    // "on-square" | "outside" | "border"
  file-side: bottom,          // bottom | top
  rank-side: right,           // right | left
  // on-square label corner placement. Vertical edge is fixed
  // (files at the bottom edge, ranks at the top edge); these pick the horizontal
  // corner. file: lower-left (default) or lower-right; rank: upper-right
  // (default) or upper-left.
  file-label-corner: left,    // left | right
  rank-label-corner: right,   // right | left
  // "border" mode theme: "square" = dark-square band with
  // light-square labels (default); "brown" = very-dark-brown band, creme labels;
  // "dark" = charcoal band, light-grey labels (a neutral dark-mode look).
  border-theme: "square",     // "square" | "brown" | "dark"
  border: 0.5pt + luma(40),   // thin board outline (none to drop)
  grid: false,                // 1pt grid lines between squares
  piece-set: default-piece-set, // SVG set name, or "unicode" for the glyph fallback
  piece-scale: 0.95,          // fraction of a square the piece occupies
  baseline-inset: 0.20,       // glyph fallback only: baseline lift (fraction of a square)
  label-color: luma(90),      // "outside" mode strip labels
  label-border-ratio: 0.07,   // "border" mode band width as a fraction of the board
  white-fill: default-white-fill, // glyph fallback only
  black-fill: default-black-fill, // glyph fallback only
  piece-font: default-piece-fonts, // glyph fallback only
  piece-glyphs: (:),          // glyph fallback: extra `kind -> glyph` entries for
                              // custom (fairy) kinds; overrides the built-in six.
                              // Auto-seeded from a custom variant's `glyphs:` map.
  // Highlights. Entries: a square name "e4" (uses
  // highlight-shape + highlight-fill), a (square, color) pair (filled, explicit
  // color -- e.g. PGN %csl), or a dict (square:, shape:, color:) for full
  // control. Shapes: "filled" | "cross" | "circle". By convention a "cross"
  // marks an EMPTY square (it would clash with a piece); not enforced.
  highlight: (),
  highlight-shape: "filled",  // default shape for plain-string entries
  highlight-fill: default-highlight-base,   // filled-highlight color (opaque base)
  highlight-transparency: 75%,              // applied to highlight-fill
  cross-color: red,           // cross highlight stroke color
  circle-color: green,        // circle highlight stroke color
  cross-width: 2pt,           // cross stroke width
  circle-width: 2pt,          // circle stroke width
  arrows: (),                 // array of arrows, each `(from, to, color)` e.g. ("f3","e5","G")
  arrow-color: default-highlight-base,  // default arrow color (opaque base)
  arrow-transparency: 85%,    // applied to the default arrow color (more transparent than highlights)
  arrow-width: auto,          // shaft width; auto -> proportional to the square
  // In-check indicator. A radial glow (color -> transparent) on the
  // king that is in check, drawn under the piece. `check` gates it; `check-color`
  // is the glow's inner color. `check-square` is the marked square, auto-filled
  // by `board()` from the side-to-move's king for ANALYZABLE variants (standard
  // chess) and user-overridable; it stays `none` for fairy/bare positions.
  check: false,               // show the in-check glow
  check-color: red,           // glow inner color (fades to its own transparent)
  check-square: none,         // square name to glow, or none (auto-filled)
  // Move-quality indicator. A small badge on the destination square
  // of the last move, colored by the move's assessment. `move-quality` gates it;
  // `move-quality-mark` is the data `(square: "e5", symbol: "!!")`. Because a badge
  // is tied to a MOVE, it is derived and injected ONLY by `diagram-after` (from the
  // move's quality NAG / literal suffix) -- never settable on a bare position, and
  // never on an empty square. Per-category backgrounds are settable; text is white.
  move-quality: false,        // show the move-quality badge
  move-quality-mark: none,    // (square: <name>, symbol: <! ? !! ?? !? ?!>) — internal, set by diagram-after only
  move-quality-colors: (
    good: rgb("#4b8fd1"),        // ! !!   (light blue)
    bad: rgb("#c0392b"),         // ? ??   (red)
    interesting: rgb("#67a04a"), // !? ?!  (green)
  ),
  // Mapping from PGN %cal/%csl color letters to colors.
  annotation-colors: (
    G: rgb(21, 120, 27, 200),   // green
    R: rgb(136, 32, 32, 200),   // red
    Y: rgb(224, 160, 0, 200),   // yellow
    B: rgb(0, 70, 160, 200),    // blue
    O: rgb(224, 110, 0, 200),   // orange
  ),
)

// ---- i18n -----------------------------------------------------
// One document-wide language setting drives every language-aware string
// (diagram / table supplements, outline titles, and notation piece letters).
//   * a code ("en", "de", ...) -> that language;
//   * "auto"                    -> follow `#set text(lang: ..)`.
// Default "en". Per-call `lang:` arguments override this; they default to the
// `auto` VALUE meaning "consult this document setting".
#let default-i18n-style = (
  lang: "en",
)

// ---- diagram style --------------------------------------------------------
// `supplement` / `outline-title` default to the `auto` VALUE = "use the
// language-aware string"; set a literal (content) to override, per document or
// per call.
#let default-diagram-style = (
  info-bold: true,            // bold the auto game-info line
  info-gap: 0.6em,            // space between the game-info line and the board
  supplement: auto,           // figure supplement (auto -> localized "Diagram")
  outline-title: auto,        // chess-diagram-outline title (auto -> "List of Diagrams")
)

// ---- table style ----------------------------------------------
// The #figure wrapper around a tournament table (standings / cross-table /
// progress). Tables are figures of `kind: "chess-table"` so they get their own
// counter, can be referenced (@label -> "Table 3") and listed by
// `chess-table-outline`. `supplement` / `outline-title` are language-aware
// (auto -> localized), with their own bucket so each defaults independently.
#let default-table-style = (
  supplement: auto,           // figure supplement (auto -> localized "Table")
  outline-title: auto,        // chess-table-outline title (auto -> "List of Tables")
  title-gap: 0.6em,           // gap between an above-table `title` and the table
)

// ---- PGN handling ---------------------------------------------
// How PGN-embedded extras are HANDLED at render time. Parsing stays lossless;
// these switches only decide what gets *interpreted/shown*. The content-extra
// switches default OFF (reading a PGN yields plain movetext unless you opt in);
// `bold-mainline` is presentation only and defaults ON.
#let default-pgn-style = (
  annotations: false,  // process %cal/%csl comment commands -> arrows/highlights
  nags:        false,  // render NAGs ("Nf3!", "d4⩲") in notation
  comments:    false,  // include comment prose in notation
  diagrams:    false,  // act on embedded diagram markers (consumer: chess-notation, splices boards into the movetext)
  variations:  false,  // splice variations (RAVs) into notation output
  bold-mainline: true, // render mainline moves bold (variations stay normal)
)

// Document-wide overrides (document-order state, like Typst's own #set).
#let board-style-state = state("staunton-board-style", (:))
#let diagram-style-state = state("staunton-diagram-style", (:))
#let table-style-state = state("staunton-table-style", (:))
#let i18n-style-state = state("staunton-i18n-style", (:))
#let pgn-style-state = state("staunton-pgn-style", (:))

#let board-style-keys = default-board-style.keys()
#let diagram-style-keys = default-diagram-style.keys()
#let table-style-keys = default-table-style.keys()
#let i18n-style-keys = default-i18n-style.keys()
#let pgn-style-keys = default-pgn-style.keys()

// Board options that are inherently *position-specific* and therefore make no
// sense as document-wide defaults (a single default would stamp the SAME squares
// on every later board). `highlight` / `arrows` are per-CALL board arguments;
// `move-quality-mark` is derived from a game move by `diagram-after`. All three
// stay valid where they belong (see `board` / `diagram`); the defaults setters
// reject them.
#let board-non-default-keys = ("highlight", "arrows", "move-quality-mark")

// ---- setters --------------------------------------------------------------
#let _reject-flip(f) = assert(
  not ("flip" in f) and not ("orientation" in f),
  message: "board flipping is per-diagram only; pass `flip: true` to a diagram, not to a defaults setter",
)

// Reject the position-specific board keys (see `board-non-default-keys`) from a
// defaults setter, naming the offender and pointing at where it belongs.
#let _reject-non-default-board(f) = {
  for k in f.keys() {
    assert(not board-non-default-keys.contains(k),
      message: "`" + k + "` is position-specific and cannot be a document default; pass `highlight` / `arrows` per call, and let `diagram-after` supply the move-quality badge")
  }
}

/// Set default *board* style fields for all subsequent boards and diagrams
/// (document-order state, like a Typst `#set`). `flip` is rejected (per-diagram
/// only), as are the position-specific `highlight` / `arrows` (per-call only) and
/// `move-quality-mark` (supplied by `diagram-after`).
///
/// - ..fields (arguments): named board style options (`size`, `light`, `dark`,
///   `labels`, `label-mode`, `piece-set`, …); unknown keys error.
/// -> content
#let set-board-defaults(..fields) = {
  let f = fields.named()
  _reject-flip(f)
  _reject-non-default-board(f)
  for k in f.keys() {
    assert(board-style-keys.contains(k), message: "unknown board style option: " + k)
  }
  board-style-state.update(s => s + f)
}

/// Set default *diagram* style fields (the `#figure` wrapper) for subsequent
/// diagrams.
///
/// - ..fields (arguments): named diagram style options (`supplement`,
///   `outline-title`, `info-bold`, `info-gap`, …); unknown keys error.
/// -> content
#let set-diagram-defaults(..fields) = {
  let f = fields.named()
  for k in f.keys() {
    assert(diagram-style-keys.contains(k), message: "unknown diagram style option: " + k)
  }
  diagram-style-state.update(s => s + f)
}

/// Set default *table* style fields (the `#figure` wrapper around tournament
/// tables) for subsequent `*-table` renderers.
///
/// - ..fields (arguments): named table style options — currently `supplement`
///   (default "Table"), `outline-title`, `title-gap`; unknown keys error.
/// -> content
#let set-table-defaults(..fields) = {
  let f = fields.named()
  for k in f.keys() {
    assert(table-style-keys.contains(k), message: "unknown table style option: " + k)
  }
  table-style-state.update(s => s + f)
}

/// Set the document language for all language-aware strings (supplements, outline
/// titles, notation piece letters).
///
/// - code (str): a language code (`"en"`, `"de"`, …) or `"auto"` (follow
///   `#set text(lang: ..)`).
/// -> content
#let set-lang(code) = i18n-style-state.update(s => s + (lang: code))

/// Set default PGN-handling fields for subsequent notation / diagram output.
///
/// - ..fields (arguments): named switches — `annotations`, `nags`, `comments`,
///   `diagrams`, `variations`, `bold-mainline`; unknown keys error.
/// -> content
#let set-pgn-defaults(..fields) = {
  let f = fields.named()
  for k in f.keys() {
    assert(pgn-style-keys.contains(k), message: "unknown pgn handling option: " + k)
  }
  pgn-style-state.update(s => s + f)
}

/// Umbrella setter: route each field to the board, diagram, table, i18n or
/// PGN-handling bucket — handy for setting several defaults at once. `flip` /
/// `orientation` are rejected (per-diagram only), as are the position-specific
/// `highlight` / `arrows` and `move-quality-mark` (see `set-board-defaults`).
///
/// - ..fields (arguments): any named style option from the board, diagram, table,
///   i18n or PGN-handling groups; unknown keys error. (`supplement` /
///   `outline-title`, shared by diagram and table, route to the diagram bucket —
///   use `set-table-defaults` for the table ones.)
/// -> content
#let set-chess-defaults(..fields) = {
  let f = fields.named()
  _reject-flip(f)
  _reject-non-default-board(f)
  let bd = (:)
  let dg = (:)
  let tb = (:)
  let ig = (:)
  let pg = (:)
  for (k, v) in f {
    // `supplement` / `outline-title` are in BOTH diagram and table buckets; the
    // umbrella routes them to DIAGRAM (back-compat). Use set-table-defaults for
    // the table ones.
    if board-style-keys.contains(k) { bd.insert(k, v) }
    else if diagram-style-keys.contains(k) { dg.insert(k, v) }
    else if table-style-keys.contains(k) { tb.insert(k, v) }
    else if i18n-style-keys.contains(k) { ig.insert(k, v) }
    else if pgn-style-keys.contains(k) { pg.insert(k, v) }
    else { panic("unknown style option: " + k) }
  }
  if bd.len() > 0 { board-style-state.update(s => s + bd) }
  if dg.len() > 0 { diagram-style-state.update(s => s + dg) }
  if tb.len() > 0 { table-style-state.update(s => s + tb) }
  if ig.len() > 0 { i18n-style-state.update(s => s + ig) }
  if pg.len() > 0 { pgn-style-state.update(s => s + pg) }
}

/// Set the default piece set for subsequent diagrams — a convenience wrapper over
/// `set-board-defaults(piece-set: set)`. Set it once; every later board/diagram
/// uses it (Typst memoizes the underlying file reads, so a shared loader does not
/// re-read art per board).
///
/// - spec (str | function | dictionary): a bundled name (`"cburnett"`, `"merida"`,
///   `"unicode"`/`none`), or a custom loader — a function `(color, kind) -> bytes
///   | content` (e.g. from `svg-piece-set`), or a dict keyed `"<color>-<kind>"`.
/// -> content
#let set-piece-set(spec) = board-style-state.update(s => s + (piece-set: spec))

/// Build a style-overrides dict (just sugar around named arguments).
#let chess-style(..fields) = fields.named()

// ---- back-compat aliases --------------------------------------------------
// Pre-split names kept so existing importers (board.typ) and tests keep working.
#let default-style = default-board-style
#let style-state = board-style-state
#let style-keys = board-style-keys + diagram-style-keys
