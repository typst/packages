// ===========================================================================
// Board renderer.
//
// The board is drawn on a free canvas using `place(dx, dy, ...)`. Every square,
// piece, highlight and label is positioned by ONE function `_screen`, which also
// handles board orientation (white or black at the bottom). The screen y-flip
// lives here and only here.
//
// `render-board(board, flip: false, cols: 8, rows: 8, ..overrides)` resolves a
// diagram-style (built-in ⊕ document state ⊕ per-call overrides) and draws it.
// The geometry (`cols` x `rows`) is NOT 8x8-only: it is threaded through from the
// position model, so the same renderer serves standard chess
// (8x8), Xiangqi (9x9/9x10), Capablanca (10x8/10x10), etc. Orientation is NOT a
// style field: it is decided by the per-call `flip` argument.
//
// Board labeling (`label-mode` field) has three modes:
//   * "on-square" (default): tiny file letters in a bottom corner of the
//     file-side edge squares, rank digits in a top corner of the rank-side edge
//     squares, each in the OPPOSITE color of its square. Which corner is set by
//     `file-label-corner` / `rank-label-corner`. Drawn inside the board (no
//     gutter), at a fixed font fraction that does NOT change with board size.
//   * "outside": label strips in a gutter outside the board (the classic look).
//   * "border": a band of `label-border-ratio` width around the board. The band
//     fill / label color follow `border-theme`, resolved by `_band-colors`:
//     "square" = dark band + light labels, "brown" = espresso band + creme
//     labels, "creme" = creme band + saddle labels, "dark" = charcoal band +
//     light-grey labels, "light" = the mirror of "dark". "wood" and "marble"
//     additionally composite a material texture on top of their backdrop
//     color, via `_band-material`.
// `labels: false` suppresses all of them. Board labels always use a fixed
// sans-serif font, independent of the document / diagram font.
//
// Size handling (`size` field):
//   * auto / none / <= 0  -> default size, clamped to available width;
//   * a length or ratio   -> that size, clamped so the whole figure (board plus
//                            any label gutter) fits the available width AND
//                            height of the insertion context (read via layout()).
//   `size` is the LARGER board dimension; cells stay square (sq = size /
//   max(cols, rows)), so a non-square board is sized by its longer side.
// ===========================================================================

#import "coords.typ": file-letter, parse-square, is-dark-square, _square-index
#import "pieces.typ": square-piece
#import "style.typ": default-style, style-state, border-brown, border-creme, border-saddle, border-dark, border-dark-label, border-marble, _expand-themes, _adjust-color-pair, _html-target

#let default-board-size = 6.4cm

// Board labels use their own sans-serif (the `label-font` board-style option),
// independent of the main/diagram font. `render-board` shadows `_label-text` with
// a closure bound to `st.label-font`; this module-level default is the fallback.
#let _label-text(body, size, fill) = text(font: ("Arial", "DejaVu Sans Mono"), size: size, fill: fill, body)

// Label sizing (fractions of a square side). On-square labels are small and sit
// tucked into the corner; the "outside"/"border" labels live in a gutter so can
// be larger.
#let _on-square-label-frac = 0.22   // on-square label size (a bit smaller)
#let _on-square-pad-frac = 0.07     // on-square label inset from the corner (further in)
#let _strip-label-frac = 0.40       // "outside"/"border" label size

// (col,row) -> (dx,dy) for a square of side `sq`, honouring orientation and the
// board geometry. White at the bottom: file a on the left, rank 1 at the bottom
// (screen y points down, hence the (rows-1-row) flip). Black at the bottom
// mirrors both axes.
#let _screen(col, row, sq, orientation, cols, rows) = {
  if orientation == "black" {
    (dx: (cols - 1 - col) * sq, dy: row * sq)
  } else {
    (dx: col * sq, dy: (rows - 1 - row) * sq)
  }
}

