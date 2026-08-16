// Canvas assembly: per-panel scale training for free scales and the three
// canvas builders (facet-wrap grid, facet-grid, single panel) that lay out
// panels, strips, shared axis titles, and the plot-level legend.

#import "../deps.typ": cetz
#import "../scale/train.typ": mapping-display-name, positional-aesthetics, train
#import "../theme/theme.typ": _scalar-cascade, _text-args
#import "../utils/typst-markup.typ": resolve-prose
#import "../utils/palette.typ": default-discrete
#import "../legend.typ" as legend-mod
#import "common.typ": _per-side
#import "axis-format.typ": _axis-title, _sec-spec, _shared-axis-breaks
#import "domain.typ": (
  _apply-coord, _apply-coord-transform, _apply-expand, _apply-flip, _apply-labs,
  _fixed-inner-size, _is-flipped, _post-train,
)
#import "extents.typ": (
  _AX-TITLE-LABEL-GAP, _ax-text-cm, _axis-label-extents,
  _secondary-label-extents, _text-margin-cm, _x-label-depth, _y-label-width,
)
#import "facet.typ": _draw-strip, _strip-band, _strip-texts
#import "panel-draw.typ": _draw-axis-and-layers

#let _panel-row-count(panel-layers) = {
  let n = 0
  for layer in panel-layers { n += layer.data.len() }
  n
}

