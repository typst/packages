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
// shapes U+265A..U+265F for BOTH colors, and distinguish color via `fill` + a
// contrasting `stroke`. Reasons:
//   * many fonts render the outline ("white") glyphs poorly or inconsistently;
//   * a single shape keeps white and black pieces visually identical in form;
//   * fill + stroke gives good contrast on both light and dark squares.
// The glyph path keeps the baseline lift + per-kind size correction it needs.
// ===========================================================================

/// The six chess piece kinds: king, queen, rook, bishop, knight, pawn.
#let piece-kinds = ("king", "queen", "rook", "bishop", "knight", "pawn")
/// The two piece colors: white and black.
#let piece-colors = ("white", "black")

// SVG piece sets bundled under src/assets/piece_sets/. `default-piece-set` is the
// factory default; `"unicode"` (or `none`) selects the glyph fallback.
// `known-piece-sets` is the list of sets we SHIP (used by docs/examples); it is
// NOT a guard -- any set NAME is accepted, and a vendored/forked copy can add a
// set by dropping a folder under src/assets/piece_sets/<name>/ (a name with no
// matching SVG simply fails to load -- Typst's own error). NOTE: the folder-drop
// only works from a working copy; an INSTALLED package cannot read files outside
// its own sandbox, so the supported way for users to load their OWN downloaded
// sets is a loader function / bytes dict passed as `piece-set` (see square-piece).
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

/// Resolve the fallback glyph for a piece `kind`: a caller/variant-supplied glyph
/// (from `glyphs`) wins, else the built-in table (standard six only), else `none`
/// (the caller decides how to error). Unicode cannot foresee every fairy piece, so
/// a custom kind must bring its own glyph or be drawn from an SVG piece-set.
///
/// - kind (str): the piece kind.
/// - glyphs (dictionary): extra `kind -> glyph` entries (e.g. a variant's map).
/// -> str | none
#let _resolve-glyph(kind, glyphs) = glyphs.at(kind, default: piece-glyphs.at(kind, default: none))

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
/// - glyphs (dictionary): extra `kind -> glyph` entries for custom (fairy) kinds,
///   consulted before the built-in six-kind table. A kind with no glyph in either
///   is an error (the built-in table can only cover the standard six).
/// -> content
#let piece-content(
  kind,
  color,
  size,
  white-fill: default-white-fill,
  black-fill: default-black-fill,
  stroke-ratio: 0.03,
  font: default-piece-fonts,
  glyphs: (:),
) = {
  let glyph = _resolve-glyph(kind, glyphs)
  assert(glyph != none, message: "no glyph for piece kind \"" + kind + "\": the "
    + "built-in fallback covers only the standard six and no glyph was supplied — "
    + "add one via the variant's `glyphs:` map, or draw it from an SVG loader/"
    + "bytes-dict `piece-set`")
  assert(piece-colors.contains(color), message: "unknown piece color: \"" + repr(color) + "\" (expected \"white\" or \"black\")")
  let fill = if color == "white" { white-fill } else { black-fill }
  let stroke-col = if color == "white" { black-fill } else { white-fill }
  // Custom kinds have no tuned size ratio; default to the pawn baseline (1.0).
  let glyph-size = size * piece-size-ratio.at(kind, default: 1.0)
  // "bounds" makes the text box hug the actual glyph ink, so that bottom-
  // aligning different-sized pieces puts them all on one common baseline.
  set text(font: font, fallback: true, top-edge: "bounds", bottom-edge: "bounds")
  text(
    size: glyph-size,
    fill: fill,
    stroke: stroke-ratio * glyph-size + stroke-col,
    glyph,
  )
}

// Box a user-loader's return value into a `sq`-side square. The value is either
// raw image `bytes` (which we decode + size ourselves) or ready-made `content`
// (passed through untouched, so the loader may size/style it however it likes).
// `image(bytes, ..)` decodes in memory -- no filesystem access -- so this is safe
// to call from inside the package; the loader itself does any `read()`/`image()`
// from the USER's document, where paths resolve against the user's project root.
#let _box-loaded(v, sq, piece-scale, color, kind) = {
  let art = if type(v) == bytes {
    image(v, width: sq * piece-scale)
  } else if type(v) == content {
    v
  } else {
    assert(false, message: "piece loader for " + color + " " + kind + " returned "
      + type(v) + "; expected bytes (e.g. read(path, encoding: none)) or content (e.g. image(path))")
  }
  box(width: sq, height: sq, align(center + horizon, art))
}

