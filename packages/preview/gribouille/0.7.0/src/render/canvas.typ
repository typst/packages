// Canvas assembly: per-panel scale training for free scales and the three
// canvas builders (facet-wrap grid, facet-grid, single panel) that lay out
// panels, strips, shared axis titles, and the plot-level legend.

#import "../deps.typ": cetz
#import "../scale/train.typ": mapping-display-name, positional-aesthetics, train
#import "../theme/theme.typ": _tick-length, resolve-theme-palette
#import "legend.typ" as legend-mod
#import "common.typ": _tick-cm-sides
#import "axis-format.typ": _axis-title, _sec-spec, _shared-axis-breaks
#import "domain.typ": (
  _apply-coord, _apply-coord-transform, _apply-expand, _apply-flip,
  _apply-labels, _fixed-inner-size, _is-flipped, _post-train,
)
#import "extents.typ": (
  _AX-TITLE-LABEL-GAP, _LAYOUT-TOLERANCE, _axis-label-extents, _merge-extents,
  _sec-band-cm, _sec-title-offset-cm, _secondary-label-extents, _text-margin-cm,
  _title-angle, _title-body, _title-extent-cm, _x-title-place, _y-title-place,
)
#import "facet.typ": (
  _draw-strip, _facet-gutter, _fit-gutter, _strip-band, _strip-texts,
  _wrap-tracks,
)
#import "panel-draw.typ": _draw-axis-and-layers
#import "../utils/errors.typ": cm-text, fail

// Passes allowed when settling the two facet-grid strip bands against the
// panels they leave. Each pass may only thicken a band, so the panels descend
// and the loop settles; real grids take two, and the cap only bounds a
// degenerate one. A grid that exhausted it would box its labels to the panel
// the pass before left, so the cap sits well clear of what any grid needs.
#let _STRIP-FIT-PASSES = 8

// The strips shrink with the grid, giving up their fixed base band and then
// the whitespace around them, but a label cannot be shrunk further than the
// room its own glyphs need. Past that the grid would lay a band outside the
// canvas, so say what is needed rather than ship a figure that outgrew the
// size it was asked for, exactly as an oversized axis title does.
#let _check-strip-fit(needed, available, dim) = {
  if needed <= available + _LAYOUT-TOLERANCE { return }
  fail(
    "plot",
    "the facet strips need "
      + cm-text(needed)
      + " cm of "
      + dim
      + " along a panel grid of "
      + cm-text(calc.max(0.0, available))
      + " cm, and their labels do not fit in less",
    hint: "Give the plot more room with `width`/`height`, facet over fewer "
      + "levels, or shrink the strip text with "
      + "`theme(strip-text: element-text(size: ...))`.",
  )
}

// A strip label wraps into the panel it names, but a single word cannot be
// broken, so a word wider than the panel runs past it however the label wraps.
// Report the room that word needs, the way an oversized axis title does, rather
// than draw a label over its neighbours. `name` says which band: a facet-wrap
// strip, or a facet-grid column or row band.
#let _check-strip-overrun(min-width, along, name) = {
  if min-width <= along + _LAYOUT-TOLERANCE { return }
  fail(
    "plot",
    "the "
      + name
      + " have a "
      + cm-text(min-width)
      + " cm word that cannot wrap into the "
      + cm-text(calc.max(0.0, along))
      + " cm the panel leaves it",
    hint: "Shorten the level names with a `labeller`, break them with `\\`, "
      + "give the plot more room with `width`/`height`, or shrink the strip "
      + "text with `theme(strip-text: element-text(size: ...))`.",
  )
}

#let _panel-row-count(panel-layers) = {
  let n = 0
  for layer in panel-layers { n += layer.data.len() }
  n
}

