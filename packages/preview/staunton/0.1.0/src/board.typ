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
//     squares, each in the OPPOSITE colour of its square. Which corner is set by
//     `file-label-corner` / `rank-label-corner`. Drawn inside the board (no
//     gutter), at a fixed font fraction that does NOT change with board size.
//   * "outside": label strips in a gutter outside the board (the classic look).
//   * "border": a band of `label-border-ratio` width around the board. The band
//     fill / label colour follow `border-theme` ("square" = dark band + light
//     labels, "brown" = dark-brown band + creme labels).
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

#import "coords.typ": file-letter, parse-square, is-dark-square
#import "pieces.typ": square-piece
#import "style.typ": default-style, style-state, border-brown, border-creme, border-dark, border-dark-label

#let default-board-size = 6.4cm

// Board labels use their own sans-serif (the `label-font` board-style option),
// independent of the main/diagram font. `render-board` shadows `_label-text` with
// a closure bound to `st.label-font`; this module-level default is the fallback.
#let _label-text(body, size, fill) = text(font: ("Arial", "DejaVu Sans Mono"), size: size, fill: fill, body)

// Label sizing (fractions of a square side). On-square labels are small and sit
// tucked into the corner; the "outside"/"border" labels live in a gutter so can
// be larger.
#let _on-square-label-frac = 0.22   // on-square label size (item 1: a bit smaller)
#let _on-square-pad-frac = 0.07     // on-square label inset from the corner (item 1: further in)
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

// Set a colour's alpha to an absolute opacity (`100% - transparency`), preserving
// its RGB components. Used to apply the `*-transparency` style fields to the
// (opaque) default highlight/arrow colours.
#let _with-alpha(col, transparency) = {
  let c = rgb(col).components()
  rgb(c.at(0), c.at(1), c.at(2), 100% - transparency)
}

// Resolve a colour spec used by arrows / highlights (item 6/8):
//   * `auto`         -> the supplied fallback colour;
//   * a string (a PGN %cal/%csl letter like "G") -> annotation-colors lookup;
//   * a colour value -> used as-is.
#let _resolve-anno-color(c, anno-map, fallback) = {
  if c == auto { fallback }
  else if type(c) == str { anno-map.at(c, default: fallback) }
  else { c }
}

// A straight arrow (item 6): a shaft plus a filled triangular head, from
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
  let sw = if shaft-w == auto { sq * 0.13 } else { shaft-w }
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

