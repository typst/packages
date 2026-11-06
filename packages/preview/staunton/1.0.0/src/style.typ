// ===========================================================================
// Styling: presentation config, kept separate from game/position data.
//
// There are five style buckets:
//   * BOARD style   -- everything the board renderer draws: square colors,
//     labels, piece set, highlights, grid, arrows, ...  Consumed by `board()` /
//     `render-board`.
//   * DIAGRAM style -- the #figure wrapper around a board: the above game-info
//     line (bold? gap?) and the figure supplement. Consumed by `diagram`.
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

// Are we rendering for an HTML target? `target()` and `html.frame` are Typst
// 0.15+, and they are the library's ONLY hard dependency on 0.15 -- everything
// else renders on 0.14. Testing `sys.version` first means `target()` is never
// evaluated on an older compiler (`and` short-circuits), so paged (PDF/PNG)
// output keeps working there while HTML export stays a 0.15+ feature.
//
// Shared by every renderer that has an HTML-specific branch, so the version
// predicate exists exactly once: board.typ (wraps the board in `html.frame`)
// and tournament.typ (skips `align`, which native HTML export does not support).
#let _html-target() = (sys.version.at(0) > 0 or sys.version.at(1) >= 15) and target() == "html"

// Shared base color for the default highlight fill AND the default arrow color
// (arrows default to the highlight color). The transparency
// is applied separately by the renderer via `highlight-transparency` /
// `arrow-transparency`, so this base is stored fully opaque.
#let default-highlight-base = rgb(60, 130, 90)
// "border" mode label themes: the FIXED-color themes "brown", "creme", "dark"
// and "light". The two MATERIAL themes ("wood", "marble") have no constants
// here on purpose -- they derive their band and label from the board's own
// colors (see `_band-colors` in src/board.typ), so they follow `color-theme`
// instead of fighting it.
// NOTE: `border-brown` (the brown theme's BAND) and `border-saddle` (the creme
// theme's LABEL) are two DIFFERENT browns and must stay separate constants --
// brown/creme are deliberately not a mirrored pair, unlike dark/light.
#let border-brown = rgb("#4a3319")        // "espresso" brown band (brown theme)
#let border-creme = rgb("#f3ecd8")        // creme-white: brown-theme labels, creme-theme band
#let border-saddle = rgb("#6b4423")       // "saddle" brown labels (creme theme)
#let border-dark = rgb("#2b2b2b")         // charcoal: dark-theme band, light-theme labels
#let border-dark-label = rgb("#e8e8e8")   // light-grey: dark-theme labels, light-theme band

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
  // light-square labels (default); "brown" = espresso-brown band, creme labels;
  // "creme" = creme band, saddle-brown labels; "dark" = charcoal band, light-grey
  // labels (a neutral dark-mode look); "light" = light-grey band, charcoal labels
  // (the mirror of "dark"). The two MATERIAL themes differ from those five: they
  // take no fixed colors at all -- "wood" and "marble" derive their band from
  // the board's own palette (dark square darkened 32%, light square as the
  // label) and composite a grain/veining texture over it, so the band follows
  // `color-theme` instead of clashing with it. Note "creme" is NOT a mirrored
  // "brown": the two use different browns by design.
  border-theme: "square",     // "square" | "brown" | "creme" | "dark" | "light" | "wood" | "marble"
  border: 0.5pt + luma(40),   // thin board outline (none to drop)
  // Two-layer theme fields. Both are expanded EAGERLY by the defaults setters
  // and the per-call override layer (see `_expand-themes`) whenever a caller
  // actually supplies one -- at that point the theme key is replaced by its
  // contributed fields. `default-board-style` itself is NOT run through
  // `_expand-themes`, so these two keys still show up with value `none` in a
  // resolved style dict when no theme was ever set; harmless, since nothing
  // reads them.
  // `color-theme`: a built-in name (see `builtin-color-themes`) or a dict from
  // `color-theme(..)` (light/dark only, for now).
  color-theme: none,
  // Square-fill pattern. `none` = flat fill (default, unchanged); "stripes" =
  // thin black diagonal stripes drawn as an overlay on DARK squares only (light
  // squares stay flat). "marble"/"wood" = transparent material overlays
  // composited ON TOP of the flat square colors (they never change the theme
  // colors) -- both pattern BOTH square colors, using a separate asset per
  // color. The artwork is monochrome: it supplies shading only, so the hue
  // always comes from the theme and any `color-theme` works.
  // Each square's overlay is rotated/mirrored by a deterministic per-square
  // orientation so the artwork doesn't look uniformly repeated; marble also
  // alternates between two variants for the same reason.
  // Normally set via `color-theme(.., pattern: ..)` rather than directly,
  // but it lives here as a plain board-style field so it flows through the
  // same three-layer merge as `light`/`dark`.
  pattern: none,          // none | "stripes" | "marble" | "wood"
  // Whether a material `pattern` is also drawn on LIGHT squares. Default `true`
  // (both square colors patterned, so a wood board reads as inlaid light and
  // dark timber). Set `false` to pattern dark squares only -- which is what
  // "wood" did before 1.0.0, so this is the opt-out for that older look.
  // No effect on "stripes", which is dark-only by construction.
  pattern-light: true,    // bool
  // Lightness nudges applied to the theme's resolved `light`/`dark` pair
  // (HSL lightness only; hue/saturation pass through unchanged), each a signed
  // ratio in [-100%, +100%] (silently clamped outside it). `auto` = no
  // adjustment. Normally set via `color-theme(.., brightness: .., contrast: ..)`
  // rather than directly, but they live here as plain board-style fields so
  // they flow through the same three-layer merge as `light`/`dark`/`pattern`.
  brightness: auto,      // auto | ratio -- shift both squares lighter/darker
  contrast: auto,        // auto | ratio -- spread/compress the light-dark gap
  // `board-theme`: a built-in name (see `builtin-board-themes`) or a dict from
  // `board-theme(..)` (any board style field, plus `color-theme`).
  board-theme: none,
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
  // Marker strokes / margins are proportional to the square by default, so marks
  // scale with the board. Each accepts `auto` (the default ratio shown), a ratio
  // (e.g. `10%` of the square), or an absolute length. See `_resolve-square-dim`.
  cross-width: auto,          // cross stroke width;   auto -> 15% of the square
  circle-width: auto,         // circle stroke width;  auto -> 15% of the square
  cross-margin: auto,         // corner-to-tip distance (cross length); auto -> 10% of the square
  circle-margin: auto,        // circle inset from the border; auto -> 3% of the square
  arrows: (),                 // array of arrows, each `(from, to, color)` e.g. ("f3","e5","G")
  arrow-color: default-highlight-base,  // default arrow color (opaque base)
  arrow-transparency: 35%,    // applied to the default arrow color (thin lines need to stay clearly visible)
  arrow-width: auto,          // shaft width; auto -> 15% of the square (ratio / length also accepted)
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
  outline-title: auto,        // diagram-outline title (auto -> "List of Diagrams")
)