// Per-panel positional retrain: train the positional aesthetics on a layer
// subset and run the same label/coord pipeline the top-level training gets,
// so a free panel scale behaves exactly like a shared one would.
#let _train-positional(spec, layers, coord, labels) = {
  let pt = train(
    scales: spec.scales,
    layers: layers,
    mapping: spec.mapping,
    data: spec.data,
    aesthetics: positional-aesthetics,
  )
  pt = _apply-labels(pt, labels)
  pt = _post-train(pt, layers)
  pt = _apply-coord-transform(pt, coord)
  pt = _apply-coord(pt, coord)
  pt = _apply-expand(pt, coord)
  _apply-flip(pt, coord)
}

// Shared break sets for a facet canvas. A free axis resets its entry to
// `none` so `_draw-cartesian-axis` falls back to per-panel computation (the
// per-panel scale is what differs); the fixed axis still benefits from the
// cached breaks even when the other axis is free.
#let _facet-shared-breaks(trained, free-x, free-y, coord: none) = {
  let s = _shared-axis-breaks(trained, coord: coord)
  if free-x {
    s.insert("x", none)
    s.insert("x-sec", none)
  }
  if free-y {
    s.insert("y", none)
    s.insert("y-sec", none)
  }
  s
}

// Shared facet-canvas tail: the centred x/y axis titles plus the plot-level
// legend. Returns cetz elements; `grid-w`/`grid-h` are the panel-grid extents
// and `right-strip`/`top-strip` the facet-grid strip bands (0 under wrap).
#let _facet-titles-and-legend(
  ctx,
  grid-w,
  grid-h,
  right-strip: 0.0,
  top-strip: 0.0,
) = {
  let spec = ctx.spec
  let theme = ctx.theme
  let trained = ctx.trained
  let margin = ctx.margin
  let _ax-title = ctx.style.ax-title

  let x-trained = trained.at("x", default: none)
  let y-trained = trained.at("y", default: none)
  let _map-name(axis) = if spec.mapping == none { none } else {
    mapping-display-name(spec.mapping.at(axis, default: none))
  }
  let x-title = _axis-title(x-trained, _map-name("x"))
  let y-title = _axis-title(y-trained, _map-name("y"))
  let _tick-len = _tick-cm-sides(theme)
  // The band between the panel grid and its title is the one `_chrome-margins`
  // reserved, carried here rather than recomputed: a suppressed axis draws no
  // ticks or labels and a radial panel draws neither band outside its edges, so
  // recomputing it means remembering both gates in a second place, and a title
  // offset by a band nothing drew lands outside its own margin, growing the
  // canvas past the requested size.
  let _xt-gap = _text-margin-cm(_ax-title.xb, "top", _AX-TITLE-LABEL-GAP)
  let _yt-gap = _text-margin-cm(_ax-title.yl, "right", _AX-TITLE-LABEL-GAP)
  let _xt-cm = _title-extent-cm(_ax-title.xb, ctx.x-title-extents, "x")
  let _yt-cm = _title-extent-cm(_ax-title.yl, ctx.y-title-extents, "y")
  // A shared title spans the whole grid, so the themed `align` pins it to the
  // grid's own ends, the way a single plot's pins it to the panel's.
  let _x-span = (margin.left, margin.left + grid-w)
  let _y-span = (margin.bottom, margin.bottom + grid-h)
  if x-title != none and _ax-title.xb.size > 0pt {
    let (cx, x-anchor) = _x-title-place(_ax-title.xb.align, .._x-span)
    cetz.draw.content(
      (
        cx,
        margin.bottom - ctx.x-edge-band - _xt-gap - _xt-cm,
      ),
      _title-body(x-title, _ax-title.xb, ctx.x-title-extents),
      anchor: x-anchor,
      angle: _title-angle(_ax-title.xb, 0),
    )
  }
  if y-title != none and _ax-title.yl.size > 0pt {
    let (cy, y-anchor) = _y-title-place(_ax-title.yl.align, .._y-span)
    cetz.draw.content(
      (
        margin.left - ctx.y-edge-band - _yt-gap - _yt-cm / 2,
        cy,
      ),
      _title-body(y-title, _ax-title.yl, ctx.y-title-extents),
      angle: _title-angle(_ax-title.yl, 90),
      anchor: y-anchor,
    )
  }

  // The secondary titles hang off the far edge of the grid rather than the
  // panel edge a single plot uses, so the strip bands sit between the axis and
  // its title. `_chrome-margins` reserved the same extent on that side, and the
  // extents carried here are the ones it fitted, so a long title arrives
  // already wrapped.
  let _x-sec = _sec-spec(x-trained, coord: ctx.coord)
  let _y-sec = _sec-spec(y-trained, coord: ctx.coord)
  if _x-sec != none and _x-sec.name != none and _ax-title.xt.size > 0pt {
    let _x-sec-offset = _sec-title-offset-cm(
      _tick-len.xt,
      ctx.x-sec-extents,
      _ax-title.xt,
      "x",
    )
    let (cx, x-anchor) = _x-title-place(_ax-title.xt.align, .._x-span)
    cetz.draw.content(
      (cx, margin.bottom + grid-h + top-strip + _x-sec-offset),
      _title-body(_x-sec.name, _ax-title.xt, ctx.x-sec-title-extents),
      anchor: x-anchor,
      angle: _title-angle(_ax-title.xt, 0),
    )
  }
  if _y-sec != none and _y-sec.name != none and _ax-title.yr.size > 0pt {
    let _y-sec-offset = _sec-title-offset-cm(
      _tick-len.yr,
      ctx.y-sec-extents,
      _ax-title.yr,
      "y",
    )
    let _y-sec-cm = _title-extent-cm(_ax-title.yr, ctx.y-sec-title-extents, "y")
    let (cy, y-anchor) = _y-title-place(_ax-title.yr.align, .._y-span)
    cetz.draw.content(
      (margin.left + grid-w + right-strip + _y-sec-offset + _y-sec-cm / 2, cy),
      _title-body(_y-sec.name, _ax-title.yr, ctx.y-sec-title-extents),
      angle: _title-angle(_ax-title.yr, 90),
      anchor: y-anchor,
    )
  }

  if ctx.guides.len() > 0 {
    let lctx = (
      trained: trained,
      palette: resolve-theme-palette(theme),
      theme: theme,
      canvas-w: ctx.width-units,
      canvas-h: ctx.height-units,
    )
    legend-mod.draw(
      ctx.guides,
      lctx,
      panel-rect: (
        x: margin.left,
        y: margin.bottom,
        w: grid-w,
        h: grid-h,
      ),
      margin: margin,
      legend-gap: ctx.legend-gap,
      sec-y-extent: ctx.sec-y-extent,
      sec-x-extent: ctx.sec-x-extent,
      right-strip: right-strip,
      top-strip: top-strip,
      theme: theme,
    )
  }
}