// Draw one highlight inside the board canvas at screen offset (dx, dy):
//   * "filled" -> a square-filling rect in `fill`;
//   * "circle" -> a centred circle whose OUTER stroke edge just touches the square
//                 border (radius shrunk by half the stroke), stroked in `circle-col`;
//   * "cross"  -> an X spanning ~95% of the square, stroked in `cross-col` with
//                 round caps. The two diagonals are placed INDEPENDENTLY: a single
//                 `place` holding both lines would stack them in normal flow,
//                 dropping the second diagonal onto a lower square.
#let _draw-highlight(shape, dx, dy, sq, fill, cross-col, circle-col, cross-w, circle-w) = {
  if shape == "filled" {
    place(dx: dx, dy: dy, rect(width: sq, height: sq, fill: fill, stroke: none))
  } else if shape == "circle" {
    // The stroke straddles the radius, so the outer edge sits at radius + w/2.
    // Shrink the radius by w/2 and re-centre by w/2 so that outer edge lands
    // exactly on the square border, never beyond it.
    place(
      dx: dx + circle-w / 2,
      dy: dy + circle-w / 2,
      circle(radius: sq / 2 - circle-w / 2, fill: none, stroke: circle-w + circle-col),
    )
  } else if shape == "cross" {
    let inset = sq * 0.025   // ~95% corner-to-corner
    let str = stroke(paint: cross-col, thickness: cross-w, cap: "round")
    place(dx: dx, dy: dy, line(start: (inset, sq - inset), end: (sq - inset, inset), stroke: str))      // LL -> UR
    place(dx: dx, dy: dy, line(start: (inset, inset), end: (sq - inset, sq - inset), stroke: str))      // UL -> LR
  } else {
    panic("highlight shape must be \"filled\", \"cross\", or \"circle\"; got " + repr(shape))
  }
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
    let st = default-style + style-state.get() + overrides.named()
    // Labels use `st.label-font` (configurable); shadow the helper so the call
    // sites below pick it up without threading the font through each one.
    let _label-text = (body, size, fill) => text(font: st.label-font, size: size, fill: fill, body)
    assert(st.file-side == bottom or st.file-side == top, message: "file-side must be `top` or `bottom`")
    assert(st.rank-side == left or st.rank-side == right, message: "rank-side must be `left` or `right`")
    assert(st.file-label-corner == left or st.file-label-corner == right, message: "file-label-corner must be `left` or `right`")
    assert(st.rank-label-corner == left or st.rank-label-corner == right, message: "rank-label-corner must be `left` or `right`")
    let modes = ("on-square", "outside", "border")
    assert(modes.contains(st.label-mode), message: "label-mode must be one of " + repr(modes) + "; got " + repr(st.label-mode))
    let themes = ("square", "brown", "dark")
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

      // colours that depend on style fields (computed once)
      let hl-default-fill = _with-alpha(st.highlight-fill, st.highlight-transparency)
      let arrow-default = _with-alpha(st.arrow-color, st.arrow-transparency)

      let board-canvas = box(width: bw, height: bh, {
        // checker
        for row in range(rows) {
          for col in range(cols) {
            let o = _screen(col, row, sq, orient, cols, rows)
            place(dx: o.dx, dy: o.dy, rect(
              width: sq, height: sq,
              fill: if is-dark-square(col, row) { st.dark } else { st.light },
              stroke: none,
            ))
          }
        }
        // highlights (under the pieces, over the checker). Each entry is a square
        // name (uses highlight-shape + highlight-fill), a (square, color) pair
        // (filled, explicit colour -- e.g. PGN %csl), or a dict (square:, shape:,
        // color:) for full control.
        for h in st.highlight {
          let hname = none
          let shape = st.highlight-shape
          let ecol = auto   // explicit colour, or auto = use the shape default
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
          _draw-highlight(shape, o.dx, o.dy, sq, fill, cross-c, circle-c, st.cross-width, st.circle-width)
        }
        // optional grid lines between squares: a fixed 0.5pt black, at every
        // size (item 2). Drawn over the checker/highlights, under the pieces.
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
          let p = parse-square(name, cols: cols, rows: rows)
          let o = _screen(p.col, p.row, sq, orient, cols, rows)
          place(dx: o.dx, dy: o.dy, square-piece(
            piece.kind, piece.color, sq,
            piece-set: st.piece-set,
            white-fill: st.white-fill, black-fill: st.black-fill, font: st.piece-font,
            piece-scale: st.piece-scale, baseline-inset: st.baseline-inset,
          ))
        }
        // on-square labels: drawn on top, in the chosen corner, in the opposite
        // colour of the square they sit on. The edge rank/file follows file-side /
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
        // arrows (item 6): on top of the pieces. Each entry is a dict
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
      })

      if not labels or mode == "on-square" { return board-canvas }

      if mode == "border" {
        // a band of width `g` around the board (item 2). `border-theme` picks the
        // band fill / label colour. A thin black line always separates the band
        // from the board, regardless of the `border` outline.
        let total-w = bw + 2 * g
        let total-h = bh + 2 * g
        let band-fill = if st.border-theme == "brown" { border-brown } else if st.border-theme == "dark" { border-dark } else { st.dark }
        let band-label = if st.border-theme == "brown" { border-creme } else if st.border-theme == "dark" { border-dark-label } else { st.light }
        box(width: total-w, height: total-h, {
          place(rect(width: total-w, height: total-h, fill: band-fill, stroke: none))
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
    if target() == "html" { html.frame(rendered) } else { rendered }
  }
}