// ---- table style ----------------------------------------------
// The #figure wrapper around a tournament table (standings / cross-table /
// progress). Tables are figures of `kind: "chess-table"` so they get their own
// counter, can be referenced (@label -> "Table 3") and listed by
// `table-outline`. `supplement` / `outline-title` are language-aware
// (auto -> localized), with their own bucket so each defaults independently.
#let default-table-style = (
  supplement: auto,           // figure supplement (auto -> localized "Table")
  outline-title: auto,        // table-outline title (auto -> "List of Tables")
  title-gap: 0.6em,           // gap between an above-table `title` and the table
  grid: "complete",           // rule preset: "complete" | "no-outer" | "header-rule"
  header-align: center,       // alignment of the header row
  header-fill: none,          // header fill: none | "gray" | a color
  body-align: center,         // alignment of body data columns (the name column stays left)
  body-fill: none,            // body fill: none | "zebra" | a color
  table-align: center,        // page alignment of the table (+ title); does NOT move the caption (Typst API wall, see _table-figure)
  caption-bold: false,        // bold the caller's caption text (not the figure's auto "Table N:" prefix; same wall)
  highlight-winners: true,    // bold the rank-1 entity's name + points
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
  diagrams:    false,  // act on embedded diagram markers (consumer: notation, splices boards into the movetext)
  variations:  false,  // splice variations (RAVs) into notation output
  bold-mainline: true, // render mainline moves bold (variations stay normal)
  spaced:      true,   // space after the move number ("24. Nf3"); false -> dense ("24.Nf3")
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