#let _train-panels(spec, panels, trained, coord, labels, free-x, free-y) = {
  if not (free-x or free-y) { return () }
  // Only positional aesthetics are retrained per panel; non-positionals stay
  // shared so legends do not fragment. Label names must be re-applied because
  // pt.x / pt.y overwrite the globally-labelled merged.x / merged.y below.
  panels.map(p => {
    let pt = _train-positional(spec, p.layers, coord, labels)
    let merged = trained
    if free-x and pt.at("x", default: none) != none {
      merged.insert("x", pt.x)
    }
    if free-y and pt.at("y", default: none) != none {
      merged.insert("y", pt.y)
    }
    merged
  })
}

// Grid analogue of `_train-panels`: free-x trains x once PER COLUMN (union over
// the column's rows) and free-y trains y once PER ROW (union over the row's
// columns), so every panel in a column shares one x domain and every panel in a
// row shares one y domain. Non-positional scales stay shared. Returns one merged
// trained dict per panel, indexed `r * n-cols + c`; `()` when neither axis is free.
#let _train-grid-panels(
  spec,
  panels,
  trained,
  coord,
  labels,
  n-rows,
  n-cols,
  free-x,
  free-y,
) = {
  if not (free-x or free-y) { return () }
  let n-layers = panels.at(0).layers.len()
  // Concatenate layer `li`'s data across a set of panel indices, preserving
  // layer order so `train` folds the group exactly like a single panel would.
  let union-layers = idxs => {
    range(n-layers).map(li => {
      let merged = panels.at(idxs.at(0)).layers.at(li)
      let data = ()
      for pi in idxs { data += panels.at(pi).layers.at(li).data }
      merged.data = data
      merged
    })
  }
  // Same positional pipeline as `_train-panels`, run once per group.
  let train-group = group-layers => _train-positional(
    spec,
    group-layers,
    coord,
    labels,
  )
  // One trained x per column (union over its rows), one trained y per row.
  let col-x = if free-x {
    range(n-cols).map(c => {
      let idxs = range(n-rows).map(r => r * n-cols + c)
      train-group(union-layers(idxs)).at("x", default: none)
    })
  } else { none }
  let row-y = if free-y {
    range(n-rows).map(r => {
      let idxs = range(n-cols).map(c => r * n-cols + c)
      train-group(union-layers(idxs)).at("y", default: none)
    })
  } else { none }
  let out = ()
  for r in range(n-rows) {
    for c in range(n-cols) {
      let merged = trained
      if free-x and col-x.at(c) != none { merged.insert("x", col-x.at(c)) }
      if free-y and row-y.at(r) != none { merged.insert("y", row-y.at(r)) }
      out.push(merged)
    }
  }
  out
}