// Resolve a "border"-mode label band to its `(fill, label)` color pair.
// Pure (everything arrives through parameters) so it is directly unit-testable:
// the rendered band is a plain `rect`, which Typst cannot `query()`, so this
// function is the ONLY machine-checkable form of the theme -> color mapping.
// `light` / `dark` are the board's own square colors, used by the "square" theme.
//
// NOTE: "creme" is NOT a mirrored "brown" -- they use two deliberately different
// browns (#4a3319 band vs #6b4423 label). "light" IS the exact mirror of "dark".
// Callers must have validated `theme` already; an unknown value falls back to
// the "square" pair rather than erroring (the assert in `render-board` is the
// gate that makes that unreachable in practice).
// "wood" and "marble" also return a `(fill, label)` pair, but for those two
// themes the returned `fill` is only the BACKDROP color: a material texture
// (see `_band-material`) is composited on top of it, so the pair alone does
// not fully describe the rendered band.
#let _band-colors(theme, light, dark) = {
  if theme == "brown" { (border-brown, border-creme) }
  else if theme == "creme" { (border-creme, border-saddle) }
  else if theme == "dark" { (border-dark, border-dark-label) }
  else if theme == "light" { (border-dark-label, border-dark) }
  else if theme == "wood" { (border-brown, border-creme) }
  else if theme == "marble" { (border-marble, border-creme) }
  else { (dark, light) }
}

// Resolve a single square's BASE fill: always the flat theme color for its
// dark/light-ness. Every `pattern` (stripes / marble / wood) is drawn as a
// SEPARATE per-square overlay on top in `_checker` -- the base fill never
// changes. Pure and directly unit-testable (`pattern` no longer affects the
// return, kept in the signature for call-site stability).
#let _square-fill(is-dark, light, dark, pattern) = {
  if is-dark { dark } else { light }
}

// Pure: the diagonal-stripe overlay for one dark square, size `sq`. Drawn as a
// set of CONTINUOUS 45-degree strokes (`x + y = k*step`), each a single line
// with butt ends clipped to the square. This replaces the old `tiling()` fill,
// which dashed the diagonals: a tiling anti-aliases each cell independently, so
// where a diagonal crossed a cell boundary the two clipped edges did not sum to
// fully opaque -- a faint seam every `step` that read as tapered gaps. One
// continuous stroke per line has no interior boundary and stays uniform.
// `step` is the c-spacing (perpendicular gap = step / sqrt(2)); matches the old
// 4pt tile density.
#let _stripes-overlay(sq, step: 4pt, sw: 0.5pt) = box(width: sq, height: sq, clip: true, {
  let n = calc.ceil(2 * sq / step)
  for k in range(1, n) {
    let cc = k * step
    let (p1, p2) = if cc <= sq { ((0pt, cc), (cc, 0pt)) } else { ((cc - sq, sq), (sq, cc - sq)) }
    place(line(start: p1, end: p2, stroke: sw + black))
  }
})

// Pure: resolves the source-relative SVG path for a "marble"/"wood" pattern
// overlay on a given square, or `none` when the pattern has no overlay
// (`none`, "stripes", or an unknown value) -- same convention as
// src/pieces.typ's `image(...)` calls, resolved relative to this source
// file and packaging-safe. Wood only patterns dark squares; marble patterns
// both.
#let _material-asset(pattern, is-dark) = {
  if pattern == "marble" {
    if is-dark { "assets/patterns/marble_dark.svg" } else { "assets/patterns/marble_light.svg" }
  } else if pattern == "wood" {
    if is-dark { "assets/patterns/wood.svg" } else { none }
  } else {
    none
  }
}

// Pure: a deterministic per-square (rot, mirror) pair for the material
// overlay, so the identical SVG tile doesn't look uniformly repeated across
// the board. Marble varies freely (8-way: any 90deg rotation, mirrored or
// not). Wood is axis-preserving (4-way: only 0/180deg, never 90/270, which
// would turn the vertical grain horizontal).
#let _material-orientation(pattern, row, col) = {
  let h = calc.rem(row * 73 + col * 179 + row * col * 13 + 7, 1009)
  if pattern == "marble" {
    let k = calc.rem(h, 8)
    (rot: calc.rem(k, 4) * 90deg, mirror: k >= 4)
  } else if pattern == "wood" {
    let k = calc.rem(h, 4)
    (rot: calc.rem(k, 2) * 180deg, mirror: k >= 2)
  } else {
    (rot: 0deg, mirror: false)
  }
}