// ---- board themes -----------------------------------------------------
// Two-layer theming on top of the plain style fields above:
//   * `color-theme(..)` bundles just `light` / `dark` (more fields land here in
//     later phases -- brightness/contrast/pattern).
//   * `board-theme(..)` bundles any board style field (plus a nested
//     `color-theme`) into one reusable "look".
// Both accept a built-in name (string) OR a value from the constructor; user
// themes are plain `#let`-bound values, not registered anywhere -- only the
// BUILT-INS below are reachable by string name.

// Keep the allowed-key list named so later phases (brightness/contrast/pattern)
// can extend it in one place.
#let color-theme-keys = ("light", "dark", "pattern", "brightness", "contrast")

// Validate a color-theme fields dict -- shared by the `color-theme(..)`
// constructor AND `_resolve-color-theme` (a hand-rolled dict passed straight as
// `color-theme: (..)` is indistinguishable from the constructor's output, so
// this guard must ALSO run at resolve time, or a raw dict bypasses it entirely).
#let _validate-color-theme-fields(f) = {
  for k in f.keys() {
    assert(color-theme-keys.contains(k),
      message: "unknown color theme option: \"" + k + "\" (expected one of " + repr(color-theme-keys) + ")")
  }
  for k in ("light", "dark") {
    if k in f {
      assert(type(f.at(k)) == color,
        message: "color theme `" + k + "` must be a color; got " + repr(f.at(k)))
    }
  }
  if "pattern" in f {
    let p = f.at("pattern")
    assert(p == none or p == "stripes" or p == "marble" or p == "wood",
      message: "unknown pattern: " + repr(p) + " (expected `none`, \"stripes\", \"marble\", or \"wood\")")
  }
  for k in ("brightness", "contrast") {
    if k in f {
      let v = f.at(k)
      assert(v == auto or type(v) == ratio,
        message: "color theme `" + k + "` must be `auto` or a ratio; got " + repr(v))
    }
  }
}

// ---- brightness / contrast adjustment ----------------------------------
// Pure HSL-lightness math (see prompt-38 §2/§12/§13). Applied ONCE, by
// `render-board`, to the final resolved `light`/`dark` pair -- NOT inside
// `_resolve-color-theme`/`_expand-themes`, which stay pure merge/lookup.

// `c` (a color) -> (h: angle, s: ratio, l: float in 0..1). `l` is unwrapped to
// a plain float so it can take part in the arithmetic below; `h`/`s` are kept
// as-is since they only ever pass through unchanged.
#let _rgb-to-hsl(c) = {
  let (h, s, l, ..) = c.hsl().components()
  (h: h, s: s, l: l / 100%)
}

// (h: angle, s: ratio, l: float in 0..1) -> color, the inverse of `_rgb-to-hsl`.
#let _hsl-to-rgb(h, s, l) = rgb(color.hsl(h, s, l * 100%))

