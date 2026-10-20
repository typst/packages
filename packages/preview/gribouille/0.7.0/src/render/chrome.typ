// Chrome-margin stage: measures axis labels, titles, and secondary axes,
// folds in legend extents and themed surface outsets, and assembles the
// four-side panel margin consumed by the canvas builders. Pulled out of
// `render-plot-deferred` so the orchestrator reads as a pipeline.

#import "../scale/train.typ": mapping-display-name
#import "../theme/theme.typ": _rect-outset-cm
#import "../utils/margin.typ": opposite-side, perpendicular-sides
#import "../utils/radial.typ": is-radial
#import "common.typ": _text-sides, _tick-cm-sides
#import "axis-format.typ": _axis-tick-values, _axis-title, _sec-spec
#import "axis-parts.typ": axis-band-cm, axis-entries
#import "guides.typ": _axis-text-angle, _read-axis-guide
#import "legend.typ": paints-bar, side-block-cm
#import "facet.typ": _facet-gutter, _fit-gutter
#import "domain.typ": _fixed-inner-size, _is-flipped
#import "../utils/errors.typ": cm-text, fail
#import "extents.typ": (
  _AX-TITLE-LABEL-GAP, _LAYOUT-TOLERANCE, _TICK-LABEL-GAP, _axis-guide-rows,
  _axis-label-extents, _axis-title-extents, _fit-title-extents, _label-overhang,
  _label-reach, _merge-extents, _sec-extent, _secondary-label-extents,
  _text-margin-cm, _title-angle, _title-extent-cm, _title-overrun-cm,
  _title-pad-cm, _title-span-cm, _x-label-anchor,
)

// What actually makes a guide of each kind smaller. A key grid takes rows and
// columns; a colour bar is one bar and ignores them, and a custom block is the
// content it was handed, so each is told what it can do rather than what a
// swatch can.
#let _SHRINK-ADVICE = (
  swatch: "shrink its footprint with `guide-legend(nrow:/ncolumn:)`",
  "size-ladder": "shrink its footprint with `guide-legend(nrow:/ncolumn:)`",
  colourbar: "turn it with `guide-legend(direction:)`",
  custom: "shrink the block with `guide-custom(width:/height:)`",
)

// The advice for the guides one side carries. A side with several kinds on it
// gets each of them once, because any one of them shrinking may be enough.
#let _shrink-hint(side-guides) = {
  let advice = ()
  for g in side-guides {
    let one = _SHRINK-ADVICE.at(g.at("kind", default: ""), default: none)
    if one != none and not advice.contains(one) { advice.push(one) }
  }
  if advice.len() == 0 { return "shrink the legend." }
  advice.join(", or ") + "."
}

// Passes allowed when settling axis-title wrapping against the panel size.
// Real plots settle in two or three; the cap only bounds a degenerate one.
#let _TITLE-FIT-PASSES = 8