// Apply a mirror then a rotation to `body` with reflow disabled, so the
// square footprint is preserved (a square under 90deg-multiple rotations /
// axis mirrors stays exactly square, so placement is unaffected).
#let _oriented(body, rot, mirror) = {
  let m = if mirror { scale(x: -100%, reflow: false, body) } else { body }
  rotate(rot, reflow: false, m)
}

// Resolve a "border"-mode label band's material texture: the source-relative
// SVG path for the "wood"/"marble" border-themes, or `none` for the five
// themes that stay a flat color. Pure and directly unit-testable (like
// `_band-colors`, since the rendered band is a plain `rect`/`image` stack,
// which Typst cannot `query()`).
//
// Deliberately does NOT delegate to `_material-asset`: the band is drawn as a
// SINGLE image spanning the whole band rect, not a tiled grid of squares, so
// it needs its own band-scale assets (`wood_band.svg`/`marble_band.svg`)
// authored at roughly 10x the noise frequency of the square assets -- without
// that, one image stretched over the full band (~7.3cm vs. ~0.8cm for a
// square) would lose its material character (wood degenerating into large
// blobs, marble washing out to a near-flat white). This is why the returned
// path no longer agrees with `_material-asset("wood"/"marble", ..)`.
#let _band-material(theme) = {
  if theme == "wood" { "assets/patterns/wood_band.svg" }
  else if theme == "marble" { "assets/patterns/marble_band.svg" }
  else { none }
}

// Draw the checkerboard squares. Pure (closes over no context/style value --
// everything comes through its parameters), so Typst can memoise it: a
// document whose diagrams share geometry+size+colors+pattern builds the
// checker once instead of per board.
#let _checker(cols, rows, sq, orientation, light, dark, pattern) = {
  // The stripe overlay is identical for every dark square (depends only on sq),
  // so build it once and reuse rather than per square.
  let stripes = if pattern == "stripes" { _stripes-overlay(sq) } else { none }
  for row in range(rows) {
    for col in range(cols) {
      let is-d = is-dark-square(col, row)
      let o = _screen(col, row, sq, orientation, cols, rows)
      place(dx: o.dx, dy: o.dy, rect(
        width: sq, height: sq,
        fill: _square-fill(is-d, light, dark, pattern),
        stroke: none,
      ))
      // Pattern overlay on top of the flat fill: stripes (dark squares) or a
      // material SVG (marble both squares / wood dark only).
      if is-d and stripes != none {
        place(dx: o.dx, dy: o.dy, stripes)
      } else {
        let _asset = _material-asset(pattern, is-d)
        if _asset != none {
          let _ori = _material-orientation(pattern, row, col)
          place(dx: o.dx, dy: o.dy, _oriented(image(_asset, width: sq, height: sq), _ori.rot, _ori.mirror))
        }
      }
    }
  }
}

// Set a color's alpha to an absolute opacity (`100% - transparency`), preserving
// its RGB components. Used to apply the `*-transparency` style fields to the
// (opaque) default highlight/arrow colors.
#let _with-alpha(col, transparency) = {
  let c = rgb(col).components()
  rgb(c.at(0), c.at(1), c.at(2), 100% - transparency)
}

// Resolve a color spec used by arrows / highlights:
//   * `auto`         -> the supplied fallback color;
//   * a string (a PGN %cal/%csl letter like "G") -> annotation-colors lookup;
//   * a color value -> used as-is.
#let _resolve-anno-color(c, anno-map, fallback) = {
  if c == auto { fallback }
  else if type(c) == str { anno-map.at(c, default: fallback) }
  else { c }
}

// Resolve a per-square dimension (a marker stroke width or margin) so marks scale
// with the board by default:
//   * `auto`    -> `default` (a ratio like 15%) times the square size `sq`;
//   * a `ratio` -> that fraction of the square (e.g. `10%` -> 0.1 * sq);
//   * a `length`-> used as-is (absolute escape hatch, e.g. `2pt`).
#let _resolve-square-dim(value, sq, default) = {
  if value == auto { default * sq }
  else if type(value) == ratio { value * sq }
  else if type(value) == length { value }
  else { panic("marker dimension must be `auto`, a ratio (e.g. 10%), or a length; got " + repr(value)) }
}