// Nudge a resolved `light`/`dark` color pair's lightness by `brightness`
// (shift both together) and `contrast` (spread/compress the gap around their
// own midpoint), each `auto` (no-op) or a signed ratio silently clamped to
// [-100%, +100%]. Hue/saturation of each color pass through unchanged. The
// result is always held at least 5% apart in lightness, with `light` forced
// to stay the lighter of the two. When both inputs are `auto` (or both `0%`)
// and the pair is already >= 5% apart, this is an exact identity.
// -> (light: color, dark: color)
#let _adjust-color-pair(light, dark, brightness, contrast) = {
  let b = if brightness == auto { 0.0 } else { calc.clamp(brightness / 100%, -1.0, 1.0) }
  let c = if contrast == auto { 0.0 } else { calc.clamp(contrast / 100%, -1.0, 1.0) }

  let (h: h-light, s: s-light, l: l-light) = _rgb-to-hsl(light)
  let (h: h-dark, s: s-dark, l: l-dark) = _rgb-to-hsl(dark)

  // Step 2: brightness, applied independently to each lightness.
  let brighten(l) = if b >= 0 { l + b * (1 - l) } else { l + b * l }
  let l1-light = brighten(l-light)
  let l1-dark = brighten(l-dark)

  // Step 3: contrast, around the midpoint of the post-brightness values.
  let m1 = (l1-light + l1-dark) / 2
  let l2-light = m1 + (l1-light - m1) * (1 + c)
  let l2-dark = m1 - (m1 - l1-dark) * (1 + c)

  // Step 4: enforce the 5%-separation floor and [0,1] bounds together, with
  // `light` forced to be the lighter of the pair (field identity, not
  // magnitude).
  let m2 = (l2-light + l2-dark) / 2
  let half = calc.max((l2-light - l2-dark) / 2, 0.025)
  let m3 = calc.clamp(m2, half, 1 - half)
  let l3-light = m3 + half
  let l3-dark = m3 - half

  (
    light: _hsl-to-rgb(h-light, s-light, l3-light),
    dark: _hsl-to-rgb(h-dark, s-dark, l3-dark),
  )
}

// Validate a board-theme fields dict -- shared by the `board-theme(..)`
// constructor AND `_resolve-board-theme` (same reasoning as
// `_validate-color-theme-fields`: a raw dict must be caught at resolve time).
// A board-theme is deliberately FLAT: it may reference a `color-theme`, but not
// another `board-theme` -- no recursion, compose with `color-theme` instead.
#let _validate-board-theme-fields(f) = {
  _reject-flip(f)
  _reject-non-default-board(f)
  assert(not ("board-theme" in f),
    message: "a board-theme cannot contain another board-theme; compose with `color-theme` instead")
  for k in f.keys() {
    assert(board-style-keys.contains(k), message: "unknown board theme option: " + k)
  }
}

// Built-in registries (plain dicts, not state -- these are static catalogues,
// not document-order overrides). Derive "staunton-default" FROM the factory
// dict so the two can never drift apart.
//
// The nine square-color pairs below ("scid" through "wheat") are reproduced
// from kokopu-react (https://github.com/yo35/kokopu-react), LGPL-3.0,
// (c) Yoann Le Montagner. Several are named for and reproduce the look of
// external sources: "wikipedia" (Wikipedia's chess diagrams), "scid" (the
// SCID database app), "xboard" (XBoard). Only the square COLORS are
// borrowed -- the board chrome (labels/border) below stays staunton's own
// house style, matching "staunton-default".
#let builtin-color-themes = (
  "staunton-default": (light: default-board-style.light, dark: default-board-style.dark),
  "dutch-gray": (light: rgb("#ffffff"), dark: rgb("#d1d2d4")),
  "scid": (light: rgb("#f3f3f3"), dark: rgb("#7389b6")),
  "wikipedia": (light: rgb("#ffce9e"), dark: rgb("#d18b47")),
  "xboard": (light: rgb("#c8c365"), dark: rgb("#77a26d")),
  "coral": (light: rgb(177, 228, 185), dark: rgb(112, 162, 163)),
  "dusk": (light: rgb(204, 183, 174), dark: rgb(112, 102, 119)),
  "emerald": (light: rgb(173, 189, 143), dark: rgb(111, 143, 114)),
  "marine": (light: rgb(157, 172, 255), dark: rgb(111, 115, 210)),
  "sandcastle": (light: rgb(227, 193, 111), dark: rgb(184, 139, 74)),
  "wheat": (light: rgb(234, 240, 206), dark: rgb(187, 190, 100)),
)