// Compute the chrome margin and every measured extent the canvas builders
// need. `ctx` carries: `spec`, `theme`, `trained`, `coord`, `guides`,
// `extents` (legend side extents), `legend-gap`, `width-units`,
// `height-units`, `facet-grid-mode`, `faceted` (either facet mode: the legend
// is centred on the whole panel grid there), `free-x`, `free-y`,
// `panel-trained-list`, `margin-override`.
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
  // `_sec-spec` answers `none` for a radial coord, so a radial panel reserves
  // no tick, label, gap, or title depth for an axis it never draws; every
  // extent, margin, and title side below falls away with the spec.
  let _radial = is-radial(coord)
  let x-sec = _sec-spec(x-trained-top, coord: coord)
  let y-sec = _sec-spec(y-trained-top, coord: coord)
  let tick-len = _tick-cm-sides(theme)
  let ax-text = _text-sides(theme, "axis-text")
  let ax-title = _text-sides(theme, "axis-title")

  let x-extents = _axis-label-extents(
    x-trained-top,
    ax-text.xb.size,
    "x",
    coord,
    typst-eval: ax-text.xb.typst,
  )
  let y-extents = _axis-label-extents(
    y-trained-top,
    ax-text.yl.size,
    "y",
    coord,
    typst-eval: ax-text.yl.typst,
  )
  // Under facet-grid free scales the bottom row shows a different x per column
  // and the left column a different y per row, so the single bottom/left margin
  // must reserve the widest group's labels. Take the per-group maxima from the
  // panels that actually draw the edge axes (bottom row for x, left column for
  // y) using the same trained entries the draw will use.
  let _edge-extents = (base, axis, style, tracks, panel-at) => {
    let exts = range(tracks).map(i => _axis-label-extents(
      panel-trained-list.at(panel-at(i)).at(axis, default: none),
      style.size,
      axis,
      coord,
      typst-eval: style.typst,
    ))
    _merge-extents(base, exts)
  }
  let _free-edge = ctx.facet-grid-mode and panel-trained-list.len() > 0
  let x-extents = if _free-edge and ctx.free-x {
    _edge-extents(
      x-extents,
      "x",
      ax-text.xb,
      ctx.panel-n-cols,
      c => (ctx.panel-n-rows - 1) * ctx.panel-n-cols + c,
    )
  } else { x-extents }
  let y-extents = if _free-edge and ctx.free-y {
    _edge-extents(
      y-extents,
      "y",
      ax-text.yl,
      ctx.panel-n-rows,
      r => r * ctx.panel-n-cols,
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
  // A side whose `axis-text` is blank (`theme-void`, or a per-side
  // `element-blank()`) draws no labels, so it reserves no perpendicular depth
  // for them; otherwise the chrome margin reserves space for ink that never
  // draws, inverting the panel rect on small plot sizes.
  // A radial panel draws neither band under its edges: the angular labels ring
  // the circle inside the panel (`radial-ctx` insets `r-max` to make room) and
  // the radial ones sit along a spoke, also inside. Reserving a cartesian
  // label band there would take the room those labels need out of the panel
  // they are drawn in, so both drop to zero, exactly as the cartesian tick and
  // axis draw does under radial.
  let x-drawn = not _radial and ax-text.xb.size > 0pt and not x-guide.suppress
  let y-drawn = not _radial and ax-text.yl.size > 0pt and not y-guide.suppress
  // The table the band is measured over: the breaks the panels tick, stamped
  // with the widest label measured above. The labels themselves stay out of it,
  // because a reservation asks how deep the band is rather than what it reads,
  // and the depth comes from the stamped extents.
  let _band-entries = (axis, trained, guide, drawn, ext) => {
    if _radial or trained == none { return () }
    axis-entries(
      trained,
      guide,
      _axis-tick-values(trained),
      extent: if drawn { (ext.width, ext.height) } else { (0.0, 0.0) },
    )
  }
  let x-band-entries = _band-entries(
    "x",
    x-trained-top,
    x-guide,
    x-drawn,
    x-extents,
  )
  let y-band-entries = _band-entries(
    "y",
    y-trained-top,
    y-guide,
    y-drawn,
    y-extents,
  )
  // A tick label is centred on its break, so the break nearest a panel edge
  // reaches past it, and nothing used to reserve that reach: the label band is
  // perpendicular to its own axis. The per-break records sit behind the same
  // gate the band does, so a stripped or radial axis has none at all and
  // reserves nothing rather than nearly nothing.
  let x-recs = if x-drawn { x-extents.at("breaks", default: ()) } else { () }
  let y-recs = if y-drawn { y-extents.at("breaks", default: ()) } else { () }
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
  let x-sec-title = if x-sec == none { none } else {
    x-sec.at("name", default: none)
  }
  let y-sec-title = if y-sec == none { none } else {
    y-sec.at("name", default: none)
  }
  // The four titles take identical treatment and differ only in their text
  // style, which panel dimension bounds them, and how a failure names them.
  // Keyed as `ax-title` is so the fitted extents travel back out by side.
  let title-sides = (
    (key: "xb", title: x-title, style: ax-title.xb, axis: "x", name: "x-axis"),
    (key: "yl", title: y-title, style: ax-title.yl, axis: "y", name: "y-axis"),
    (
      key: "xt",
      title: x-sec-title,
      style: ax-title.xt,
      axis: "x",
      name: "secondary x-axis",
    ),
    (
      key: "yr",
      title: y-sec-title,
      style: ax-title.yr,
      axis: "y",
      name: "secondary y-axis",
    ),
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
  // The whole band between the panel edge and its axis title: the ticks and
  // their labels, plus the gap that holds them off the edge. It is what the two
  // extents below reserve and what the draw sites offset the title by, and it
  // travels as one figure because no reader of it wants a part.
  //
  // The band is the stack the panel draws, measured here rather than summed
  // again: a suppressed axis brings no entries and reserves nothing, a blanked
  // `axis-text` stamps no extents and reserves the ticks alone, and the gap is
  // owed whenever either of them takes room.
  //
  // Radial is the case that band cannot answer. It reserves none, because its
  // theta labels ring the inside of the panel edge rather than sitting outside
  // it, but that ink is up against the edge and owes it the gap all the same.
  let x-edge-band = if _radial { _TICK-LABEL-GAP } else {
    axis-band-cm(theme, "x", x-guide, x-band-entries)
  }
  let y-edge-band = if _radial { _TICK-LABEL-GAP } else {
    axis-band-cm(theme, "y", y-guide, y-band-entries)
  }
  let _side-gap = side => (
    extents.at(side) + (if extents.at(side) > 0 { legend-gap } else { 0.0 })
  )
  // Themed `outset` on rect surfaces reserves outer whitespace by widening
  // the chrome slot on each side; the panel canvas absorbs the diff.
  // `strip-background` is the facet decoration band itself, so its `inset`
  // and `outset` are ignored (no chrome reservation, no rect growth).
  // For every legend on side S, all four sides of the `legend-background`
  // edge -- the `inset` it paints outside the guide bbox plus the `outset`
  // it reserves -- feed chrome reservation: slot-axis sides (S and its
  // opposite) inflate `margin.S`, the opposite side (panel-facing) is also
  // mirrored into `legend-gap` so the visible gap between panel and legend
  // grows; perpendicular sides inflate the matching `margin.{perpendicular}`.
  // `panel-background` and `legend-bar` ignore `inset`, so they reserve
  // their `outset` alone.
  let any-bar = guides.any(paints-bar)
  let panel-out = _rect-outset-cm(
    theme,
    "panel-background",
    ref-w: width-units,
    ref-h: height-units,
  )
  // The block each side's legend puts on the canvas: the guide stack it draws
  // and the `legend-background` edge around it. It is measured once here and
  // read twice, by the reservation below and by the centring check at the end,
  // so the room kept for a legend and the room it is reported to need are the
  // same figure rather than two that have to agree.
  // Both fit checks below blame a side, so both name what the guides on that
  // side can do about it.
  let _shrink-advice = side => _shrink-hint(
    guides.filter(g => g.placement.side == side),
  )
  let _no-edge = (top: 0.0, right: 0.0, bottom: 0.0, left: 0.0)
  let legend-blocks = (:)
  let legend-edges = (:)
  for side in ("top", "right", "bottom", "left") {
    let side-guides = guides.filter(g => g.placement.side == side)
    let block = if side-guides.len() == 0 { none } else {
      side-block-cm(
        side,
        side-guides,
        (canvas-w: width-units, canvas-h: height-units),
        theme,
        legend-gap,
      )
    }
    legend-blocks.insert(side, block)
    legend-edges.insert(side, if block == none { _no-edge } else { block.edge })
  }
  let bar-out = if any-bar {
    _rect-outset-cm(
      theme,
      "legend-bar",
      ref-w: width-units,
      ref-h: height-units,
    )
  } else { (top: 0.0, right: 0.0, bottom: 0.0, left: 0.0) }
  // For every active legend on side `leg-side`, the slot-axis sides
  // (leg-side + its opposite) sum into `margin.{leg-side}`; the
  // perpendicular sides feed `margin.{perpendicular}`. Fold once into a
  // four-side dict so `_surface-out` is a flat read. `claimed` reads the
  // four-side dict a legend on `leg-side` claims: per side for the
  // background (a `%` inset resolves against that side's own bbox), one
  // shared dict for the colour bar.
  let _by-margin-side(claimed) = {
    let acc = (top: 0.0, right: 0.0, bottom: 0.0, left: 0.0)
    for leg-side in ("top", "right", "bottom", "left") {
      if extents.at(leg-side) <= 0 { continue }
      let out = claimed(leg-side)
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
  let legend-by-side = _by-margin-side(leg-side => legend-edges.at(leg-side))
  let bar-by-side = _by-margin-side(_ => bar-out)
  let _surface-out(side) = (
    panel-out.at(side) + legend-by-side.at(side) + bar-by-side.at(side)
  )
  // What a side's legend claims of the canvas: the guide stack, the gap holding
  // it off the panel, and the background painted and reserved around it. None
  // of it moves as the titles wrap, so it is resolved once and read by the fit
  // check below, which needs the legend's share of the margin on its own.
  let legend-slot = (:)
  for side in ("top", "right", "bottom", "left") {
    legend-slot.insert(
      side,
      _side-gap(side) + legend-by-side.at(side) + bar-by-side.at(side),
    )
  }

  // The reach of each band's labels, read from the anchors the draw pins them
  // at: an x label hangs below its break from `north` or, once rotated, from
  // the corner cetz turns with the box; a y label hangs left of its break from
  // `mid-east`; the secondaries mirror both. A stack draws the same label once
  // per row, so the reach is the largest any row asks for.
  let _rows-reach = (guide, anchor-of, rec) => {
    _axis-guide-rows(guide).fold(
      (right: 0.0, left: 0.0, up: 0.0, down: 0.0),
      (acc, sub) => {
        let r = _label-reach(rec.width, rec.height, sub.angle, anchor-of(sub))
        (
          right: calc.max(acc.right, r.right),
          left: calc.max(acc.left, r.left),
          up: calc.max(acc.up, r.up),
          down: calc.max(acc.down, r.down),
        )
      },
    )
  }
  let x-sec-recs = if not _radial and x-sec != none and ax-text.xt.size > 0pt {
    x-sec-extents.at("breaks", default: ())
  } else { () }
  let y-sec-recs = if not _radial and y-sec != none and ax-text.yr.size > 0pt {
    y-sec-extents.at("breaks", default: ())
  } else { () }
  // The four bands take identical treatment and differ only in which records
  // they carry, which panel dimension they run along, and how far one of their
  // labels reaches from the break it is centred on. `axis` names the direction
  // the band runs, which is what maps `_label-reach`'s four sides onto the two
  // ends of the span and onto the two canvas sides the reach is floored on.
  let reach-bands = (
    (
      axis: "x",
      recs: x-recs,
      reach: rec => _rows-reach(
        x-guide,
        sub => _x-label-anchor(sub.angle),
        rec,
      ),
    ),
    (
      axis: "x",
      recs: x-sec-recs,
      reach: rec => _label-reach(rec.width, rec.height, 0, "south"),
    ),
    (
      axis: "y",
      recs: y-recs,
      reach: rec => _rows-reach(y-guide, _ => "mid-east", rec),
    ),
    (
      axis: "y",
      recs: y-sec-recs,
      reach: rec => _label-reach(rec.width, rec.height, 0, "mid-west"),
    ),
  )
  // The cm the data area is already inset by inside the panel: expansion that
  // was asked for in canvas units rather than as a fraction of the domain.
  let _read-pad = t => if t == none { (0.0, 0.0) } else {
    t.at("view-pad-cm", default: (0.0, 0.0))
  }
  let x-pad = _read-pad(x-trained-top)
  let y-pad = _read-pad(y-trained-top)
  // How far a label reaches past each end of the panel it labels, per canvas
  // side. Zero on any plot with room, because the expansion gap already holds
  // the outermost break far enough inside; the margin below takes it as a
  // floor, so a zero leaves every existing layout untouched.
  let _overhang(panel-w, panel-h, slack-x, slack-y) = {
    let out = (left: 0.0, right: 0.0, bottom: 0.0, top: 0.0)
    for band in reach-bands {
      let along-x = band.axis == "x"
      let (lo-side, hi-side) = if along-x { ("left", "right") } else {
        ("bottom", "top")
      }
      let over = _label-overhang(
        band.recs,
        rec => {
          let r = (band.reach)(rec)
          if along-x { (lo: r.left, hi: r.right) } else {
            (lo: r.down, hi: r.up)
          }
        },
        if along-x { panel-w } else { panel-h },
        if along-x { x-pad } else { y-pad },
        if along-x { slack-x } else { slack-y },
      )
      out.insert(lo-side, calc.max(out.at(lo-side), over.lo))
      out.insert(hi-side, calc.max(out.at(hi-side), over.hi))
    }
    out
  }
  // The panel a label is drawn against, given the box the margins leave. A
  // facet builder splits that box into tracks and every outer cell draws the
  // edge axes, so the cell is what the reach is solved against. The strip and
  // secondary bands are not subtracted, which makes the cell read wider and
  // taller than it is laid out and so reserves less than the arithmetic alone
  // would ask for; what covers the difference is that each of those bands sits
  // between the cell and the canvas edge the label reaches towards, and
  // absorbs it. `coord-fixed` shrinks a single panel inside its box and pins it
  // bottom-left, which leaves the unused canvas as slack on the far sides.
  let _panel-of(box-w, box-h) = {
    if ctx.faceted {
      let gutters = _facet-gutter(
        spec.facet,
        theme,
        if ctx.facet-grid-mode { "facet-grid" } else { "facet-wrap" },
      )
      let ncol = ctx.panel-n-cols
      let nrow = ctx.panel-n-rows
      let gx = _fit-gutter(gutters.x, box-w, ncol)
      let gy = _fit-gutter(gutters.y, box-h, nrow)
      (
        w: calc.max(0.0, box-w - gx * (ncol - 1)) / ncol,
        h: calc.max(0.0, box-h - gy * (nrow - 1)) / nrow,
        slack-x: (0.0, 0.0),
        slack-y: (0.0, 0.0),
      )
    } else {
      let (inner-w, inner-h) = _fixed-inner-size(coord, trained, box-w, box-h)
      (
        w: inner-w,
        h: inner-h,
        slack-x: (0.0, box-w - inner-w),
        slack-y: (0.0, box-h - inner-h),
      )
    }
  }
  let _overhang-of(box-w, box-h) = {
    let p = _panel-of(calc.max(0.0, box-w), calc.max(0.0, box-h))
    _overhang(p.w, p.h, p.slack-x, p.slack-y)
  }

  // The bound each pass solves is read off the title's unwrapped extents, which
  // do not move as the panel does, so measure them once here rather than once
  // per pass. Every later measurement reads them back rather than repeating
  // them.
  let natural = (:)
  for side in title-sides {
    natural.insert(side.key, _axis-title-extents(side.title, side.style))
  }

  // Everything above is independent of how the axis titles wrap. The margin is
  // not: a title is boxed to the reading length the panel leaves it, a wrapped
  // title is thicker than one line, a thicker title takes more margin, and a
  // bigger margin leaves the panel smaller again. Solve it by iterating from
  // the unwrapped state, which is the largest panel any pass can produce.
  // `along-cm: none` there reproduces the pre-wrapping measurement exactly, so
  // a plot whose titles all fit re-measures to the same extents on the second
  // pass, settles against them, and keeps its former layout to the bit.
  let _fit(along, over, known: (:)) = {
    // Measure the title ink so its rotated bounding box reserves the right
    // perpendicular extent at any angle, mirroring the tick-label measurement.
    // A side whose box the pass above already measured hands it over on
    // `known`, since re-measuring the same box returns the same record.
    let ext = (:)
    for side in title-sides {
      let seen = known.at(side.key, default: none)
      ext.insert(side.key, if seen != none { seen } else {
        _axis-title-extents(
          side.title,
          side.style,
          along-cm: along.at(side.key),
          natural: natural.at(side.key),
        )
      })
    }
    let sec-x-extent = _sec-extent(
      x-sec,
      tick-len.xt,
      x-sec-extents,
      ax-title.xt,
      "x",
      title-ext: ext.xt,
    )
    let sec-y-extent = _sec-extent(
      y-sec,
      tick-len.yr,
      y-sec-extents,
      ax-title.yr,
      "y",
      title-ext: ext.yr,
    )
    let x-title-cm = if x-title != none {
      _title-extent-cm(ax-title.xb, ext.xb, "x")
    } else { 0.0 }
    let y-title-cm = if y-title != none {
      _title-extent-cm(ax-title.yl, ext.yl, "y")
    } else { 0.0 }
    // A stripped axis hands the gap and the pad back to the panel, which is
    // what lets a sub-centimetre canvas hold anything at all.
    let bottom-extent = (
      x-edge-band + bottom-gap + x-title-cm + _title-pad-cm(x-title-cm)
    )
    let left-extent = y-edge-band + left-gap + y-title-cm
    // Cap the right margin so the legend can never invert the panel. Without the
    // cap, `px-hi - px-lo` goes negative and axis labels render reversed (panel
    // becomes mirror-imaged into the legend).
    let max-right-margin = calc.max(
      0.0,
      width-units - calc.max(left-extent, over.left),
    )
    // The overhang is a floor on the margin, never on these extents: they are
    // handed to the canvas builders to place the axis titles, so growing them
    // would move a title away from the band it names. Floored here, the panel
    // and its titles move together and the reserved surplus is blank canvas.
    let _floor = (side, value) => calc.max(value, over.at(side))
    // What each side owes before any legend: the axis band, its title, and the
    // panel surface outset. The fit check below compares the legend slot
    // against what this leaves, so it can tell a legend that does not fit from
    // a canvas the axes alone have already filled.
    // Unfloored on purpose: this is what the axes themselves take, and the
    // legend check reads it to work out the room a legend has. Folding the
    // overhang in would make a canvas the labels dominate look full, so the
    // check would skip the very plot whose legend cannot fit. A legend that
    // does fit inside the floor shares that margin with the label reaching
    // into it, which crowds the two but cannot grow the canvas.
    let base = (
      left: left-extent + panel-out.left,
      bottom: bottom-extent + panel-out.bottom,
      top: sec-x-extent + panel-out.top,
      right: sec-y-extent + panel-out.right,
    )
    (
      margin: (
        left: _floor(
          "left",
          left-extent + _side-gap("left") + _surface-out("left"),
        ),
        bottom: _floor(
          "bottom",
          bottom-extent + _side-gap("bottom") + _surface-out("bottom"),
        ),
        top: calc.min(
          _floor("top", sec-x-extent + _side-gap("top") + _surface-out("top")),
          calc.max(0.0, height-units - bottom-extent),
        ),
        right: calc.min(
          _floor(
            "right",
            sec-y-extent + _side-gap("right") + _surface-out("right"),
          ),
          max-right-margin,
        ),
      ),
      base: base,
      max-right-margin: max-right-margin,
      sec-x-extent: sec-x-extent,
      sec-y-extent: sec-y-extent,
      ext: ext,
    )
  }

  // Each pass may only tighten a bound, never loosen one; erring small merely
  // over-reserves, since a box narrower than the panel cannot overrun it.
  let _tighten(prev, next) = if next == none {
    prev
  } else if prev == none { next } else { calc.min(prev, next) }

  // The overhang runs the other way: a bigger margin is a smaller panel, a
  // smaller panel puts its outermost break closer to the edge, and a closer
  // break reaches further past it. So a pass may only raise this floor, which
  // keeps the panel descending exactly as the title bound does, and both
  // settle together.
  let _loosen = (prev, next) => (
    ("top", "right", "bottom", "left")
      .map(side => (side, calc.max(prev.at(side), next.at(side))))
      .to-dict()
  )

  let along = (xb: none, yl: none, xt: none, yr: none)
  let over = (top: 0.0, right: 0.0, bottom: 0.0, left: 0.0)
  let fit = _fit(along, over)
  let panel-w = 0.0
  let panel-h = 0.0
  // Each pass can only take panel extent away, never give it back, so the
  // sequence descends and is bounded below by zero: it settles. Stop once the
  // panel holds still AND every title fits the span it was bounded to; the cap
  // is a backstop for a degenerate plot, where the panel floors at zero in
  // `_fit` and the empty-canvas guard in `render-plot` takes over.
  for _ in range(_TITLE-FIT-PASSES) {
    let next-w = calc.max(0.0, width-units - fit.margin.left - fit.margin.right)
    let next-h = calc.max(
      0.0,
      height-units - fit.margin.top - fit.margin.bottom,
    )
    let settled = (
      calc.abs(next-w - panel-w) < _LAYOUT-TOLERANCE
        and calc.abs(next-h - panel-h) < _LAYOUT-TOLERANCE
    )
    let fitted = title-sides.all(side => {
      let panel-cm = if side.axis == "x" { next-w } else { next-h }
      let span = _title-span-cm(side.style, fit.ext.at(side.key), side.axis)
      span <= panel-cm + _LAYOUT-TOLERANCE
    })
    if settled and fitted { break }
    panel-w = next-w
    panel-h = next-h
    over = _loosen(over, _overhang-of(next-w, next-h))
    // The fitted extents travel with the box they were measured at, so `_fit`
    // re-measures only a side whose earlier, tighter box the fit did not keep.
    let fitted-ext = (:)
    for side in title-sides {
      let panel-cm = if side.axis == "x" { panel-w } else { panel-h }
      let solved = _fit-title-extents(
        side.title,
        side.style,
        side.axis,
        panel-cm,
        natural.at(side.key),
      )
      let kept = _tighten(along.at(side.key), solved.along)
      along.insert(side.key, kept)
      fitted-ext.insert(side.key, if kept == solved.along { solved.ext } else {
        none
      })
    }
    fit = _fit(along, over, known: fitted-ext)
  }

  // Two ways wrapping can fail to rescue a title, both of which would push the
  // canvas past the requested size. Say so rather than ship a figure that
  // silently outgrows the box it was given.
  for side in title-sides {
    let ext = fit.ext.at(side.key)
    let panel-cm = if side.axis == "x" { panel-w } else { panel-h }
    // A word wider than the box it wraps in.
    if _title-overrun-cm(ext) > _LAYOUT-TOLERANCE {
      fail(
        "plot",
        "the "
          + side.name
          + " title has a "
          + cm-text(ext.min-width)
          + " cm word that cannot wrap into the "
          + cm-text(ext.along)
          + " cm the panel leaves it",
        hint: "Shorten the title, break it with `\\`, or give the plot more "
          + "room with `width`/`height`.",
      )
    }
    // A title rotated off its axis spans the panel with both its length and
    // its thickness, and narrowing the box trades one for the other. Past a
    // point that trade stops paying and no box fits at all.
    let span = _title-span-cm(side.style, ext, side.axis)
    if span > panel-cm + _LAYOUT-TOLERANCE {
      let default-deg = if side.axis == "x" { 0 } else { 90 }
      fail(
        "plot",
        "the "
          + side.name
          + " title spans "
          + cm-text(span)
          + " cm along a panel of "
          + cm-text(panel-cm)
          + " cm, and no wrapping of it at "
          + str(calc.round(
            _title-angle(side.style, default-deg).deg(),
            digits: 1,
          ))
          + "deg spans less",
        hint: "Shorten the title, return it to its natural angle, reduce its "
          + "font size, or give the plot more room with `width`/`height`.",
      )
    }
  }

  // The overhang is a floor on the margin, and two opposite reaches that
  // together outrun the canvas cannot both be floored: `max-right-margin` caps
  // the right margin against the left, and the top against the bottom band, so
  // the panel floors at zero rather than inverting and the ink draws past the
  // canvas edge anyway. A tick label can neither wrap nor shrink, so say what it
  // needs rather than ship a figure that outgrew the size it was asked for,
  // exactly as an oversized axis title does. The margins the caps do not touch
  // are floored outright and read here as the invariant they satisfy.
  //
  // `_overhang` reads the x labels' reach onto the left and right sides and the
  // y labels' onto the bottom and top, so each axis owns the two sides its own
  // labels can spill across, and is named by them.
  //
  // Nothing here fires under `margin-override`: a shared `compose()` margin may
  // not fail a plot that fits on its own, and `_probe-margins` solves every
  // panel unshared at its cell size first, so an oversized label fails there.
  let overhang-axes = if ctx.margin-override != none { () } else {
    (
      (
        dim: "width",
        key: "x",
        sides: ("left", "right"),
        extent: width-units,
        turn: "rotate the labels with `guides(x: guide-axis(angle: 45))`, ",
      ),
      (
        dim: "height",
        key: "y",
        sides: ("bottom", "top"),
        extent: height-units,
        // Turning a y label trades the thickness it reaches by for its length,
        // which is the wrong way round, so the advice is shorten or shrink.
        turn: "",
      ),
    )
  }
  for axis in overhang-axes {
    // The axes alone can fill a small canvas, which draws an empty panel rather
    // than failing: the label band is deliberately uncapped, as the sparkline
    // cases rest on. A reach of a fraction of a millimetre is not to blame for
    // the room that band took, and naming it would send the reader after the
    // wrong label. Same reading as the legend check below.
    let base-total = axis.sides.map(s => fit.base.at(s)).sum()
    if base-total > axis.extent + _LAYOUT-TOLERANCE { continue }
    for side in axis.sides {
      if over.at(side) <= fit.margin.at(side) + _LAYOUT-TOLERANCE {
        continue
      }
      fail(
        "plot",
        "the "
          + axis.key
          + "-axis tick labels reach "
          + cm-text(over.at(side))
          + " cm past the panel on the "
          + side
          + " and the plot leaves them "
          + cm-text(fit.margin.at(side))
          + " cm",
        hint: "Increase `"
          + axis.dim
          + "`, "
          + axis.turn
          + "shorten the labels with a `labels:` function on the "
          + axis.key
          + " scale, or shrink them with "
          + "`theme(axis-text: element-text(size: ...))`.",
      )
    }
  }

  // A legend is the one chrome band that can neither wrap nor shrink: it draws
  // the stack it measured, wherever the margin puts it, so an unbounded one
  // grows the figure past the requested `width`/`height`. Cap it here rather
  // than inside `_fit`, whose passes may only tighten, and before the
  // `margin-override` overlay, so a shared `compose()` margin cannot fail a
  // plot that fits on its own.
  //
  // First across the slot's own axis: the two margins have to leave the panel
  // no less than nothing.
  for axis in (
    (
      dim: "width",
      sides: ("left", "right"),
      extent: width-units,
      lead: "Increase `width`, move the legend to `top`/`bottom`, or ",
    ),
    (
      dim: "height",
      sides: ("bottom", "top"),
      extent: height-units,
      lead: "Increase `height`, move the legend to `left`/`right`, or ",
    ),
  ) {
    let base-total = axis.sides.map(s => fit.base.at(s)).sum()
    // The axes alone can fill a small canvas, which draws an empty panel rather
    // than failing; a legend is not to blame for the room they took.
    if base-total > axis.extent + _LAYOUT-TOLERANCE { continue }
    let room = axis.extent - base-total
    if (
      axis.sides.map(s => legend-slot.at(s)).sum()
        <= (
          room + _LAYOUT-TOLERANCE
        )
    ) {
      continue
    }
    // Blame a side that actually carries a legend. A legend claims room on the
    // two sides across from it as well, since its background is painted around
    // the whole stack, so a slot alone does not mean a legend sits there, and
    // naming that side would send the reader to move a legend that is not
    // there. Only the backdrop reaches across, and the block it belongs to is
    // measured whole by the centring check below, which names the right side.
    let carrying = axis.sides.filter(s => extents.at(s) > 0)
    if carrying.len() == 0 { continue }
    for side in carrying {
      fail(
        "plot",
        "the "
          + side
          + " legend needs "
          + cm-text(legend-slot.at(side))
          + " cm of "
          + axis.dim
          + " and the plot leaves it "
          + cm-text(calc.max(
            0.0,
            room - legend-slot.at(opposite-side.at(side)),
          ))
          + " cm",
        hint: axis.lead + _shrink-advice(side),
      )
    }
  }

  // Then across the other axis, where the stack is centred on the panel and
  // reaches half its extent either way. A facet builder hands the legend the
  // whole panel grid; a single panel shrinks inside its box, which is what
  // `coord-fixed` does and why the centre it is measured from moves.
  let box-w = calc.max(0.0, width-units - fit.margin.left - fit.margin.right)
  let box-h = calc.max(0.0, height-units - fit.margin.top - fit.margin.bottom)
  let (panel-cw, panel-ch) = if ctx.faceted { (box-w, box-h) } else {
    _fixed-inner-size(coord, trained, box-w, box-h)
  }
  for side in ("top", "right", "bottom", "left") {
    let block = legend-blocks.at(side)
    if block == none { continue }
    let vertical = side == "left" or side == "right"
    let centre = if vertical {
      fit.margin.bottom + panel-ch / 2
    } else { fit.margin.left + panel-cw / 2 }
    let half = if vertical { block.content-h / 2 } else { block.content-w / 2 }
    let near = if vertical { block.edge.bottom } else { block.edge.left }
    let far = if vertical { block.edge.top } else { block.edge.right }
    let extent = if vertical { height-units } else { width-units }
    let over = calc.max(half + near - centre, centre + half + far - extent)
    if over > _LAYOUT-TOLERANCE {
      let stands = if vertical { block.height } else { block.width }
      let reading = if vertical { "tall" } else { "wide" }
      fail(
        "plot",
        "the "
          + side
          + " legend stands "
          + cm-text(stands)
          + " cm "
          + reading
          + " centred on the panel and overruns the plot by "
          + cm-text(over)
          + " cm",
        hint: (
          if vertical {
            "Increase `height`, move the legend to `top`/`bottom`, or "
          } else { "Increase `width`, move the legend to `left`/`right`, or " }
        )
          + _shrink-advice(side),
      )
    }
  }

  let margin = fit.margin
  // `compose(align-panels: true)` forces a shared margin so panels' plot areas
  // line up; overlay the supplied sides, then clamp every side against this
  // panel's own extent so a forced margin can never invert the plot rect. Each
  // bound leaves the opposite side no less than zero, matching
  // `max-right-margin`; a panel that lands at zero draws empty rather than
  // mirrored.
  if ctx.margin-override != none {
    margin = margin + ctx.margin-override
    margin.right = calc.min(margin.right, fit.max-right-margin)
    margin.left = calc.min(margin.left, calc.max(
      0.0,
      width-units - margin.right,
    ))
    margin.top = calc.min(margin.top, calc.max(
      0.0,
      height-units - margin.bottom,
    ))
    margin.bottom = calc.min(margin.bottom, calc.max(
      0.0,
      height-units - margin.top,
    ))
    // A shared margin only ever grows a side, and a grown margin is a smaller
    // panel with a longer label reach, so the floor is taken again against the
    // margin actually used. The records and their reaches were measured once
    // above, so this is float arithmetic rather than a second measuring pass.
    for _ in range(_TITLE-FIT-PASSES) {
      let next = _overhang-of(
        width-units - margin.left - margin.right,
        height-units - margin.top - margin.bottom,
      )
      let raised = _loosen(over, next)
      if raised == over { break }
      over = raised
      margin.left = calc.max(margin.left, over.left)
      margin.bottom = calc.max(margin.bottom, over.bottom)
      margin.right = calc.min(
        calc.max(margin.right, over.right),
        calc.max(0.0, width-units - margin.left),
      )
      margin.top = calc.min(
        calc.max(margin.top, over.top),
        calc.max(0.0, height-units - margin.bottom),
      )
    }
  }

  (
    margin: margin,
    overhang: over,
    ax-text: ax-text,
    x-extents: x-extents,
    y-extents: y-extents,
    x-edge-band: x-edge-band,
    y-edge-band: y-edge-band,
    x-sec-extents: x-sec-extents,
    y-sec-extents: y-sec-extents,
    sec-x-extent: fit.sec-x-extent,
    sec-y-extent: fit.sec-y-extent,
    x-title-extents: fit.ext.xb,
    y-title-extents: fit.ext.yl,
    x-sec-title-extents: fit.ext.xt,
    y-sec-title-extents: fit.ext.yr,
  )
}