/// Build a `piece-set` loader from a caller-supplied file reader and a *filename
/// pattern*, so a downloaded/self-made set loads without prescribing one fixed
/// naming scheme. You supply only *how to read a file* (which must be authored in
/// YOUR document so paths resolve against your project root — see square-piece)
/// and the `pattern` your set follows; the helper substitutes it per `(color,
/// kind)`. This is the convenient way to load a custom set, including fairy sets.
///
/// Pattern placeholders (we prescribe the *vocabulary*, not the layout):
/// / `{kind}`: long kind name — `"king"`, `"alfil"`.
/// / `{color}`: long color — `"white"`, `"black"`.
/// / `{c}`: short color — `"w"`, `"b"`.
/// / `{K}` / `{k}`: the kind's letter, upper / lower case. Needs a letter for the
///   kind: taken from `letters` if given, else the built-in standard map (so it
///   only works out-of-the-box for the standard six). Pass `letters` for custom
///   kinds that use a `{K}`/`{k}` pattern.
///
/// ```typ
/// // fairy set named e.g. "alfil_white.svg"
/// #named-piece-set(f => read("/assets/fairy_1/" + f, encoding: none))
/// // lichess layout "wK.svg"
/// #named-piece-set(f => read("/assets/alpha/" + f, encoding: none), pattern: "{c}{K}.svg")
/// ```
///
/// - read-file (function): `(filename: str) -> bytes | content`.
/// - pattern (str): the filename template (default `"{kind}_{color}.svg"`).
/// - letters (dictionary): optional `kind -> letter` map for `{K}`/`{k}` patterns.
/// -> function
#let named-piece-set(read-file, pattern: "{kind}_{color}.svg", letters: none) = (color, kind) => {
  let c = if color == "white" { "w" } else { "b" }
  let name = pattern.replace("{kind}", kind).replace("{color}", color).replace("{c}", c)
  if name.contains("{K}") or name.contains("{k}") {
    let lk = if letters != none and kind in letters { letters.at(kind) }
      else if kind in kind-letters { kind-letters.at(kind) }
      else { panic("named-piece-set: pattern uses {K}/{k} but no letter is known for "
        + "kind \"" + kind + "\"; pass `letters: (" + kind + ": \"X\", ..)`") }
    name = name.replace("{K}", upper(lk)).replace("{k}", lower(lk))
  }
  read-file(name)
}

/// Build a `piece-set` loader for the standard lichess file layout
/// (`{w,b}{K,Q,R,B,N,P}.svg`) — a thin alias of `named-piece-set` with
/// `pattern: "{c}{K}.svg"`, kept for back-compatibility.
///
/// - read-file (function): `(filename: str) -> bytes | content`.
/// -> function
#let svg-piece-set(read-file) = named-piece-set(read-file, pattern: "{c}{K}.svg")

// Resolve a base `piece-set` (a bundled NAME, a loader function, or a bytes/
// content dict) to the art (bytes | content) for one (color, kind). Used by
// `with-fallback` to draw the kinds it delegates to the base. A bundled NAME is
// read as bytes from the packaged assets (source-relative, so packaging-safe).
#let _piece-art(base, color, kind) = {
  if type(base) == function {
    base(color, kind)
  } else if type(base) == dictionary {
    let key = color + "-" + kind
    assert(key in base, message: "with-fallback base (dictionary) has no entry for \"" + key + "\"")
    base.at(key)
  } else {
    let c = if color == "white" { "w" } else { "b" }
    assert(kind in kind-letters, message: "with-fallback base set \"" + base
      + "\" has no file for kind \"" + kind + "\" (bundled sets cover only the "
      + "standard six); give custom kinds their own loader, or adjust `base-kinds`")
    read("assets/piece_sets/" + base + "/" + c + kind-letters.at(kind) + ".svg", encoding: none)
  }
}

/// Compose a custom-kind `loader` with a fallback `base` piece-set, so ONE
/// `piece-set` can draw a mixed board (standard pieces + fairy pieces). Standard
/// kinds are drawn from `base`; every other kind is delegated to `loader`. This is
/// the ergonomic answer to "standard king/pawn alongside alfil/dabbaba/ferz".
///
/// ```typ
/// #let art = with-fallback(named-piece-set(
///   f => read("/assets/fairy_1/" + f, encoding: none)))
/// #board(position(.., variant: fairy), piece-set: art)
/// ```
///
/// - loader (function): `(color, kind) -> bytes | content` for the non-base kinds.
/// - base (str, function, dictionary): the fallback piece-set for `base-kinds`
///   (default the factory set `"cburnett"`); any `piece-set` form.
/// - base-kinds (array): the kinds served by `base` (default the standard six).
/// -> function
#let with-fallback(loader, base: default-piece-set, base-kinds: piece-kinds) = (color, kind) => {
  if base-kinds.contains(kind) { _piece-art(base, color, kind) } else { loader(color, kind) }
}

