// ===========================================================================
// Piece model & rendering.
//
// Pieces are drawn from SVG piece sets (src/assets/piece_sets/<set>/), with the
// Unicode chess glyphs as a fallback when the set is "unicode"/none. The
// public seam callers use is `square-piece(kind, color, sq, set: ..)`, which
// returns content already sized to a `sq`-side square and hides the SVG-vs-glyph
// difference.
//
// SVG path (default): the bundled SVGs already carry the correct baseline, so we
// just centre them in the square -- no baseline lifting, no per-kind correction.
//
// Glyph fallback: we deliberately use only the SOLID (nominally "black") glyph
// shapes U+265A..U+265F for BOTH colours, and distinguish colour via `fill` + a
// contrasting `stroke`. Reasons:
//   * many fonts render the outline ("white") glyphs poorly or inconsistently;
//   * a single shape keeps white and black pieces visually identical in form;
//   * fill + stroke gives good contrast on both light and dark squares.
// The glyph path keeps the baseline lift + per-kind size correction it needs.
// ===========================================================================

/// The six chess piece kinds: king, queen, rook, bishop, knight, pawn.
#let piece-kinds = ("king", "queen", "rook", "bishop", "knight", "pawn")
/// The two piece colours: white and black.
#let piece-colors = ("white", "black")

// SVG piece sets bundled under src/assets/piece_sets/. `default-piece-set` is the
// factory default; `"unicode"` (or `none`) selects the glyph fallback.
// `known-piece-sets` is the list of sets we SHIP (used by docs/examples); it is
// NOT a guard -- any set name is accepted so users can add their own set by
// dropping a folder under src/assets/piece_sets/<name>/ with no code change. A name
// that has no matching SVG simply fails to load the image (Typst's own error).
/// The factory-default piece set (`"cburnett"`). Set `"unicode"` (or `none`) to
/// select the glyph fallback.
#let default-piece-set = "cburnett"
// Sets bundled with the package (advisory list only -- NOT a guard; any name is
// accepted, see square-piece). Only the GPLv2+ sets ship; the other lichess sets
// are non-commercial-licensed and are not redistributed here.
/// The piece sets bundled with the package (`"cburnett"`, `"merida"`) — an
/// advisory list, not a guard: any set name is accepted (drop a folder under
/// `src/assets/piece_sets/<name>/`).
#let known-piece-sets = ("cburnett", "merida")

// piece kind -> file letter used in the SVG file names ("wK.svg", "bN.svg", ...).
#let kind-letters = (king: "K", queen: "Q", rook: "R", bishop: "B", knight: "N", pawn: "P")

// Internal: glyphs render best at ~0.80 of the square, so the glyph fallback
// applies this factor on top of `piece-scale` (whose 1.0 default fills the SVG
// square). This keeps glyph pieces at the size they were tuned to.
#let _glyph-fit = 0.80

// Solid glyph per kind (U+265A king .. U+265F pawn).
#let piece-glyphs = (
  king: "\u{265A}",
  queen: "\u{265B}",
  rook: "\u{265C}",
  bishop: "\u{265D}",
  knight: "\u{265E}",
  pawn: "\u{265F}",
)

// Per-kind size correction. In the Unicode chess glyphs the pawn is drawn
// proportionally larger than the major pieces at the same font size, so the
// majors look too small next to pawns. We take the pawn as the baseline (1.0)
// and scale the rest up to even out their apparent size on the board.
#let piece-size-ratio = (
  king: 1.18,
  queen: 1.18,
  rook: 1.18,
  bishop: 1.18,
  knight: 1.18,
  pawn: 1.0,
)

// Glyph-fallback (piece-set "unicode") font. We name only Typst's always-embedded
// "DejaVu Sans Mono" so a stock install never warns "unknown font family"; because
// the piece renderer sets `fallback: true`, Typst still auto-resolves the chess
// glyphs (U+2654..265F) from a system symbol font (Segoe UI Symbol, Apple Symbols,
// Noto Sans Symbols 2, ...) when the embedded font lacks them. Override with the
// `piece-font` board option to pin a specific family.
#let default-piece-fonts = ("DejaVu Sans Mono",)

#let default-white-fill = rgb("#fcfcfa")
#let default-black-fill = rgb("#1a1a1a")