// A straight arrow: a shaft plus a filled triangular head, from
// (fx,fy) to (tx,ty) in board-canvas coordinates. Drawn by `place`ing at the
// origin and giving absolute vertex coordinates, so it composes with the rest of
// the canvas. The head scales with the square `sq`; the shaft width is
// `shaft-w` (a length, or `auto` -> proportional to `sq`). Zero-length skipped.
#let _arrow-shape(fx, fy, tx, ty, sq, color, shaft-w) = {
  let dx = (tx - fx) / 1pt
  let dy = (ty - fy) / 1pt
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return }
  let ux = dx / len
  let uy = dy / len
  let head-len = sq * 0.36
  let head-hw = sq * 0.20
  let sw = _resolve-square-dim(shaft-w, sq, 15%)
  let bx = tx - ux * head-len   // base of the head (shaft stops here)
  let by = ty - uy * head-len
  let px = -uy                  // unit perpendicular
  let py = ux
  place(dx: 0pt, dy: 0pt, line(start: (fx, fy), end: (bx, by), stroke: sw + color))
  place(dx: 0pt, dy: 0pt, polygon(
    fill: color,
    (tx, ty),
    (bx + px * head-hw, by + py * head-hw),
    (bx - px * head-hw, by - py * head-hw),
  ))
}

// Draw one highlight inside the board canvas at screen offset (dx, dy). Stroke
// widths and margins are resolved via `_resolve-square-dim` (auto -> a proportion
// of the square, or a ratio / absolute length):
//   * "filled" -> a square-filling rect in `fill`;
//   * "circle" -> a centred ring whose OUTER stroke edge sits `circle-margin`
//                 inside the square border (margin 0 -> touches the border);
//   * "cross"  -> an X whose round-cap TIPS sit `cross-margin` from each corner,
//                 stroked with round caps. The two diagonals are placed
//                 INDEPENDENTLY: a single `place` holding both lines would stack
//                 them in normal flow, dropping the second diagonal a square down.
#let _draw-highlight(shape, dx, dy, sq, fill, cross-col, circle-col, cross-w, circle-w, cross-margin, circle-margin) = {
  if shape == "filled" {
    place(dx: dx, dy: dy, rect(width: sq, height: sq, fill: fill, stroke: none))
  } else if shape == "circle" {
    let w = _resolve-square-dim(circle-w, sq, 15%)
    let m = _resolve-square-dim(circle-margin, sq, 3%)
    // Outer stroke edge sits `m` inside the border; the stroke straddles the
    // radius, so shrink the radius by `m + w/2` and re-centre by the same.
    let radius = sq / 2 - m - w / 2
    assert(radius > 0pt, message: "circle highlight: circle-width + circle-margin exceed the square; reduce one of them")
    place(
      dx: dx + m + w / 2,
      dy: dy + m + w / 2,
      circle(radius: radius, fill: none, stroke: w + circle-col),
    )
  } else if shape == "cross" {
    let w = _resolve-square-dim(cross-w, sq, 15%)
    let m = _resolve-square-dim(cross-margin, sq, 10%)
    // `cross-margin` is the distance from each corner to the cross TIP (like
    // board-n-pieces). Round caps extend w/2 along the diagonal, i.e. w/√8 per
    // axis, so pull the geometric endpoints in by that offset to land the tip at
    // exactly `m`. This gives the shorter, cleaner "×" (not a full-diagonal line).
    let off = w / calc.sqrt(8)
    let lo = m + off
    let hi = sq - m - off
    assert(lo < hi, message: "cross highlight: cross-margin (plus stroke) too large for the square")
    let str = stroke(paint: cross-col, thickness: w, cap: "round")
    place(dx: dx, dy: dy, line(start: (lo, hi), end: (hi, lo), stroke: str))      // LL -> UR
    place(dx: dx, dy: dy, line(start: (lo, lo), end: (hi, hi), stroke: str))      // UL -> LR
  } else {
    panic("highlight shape must be \"filled\", \"cross\", or \"circle\"; got " + repr(shape))
  }
}