// Depth (cm) a facet cell owes the secondary axis on `axis`: zero unless the
// trained scale carries a `secondary:` spec that the panels actually draw.
// Under free scales each panel measures its own labels, so the widest wins
// and every cell keeps the same geometry.
#let _facet-sec-band(ctx, panel-extents, axis) = {
  let trained = ctx.trained.at(axis, default: none)
  if _sec-spec(trained, coord: ctx.coord) == none { return 0.0 }
  let style = if axis == "x" { ctx.ax-text.xt } else { ctx.ax-text.yr }
  if style.size <= 0pt { return 0.0 }
  let key = axis + "-sec"
  let base = if axis == "x" { ctx.x-sec-extents } else { ctx.y-sec-extents }
  let ext = if panel-extents == none { base } else {
    _merge-extents(base, panel-extents.map(pe => pe.at(key, default: base)))
  }
  let side = if axis == "x" { "axis-ticks-xt" } else { "axis-ticks-yr" }
  _sec-band-cm(_tick-length(ctx.theme, side) / 1cm, ext, axis)
}

#let _render-canvas-wrap(ctx) = {
  let spec = ctx.spec
  let theme = ctx.theme
  let coord = ctx.coord
  let trained = ctx.trained
  let panels = ctx.panels
  let panel-trained-list = ctx.panel-trained-list
  let wrap-levels = ctx.wrap-levels
  let margin = ctx.margin
  let width-units = ctx.width-units
  let height-units = ctx.height-units
  let free-x = ctx.free-x
  let free-y = ctx.free-y
  let style = ctx.style
  let x-extents = ctx.x-extents
  let y-extents = ctx.y-extents
  let x-sec-extents = ctx.x-sec-extents
  let y-sec-extents = ctx.y-sec-extents
  let ax-text = ctx.ax-text

  // Per-panel extents under free scales: each panel's trained scale carries
  // its own break/level set, so the longest label can differ panel-to-panel.
  // Measured here (still inside the outer `context`) before the canvas
  // closure, since cetz canvas does not expose layout measurement.
  let panel-extents = if not (free-x or free-y) {
    none
  } else {
    panel-trained-list.map(pt => {
      let xt = pt.at("x", default: none)
      let yt = pt.at("y", default: none)
      let xs = _sec-spec(xt, coord: coord)
      let ys = _sec-spec(yt, coord: coord)
      (
        x: if free-x {
          _axis-label-extents(
            xt,
            ax-text.xb.size,
            "x",
            coord,
            typst-eval: ax-text.xb.typst,
          )
        } else { x-extents },
        y: if free-y {
          _axis-label-extents(
            yt,
            ax-text.yl.size,
            "y",
            coord,
            typst-eval: ax-text.yl.typst,
          )
        } else { y-extents },
        x-sec: if free-x {
          _secondary-label-extents(
            xt,
            xs,
            ax-text.xt.size,
            typst-eval: ax-text.xt.typst,
          )
        } else { x-sec-extents },
        y-sec: if free-y {
          _secondary-label-extents(
            yt,
            ys,
            ax-text.yr.size,
            typst-eval: ax-text.yr.typst,
          )
        } else { y-sec-extents },
      )
    })
  }

  let levels = wrap-levels
  let n = levels.len()
  let (ncol, nrow) = _wrap-tracks(spec.facet, n)
  let strip-texts = _strip-texts(
    spec.facet.at("labeller", default: none),
    spec.facet.variable,
    levels,
    i => _panel-row-count(panels.at(i).layers),
  )
  let gutters = _facet-gutter(spec.facet, theme, "facet-wrap")

  let all-x = ("all_x", "all").contains(spec.facet.axes)
  let all-y = ("all_y", "all").contains(spec.facet.axes)

  // A panel's secondary x axis is drawn at its top edge, which is exactly
  // where the strip band above it is painted, so the cell reserves the axis
  // depth between the two. Only the rows that draw one pay for it: with fixed
  // scales that is the top row alone, and every panel keeps the same size
  // either way because the band is inserted inside the cell.
  let sec-band = _facet-sec-band(ctx, panel-extents, "x")
  let _sec-band-of = row => if sec-band > 0 and (free-x or all-x or row == 0) {
    sec-band
  } else { 0.0 }

  let grid-w = width-units - margin.left - margin.right
  let grid-h = height-units - margin.bottom - margin.top
  // Gutters and strips are fixed costs the grid pays before the panels get
  // anything, and nothing used to cap them against the grid, so a small plot
  // laid its top strip past the canvas edge. Budget them instead: every row
  // owes a strip, so a band may take at most its share of what the secondary
  // bands leave, and the whitespace between panels gives way before a label
  // does. Floor the panel at zero: an empty panel is honest, a negative one
  // draws mirrored.
  let sec-total = range(nrow).map(_sec-band-of).sum(default: 0.0)
  // The column width owes the strips nothing, so it settles first and is the
  // reading length the labels are boxed to.
  let gutter-x = _fit-gutter(gutters.x, grid-w, ncol)
  let panel-w = calc.max(0.0, grid-w - gutter-x * (ncol - 1)) / ncol
  let strip = _strip-band(
    strip-texts,
    style,
    0.45,
    budget: calc.max(0.0, grid-h - sec-total) / nrow,
    along-cm: panel-w,
  )
  _check-strip-fit(strip.text * nrow + sec-total, grid-h, "height")
  _check-strip-overrun(strip.min-width, panel-w, "facet strips")
  let strip-h = strip.band
  let gutter-y = _fit-gutter(
    gutters.y,
    grid-h - sec-total - strip-h * nrow,
    nrow,
  )
  let panel-h = (
    calc.max(
      0.0,
      grid-h - gutter-y * (nrow - 1) - strip-h * nrow - sec-total,
    )
      / nrow
  )

  let shared-breaks = _facet-shared-breaks(
    trained,
    free-x,
    free-y,
    coord: coord,
  )

  cetz.canvas(length: 1cm, {
    import cetz.draw: *
    hide(rect((0, 0), (width-units, height-units)), bounds: true)
    for (i, level) in levels.enumerate() {
      let col = calc.rem(i, ncol)
      let row = int(i / ncol)
      let x0 = margin.left + col * (panel-w + gutter-x)
      // Rows below this one each contribute a cell plus a gutter, and a cell
      // is the panel, its own secondary band, and its strip.
      let y0 = (
        margin.bottom
          + range(row + 1, nrow).fold(
            0.0,
            (acc, r) => acc + panel-h + _sec-band-of(r) + strip-h + gutter-y,
          )
      )
      let panel-layers = panels.at(i).layers
      let strip-text = strip-texts.at(i)
      let strip-y = y0 + panel-h + _sec-band-of(row)
      _draw-strip(
        (x0, strip-y),
        (x0 + panel-w, strip-y + strip-h),
        strip-text,
        style,
        theme,
        along-cm: strip.alongs.at(i),
      )
      let panel-trained = if panel-trained-list.len() == 0 {
        trained
      } else { panel-trained-list.at(i) }
      let (inner-w, inner-h) = _fixed-inner-size(
        coord,
        panel-trained,
        panel-w,
        panel-h,
      )
      let inner-y0 = y0 + (panel-h - inner-h)
      let _pe = if panel-extents != none {
        panel-extents.at(i)
      } else {
        (
          x: x-extents,
          y: y-extents,
          x-sec: x-sec-extents,
          y-sec: y-sec-extents,
        )
      }
      _draw-axis-and-layers(
        panel-layers,
        panel-trained,
        theme,
        spec,
        (x0, inner-y0),
        (inner-w, inner-h),
        // `i + ncol >= n`: no panel sits below this one, so it owns the
        // bottom x axis even if its row isn't the geometric last row
        // (trailing empty slots in a partial wrap).
        show-x-labels: free-x or all-x or i + ncol >= n,
        show-y-labels: free-y or all-y or col == 0,
        show-x-title: false,
        show-y-title: false,
        show-x-sec: free-x or all-x or row == 0,
        show-y-sec: free-y or all-y or col == ncol - 1,
        show-x-sec-title: false,
        show-y-sec-title: false,
        flipped: _is-flipped(coord),
        axis-breaks: shared-breaks,
        x-extents: _pe.x,
        y-extents: _pe.y,
        x-sec-extents: _pe.x-sec,
        y-sec-extents: _pe.y-sec,
        canvas-w: width-units,
        canvas-h: height-units,
      )
    }

    _facet-titles-and-legend(ctx, grid-w, grid-h)
  })
}