/// Render a piece as content sized to a `sq`-side square, ready to be `place`d at
/// the square's screen origin. This is the seam the board renderer uses.
///
/// `piece-set` selects where the art comes from:
///   * a bundled/set *name* (str) -> the matching SVG under
///     src/assets/piece_sets/<name>/, centred in the square. The SVGs carry the
///     correct baseline, so no baseline adjustment is done; `piece-scale` (1.0
///     fills the square) just scales the image. The name is NOT checked against a
///     list -- a missing/misnamed file fails to load (Typst's own error), which
///     lets a vendored copy add a set by dropping in a folder.
///   * a *function* `(color, kind) -> bytes | content` -> a user-supplied loader.
///     This is the only mechanism that can reach the user's OWN files from an
///     installed package: because the loader body is authored in the user's
///     document, any `read()`/`image()` inside it resolves against the user's
///     project root (package code cannot -- its paths resolve to the package's
///     own sandbox). The loader is kind-agnostic: `kind` is passed straight
///     through, with no fixed six-kind letter map.
///   * a *dictionary* keyed `"<color>-<kind>"` (e.g. `"white-king"`) -> the
///     bytes/content for that piece; a missing key is a clear error. Same
///     kind-agnostic contract as the function form.
///   * `"unicode"` or `none` -> the Unicode glyph fallback, which keeps the
///     baseline lift (`baseline-inset`) and per-kind size correction.
#let square-piece(
  kind,
  color,
  sq,
  piece-set: default-piece-set,
  white-fill: default-white-fill,
  black-fill: default-black-fill,
  font: default-piece-fonts,
  glyphs: (:),
  piece-scale: 1.0,
  baseline-inset: 0.20,
) = {
  // NOTE: `kind` is NOT gated against the standard six here. The kind vocabulary
  // is validated upstream by the (variant-aware) position layer, so a custom
  // (fairy) kind reaches us legitimately. The loader/dict paths draw ANY kind;
  // only the two paths that genuinely need the built-in six-kind tables (the
  // bundled-name path's `kind-letters`, and the Unicode glyph fallback) guard the
  // kind locally, with a message that points custom kinds at a loader.
  assert(piece-colors.contains(color), message: "unknown piece color: \"" + repr(color) + "\" (expected \"white\" or \"black\")")

  if piece-set == none or piece-set == "unicode" {
    // Glyph fallback: lift onto a common baseline and apply the glyph fit factor.
    // A custom (fairy) kind is drawable here iff a glyph was supplied for it;
    // `piece-content` enforces that (built-in table covers only the standard six).
    box(
      width: sq, height: sq, inset: (bottom: sq * baseline-inset),
      align(center + bottom, piece-content(
        kind, color, sq * piece-scale * _glyph-fit,
        white-fill: white-fill, black-fill: black-fill, font: font, glyphs: glyphs,
      )),
    )
  } else if type(piece-set) == function {
    // User loader: authored in the user's document, so its file access resolves
    // against the user's project root. This is how downloaded/custom sets load.
    // Kind-agnostic: any (fairy) kind is passed straight through.
    _box-loaded(piece-set(color, kind), sq, piece-scale, color, kind)
  } else if type(piece-set) == dictionary {
    // Kind-agnostic: keyed "<color>-<kind>", so custom kinds work as-is.
    let key = color + "-" + kind
    assert(key in piece-set, message: "piece set (dictionary) has no entry for \""
      + key + "\"; keys present: " + repr(piece-set.keys()))
    _box-loaded(piece-set.at(key), sq, piece-scale, color, kind)
  } else {
    let c = if color == "white" { "w" } else { "b" }
    // Bundled-set NAME path: needs the fixed six-kind `kind-letters` map, so a
    // custom kind cannot be served here -- point the user at a loader/dict.
    assert(kind in kind-letters, message: "bundled piece set \"" + piece-set
      + "\" has no file for custom kind \"" + kind + "\" (named sets cover only the "
      + "standard six); render it with an SVG loader or bytes-dict `piece-set` "
      + "(e.g. `with-fallback`)")
    // Path resolves relative to THIS file (src/pieces.typ), so it is independent
    // of the compile root and survives packaging.
    let path = "assets/piece_sets/" + piece-set + "/" + c + kind-letters.at(kind) + ".svg"
    box(width: sq, height: sq, align(center + horizon, image(path, width: sq * piece-scale)))
  }
}
