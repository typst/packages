// Render orchestrator: trains scales, prepares layers, then dispatches to the
// canvas builders in `render/`. The per-concern helpers live under `render/`;
// this file wires them together and exposes `render-plot` / `render-plot-deferred`.

#import "scale/train.typ": train
#import "utils/errors.typ": check, fail
#import "scale/oob.typ": filter-oob
#import "theme/current.typ": _theme-state
#import "theme/defaults.typ": merge-theme
#import "theme/theme.typ": _text-style
#import "render/legend.typ" as legend-mod
#import "render/common.typ": _strip-mapping-refs
#import "render/chrome.typ": _chrome-margins
#import "render/prestat.typ": _preprocess-data
#import "render/validate.typ": validate-spec
#import "render/domain.typ": (
  _apply-coord, _apply-coord-transform, _apply-expand, _apply-flip,
  _apply-labels, _post-train,
)
#import "render/extents.typ": _text-margin-cm
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
  let labels = spec.at("labels", default: none)

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
    labels,
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

  // Reject an aesthetic or facet variable that names a column absent from the
  // (stat-transformed) data, so a typo fails loudly instead of resolving to an
  // all-`none` column.
  validate-spec(spec, prepared)

  let trained = train(
    scales: spec.scales,
    layers: prepared,
    mapping: spec.mapping,
    data: spec.data,
  )
  trained = _apply-labels(trained, labels)

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
      labels,
      grid-n-rows,
      grid-n-cols,
      free-x,
      free-y,
    )
  } else {
    _train-panels(spec, panels, trained, coord, labels, free-x, free-y)
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
  // Base swatch key glyph diameter, overridable per legend by `key-size`.
  let _legend-key-cm = theme.at("legend-key", default: 0.24cm) / 1cm
  // Custom guides lack `aesthetics`; default keeps them unsuppressed.
  let guides = legend-mod
    .guides-for(
      spec,
      trained,
      size-pt: _legend-size-pt,
      key-diam-cm: _legend-key-cm,
      theme: theme,
    )
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

  let chrome = _chrome-margins((
    spec: spec,
    theme: theme,
    trained: trained,
    coord: coord,
    guides: guides,
    extents: extents,
    legend-gap: legend-gap,
    width-units: width-units,
    height-units: height-units,
    facet-grid-mode: facet-grid-mode,
    free-x: free-x,
    free-y: free-y,
    grid-n-rows: grid-n-rows,
    grid-n-cols: grid-n-cols,
    panel-trained-list: panel-trained-list,
    margin-override: margin-override,
  ))
  let margin = chrome.margin
  let ax-text = chrome.ax-text
  let x-extents = chrome.x-extents
  let y-extents = chrome.y-extents
  let x-sec-extents = chrome.x-sec-extents
  let y-sec-extents = chrome.y-sec-extents
  let sec-x-extent = chrome.sec-x-extent
  let sec-y-extent = chrome.sec-y-extent
  let x-title-extents = chrome.x-title-extents
  let y-title-extents = chrome.y-title-extents

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
      x-title-extents: x-title-extents,
      y-title-extents: y-title-extents,
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
      x-title-extents: x-title-extents,
      y-title-extents: y-title-extents,
      x-sec-extents: x-sec-extents,
      y-sec-extents: y-sec-extents,
    ))
  } else {
    _render-canvas-single((
      spec: spec,
      theme: theme,
      coord: coord,
      trained: trained,
      prepared: prepared,
      guides: guides,
      legend-gap: legend-gap,
      sec-y-extent: sec-y-extent,
      sec-x-extent: sec-x-extent,
      margin: margin,
      width-units: width-units,
      height-units: height-units,
      x-extents: x-extents,
      y-extents: y-extents,
      x-title-extents: x-title-extents,
      y-title-extents: y-title-extents,
      x-sec-extents: x-sec-extents,
      y-sec-extents: y-sec-extents,
    ))
  }

  (
    content: _render-decorate(canvas, deco-parts),
    guides: guides,
    trained: trained,
    margin: margin,
  )
}

#let render-plot(spec) = render-plot-deferred(spec).content