#let _render-canvas-grid(ctx) = {
  let spec = ctx.spec
  let theme = ctx.theme
  let coord = ctx.coord
  let trained = ctx.trained
  let panels = ctx.panels
  let grid-row-levels = ctx.grid-row-levels
  let grid-col-levels = ctx.grid-col-levels
  let margin = ctx.margin
  let width-units = ctx.width-units
  let height-units = ctx.height-units
  let style = ctx.style
  let x-extents = ctx.x-extents
  let y-extents = ctx.y-extents
  let x-sec-extents = ctx.x-sec-extents
  let y-sec-extents = ctx.y-sec-extents
  let panel-trained-list = ctx.panel-trained-list
  let free-x = ctx.free-x
  let free-y = ctx.free-y

  let row-var = spec.facet.rows
  let col-var = spec.facet.columns
  let row-levels = grid-row-levels
  let col-levels = grid-col-levels
  let n-rows = calc.max(1, row-levels.len())
  let n-cols = calc.max(1, col-levels.len())
  let _grid-labeller = spec.facet.at("labeller", default: none)
  let _col-count(c) = {
    let n = 0
    for r in range(n-rows) {
      n += _panel-row-count(panels.at(r * n-cols + c).layers)
    }
    n
  }
  let _row-count(r) = {
    let n = 0
    for c in range(n-cols) {
      n += _panel-row-count(panels.at(r * n-cols + c).layers)
    }
    n
  }
  let col-strip-texts = if col-var == none { () } else {
    _strip-texts(_grid-labeller, col-var, col-levels, _col-count)
  }
  let row-strip-texts = if row-var == none { () } else {
    _strip-texts(_grid-labeller, row-var, row-levels, _row-count)
  }
  let gutters = _facet-gutter(spec.facet, theme, "facet-grid")
  // The top row draws its secondary x axis at the grid's top edge, under the
  // column strips, which are painted after every panel and would cover it.
  // Reserve the axis depth between the two. The right column's secondary y
  // does the same against the row strips.
  let sec-band-x = if col-var == none { 0.0 } else {
    _facet-sec-band(ctx, none, "x")
  }
  let sec-band-y = if row-var == none { 0.0 } else {
    _facet-sec-band(ctx, none, "y")
  }
  // One band above the whole grid and one beside it, each budgeted against
  // what the canvas leaves once the margins and the secondary bands are paid.
  // A row strip is drawn rotated, so the label height it measures is the
  // band's width and the grid's width is what has to hold it.
  let v-room = height-units - margin.bottom - margin.top - sec-band-x
  let h-room = width-units - margin.left - margin.right - sec-band-y
  // A column band eats the height a row label reads along, and a row band eats
  // the width a column label reads along, so the two are solved together: box
  // the labels to the panels the current bands leave, re-measure, and stop once
  // the panels hold still. A pass can only thicken a band, so the panels
  // descend and the loop settles; the cap is a backstop for a degenerate grid,
  // where the panel floors at zero and the labels-only check below takes over.
  let col-strip = none
  let row-strip = none
  let top-strip = 0.0
  let right-strip = 0.0
  let grid-w = 0.0
  let grid-h = 0.0
  let gutter-x = gutters.x
  let gutter-y = gutters.y
  // `none` until a pass has sized them: the first measurement boxes the labels
  // to nothing at all, and every later one to the panels the last pass left.
  let panel-w = none
  let panel-h = none
  for _ in range(_STRIP-FIT-PASSES) {
    col-strip = _strip-band(
      col-strip-texts,
      style,
      0.45,
      budget: v-room,
      along-cm: panel-w,
    )
    row-strip = _strip-band(
      row-strip-texts,
      style,
      0.55,
      budget: h-room,
      along-cm: panel-h,
    )
    top-strip = if col-var != none { col-strip.band } else { 0.0 }
    right-strip = if row-var != none { row-strip.band } else { 0.0 }
    grid-w = h-room - right-strip
    grid-h = v-room - top-strip
    // The whitespace between panels gives way to what the bands leave, the
    // same way it does under facet-wrap.
    gutter-x = _fit-gutter(gutters.x, grid-w, n-cols)
    gutter-y = _fit-gutter(gutters.y, grid-h, n-rows)
    let next-w = calc.max(0.0, grid-w - gutter-x * (n-cols - 1)) / n-cols
    let next-h = calc.max(0.0, grid-h - gutter-y * (n-rows - 1)) / n-rows
    let settled = (
      panel-w != none
        and calc.abs(next-w - panel-w) < _LAYOUT-TOLERANCE
        and calc.abs(next-h - panel-h) < _LAYOUT-TOLERANCE
    )
    panel-w = next-w
    panel-h = next-h
    if settled { break }
  }
  if col-var != none {
    _check-strip-fit(col-strip.text, v-room, "height")
    _check-strip-overrun(col-strip.min-width, panel-w, "facet column strips")
  }
  if row-var != none {
    _check-strip-fit(row-strip.text, h-room, "width")
    _check-strip-overrun(row-strip.min-width, panel-h, "facet row strips")
  }
  let inner-right = margin.right + right-strip + sec-band-y

  let shared-breaks = _facet-shared-breaks(
    trained,
    free-x,
    free-y,
    coord: coord,
  )

  cetz.canvas(length: 1cm, {
    import cetz.draw: *
    hide(rect((0, 0), (width-units, height-units)), bounds: true)
    for (r, row-lv) in row-levels.enumerate() {
      for (c, col-lv) in col-levels.enumerate() {
        let x0 = margin.left + c * (panel-w + gutter-x)
        let y0 = margin.bottom + (n-rows - 1 - r) * (panel-h + gutter-y)
        let panel-layers = panels.at(r * n-cols + c).layers
        let panel-trained = if panel-trained-list.len() == 0 {
          trained
        } else { panel-trained-list.at(r * n-cols + c) }
        let (inner-w, inner-h) = _fixed-inner-size(
          coord,
          panel-trained,
          panel-w,
          panel-h,
        )
        let inner-y0 = y0 + (panel-h - inner-h)
        _draw-axis-and-layers(
          panel-layers,
          panel-trained,
          theme,
          spec,
          (x0, inner-y0),
          (inner-w, inner-h),
          show-x-labels: r == n-rows - 1,
          show-y-labels: c == 0,
          show-x-title: false,
          show-y-title: false,
          show-x-sec: r == 0,
          show-y-sec: c == n-cols - 1,
          show-x-sec-title: false,
          show-y-sec-title: false,
          flipped: _is-flipped(coord),
          axis-breaks: shared-breaks,
          x-extents: x-extents,
          y-extents: y-extents,
          x-sec-extents: x-sec-extents,
          y-sec-extents: y-sec-extents,
          canvas-w: width-units,
          canvas-h: height-units,
        )
      }
    }

    if col-var != none {
      let strip-y = margin.bottom + grid-h + sec-band-x
      for c in range(col-levels.len()) {
        let x0 = margin.left + c * (panel-w + gutter-x)
        _draw-strip(
          (x0, strip-y),
          (x0 + panel-w, strip-y + top-strip),
          col-strip-texts.at(c),
          style,
          theme,
          along-cm: col-strip.alongs.at(c),
        )
      }
    }

    if row-var != none {
      let strip-x = margin.left + grid-w + sec-band-y
      for r in range(row-levels.len()) {
        let y0 = margin.bottom + (n-rows - 1 - r) * (panel-h + gutter-y)
        _draw-strip(
          (strip-x, y0),
          (strip-x + right-strip, y0 + panel-h),
          row-strip-texts.at(r),
          style,
          theme,
          angle: -90deg,
          along-cm: row-strip.alongs.at(r),
        )
      }
    }

    _facet-titles-and-legend(
      ctx,
      grid-w,
      grid-h,
      right-strip: right-strip + sec-band-y,
      top-strip: top-strip + sec-band-x,
    )
  })
}

