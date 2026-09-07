// Chrome-margin stage: measures axis labels, titles, and secondary axes,
// folds in legend extents and themed surface outsets, and assembles the
// four-side panel margin consumed by the canvas builders. Pulled out of
// `render-plot-deferred` so the orchestrator reads as a pipeline.

#import "../scale/train.typ": mapping-display-name
#import "../theme/theme.typ": _rect-outset-cm, _scalar-cascade, _text-style
#import "../utils/margin.typ": opposite-side, perpendicular-sides
#import "common.typ": _per-side
#import "axis-format.typ": _axis-title, _sec-spec
#import "guides.typ": _axis-text-angle, _read-axis-guide
#import "domain.typ": _is-flipped
#import "extents.typ": (
  _AX-TITLE-LABEL-GAP, _axis-label-extents, _axis-title-extents, _sec-extent,
  _secondary-label-extents, _text-margin-cm, _title-extent-cm,
  _x-label-depth-stack, _y-label-width-stack,
)

// Compute the chrome margin and every measured extent the canvas builders
// need. `ctx` carries: `spec`, `theme`, `trained`, `coord`, `guides`,
// `extents` (legend side extents), `legend-gap`, `width-units`,
// `height-units`, `facet-grid-mode`, `free-x`, `free-y`, `grid-n-rows`,
// `grid-n-cols`, `panel-trained-list`, `margin-override`.
#let _chrome-margins(ctx) = {
  let spec = ctx.spec
  let theme = ctx.theme
  let trained = ctx.trained
  let coord = ctx.coord
  let guides = ctx.guides
  let extents = ctx.extents
  let legend-gap = ctx.legend-gap
  let width-units = ctx.width-units
  let height-units = ctx.height-units
  let panel-trained-list = ctx.panel-trained-list

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
    ctx.facet-grid-mode and ctx.free-x and panel-trained-list.len() > 0
  ) {
    let exts = range(ctx.grid-n-cols).map(c => _axis-label-extents(
      panel-trained-list
        .at((ctx.grid-n-rows - 1) * ctx.grid-n-cols + c)
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
    ctx.facet-grid-mode and ctx.free-y and panel-trained-list.len() > 0
  ) {
    let exts = range(ctx.grid-n-rows).map(r => _axis-label-extents(
      panel-trained-list.at(r * ctx.grid-n-cols).at("y", default: none),
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
  // A suppressed (`labels(x: none)`) or nameless axis title reserves no extent;
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
  // Measure the title ink so its rotated bounding box reserves the right
  // perpendicular extent at any angle, mirroring the tick-label measurement.
  let x-title-extents = _axis-title-extents(
    x-title,
    ax-title.xb.size,
    typst-eval: ax-title.xb.typst,
  )
  let y-title-extents = _axis-title-extents(
    y-title,
    ax-title.yl.size,
    typst-eval: ax-title.yl.typst,
  )
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
  let x-title-cm = if x-title != none {
    _title-extent-cm(ax-title.xb, x-title-extents, "x")
  } else { 0.0 }
  let y-title-cm = if y-title != none {
    _title-extent-cm(ax-title.yl, y-title-extents, "y")
  } else { 0.0 }
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
  if ctx.margin-override != none {
    margin = margin + ctx.margin-override
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

  (
    margin: margin,
    ax-text: ax-text,
    x-extents: x-extents,
    y-extents: y-extents,
    x-sec-extents: x-sec-extents,
    y-sec-extents: y-sec-extents,
    sec-x-extent: sec-x-extent,
    sec-y-extent: sec-y-extent,
    x-title-extents: x-title-extents,
    y-title-extents: y-title-extents,
  )
}