#let _train-panels(spec, panels, trained, coord, labs, free-x, free-y) = {
  if not (free-x or free-y) { return () }
  // Only positional aesthetics are retrained per panel; non-positionals stay
  // shared so legends do not fragment. Labs labels must be re-applied because
  // pt.x / pt.y overwrite the globally-labelled merged.x / merged.y below.
  panels.map(p => {
    let pt = train(
      scales: spec.scales,
      layers: p.layers,
      mapping: spec.mapping,
      data: spec.data,
      aesthetics: positional-aesthetics,
    )
    pt = _apply-labs(pt, labs)
    pt = _post-train(pt, p.layers)
    pt = _apply-coord-transform(pt, coord)
    pt = _apply-coord(pt, coord)
    pt = _apply-expand(pt, coord)
    pt = _apply-flip(pt, coord)
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
  labs,
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
  let train-group = group-layers => {
    let pt = train(
      scales: spec.scales,
      layers: group-layers,
      mapping: spec.mapping,
      data: spec.data,
      aesthetics: positional-aesthetics,
    )
    pt = _apply-labs(pt, labs)
    pt = _post-train(pt, group-layers)
    pt = _apply-coord-transform(pt, coord)
    pt = _apply-coord(pt, coord)
    pt = _apply-expand(pt, coord)
    pt = _apply-flip(pt, coord)
    pt
  }
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

#let _render-canvas-wrap(ctx) = {
  let spec = ctx.spec
  let theme = ctx.theme
  let coord = ctx.coord
  let trained = ctx.trained
  let panels = ctx.panels
  let panel-trained-list = ctx.panel-trained-list
  let wrap-levels = ctx.wrap-levels
  let guides = ctx.guides
  let legend-gap = ctx.legend-gap
  let sec-y-extent = ctx.sec-y-extent
  let sec-x-extent = ctx.sec-x-extent
  let margin = ctx.margin
  let width-units = ctx.width-units
  let height-units = ctx.height-units
  let free-x = ctx.free-x
  let free-y = ctx.free-y
  let style = ctx.style
  let _ax-title = style.ax-title
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
      let xs = _sec-spec(xt)
      let ys = _sec-spec(yt)
      (
        x: if free-x {
          _axis-label-extents(xt, ax-text.xb.size, typst-eval: ax-text.xb.typst)
        } else { x-extents },
        y: if free-y {
          _axis-label-extents(yt, ax-text.yl.size, typst-eval: ax-text.yl.typst)
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
  let ncol = if spec.facet.ncolumn != none {
    spec.facet.ncolumn
  } else if spec.facet.nrow != none {
    calc.ceil(n / spec.facet.nrow)
  } else {
    calc.max(1, int(calc.ceil(calc.sqrt(n))))
  }
  let nrow = calc.max(1, int(calc.ceil(n / ncol)))
  let strip-texts = _strip-texts(
    spec.facet.at("labeller", default: none),
    spec.facet.variable,
    levels,
    i => _panel-row-count(panels.at(i).layers),
  )
  let strip-h = _strip-band(strip-texts, style, 0.45)
  let gutter-x = 0.4
  let gutter-y = 0.4
  let grid-w = width-units - margin.left - margin.right
  let grid-h = height-units - margin.bottom - margin.top
  let panel-w = (grid-w - gutter-x * (ncol - 1)) / ncol
  let panel-h = (grid-h - gutter-y * (nrow - 1) - strip-h * nrow) / nrow

  // Compute shared breaks once per axis. A free axis sets its entry to
  // `none` so `_draw-axis-and-layers` falls back to per-panel computation
  // (the per-panel scale is what differs); the fixed axis still benefits
  // from the cached breaks even when the other axis is free.
  let shared-breaks = {
    let s = _shared-axis-breaks(trained)
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

  let all-x = ("all_x", "all").contains(spec.facet.axes)
  let all-y = ("all_y", "all").contains(spec.facet.axes)

  cetz.canvas(length: 1cm, {
    import cetz.draw: *
    hide(rect((0, 0), (width-units, height-units)), bounds: true)
    for (i, level) in levels.enumerate() {
      let col = calc.rem(i, ncol)
      let row = int(i / ncol)
      let x0 = margin.left + col * (panel-w + gutter-x)
      let y0 = (
        margin.bottom + (nrow - 1 - row) * (panel-h + gutter-y + strip-h)
      )
      let panel-layers = panels.at(i).layers
      let strip-text = strip-texts.at(i)
      _draw-strip(
        (x0, y0 + panel-h),
        (x0 + panel-w, y0 + panel-h + strip-h),
        strip-text,
        style,
        theme,
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

    let x-trained = trained.at("x", default: none)
    let y-trained = trained.at("y", default: none)
    let _map-name(axis) = if spec.mapping == none { none } else {
      mapping-display-name(spec.mapping.at(axis, default: none))
    }
    let x-title = _axis-title(x-trained, _map-name("x"))
    let y-title = _axis-title(y-trained, _map-name("y"))
    let _len-side = (p, s, a) => _scalar-cascade(theme, p, s, a) / 1cm
    let _tick-len = _per-side(_len-side, "tick-length")
    let _xlbl-depth = _x-label-depth(0, 1, x-extents.width, x-extents.height)
    let _ylbl-width = _y-label-width(0, 1, y-extents.width, y-extents.height)
    let _xt-gap = _text-margin-cm(_ax-title.xb, "top", _AX-TITLE-LABEL-GAP)
    let _yt-gap = _text-margin-cm(_ax-title.yl, "right", _AX-TITLE-LABEL-GAP)
    let _xt-cm = _ax-text-cm(_ax-title.xb.size)
    let _yt-cm = _ax-text-cm(_ax-title.yl.size)
    if x-title != none and _ax-title.xb.size > 0pt {
      content(
        (
          margin.left + grid-w / 2,
          margin.bottom - _tick-len.xb - 0.1 - _xlbl-depth - _xt-gap - _xt-cm,
        ),
        text(.._text-args(_ax-title.xb))[#resolve-prose(
          x-title,
          eval-strings: _ax-title.xb.typst,
        )],
        anchor: "south",
      )
    }
    if y-title != none and _ax-title.yl.size > 0pt {
      content(
        (
          margin.left - _tick-len.yl - 0.1 - _ylbl-width - _yt-gap - _yt-cm / 2,
          margin.bottom + grid-h / 2,
        ),
        text(.._text-args(_ax-title.yl))[#resolve-prose(
          y-title,
          eval-strings: _ax-title.yl.typst,
        )],
        angle: 90deg,
      )
    }

    if guides.len() > 0 {
      let lctx = (
        trained: trained,
        palette: default-discrete,
        theme: theme,
        canvas-w: width-units,
        canvas-h: height-units,
      )
      legend-mod.draw(
        guides,
        lctx,
        panel-rect: (
          x: margin.left,
          y: margin.bottom,
          w: grid-w,
          h: grid-h,
        ),
        margin: margin,
        legend-gap: legend-gap,
        sec-y-extent: sec-y-extent,
        sec-x-extent: sec-x-extent,
        right-strip: 0.0,
        theme: theme,
      )
    }
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
  let guides = ctx.guides
  let legend-gap = ctx.legend-gap
  let sec-y-extent = ctx.sec-y-extent
  let sec-x-extent = ctx.sec-x-extent
  let margin = ctx.margin
  let width-units = ctx.width-units
  let height-units = ctx.height-units
  let style = ctx.style
  let _ax-title = style.ax-title
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
  let strip-h = _strip-band(col-strip-texts, style, 0.45)
  let strip-w = _strip-band(row-strip-texts, style, 0.55)
  let gutter-x = 0.3
  let gutter-y = 0.3
  let top-strip = if col-var != none { strip-h } else { 0.0 }
  let right-strip = if row-var != none { strip-w } else { 0.0 }
  let inner-right = margin.right + right-strip
  let grid-w = width-units - margin.left - inner-right
  let grid-h = height-units - margin.bottom - margin.top - top-strip
  let panel-w = (grid-w - gutter-x * (n-cols - 1)) / n-cols
  let panel-h = (grid-h - gutter-y * (n-rows - 1)) / n-rows

  // Under free scales each column (x) / row (y) carries its own domain, so the
  // shared break set no longer applies; `none` makes `_draw-cartesian-axis`
  // recompute breaks from each panel's own trained scale.
  let shared-breaks = {
    let s = _shared-axis-breaks(trained)
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
      let strip-y = margin.bottom + grid-h
      for c in range(col-levels.len()) {
        let x0 = margin.left + c * (panel-w + gutter-x)
        _draw-strip(
          (x0, strip-y),
          (x0 + panel-w, strip-y + top-strip),
          col-strip-texts.at(c),
          style,
          theme,
        )
      }
    }

    if row-var != none {
      let strip-x = margin.left + grid-w
      for r in range(row-levels.len()) {
        let y0 = margin.bottom + (n-rows - 1 - r) * (panel-h + gutter-y)
        _draw-strip(
          (strip-x, y0),
          (strip-x + right-strip, y0 + panel-h),
          row-strip-texts.at(r),
          style,
          theme,
          angle: -90deg,
        )
      }
    }

    let x-trained = trained.at("x", default: none)
    let y-trained = trained.at("y", default: none)
    let _map-name(axis) = if spec.mapping == none { none } else {
      mapping-display-name(spec.mapping.at(axis, default: none))
    }
    let x-title = _axis-title(x-trained, _map-name("x"))
    let y-title = _axis-title(y-trained, _map-name("y"))
    let _len-side = (p, s, a) => _scalar-cascade(theme, p, s, a) / 1cm
    let _tick-len = _per-side(_len-side, "tick-length")
    let _xlbl-depth = _x-label-depth(0, 1, x-extents.width, x-extents.height)
    let _ylbl-width = _y-label-width(0, 1, y-extents.width, y-extents.height)
    let _xt-gap = _text-margin-cm(_ax-title.xb, "top", _AX-TITLE-LABEL-GAP)
    let _yt-gap = _text-margin-cm(_ax-title.yl, "right", _AX-TITLE-LABEL-GAP)
    let _xt-cm = _ax-text-cm(_ax-title.xb.size)
    let _yt-cm = _ax-text-cm(_ax-title.yl.size)
    if x-title != none and _ax-title.xb.size > 0pt {
      content(
        (
          margin.left + grid-w / 2,
          margin.bottom - _tick-len.xb - 0.1 - _xlbl-depth - _xt-gap - _xt-cm,
        ),
        text(.._text-args(_ax-title.xb))[#resolve-prose(
          x-title,
          eval-strings: _ax-title.xb.typst,
        )],
        anchor: "south",
      )
    }
    if y-title != none and _ax-title.yl.size > 0pt {
      content(
        (
          margin.left - _tick-len.yl - 0.1 - _ylbl-width - _yt-gap - _yt-cm / 2,
          margin.bottom + grid-h / 2,
        ),
        text(.._text-args(_ax-title.yl))[#resolve-prose(
          y-title,
          eval-strings: _ax-title.yl.typst,
        )],
        angle: 90deg,
      )
    }

    if guides.len() > 0 {
      let lctx = (
        trained: trained,
        palette: default-discrete,
        theme: theme,
        canvas-w: width-units,
        canvas-h: height-units,
      )
      legend-mod.draw(
        guides,
        lctx,
        panel-rect: (
          x: margin.left,
          y: margin.bottom,
          w: grid-w,
          h: grid-h,
        ),
        margin: margin,
        legend-gap: legend-gap,
        sec-y-extent: sec-y-extent,
        sec-x-extent: sec-x-extent,
        right-strip: right-strip,
        top-strip: top-strip,
        theme: theme,
      )
    }
  })
}

#let _render-canvas-single(
  spec,
  theme,
  trained,
  prepared,
  coord,
  guides,
  legend-gap,
  sec-y-extent,
  sec-x-extent,
  margin,
  width-units,
  height-units,
  x-extents,
  y-extents,
  x-sec-extents,
  y-sec-extents,
) = {
  let px-lo = margin.left
  let px-hi = width-units - margin.right
  let py-lo = margin.bottom
  let py-hi = height-units - margin.top

  let box-w = px-hi - px-lo
  let box-h = py-hi - py-lo
  let (inner-w, inner-h) = _fixed-inner-size(coord, trained, box-w, box-h)

  cetz.canvas(length: 1cm, {
    import cetz.draw: hide, rect
    hide(rect((0, 0), (width-units, height-units)), bounds: true)
    _draw-axis-and-layers(
      prepared,
      trained,
      theme,
      spec,
      (px-lo, py-lo),
      (inner-w, inner-h),
      guides: guides,
      legend-args: (
        panel-rect: (x: px-lo, y: py-lo, w: inner-w, h: inner-h),
        margin: margin,
        legend-gap: legend-gap,
        sec-y-extent: sec-y-extent,
        sec-x-extent: sec-x-extent,
        right-strip: 0.0,
      ),
      flipped: _is-flipped(coord),
      x-extents: x-extents,
      y-extents: y-extents,
      x-sec-extents: x-sec-extents,
      y-sec-extents: y-sec-extents,
      canvas-w: width-units,
      canvas-h: height-units,
    )
  })
}