// Single-panel canvas builder; takes the same named-dict ctx convention as
// `_render-canvas-wrap` / `_render-canvas-grid`.
#let _render-canvas-single(ctx) = {
  let coord = ctx.coord
  let trained = ctx.trained
  let margin = ctx.margin
  let width-units = ctx.width-units
  let height-units = ctx.height-units

  let px-lo = margin.left
  let px-hi = width-units - margin.right
  let py-lo = margin.bottom
  let py-hi = height-units - margin.top

  // Chrome can consume the whole canvas on a very small plot; floor the panel at
  // zero so it draws empty rather than inverting into a mirrored rect.
  let box-w = calc.max(0.0, px-hi - px-lo)
  let box-h = calc.max(0.0, py-hi - py-lo)
  let (inner-w, inner-h) = _fixed-inner-size(coord, trained, box-w, box-h)

  cetz.canvas(length: 1cm, {
    import cetz.draw: hide, rect
    hide(rect((0, 0), (width-units, height-units)), bounds: true)
    _draw-axis-and-layers(
      ctx.prepared,
      trained,
      ctx.theme,
      ctx.spec,
      (px-lo, py-lo),
      (inner-w, inner-h),
      guides: ctx.guides,
      legend-args: (
        panel-rect: (x: px-lo, y: py-lo, w: inner-w, h: inner-h),
        margin: margin,
        legend-gap: ctx.legend-gap,
        sec-y-extent: ctx.sec-y-extent,
        sec-x-extent: ctx.sec-x-extent,
        right-strip: 0.0,
      ),
      flipped: _is-flipped(coord),
      x-extents: ctx.x-extents,
      y-extents: ctx.y-extents,
      x-title-extents: ctx.x-title-extents,
      y-title-extents: ctx.y-title-extents,
      x-sec-title-extents: ctx.x-sec-title-extents,
      y-sec-title-extents: ctx.y-sec-title-extents,
      x-sec-extents: ctx.x-sec-extents,
      y-sec-extents: ctx.y-sec-extents,
      x-edge-band: ctx.x-edge-band,
      y-edge-band: ctx.y-edge-band,
      canvas-w: width-units,
      canvas-h: height-units,
    )
  })
}