// INVARIANT: every built-in board-theme sets the SAME key set (currently
// `color-theme`, `labels`, `border`) -- so switching between any two built-ins
// is symmetric and never leaves a stale field behind from whichever theme
// applied previously. If a future built-in adds a key, "staunton-default" must
// gain it too, derived from the factory default (`default-board-style`), so
// applying "staunton-default" always fully restores house style.
#let builtin-board-themes = (
  "staunton-default": (
    color-theme: "staunton-default",
    labels: default-board-style.labels,
    border: default-board-style.border,
  ),
  "dutch-gray": (color-theme: "dutch-gray", labels: false, border: none),
  "scid": (
    color-theme: "scid",
    labels: default-board-style.labels,
    border: default-board-style.border,
  ),
  "wikipedia": (
    color-theme: "wikipedia",
    labels: default-board-style.labels,
    border: default-board-style.border,
  ),
  "xboard": (
    color-theme: "xboard",
    labels: default-board-style.labels,
    border: default-board-style.border,
  ),
  "coral": (
    color-theme: "coral",
    labels: default-board-style.labels,
    border: default-board-style.border,
  ),
  "dusk": (
    color-theme: "dusk",
    labels: default-board-style.labels,
    border: default-board-style.border,
  ),
  "emerald": (
    color-theme: "emerald",
    labels: default-board-style.labels,
    border: default-board-style.border,
  ),
  "marine": (
    color-theme: "marine",
    labels: default-board-style.labels,
    border: default-board-style.border,
  ),
  "sandcastle": (
    color-theme: "sandcastle",
    labels: default-board-style.labels,
    border: default-board-style.border,
  ),
  "wheat": (
    color-theme: "wheat",
    labels: default-board-style.labels,
    border: default-board-style.border,
  ),
)

// Build a copy of `d` without the given keys. Deliberately NOT `d.remove(..)`:
// a theme dict is typically bound to more than one variable at once (e.g. the
// same `color-theme` value referenced both directly and nested inside a
// `board-theme`), and inside a function `.remove(..)` was found to mutate the
// shared underlying dict rather than copy it when more than one binding is
// live -- rebuilding here sidesteps that entirely.
#let _without-keys(d, keys) = {
  let r = (:)
  for (k, v) in d {
    if not keys.contains(k) { r.insert(k, v) }
  }
  r
}

// Resolve a `color-theme:` value (built-in name or constructor dict, OR a
// hand-rolled dict -- validated here since the two are indistinguishable) to
// its contributed fields.
#let _resolve-color-theme(v) = {
  if type(v) == str {
    assert(builtin-color-themes.keys().contains(v),
      message: "unknown built-in color theme: \"" + v + "\" (expected one of " + repr(builtin-color-themes.keys()) + ")")
    builtin-color-themes.at(v)
  } else if type(v) == dictionary {
    _validate-color-theme-fields(v)
    v
  } else {
    panic("color-theme must be a built-in name (string) or a dict from `color-theme(..)`; got " + repr(type(v)))
  }
}

// Resolve a `board-theme:` value (built-in name or constructor dict, OR a
// hand-rolled dict -- validated here since the two are indistinguishable) to
// its contributed fields, expanding its OWN nested `color-theme` first (inside
// the board-theme's contribution -- see the precedence rule in
// `_expand-themes`). A nested `color-theme` key is always stripped, even when
// its value is `none` (a no-op theme), so it never leaks into the result.
#let _resolve-board-theme(v) = {
  let bt = if type(v) == str {
    assert(builtin-board-themes.keys().contains(v),
      message: "unknown built-in board theme: \"" + v + "\" (expected one of " + repr(builtin-board-themes.keys()) + ")")
    builtin-board-themes.at(v)
  } else if type(v) == dictionary {
    _validate-board-theme-fields(v)
    v
  } else {
    panic("board-theme must be a built-in name (string) or a dict from `board-theme(..)`; got " + repr(type(v)))
  }
  if "color-theme" in bt {
    let ctv = bt.color-theme
    bt = _without-keys(bt, ("color-theme",))
    if ctv != none {
      bt = _resolve-color-theme(ctv) + bt
    }
  }
  bt
}

