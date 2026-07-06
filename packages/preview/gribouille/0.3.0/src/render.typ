// Render orchestrator: trains scales, prepares layers, then dispatches to the
// canvas builders in `render/`. The per-concern helpers live under `render/`;
// this file wires them together and exposes `render-plot` / `render-plot-deferred`.

#import "deps.typ": cetz
#import "scale/train.typ": mapping-display-name, train
#import "utils/errors.typ": check, fail
#import "scale/oob.typ": filter-oob
#import "theme/current.typ": _theme-state
#import "theme/defaults.typ": merge-theme
#import "theme/theme.typ": _rect-outset-cm, _scalar-cascade, _text-style
#import "utils/margin.typ": opposite-side, perpendicular-sides
#import "legend.typ" as legend-mod
#import "render/common.typ": _per-side, _strip-mapping-refs
#import "render/axis-format.typ": _axis-title, _sec-spec
#import "render/guides.typ": _axis-text-angle, _read-axis-guide
#import "render/prestat.typ": _preprocess-data
#import "render/domain.typ": (
  _apply-coord, _apply-coord-transform, _apply-expand, _apply-flip, _apply-labs,
  _is-flipped, _post-train,
)
#import "render/extents.typ": (
  _AX-TITLE-LABEL-GAP, _ax-text-cm, _axis-label-extents, _sec-extent,
  _secondary-label-extents, _text-margin-cm, _x-label-depth-stack,
  _y-label-width-stack,
)
#import "render/facet.typ": _measure-label-sizes, _render-prepare, _render-style
#import "render/canvas.typ": (
  _render-canvas-grid, _render-canvas-single, _render-canvas-wrap,
  _train-grid-panels, _train-panels,
)
// Re-exported so `compose.typ`'s `#import "render.typ": _decorate-*` resolves.
#import "render/decorate.typ": (
  _decorate-extents, _decorate-parts, _render-decorate,
)