// In-check glow: a square-filling radial gradient, drawn UNDER the
// piece so the king reads crisp on top and the glow radiates from beneath it —
// the Lichess look. The gradient's default 50% radius is the circle inscribed in
// the square (touching the four EDGE MIDPOINTS); the four corners fall outside it
// and so keep the underlying square color. We hold the glow FULLY OPAQUE almost
// to that edge, fading out only in the last sliver, so the color reaches the edge
// midpoints and only the corners stay bare. The transparent stop reuses `color`'s
// RGB at 0% alpha so the fade is hueless.
#let _draw-check(dx, dy, sq, color) = {
  let c = rgb(color).components()
  let clear = rgb(c.at(0), c.at(1), c.at(2), 0%)
  place(dx: dx, dy: dy, rect(
    width: sq, height: sq, stroke: none,
    fill: gradient.radial((color, 0%), (color, 78%), (clear, 100%)),
  ))
}

// Move-quality symbol -> category. The six recognised glyphs only.
#let _mq-category(symbol) = {
  if symbol == "!" or symbol == "!!" { "good" }
  else if symbol == "?" or symbol == "??" { "bad" }
  else if symbol == "!?" or symbol == "?!" { "interesting" }
  else { panic("move-quality symbol must be one of ! ? !! ?? !? ?!; got " + repr(symbol)) }
}

// Move-quality badge: a filled disc near the square's screen
// top-right, its centre pulled INTO the move's square by `inset` (so it reads as
// belonging to that square) while still spilling over the top-right edge into the
// neighbours. Prompt 28 enlarged the disc (r ≈ 0.28·sq) and moved the centre off
// the bare corner. `colors` is the per-category background map; the symbol text is
// always white. Two-glyph symbols ("!!") shrink to fit. Drawn on top of
// everything. The corner is orientation-agnostic (always screen upper-right),
// matching the Lichess look under a flip.
#let _draw-move-quality(dx, dy, sq, symbol, colors) = {
  let bg = colors.at(_mq-category(symbol))
  let r = sq * 0.28
  let inset = r * 0.5   // pull the centre down-and-left, into the move's square
  let fs = if symbol.clusters().len() >= 2 { r * 0.85 } else { r * 1.2 }
  // box top-left so the disc centre lands at (dx + sq - inset, dy + inset)
  place(dx: dx + sq - inset - r, dy: dy + inset - r, box(width: 2 * r, height: 2 * r, {
    place(circle(radius: r, fill: bg, stroke: none))
    place(box(width: 2 * r, height: 2 * r, align(center + horizon,
      text(fill: white, size: fs, weight: "bold", symbol))))
  }))
}

// `w-factor` / `h-factor` are the multipliers (on the nominal size `s`) that the
// board width / height occupy, INCLUDING any label gutter. For a square 8x8 with
// no gutter both are 1; for a 10x8 board the height factor is 0.8; "outside"
// adds one gutter and "border" two per dimension.
#let _resolve-size(size, available, w-factor, h-factor) = {
  let avail-w = available.width
  let avail-h = available.height
  let raw = size
  if raw == auto or raw == none {
    raw = default-board-size
  } else if type(raw) == ratio {
    raw = avail-w * raw
  } else if type(raw) == length {
    if raw <= 0pt { raw = default-board-size }
  } else {
    panic("size must be a length, ratio, or auto; got: " + repr(size))
  }
  let s = calc.min(raw, avail-w / w-factor)
  if avail-h > 1pt { s = calc.min(s, avail-h / h-factor) }
  s
}