/// Bundle a reusable color pairing (`light` / `dark`, plus `pattern`,
/// `brightness`, `contrast`) for use as `color-theme:` on `board()`,
/// `set-board-defaults`, or inside a `board-theme`.
///
/// - ..fields (arguments): `light` and/or `dark` colors; `pattern` (`none`;
///   `"stripes"`, diagonal stripes on dark squares only; or `"marble"` / `"wood"`,
///   material overlays on both squares -- the material overlays are composited
///   over the theme colors, never replacing them, and carry only light and
///   shadow, so the hue always comes from the theme. Set `pattern-light: false`
///   on the board to restrict a material to dark squares); `brightness` and `contrast`
///   (each `auto` or a signed ratio, e.g. `10%`/`-5%`, default `auto` = no
///   adjustment) nudge the resolved `light`/`dark` pair's HSL lightness --
///   `brightness` shifts both squares lighter/darker together, `contrast`
///   spreads or compresses the gap between them, around their own midpoint.
///   Hue/saturation are untouched. Values outside `[-100%, +100%]` are
///   silently clamped, and the pair is always held at least 5% apart
///   (lightness-wise), with `light` staying the lighter of the two; `base`
///   (a built-in color-theme name or another color-theme value to derive
///   from; its fields are merged in first, then this call's own fields
///   override them); unknown keys error.
/// -> dictionary
#let color-theme(..fields) = {
  let f = fields.named()
  if "base" in f {
    let basev = f.at("base")
    f = _without-keys(f, ("base",))
    f = _resolve-color-theme(basev) + f
  }
  _validate-color-theme-fields(f)
  f
}

/// Bundle a reusable board "look" -- any board style field, plus a nested
/// `color-theme` -- for use as `board-theme:` on `board()` or
/// `set-board-defaults`. `flip`/`orientation`, the position-specific
/// `highlight`/`arrows`/`move-quality-mark`, and a nested `board-theme` are all
/// rejected (a board-theme is flat; compose colors via `color-theme`).
///
/// - ..fields (arguments): named board style options, plus `color-theme`;
///   also `base` (a built-in board-theme name or another board-theme value
///   to derive from; its fields are merged in first, then this call's own
///   fields override them -- this composes with the nested `color-theme`
///   derivation above); unknown keys error.
/// -> dictionary
#let board-theme(..fields) = {
  let f = fields.named()
  if "color-theme" in f {
    let ctv = f.at("color-theme")
    f = _without-keys(f, ("color-theme",))
    if ctv != none {
      f = _resolve-color-theme(ctv) + f
    }
  }
  if "base" in f {
    let basev = f.at("base")
    f = _without-keys(f, ("base",))
    f = _resolve-board-theme(basev) + f
  }
  _validate-board-theme-fields(f)
  f
}

/// Expand `board-theme` / `color-theme` keys in a style layer into the fields
/// they contribute, per the precedence rule (later wins):
///   board-theme's fields  <  explicit color-theme  <  explicit individual fields
/// Pure and side-effect free (no `context`, no state reads), so it is
/// independently testable. The theme keys themselves are removed from the
/// result; every OTHER key in `layer` passes through untouched (and, being
/// explicit individual fields, wins over both theme layers).
///
/// - layer (dictionary): a style layer that may contain `board-theme` and/or
///   `color-theme`.
/// -> dictionary
#let _expand-themes(layer) = {
  if not ("board-theme" in layer) and not ("color-theme" in layer) {
    return layer
  }
  let bt-fields = if "board-theme" in layer and layer.board-theme != none {
    _resolve-board-theme(layer.board-theme)
  } else { (:) }
  let ct-fields = if "color-theme" in layer and layer.color-theme != none {
    _resolve-color-theme(layer.color-theme)
  } else { (:) }
  let rest = _without-keys(layer, ("board-theme", "color-theme"))
  bt-fields + ct-fields + rest
}