#let render-plot-deferred(
  spec,
  suppress-aesthetics: (),
  margin-override: none,
) = {
  let user-theme = if spec.theme != none { spec.theme } else {
    _theme-state.get()
  }
  let theme = merge-theme(user-theme)
  let labs = spec.at("labs", default: none)

  // Canvas dims known up-front from `spec.width` / `spec.height`; cetz
  // draw sites resolve their own rect `%` insets against per-rect natural
  // dims, but layout-time `outset` reservation references the canvas.
  check(
    type(spec.width) == length and type(spec.height) == length,
    "render-plot",
    "width/height must be resolved to concrete lengths before rendering",
  )
  let width-units-early = spec.width / 1cm
  let height-units-early = spec.height / 1cm
  // `width` / `height` bound the whole image: build the title/subtitle/caption
  // chrome up front and reserve its extent so the canvas shrinks to leave room,
  // making the composed stack total back to the requested dims.
  let deco-parts = _decorate-parts(
    labs,
    theme,
    width-units-early,
    height-units-early,
  )
  let deco = _decorate-extents(deco-parts)
  let style = _render-style(theme)

  let spec = _preprocess-data(spec)

  // Faceted plots prepare layers per panel so stats (smooth, bin, count) fit
  // each panel's own row subset, following grammar-of-graphics semantics.
  let prep = _render-prepare(spec, theme)
  let facet-wrap-mode = prep.facet-wrap-mode
  let facet-grid-mode = prep.facet-grid-mode
  let wrap-levels = prep.wrap-levels
  let grid-row-levels = prep.grid-row-levels
  let grid-col-levels = prep.grid-col-levels
  let panels = prep.panels
  let prepared = prep.prepared

  let trained = train(
    scales: spec.scales,
    layers: prepared,
    mapping: spec.mapping,
    data: spec.data,
  )
  trained = _apply-labs(trained, labs)

  // Once training is done, mapping-ref annotations have served their purpose;
  // flatten them so geoms receive plain column names.
  prepared = prepared.map(l => {
    let new = l
    new.mapping = _strip-mapping-refs(l.mapping)
    new
  })
  panels = panels.map(p => {
    let new = p
    new.layers = p.layers.map(l => {
      let ll = l
      ll.mapping = _strip-mapping-refs(l.mapping)
      ll
    })
    new
  })

  // Faceted plots render the per-panel copies under `panels`; single plots
  // render `prepared` directly. Only the path that the canvas dispatch will
  // touch needs label sizes.
  if facet-wrap-mode or facet-grid-mode {
    panels = panels.map(p => {
      let new = p
      new.layers = p.layers.map(_measure-label-sizes)
      new
    })
  } else {
    prepared = prepared.map(_measure-label-sizes)
  }

  trained = _post-train(trained, prepared)

  // coord-cartesian zooms the view: override trained domains with the user's
  // clip limits so axis ticks and marks follow them. Data outside the limits
  // is preserved for stats and training but may render outside the panel.
  let coord = spec.at("coord", default: none)
  trained = _apply-coord-transform(trained, coord)
  trained = _apply-coord(trained, coord)
  trained = _apply-expand(trained, coord)
  // coord-flip swaps trained x and y so axis labels swap automatically;
  // direction-sensitive geoms branch on `ctx.flipped` inside their draw.
  trained = _apply-flip(trained, coord)

  // Drop (or clamp under `oob: "squish"`) rows whose value falls outside any
  // user-supplied scale `limits`. Runs after training so the trained domain
  // is the rendered cutoff; before per-panel re-train so panel scales see
  // the filtered subset.
  let strict = spec.at("strict", default: false)
  let oob-pass = filter-oob(prepared, trained, strict: strict)
  prepared = oob-pass.layers
  if facet-wrap-mode or facet-grid-mode {
    panels = panels.map(p => {
      let pass = filter-oob(p.layers, trained, strict: strict)
      let new = p
      new.layers = pass.layers
      new
    })
  }

  // For non-fixed facet scales, train each panel's positional axes on its own
  // subset so x and/or y differ across panels. Non-positional scales (colour,
  // fill, size, shape, linetype) stay shared so legends do not fragment.
  // facet-wrap frees each panel independently; facet-grid frees x per column
  // and y per row (see `_train-grid-panels`).
  let facet-scales = if facet-wrap-mode or facet-grid-mode {
    spec.facet.scales
  } else { "fixed" }
  let free-x = facet-scales == "free" or facet-scales == "free_x"
  let free-y = facet-scales == "free" or facet-scales == "free_y"
  let grid-n-rows = calc.max(1, grid-row-levels.len())
  let grid-n-cols = calc.max(1, grid-col-levels.len())
  let panel-trained-list = if facet-grid-mode {
    _train-grid-panels(
      spec,
      panels,
      trained,
      coord,
      labs,
      grid-n-rows,
      grid-n-cols,
      free-x,
      free-y,
    )
  } else {
    _train-panels(spec, panels, trained, coord, labs, free-x, free-y)
  }

  let width-units = width-units-early - deco.left - deco.right
  let height-units = height-units-early - deco.top - deco.bottom
  // Floor matches the single-tick panel minimum used by `max-right-margin`.
  let _min-canvas = 0.5
  if width-units < _min-canvas or height-units < _min-canvas {
    fail(
      "plot",
      "title/subtitle/caption and plot-background padding leave a "
        + str(calc.round(width-units, digits: 2))
        + " x "
        + str(calc.round(height-units, digits: 2))
        + " cm canvas, below the "
        + str(_min-canvas)
        + " cm minimum",
      hint: "Increase width/height or reduce labels/padding.",
    )
  }

  // Legend-text font size drives every label-width / line-height
  // measurement done inside `guides-for`.
  let _legend-size-pt = _text-style(theme, "legend-text").size / 1pt
  // Custom guides lack `aesthetics`; default keeps them unsuppressed.
  let guides = legend-mod
    .guides-for(spec, trained, size-pt: _legend-size-pt)
    .filter(g => {
      let aes = g.at("aesthetics", default: ())
      not aes.any(a => suppress-aesthetics.contains(a))
    })
  let extents = legend-mod.estimate-extents(guides)
  let any-legend = (
    extents.top > 0
      or extents.right > 0
      or extents.bottom > 0
      or extents.left > 0
      or extents.inside.len() > 0
  )
  let legend-title-style = _text-style(theme, "legend-title")
  let legend-gap = if any-legend {
    _text-margin-cm(legend-title-style, "left", 1.6em)
  } else { 0.0 }

  let x-trained-top = trained.at("x", default: none)
  let y-trained-top = trained.at("y", default: none)
  let x-sec = _sec-spec(x-trained-top)
  let y-sec = _sec-spec(y-trained-top)
  let _surface-style = (p, s, _) => _text-style(theme, p + "-" + s)
  let _len-side = (p, s, a) => _scalar-cascade(theme, p, s, a) / 1cm
  let tick-len = _per-side(_len-side, "tick-length")
  let ax-text = _per-side(_surface-style, "axis-text")
  let ax-title = _per-side(_surface-style, "axis-title")

  let x-extents = _axis-label-extents(
    x-trained-top,
    ax-text.xb.size,
    typst-eval: ax-text.xb.typst,
  )
  let y-extents = _axis-label-extents(
    y-trained-top,
    ax-text.yl.size,
    typst-eval: ax-text.yl.typst,
  )
  // Under facet-grid free scales the bottom row shows a different x per column
  // and the left column a different y per row, so the single bottom/left margin
  // must reserve the widest group's labels. Take the per-group maxima from the
  // panels that actually draw the edge axes (bottom row for x, left column for
  // y) using the same trained entries the draw will use.
  let x-extents = if (
    facet-grid-mode and free-x and panel-trained-list.len() > 0
  ) {
    let exts = range(grid-n-cols).map(c => _axis-label-extents(
      panel-trained-list
        .at((grid-n-rows - 1) * grid-n-cols + c)
        .at(
          "x",
          default: none,
        ),
      ax-text.xb.size,
      typst-eval: ax-text.xb.typst,
    ))
    (
      width: exts.fold(x-extents.width, (m, e) => calc.max(m, e.width)),
      height: exts.fold(x-extents.height, (m, e) => calc.max(m, e.height)),
    )
  } else { x-extents }
  let y-extents = if (
    facet-grid-mode and free-y and panel-trained-list.len() > 0
  ) {
    let exts = range(grid-n-rows).map(r => _axis-label-extents(
      panel-trained-list.at(r * grid-n-cols).at("y", default: none),
      ax-text.yl.size,
      typst-eval: ax-text.yl.typst,
    ))
    (
      width: exts.fold(y-extents.width, (m, e) => calc.max(m, e.width)),
      height: exts.fold(y-extents.height, (m, e) => calc.max(m, e.height)),
    )
  } else { y-extents }
  let x-sec-extents = _secondary-label-extents(
    x-trained-top,
    x-sec,
    ax-text.xt.size,
    typst-eval: ax-text.xt.typst,
  )
  let y-sec-extents = _secondary-label-extents(
    y-trained-top,
    y-sec,
    ax-text.yr.size,
    typst-eval: ax-text.yr.typst,
  )

  let sec-x-extent = _sec-extent(
    x-sec,
    tick-len.xt,
    x-sec-extents,
    ax-title.xt,
    "x",
  )
  let sec-y-extent = _sec-extent(
    y-sec,
    tick-len.yr,
    y-sec-extents,
    ax-title.yr,
    "y",
  )

  let x-guide = _read-axis-guide(
    spec,
    "x",
    default-angle: _axis-text-angle(theme, "x"),
  )
  let y-guide = _read-axis-guide(
    spec,
    "y",
    default-angle: _axis-text-angle(theme, "y"),
  )
  // Themes that disable tick labels (`theme-void`) reserve no perpendicular
  // depth for them; otherwise the chrome margin reserves space for ink that
  // never draws, inverting the panel rect on small plot sizes.
  let labels-on = theme.at("tick-labels", default: true)
  let x-label-depth = if labels-on and not x-guide.suppress {
    _x-label-depth-stack(x-guide, x-extents.width, x-extents.height)
  } else { 0.0 }
  let y-label-width = if labels-on and not y-guide.suppress {
    _y-label-width-stack(y-guide, y-extents.width, y-extents.height)
  } else { 0.0 }
  // A suppressed (`labs(x: none)`) or nameless axis title reserves no extent;
  // mirror the draw-side gate so the panel reclaims the freed depth.
  let _flipped = _is-flipped(coord)
  let _x-title-name = if spec.mapping == none { none } else {
    mapping-display-name(
      spec.mapping.at(if _flipped { "y" } else { "x" }, default: none),
    )
  }
  let _y-title-name = if spec.mapping == none { none } else {
    mapping-display-name(
      spec.mapping.at(if _flipped { "x" } else { "y" }, default: none),
    )
  }
  let x-title = _axis-title(trained.at("x", default: none), _x-title-name)
  let y-title = _axis-title(trained.at("y", default: none), _y-title-name)
  // Only reserve the title-to-label gap when a title actually renders;
  // a `0pt` axis title (e.g., `theme-void`) needs no gap, and the absolute
  // `_AX-TITLE-LABEL-GAP` would otherwise tip `bottom-extent` over the floor
  // threshold and invert the panel rect on short plots.
  let bottom-gap = if x-title != none and ax-title.xb.size > 0pt {
    _text-margin-cm(ax-title.xb, "top", _AX-TITLE-LABEL-GAP)
  } else { 0.0 }
  let left-gap = if y-title != none and ax-title.yl.size > 0pt {
    _text-margin-cm(ax-title.yl, "right", _AX-TITLE-LABEL-GAP)
  } else { 0.0 }
  let x-title-cm = if x-title != none { _ax-text-cm(ax-title.xb.size) } else {
    0.0
  }
  let y-title-cm = if y-title != none { _ax-text-cm(ax-title.yl.size) } else {
    0.0
  }
  // A suppressed axis (`guides(x: none)`) draws no ticks or labels, so it
  // reserves no tick depth either; the axis line and title still render.
  let x-tick-cm = if x-guide.suppress { 0.0 } else { tick-len.xb }
  let y-tick-cm = if y-guide.suppress { 0.0 } else { tick-len.yl }
  let bottom-extent = (
    x-tick-cm + 0.1 + x-label-depth + bottom-gap + x-title-cm + 0.05
  )
  let left-extent = (
    y-tick-cm + 0.1 + y-label-width + left-gap + y-title-cm
  )

  // Cap the right margin so the legend can never push panel width below the
  // single-tick minimum. Without the cap, `px-hi - px-lo` goes negative and
  // axis labels render reversed (panel becomes mirror-imaged into the legend).
  let max-right-margin = calc.max(0.0, width-units - left-extent - 0.5)
  let _side-gap = side => (
    extents.at(side) + (if extents.at(side) > 0 { legend-gap } else { 0.0 })
  )
  // Themed `outset` on rect surfaces reserves outer whitespace by widening
  // the chrome slot on each side; the panel canvas absorbs the diff.
  // `strip-background` is the facet decoration band itself, so its `inset`
  // and `outset` are ignored (no chrome reservation, no rect growth).
  // For every legend on side S, all four `outset` sides feed chrome
  // reservation: slot-axis sides (S and its opposite) inflate `margin.S`
  // -- the opposite side (panel-facing) is also mirrored into
  // `legend-gap` so the visible gap between panel and legend grows;
  // perpendicular sides inflate the matching `margin.{perpendicular}`.
  let any-bar = guides.any(g => g.kind == "colourbar")
  let panel-out = _rect-outset-cm(
    theme,
    "panel-background",
    ref-w: width-units,
    ref-h: height-units,
  )
  let legend-out = _rect-outset-cm(
    theme,
    "legend-background",
    ref-w: width-units,
    ref-h: height-units,
  )
  let bar-out = if any-bar {
    _rect-outset-cm(
      theme,
      "legend-bar",
      ref-w: width-units,
      ref-h: height-units,
    )
  } else { (top: 0.0, right: 0.0, bottom: 0.0, left: 0.0) }
  // For every active legend on side `leg-side`, the slot-axis outset
  // sides (leg-side + its opposite) sum into `margin.{leg-side}`; the
  // perpendicular sides feed `margin.{perpendicular}`. Fold once into a
  // four-side dict so `_surface-out` is a flat read.
  let _by-margin-side(out) = {
    let acc = (top: 0.0, right: 0.0, bottom: 0.0, left: 0.0)
    for leg-side in ("top", "right", "bottom", "left") {
      if extents.at(leg-side) <= 0 { continue }
      acc.insert(
        leg-side,
        acc.at(leg-side)
          + out.at(leg-side)
          + out.at(opposite-side.at(leg-side)),
      )
      for perp in perpendicular-sides.at(leg-side) {
        acc.insert(perp, acc.at(perp) + out.at(perp))
      }
    }
    acc
  }
  let legend-by-side = _by-margin-side(legend-out)
  let bar-by-side = _by-margin-side(bar-out)
  let _surface-out(side) = (
    panel-out.at(side) + legend-by-side.at(side) + bar-by-side.at(side)
  )
  let margin = (
    left: left-extent + _side-gap("left") + _surface-out("left"),
    bottom: bottom-extent + _side-gap("bottom") + _surface-out("bottom"),
    top: sec-x-extent + _side-gap("top") + _surface-out("top"),
    right: calc.min(
      sec-y-extent + _side-gap("right") + _surface-out("right"),
      max-right-margin,
    ),
  )
  // `compose(align-panels: true)` forces a shared margin so panels' plot areas
  // line up; overlay the supplied sides, then clamp every side against this
  // panel's own extent so a forced margin can never invert the plot rect. Each
  // bound keeps at least 0.5cm of plot opposite it, matching `max-right-margin`.
  if margin-override != none {
    margin = margin + margin-override
    margin.right = calc.min(margin.right, max-right-margin)
    margin.left = calc.min(margin.left, calc.max(
      0.0,
      width-units - margin.right - 0.5,
    ))
    margin.top = calc.min(margin.top, calc.max(
      0.0,
      height-units - margin.bottom - 0.5,
    ))
    margin.bottom = calc.min(margin.bottom, calc.max(
      0.0,
      height-units - margin.top - 0.5,
    ))
  }

  // A left/right legend is centred over the panel and extends symmetrically. It
  // may spill past the panel into a bare margin harmlessly, but when it reaches
  // below the panel band into a rendered caption it overprints that text (the
  // reported "legend pushes the caption off" failure). Detect that overrun and
  // fail loudly with layout hints. A bare plot-background pad is not a caption,
  // so gate on the caption block actually existing.
  let _legend-ctx = (canvas-w: width-units, canvas-h: height-units)
  // Mirrors `_draw-side`'s `py + ph / 2` centring. Restricted to the single-plot
  // layout: facet modes centre over the panel grid plus strips, a geometry this
  // simple prediction would misjudge.
  let _panel-h = height-units - margin.top - margin.bottom
  let _panel-centre = margin.bottom + _panel-h / 2
  let _eps = 0.01
  if (
    not facet-wrap-mode
      and not facet-grid-mode
      and deco-parts.caption-block != none
  ) {
    for _legend-side in ("left", "right") {
      let side-guides = guides.filter(g => g.placement.side == _legend-side)
      if side-guides.len() == 0 { continue }
      let stacked = legend-mod.side-stacked-height(
        _legend-side,
        side-guides,
        _legend-ctx,
        theme,
        legend-gap,
      )
      if _panel-centre - stacked / 2 < -_eps {
        fail(
          "plot",
          "the "
            + _legend-side
            + " legend needs "
            + str(calc.round(stacked, digits: 2))
            + " cm and overruns the caption (the panel leaves only "
            + str(calc.round(2 * _panel-centre, digits: 2))
            + " cm above it)",
          hint: "Increase `height`, move the legend to `top`/`bottom`, or shrink "
            + "its footprint with `guide-legend(nrow:/ncolumn:)`.",
        )
      }
    }
  }

  let canvas = if facet-wrap-mode {
    _render-canvas-wrap((
      spec: spec,
      theme: theme,
      coord: coord,
      trained: trained,
      panels: panels,
      panel-trained-list: panel-trained-list,
      wrap-levels: wrap-levels,
      guides: guides,
      legend-gap: legend-gap,
      sec-y-extent: sec-y-extent,
      sec-x-extent: sec-x-extent,
      margin: margin,
      width-units: width-units,
      height-units: height-units,
      free-x: free-x,
      free-y: free-y,
      style: style,
      x-extents: x-extents,
      y-extents: y-extents,
      x-sec-extents: x-sec-extents,
      y-sec-extents: y-sec-extents,
      ax-text: ax-text,
    ))
  } else if facet-grid-mode {
    _render-canvas-grid((
      spec: spec,
      theme: theme,
      coord: coord,
      trained: trained,
      panels: panels,
      grid-row-levels: grid-row-levels,
      grid-col-levels: grid-col-levels,
      panel-trained-list: panel-trained-list,
      free-x: free-x,
      free-y: free-y,
      guides: guides,
      legend-gap: legend-gap,
      sec-y-extent: sec-y-extent,
      sec-x-extent: sec-x-extent,
      margin: margin,
      width-units: width-units,
      height-units: height-units,
      style: style,
      x-extents: x-extents,
      y-extents: y-extents,
      x-sec-extents: x-sec-extents,
      y-sec-extents: y-sec-extents,
    ))
  } else {
    _render-canvas-single(
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
    )
  }

  (
    content: _render-decorate(canvas, deco-parts),
    guides: guides,
    trained: trained,
    margin: margin,
  )
}

#let render-plot(spec) = render-plot-deferred(spec).content