/// Map a single FEN piece letter to `(kind, color)` — uppercase = white,
/// lowercase = black (e.g. `"N"` → knight/white, `"q"` → queen/black).
///
/// - letter (str): a one-character FEN piece letter.
/// -> dictionary
#let fen-piece(letter) = {
  let kinds = (p: "pawn", n: "knight", b: "bishop", r: "rook", q: "queen", k: "king")
  let key = lower(letter)
  assert(kinds.keys().contains(key), message: "invalid FEN piece letter: \"" + letter + "\"")
  (kind: kinds.at(key), color: if letter == upper(letter) { "white" } else { "black" })
}

/// Render a single piece as `size`-tall content (no square background) — the SVG
/// piece if the active set has one, else the glyph fallback.
///
/// - kind (str): one of `piece-kinds`.
/// - color (str): `"white"` or `"black"`.
/// - size (length): the glyph font size.
/// - white-fill (color): fill for white pieces.
/// - black-fill (color): fill for black pieces.
/// - stroke-ratio (float): outline width as a fraction of `size`.
/// - font (array): the glyph-fallback font family list.
/// -> content
#let piece-content(
  kind,
  color,
  size,
  white-fill: default-white-fill,
  black-fill: default-black-fill,
  stroke-ratio: 0.03,
  font: default-piece-fonts,
) = {
  assert(piece-kinds.contains(kind), message: "unknown piece kind: \"" + repr(kind) + "\" (expected one of " + repr(piece-kinds) + ")")
  assert(piece-colors.contains(color), message: "unknown piece color: \"" + repr(color) + "\" (expected \"white\" or \"black\")")
  let fill = if color == "white" { white-fill } else { black-fill }
  let stroke-col = if color == "white" { black-fill } else { white-fill }
  let glyph-size = size * piece-size-ratio.at(kind)
  // "bounds" makes the text box hug the actual glyph ink, so that bottom-
  // aligning different-sized pieces puts them all on one common baseline.
  set text(font: font, fallback: true, top-edge: "bounds", bottom-edge: "bounds")
  text(
    size: glyph-size,
    fill: fill,
    stroke: stroke-ratio * glyph-size + stroke-col,
    piece-glyphs.at(kind),
  )
}

/// Render a piece as content sized to a `sq`-side square, ready to be `place`d at
/// the square's screen origin. This is the seam the board renderer uses.
///
///   * any other `piece-set` name -> the matching SVG under
///     src/assets/piece_sets/<name>/, centred in the square. The SVGs carry the
///     correct baseline, so no baseline adjustment is done; `piece-scale` (1.0
///     fills the square) just scales the image. The name is NOT checked against a
///     list -- a missing/misnamed file fails to load (Typst's own error), which
///     lets users add their own sets by dropping in a folder.
///   * `piece-set == "unicode"` or `none` -> the Unicode glyph fallback, which
///     keeps the baseline lift (`baseline-inset`) and per-kind size correction.
#let square-piece(
  kind,
  color,
  sq,
  piece-set: default-piece-set,
  white-fill: default-white-fill,
  black-fill: default-black-fill,
  font: default-piece-fonts,
  piece-scale: 1.0,
  baseline-inset: 0.20,
) = {
  assert(piece-kinds.contains(kind), message: "unknown piece kind: \"" + repr(kind) + "\" (expected one of " + repr(piece-kinds) + ")")
  assert(piece-colors.contains(color), message: "unknown piece color: \"" + repr(color) + "\" (expected \"white\" or \"black\")")

  if piece-set == none or piece-set == "unicode" {
    // Glyph fallback: lift onto a common baseline and apply the glyph fit factor.
    box(
      width: sq, height: sq, inset: (bottom: sq * baseline-inset),
      align(center + bottom, piece-content(
        kind, color, sq * piece-scale * _glyph-fit,
        white-fill: white-fill, black-fill: black-fill, font: font,
      )),
    )
  } else {
    let c = if color == "white" { "w" } else { "b" }
    // Path resolves relative to THIS file (src/pieces.typ), so it is independent
    // of the compile root and survives packaging.
    let path = "assets/piece_sets/" + piece-set + "/" + c + kind-letters.at(kind) + ".svg"
    box(width: sq, height: sq, align(center + horizon, image(path, width: sq * piece-scale)))
  }
}