/// Set default *board* style fields for all subsequent boards and diagrams
/// (document-order state, like a Typst `#set`). `flip` is rejected (per-diagram
/// only), as are the position-specific `highlight` / `arrows` (per-call only) and
/// `move-quality-mark` (supplied by `diagram-after`).
///
/// - ..fields (arguments): named board style options (`size`, `light`, `dark`,
///   `labels`, `label-mode`, `piece-set`, …), plus `color-theme` / `board-theme`;
///   unknown keys error.
/// -> content
#let set-board-defaults(..fields) = {
  let f = fields.named()
  _reject-flip(f)
  _reject-non-default-board(f)
  for k in f.keys() {
    assert(board-style-keys.contains(k), message: "unknown board style option: " + k)
  }
  // `color-theme` / `board-theme` are expanded EAGERLY, unlike every other
  // field here: `board-style-state` is a single merged dict, so two calls lose
  // their relative order once merged. Expanding HERE -- before `state.update`,
  // not inside its closure -- records the correct result as it happens, at
  // call time (see the module header comment above `_expand-themes`). Expanding
  // inside the closure would look equivalent today (the helper is pure), but
  // would silently give back call-time evaluation the moment it stops being
  // pure -- so the hoist is deliberate, not cosmetic.
  let expanded = _expand-themes(f)
  board-style-state.update(s => s + expanded)
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

// Validate a (possibly partial) table style dictionary, erroring with a clear
// message on the first bad value. Called both from `set-table-defaults` (so a
// document-wide default is caught early) and at render time on the merged
// style (so a bad per-call value is caught too).
#let _valid-grids = ("complete", "no-outer", "header-rule")
#let _valid-aligns = (left, center, right)

#let validate-table-style(st) = {
  if "grid" in st {
    assert(_valid-grids.contains(st.grid),
      message: "unknown table grid: " + repr(st.grid) + " (expected \"complete\", \"no-outer\", or \"header-rule\")")
  }
  for k in ("header-align", "body-align", "table-align") {
    if k in st {
      assert(_valid-aligns.contains(st.at(k)),
        message: "unknown table " + k + ": " + repr(st.at(k)) + " (expected left, center, or right)")
    }
  }
  if "header-fill" in st {
    let v = st.header-fill
    assert(v == none or v == "gray" or str(type(v)) == "color",
      message: "unknown table header-fill: " + repr(v) + " (expected none, \"gray\", or a color)")
  }
  if "body-fill" in st {
    let v = st.body-fill
    assert(v == none or v == "zebra" or str(type(v)) == "color",
      message: "unknown table body-fill: " + repr(v) + " (expected none, \"zebra\", or a color)")
  }
  for k in ("caption-bold", "highlight-winners") {
    if k in st {
      assert(type(st.at(k)) == bool,
        message: "unknown table " + k + ": " + repr(st.at(k)) + " (expected true or false)")
    }
  }
}

/// Set default *table* style fields (the `#figure` wrapper around tournament
/// tables, plus rules/fills/alignment for the `*-table` renderers) for
/// subsequent `*-table` renderers.
///
/// - ..fields (arguments): named table style options — `supplement`
///   (default "Table"), `outline-title`, `title-gap`, `grid`, `header-align`,
///   `header-fill`, `body-align`, `body-fill`, `table-align`, `caption-bold`,
///   `highlight-winners`; unknown keys error.
/// -> content
#let set-table-defaults(..fields) = {
  let f = fields.named()
  for k in f.keys() {
    assert(table-style-keys.contains(k), message: "unknown table style option: " + k)
  }
  validate-table-style(f)
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
  // `bd` is a board-style bucket, so `color-theme` / `board-theme` may be in
  // it -- expand eagerly (hoisted OUT of the closure), same reasoning as
  // `set-board-defaults`.
  let expanded-bd = _expand-themes(bd)
  if expanded-bd.len() > 0 { board-style-state.update(s => s + expanded-bd) }
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