/// Render a board (square name → `(kind, color)`) to content — the low-level
/// drawing primitive under `board`. `flip: true` puts Black at the bottom.
///
/// - squares (dictionary): square name → `(kind, color)`.
/// - flip (bool): show the board from Black's side.
/// - cols (int): board width (default `8`).
/// - rows (int): board height (default `8`).
/// - ..overrides (arguments): named board style fields (see the Board style
///   options).
/// -> content
#let render-board(squares, flip: false, cols: 8, rows: 8, ..overrides) = {
  assert(type(squares) == dictionary, message: "render-board expects a squares dict (square -> (kind, color)); got " + repr(type(squares)))

  context {
    // Per-call `color-theme` / `board-theme` are expanded here, same as the
    // defaults setters (see `_expand-themes` in style.typ) -- an explicit
    // individual field in THIS call must win over a theme in THIS call.
    let st = default-style + style-state.get() + _expand-themes(overrides.named())
    // Apply the `brightness`/`contrast` lightness nudges once, here, to the
    // final resolved `light`/`dark` pair -- everything downstream (checker,
    // labels, border band) reads `st.light`/`st.dark` and must see the
    // adjusted colors.
    let (light: st-light, dark: st-dark) = _adjust-color-pair(st.light, st.dark, st.brightness, st.contrast)
    st.light = st-light
    st.dark = st-dark
    // Labels use `st.label-font` (configurable); shadow the helper so the call
    // sites below pick it up without threading the font through each one.
    let _label-text = (body, size, fill) => text(font: st.label-font, size: size, fill: fill, body)
    assert(st.file-side == bottom or st.file-side == top, message: "file-side must be `top` or `bottom`")
    assert(st.rank-side == left or st.rank-side == right, message: "rank-side must be `left` or `right`")
    assert(st.file-label-corner == left or st.file-label-corner == right, message: "file-label-corner must be `left` or `right`")
    assert(st.rank-label-corner == left or st.rank-label-corner == right, message: "rank-label-corner must be `left` or `right`")
    let modes = ("on-square", "outside", "border")
    assert(modes.contains(st.label-mode), message: "label-mode must be one of " + repr(modes) + "; got " + repr(st.label-mode))
    let themes = ("square", "brown", "creme", "dark", "light", "wood", "marble")
    assert(themes.contains(st.border-theme), message: "border-theme must be one of " + repr(themes) + "; got " + repr(st.border-theme))

    let labels = st.labels
    let orient = if flip { "black" } else { "white" }
    let maxdim = calc.max(cols, rows)

    let rendered = layout(available => {
      let mode = st.label-mode

      // gutter as a fraction of the nominal size, by mode (0 = labels on board)
      let g-ratio = if not labels { 0.0 }
        else if mode == "outside" { 0.09 }
        else if mode == "border" { st.label-border-ratio }
        else { 0.0 }

      // How much of the nominal size `s` the board + gutters occupy in each
      // dimension. The board itself occupies cols/maxdim (w) and rows/maxdim (h);
      // "border" adds the gutter on both sides, "outside" on one side.
      let base-w = cols / maxdim
      let base-h = rows / maxdim
      let (w-factor, h-factor) = if mode == "border" {
        (base-w + 2 * g-ratio, base-h + 2 * g-ratio)
      } else if mode == "outside" {
        (base-w + g-ratio, base-h + g-ratio)
      } else {
        (base-w, base-h)
      }

      let s = _resolve-size(st.size, available, w-factor, h-factor)
      let sq = s / maxdim
      let g = s * g-ratio
      let bw = cols * sq
      let bh = rows * sq
      let label-size = sq * _strip-label-frac

      // colors that depend on style fields (computed once)
      let hl-default-fill = _with-alpha(st.highlight-fill, st.highlight-transparency)
      let arrow-default = _with-alpha(st.arrow-color, st.arrow-transparency)

      let board-canvas = box(width: bw, height: bh, {
        // checker
        _checker(cols, rows, sq, orient, st.light, st.dark, st.pattern)
        // highlights (under the pieces, over the checker). Each entry is a square
        // name (uses highlight-shape + highlight-fill), a (square, color) pair
        // (filled, explicit color -- e.g. PGN %csl), or a dict (square:, shape:,
        // color:) for full control.
        for h in st.highlight {
          let hname = none
          let shape = st.highlight-shape
          let ecol = auto   // explicit color, or auto = use the shape default
          if type(h) == str {
            hname = h
          } else if type(h) == dictionary {
            hname = h.square
            shape = h.at("shape", default: st.highlight-shape)
            ecol = h.at("color", default: auto)
          } else {
            hname = h.at(0)
            if h.len() > 1 { ecol = h.at(1) }   // (square, color) -> filled
          }
          let p = parse-square(hname, cols: cols, rows: rows)
          let o = _screen(p.col, p.row, sq, orient, cols, rows)
          let fill = if ecol == auto { hl-default-fill } else { _resolve-anno-color(ecol, st.annotation-colors, hl-default-fill) }
          let cross-c = if ecol == auto { st.cross-color } else { _resolve-anno-color(ecol, st.annotation-colors, st.cross-color) }
          let circle-c = if ecol == auto { st.circle-color } else { _resolve-anno-color(ecol, st.annotation-colors, st.circle-color) }
          _draw-highlight(shape, o.dx, o.dy, sq, fill, cross-c, circle-c, st.cross-width, st.circle-width, st.cross-margin, st.circle-margin)
        }
        // in-check glow: under the pieces, over the checker/highlights.
        // `check-square` is auto-filled by `board()` for analyzable positions.
        if st.check and st.check-square != none {
          let p = parse-square(st.check-square, cols: cols, rows: rows)
          let o = _screen(p.col, p.row, sq, orient, cols, rows)
          _draw-check(o.dx, o.dy, sq, st.check-color)
        }
        // optional grid lines between squares: a fixed 0.5pt black, at every
        // size. Drawn over the checker/highlights, under the pieces.
        if st.grid {
          for k in range(1, cols) {
            place(dx: k * sq, dy: 0pt, line(start: (0pt, 0pt), end: (0pt, bh), stroke: 0.5pt + black))
          }
          for k in range(1, rows) {
            place(dx: 0pt, dy: k * sq, line(start: (0pt, 0pt), end: (bw, 0pt), stroke: 0.5pt + black))
          }
        }
        // pieces -- the renderer no longer knows about baselines: square-piece
        // returns a square-sized cell positioned correctly for its piece set.
        for (name, piece) in squares {
          // `squares` keys are always well-formed (produced by the position
          // layer), so the trusted/unvalidated fast path is safe here.
          let p = _square-index(name, cols: cols, rows: rows)
          let o = _screen(p.col, p.row, sq, orient, cols, rows)
          place(dx: o.dx, dy: o.dy, square-piece(
            piece.kind, piece.color, sq,
            piece-set: st.piece-set,
            white-fill: st.white-fill, black-fill: st.black-fill, font: st.piece-font,
            glyphs: st.piece-glyphs,
            piece-scale: st.piece-scale, baseline-inset: st.baseline-inset,
          ))
        }
        // on-square labels: drawn on top, in the chosen corner, in the opposite
        // color of the square they sit on. The edge rank/file follows file-side /
        // rank-side AND orientation, so labels move with a flip.
        if labels and mode == "on-square" {
          let pad = sq * _on-square-pad-frac
          let corner-size = sq * _on-square-label-frac
          let file-row = if st.file-side == bottom { if orient == "white" { 0 } else { rows - 1 } } else { if orient == "white" { rows - 1 } else { 0 } }
          let rank-col = if st.rank-side == right { if orient == "white" { cols - 1 } else { 0 } } else { if orient == "white" { 0 } else { cols - 1 } }
          let file-align = (if st.file-label-corner == left { left } else { right }) + bottom
          let rank-align = (if st.rank-label-corner == right { right } else { left }) + top
          for col in range(cols) {
            let o = _screen(col, file-row, sq, orient, cols, rows)
            let on-dark = is-dark-square(col, file-row)
            place(dx: o.dx, dy: o.dy, box(width: sq, height: sq, inset: pad,
              align(file-align, _label-text(file-letter(col), corner-size, if on-dark { st.light } else { st.dark }))))
          }
          for row in range(rows) {
            let o = _screen(rank-col, row, sq, orient, cols, rows)
            let on-dark = is-dark-square(rank-col, row)
            place(dx: o.dx, dy: o.dy, box(width: sq, height: sq, inset: pad,
              align(rank-align, _label-text(str(row + 1), corner-size, if on-dark { st.light } else { st.dark }))))
          }
        }
        // arrows: on top of the pieces. Each entry is a dict
        // (from:, to:, color:) or a tuple ("f3","e5") / ("f3","e5", color).
        for a in st.arrows {
          let fsq = if type(a) == dictionary { a.from } else { a.at(0) }
          let tsq = if type(a) == dictionary { a.to } else { a.at(1) }
          let rawcol = if type(a) == dictionary { a.at("color", default: auto) } else if a.len() > 2 { a.at(2) } else { auto }
          let acol = _resolve-anno-color(rawcol, st.annotation-colors, arrow-default)
          let fp = parse-square(fsq, cols: cols, rows: rows)
          let tp = parse-square(tsq, cols: cols, rows: rows)
          let fo = _screen(fp.col, fp.row, sq, orient, cols, rows)
          let to = _screen(tp.col, tp.row, sq, orient, cols, rows)
          _arrow-shape(fo.dx + sq / 2, fo.dy + sq / 2, to.dx + sq / 2, to.dy + sq / 2, sq, acol, st.arrow-width)
        }
        if st.border != none {
          place(rect(width: bw, height: bh, fill: none, stroke: st.border))
        }
        // move-quality badge: topmost, on the destination square's
        // screen top-right corner. `move-quality-mark` is derived and injected by
        // `diagram-after` only (badges are tied to a move; never a bare position).
        if st.move-quality and st.move-quality-mark != none {
          let mq = st.move-quality-mark
          let p = parse-square(mq.square, cols: cols, rows: rows)
          let o = _screen(p.col, p.row, sq, orient, cols, rows)
          _draw-move-quality(o.dx, o.dy, sq, mq.symbol, st.move-quality-colors)
        }
      })

      if not labels or mode == "on-square" { return board-canvas }

      if mode == "border" {
        // a band of width `g` around the board. `border-theme` picks the
        // band fill / label color. A thin black line always separates the band
        // from the board, regardless of the `border` outline.
        let total-w = bw + 2 * g
        let total-h = bh + 2 * g
        let (band-fill, band-label) = _band-colors(st.border-theme, st.light, st.dark)
        // "wood"/"marble" composite a single continuous material image over
        // the flat backdrop, sized exactly to the band so no clipping is
        // needed. Like the flat backdrop, it also covers the interior, which
        // the board canvas placed right after then hides.
        let _band-mat = _band-material(st.border-theme)
        box(width: total-w, height: total-h, {
          place(rect(width: total-w, height: total-h, fill: band-fill, stroke: none))
          if _band-mat != none {
            place(image(_band-mat, width: total-w, height: total-h))
          }
          place(dx: g, dy: g, board-canvas)
          place(dx: g, dy: g, rect(width: bw, height: bh, fill: none, stroke: 0.5pt + black))
          let file-dy = if st.file-side == bottom { g + bh } else { 0pt }
          for col in range(cols) {
            place(dx: g + _screen(col, 0, sq, orient, cols, rows).dx, dy: file-dy,
              box(width: sq, height: g, align(center + horizon,
                _label-text(file-letter(col), label-size, band-label))))
          }
          let rank-dx = if st.rank-side == right { g + bw } else { 0pt }
          for row in range(rows) {
            place(dx: rank-dx, dy: g + _screen(0, row, sq, orient, cols, rows).dy,
              box(width: g, height: sq, align(center + horizon,
                _label-text(str(row + 1), label-size, band-label))))
          }
        })
      } else {
        // "outside": label strips in a one-sided gutter (the classic look).
        let file-strip = box(width: bw, height: g, {
          for col in range(cols) {
            place(
              dx: _screen(col, 0, sq, orient, cols, rows).dx, dy: 0pt,
              box(width: sq, height: g, align(center + horizon,
                _label-text(file-letter(col), label-size, st.label-color))),
            )
          }
        })
        let rank-strip = box(width: g, height: bh, {
          for row in range(rows) {
            place(
              dx: 0pt, dy: _screen(0, row, sq, orient, cols, rows).dy,
              box(width: g, height: sq, align(center + horizon,
                _label-text(str(row + 1), label-size, st.label-color))),
            )
          }
        })

        let board-dx = if st.rank-side == left { g } else { 0pt }
        let board-dy = if st.file-side == top { g } else { 0pt }
        box(width: bw + g, height: bh + g, {
          place(dx: board-dx, dy: board-dy, board-canvas)
          place(dx: board-dx, dy: if st.file-side == top { 0pt } else { board-dy + bh }, file-strip)
          place(dx: if st.rank-side == left { 0pt } else { board-dx + bw }, dy: board-dy, rank-strip)
        })
      }
    })
    // The board is built from layout-dependent primitives (`layout`, `place`),
    // which HTML export drops. Under an HTML target, wrap the deferred board in
    // `html.frame`: it lays the board out into a self-contained inline SVG that
    // renders in a browser. Paged (PDF/PNG) export takes the board unchanged.
    if _html-target() { html.frame(rendered) } else { rendered }
  }
}
