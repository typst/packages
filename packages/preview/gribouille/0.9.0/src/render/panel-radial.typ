// Radial-panel rendering split out of `_draw-axis-and-layers`: the pre-geom
// pass draws grid circles and spokes, which are panel furniture, and the
// angular axis; the post-geom pass draws the radial axis so filled wedges,
// lines, and points cannot mask its labels.
//
// Both axes are guides, built as stacks of primitives and drawn through
// `place-theta` and `place-r`. A tick and a label are the same parts a
// cartesian side draws; only where they land changes, and that is the whole
// difference the `place` closure carries.

#import "../guide/compose.typ": (
  compose-stack, draw as compose-draw, layout-of, part-across, train,
)
#import "../guide/entry.typ": entry
#import "../guide/gctx.typ": place-r, place-theta
#import "../guide/primitive/labels.typ": prim-labels
#import "../guide/primitive/line.typ": prim-line
#import "../guide/primitive/spacer.typ": prim-spacer
#import "../guide/primitive/ticks.typ": prim-ticks
#import "../deps.typ": cetz
#import "../scale/train.typ": map-axis-data, map-break
#import "../theme/theme.typ": _line-stroke, _rect-style, surface-set-below
#import "../utils/radial.typ": (
  THETA-LABEL-PAD, group-theta-breaks, theta-axis-of, theta-range-of,
)
#import "../utils/typst-markup.typ": resolve-prose
#import "../utils/aes-resolve.typ": resolve-label
#import "axis-format.typ": (
  _axis-breaks, _axis-label, _axis-tick-values, _theta-group-label,
)
#import "axis-parts.typ": guide-gctx
#import "extents.typ": _resolve-extents, _theta-label-bounds
#import "guides.typ": (
  _THETA-CAP-FRAC, _THETA-CAP-MAX-RAD, _read-r-guide, _read-theta-guide,
)

// Two canvas angles are the same direction when they differ by a whole number
// of turns: a full sweep puts its first and last break on one ray.
#let _FULL-TURN-EPS = 1e-6

#let _same-angle(a, b) = {
  let turn = 2 * calc.pi
  let d = calc.rem(calc.abs(a - b), turn)
  calc.min(d, turn - d) < _FULL-TURN-EPS
}

// The ends a cap fades the arc out at, as canvas angles.
#let _capped-ends(guide, theta-range) = {
  let cap = if guide == none { "none" } else { guide.cap }
  let ends = ()
  if cap == "lower" or cap == "both" { ends.push(theta-range.at(0)) }
  if cap == "upper" or cap == "both" { ends.push(theta-range.at(1)) }
  ends
}

// Where the arc starts and ends along the guide. A cap fades it out short of
// the end angle by a fraction of the span, bounded in radians, so the notch
// stays visible on a narrow sweep without swallowing a wide one. Only a capped
// end is trimmed; the other keeps the whole span.
#let _arc-span(guide, sweep) = {
  let span = calc.abs(sweep)
  let cap = if guide == none { "none" } else { guide.cap }
  let trim = if cap == "none" or span == 0 { 0.0 } else {
    calc.min(span * _THETA-CAP-FRAC, _THETA-CAP-MAX-RAD) / span
  }
  (
    lo: if cap == "lower" or cap == "both" { trim } else { 0.0 },
    hi: if cap == "upper" or cap == "both" { 1.0 - trim } else { 1.0 },
  )
}

// The entry table the angular axis annotates: one major row per group of breaks
// that share a canvas angle, and one minor row bisecting each gap between them.
//
// Groups exist because a full sweep puts its first and last break on one ray: a
// 24-hour clock ticks once at 12 o'clock, under a label merged from both ends.
// A capped end keeps its label and gives up its tick, because the cap has just
// opened a gap in the arc there and a tick would float in it.
#let _theta-entries(groups, guide, theta-range, extent) = {
  let (theta-lo, theta-hi) = theta-range
  let sweep = theta-hi - theta-lo
  if sweep == 0 { return () }
  let (w, h) = extent
  let ends = _capped-ends(guide, theta-range)
  let fracs = groups.map(g => (g.theta - theta-lo) / sweep)
  let major = ()
  for (i, group) in groups.enumerate() {
    let capped = ends.any(end => _same-angle(group.theta, end))
    major.push((
      ..entry(
        group.value,
        label: group.label,
        tier: if capped { none } else { "major" },
      ),
      frac: fracs.at(i),
      width: w,
      height: h,
    ))
  }
  // Minors bisect each gap between majors, and are opt-in through
  // `guide-axis-theta(minor-ticks: true)`. A full turn closes the ring: its
  // last group and its first sit a gap apart like any other pair, so bisect
  // that one too rather than leaving the wrap gap bare.
  let wants-minor = guide != none and guide.minor-ticks
  let minor = ()
  if wants-minor and groups.len() >= 2 {
    let steps = fracs
    if calc.abs(calc.abs(sweep) - 2 * calc.pi) < _FULL-TURN-EPS {
      steps.push(steps.first() + 1.0)
    }
    for i in range(1, steps.len()) {
      let mid = (steps.at(i - 1) + steps.at(i)) / 2
      minor.push((..entry(none, tier: "minor"), frac: mid))
    }
  }
  (..major, ..minor)
}

// The stack the angular axis is: its arc, its tick weights, the pad that holds
// its labels off the circle, and the labels themselves.
//
// The pad is a plain spacer rather than an owed one, because the labels have
// always been held off the circle whether or not a tick was drawn between them.
#let _theta-node(guide, entries, sweep, angle) = {
  let arc = _arc-span(guide, sweep)
  train(compose-stack(
    // A spoke-only plot binds no theta guide and draws no arc; the ticks and
    // the labels do not wait for one.
    ..if guide == none { () } else { (prim-line(lo: arc.lo, hi: arc.hi),) },
    prim-ticks(tiers: ("major", "minor")),
    prim-spacer(THETA-LABEL-PAD),
    prim-labels(angle: angle),
    entries: entries,
    spacing: 0.0,
  ))
}

// The angular axis of one radial panel: the stack it draws and the radius its
// tick weights cost the circle.
//
// `reach` is the tick band alone. The labels that ring the circle are solved
// per angle by `radial-ctx` from their own boxes, so folding them in here would
// take their room twice.
//
// Every reason not to draw is folded in here, or the circle gives up radius for
// ink that never appears: a suppressed `guides(theta: none)`, an untrained
// sweep, a blank surface, and minors nobody asked for all reach nothing.
#let theta-band(theme, coord, guide, trained, axis, disp, style, ext) = {
  let none-band = (node: none, layout: none, ctx: none, reach: 0.0)
  if axis == none { return none-band }
  if guide != none and guide.suppress { return none-band }
  let theta-range = theta-range-of(coord)
  let (theta-lo, theta-hi) = theta-range
  let sweep = theta-hi - theta-lo
  // A blank `axis-text` draws no labels, so the rows carry none and stamp
  // nothing, which is what keeps the ring off the reservation as well.
  let labelled = style.size > 0pt
  let groups = if trained == none { () } else {
    group-theta-breaks(
      _axis-tick-values(trained),
      b => map-break(trained, b, theta-range),
    )
  }.map(group => (
    theta: group.first().theta,
    // The group stands for every break on its ray, and the first of them is
    // the value its merged label was built from.
    value: group.first().b,
    label: if not labelled { none } else {
      let text = _theta-group-label(
        trained,
        disp.labels,
        disp.typst-mark,
        group,
      )
      if text == none { none } else {
        resolve-prose(text, eval-strings: style.typst)
      }
    },
  ))
  let entries = _theta-entries(
    groups,
    guide,
    theta-range,
    if labelled { (ext.width, ext.height) } else { (0.0, 0.0) },
  )
  // The arc is the axis itself, so it stands on a sweep that ticks nothing: a
  // scale with `breaks: ()`, and one that never trained, both draw a bare ring
  // as they always have. Only a plot that binds no theta guide has no angular
  // axis to draw at all.
  if entries.len() == 0 and guide == none { return none-band }
  let node = _theta-node(
    guide,
    entries,
    sweep,
    if guide == none { 0 } else { guide.angle },
  )
  let ctx = guide-gctx(theme, "theta", axis, sweep: sweep)
  let layout = layout-of(node, ctx)
  (
    node: node,
    layout: layout,
    ctx: ctx,
    reach: part-across(layout, "ticks"),
  )
}

// What the radial frame needs from the angular axis before the circle is
// sized, for the `prepare` step of `coord-radial`: the label boxes and the tick
// reach `radial-ctx` takes, and the band the background draws.
//
// The theta tick labels ring the circle just outside it, so the circle has
// to leave them room inside the panel: the panel is all the room the chrome
// granted, and a label past its edge grows the whole figure past the
// requested `width`/`height`. Gate the band on the same conditions the draw
// does, so a suppressed or blank theta axis gives it back.
#let prepare-radial(panel) = {
  let _ax-text = panel.ax-text
  let _theta-guide = _read-theta-guide(panel.spec)
  let _theta-key = theta-axis-of(panel.coord)
  let _theta-text = if _theta-key == "x" { _ax-text.xb } else { _ax-text.yl }
  let _label-bounds = if (
    _theta-text.size > 0pt
      and not (_theta-guide != none and _theta-guide.suppress)
  ) {
    _theta-label-bounds(
      _resolve-extents(
        if _theta-key == "x" { panel.x-extents } else { panel.y-extents },
        _theta-text.size,
      ).at("groups", default: ()),
      if _theta-guide == none { 0 } else { _theta-guide.angle },
    )
  } else { () }
  // The theta ticks sit between the circle and those labels, so the angular
  // axis is laid out here rather than with the cartesian sides: the radius
  // owes its ticks their length before either can be placed.
  let _theta-y = _theta-key == "y"
  let _theta-band = theta-band(
    panel.theme,
    panel.coord,
    _theta-guide,
    if _theta-y { panel.y-trained } else { panel.x-trained },
    _theta-key,
    if _theta-y { panel.y-disp } else { panel.x-disp },
    if _theta-y { _ax-text.yl } else { _ax-text.xb },
    _resolve-extents(
      if _theta-y { panel.y-extents } else { panel.x-extents },
      if _theta-y { _ax-text.yl.size } else { _ax-text.xb.size },
    ),
  )
  (
    label-bounds: _label-bounds,
    tick-cm: _theta-band.reach,
    theta-band: _theta-band,
  )
}

// Pre-geom radial pass: the grid circles and the spokes, which are panel
// furniture, and then the angular axis. `panel` is the record the panel
// builds (GLOSSARY.md "panel"); this pass reads `theme`, `ink`,
// `outer-radial`, `x-trained`/`y-trained`, and `theta-band`.
//
// A faceted radial panel keeps its own tick labels, both weights, where a
// cartesian one gives them up to the panel on its edge. `show-x-labels` and
// `show-y-labels` mean "bottom row" and "first column", and they exist because
// neighbouring cartesian panels share the axis along the edge between them. A
// radial panel rings its labels inside its own circle, sharing them with
// nobody, so dropping them would leave an interior panel with no scale to read
// against. `radial-ctx` reserves the ring in every panel either way, so
// keeping them costs no room.
#let _draw-radial-panel(panel) = {
  import cetz.draw: circle, line
  let outer-radial = panel.outer-radial
  // Radial panels draw one grid weight for both circles and spokes; the
  // per-axis split and minor lines apply to cartesian panels only.
  let _grid-radial = _line-stroke(
    panel.theme,
    "panel-grid-major",
    fallback-colour: panel.ink,
  )
  let _grid-radial-discrete = surface-set-below(
    panel.theme,
    "panel-grid-major",
    "panel-grid",
  )

  let (cx, cy) = outer-radial.centre
  let r-max = outer-radial.r-max
  let theta-range = outer-radial.theta-range
  let r-range = outer-radial.r-range

  // The angular axis owns the sweep, so the radius runs along whichever scale
  // does not: `y` on a rose or radar, `x` on a pie.
  let (theta-trained, r-trained) = if outer-radial.cat-is-theta {
    (panel.x-trained, panel.y-trained)
  } else {
    (panel.y-trained, panel.x-trained)
  }

  // A discrete r scale draws its circles only when the theme sets the grid on
  // the major weight, matching the cartesian rule. The spokes below carry no
  // such gate: a radial panel with no spokes reads as an empty disc.
  let draw-r-grid = (
    _grid-radial != none
      and r-trained != none
      and (r-trained.type == "continuous" or _grid-radial-discrete)
  )
  if draw-r-grid {
    for b in _axis-tick-values(r-trained) {
      let r = map-break(r-trained, b, r-range)
      if r > 0 and r <= r-max {
        circle((cx, cy), radius: r, fill: none, stroke: _grid-radial)
      }
    }
  }

  let theta-breaks = _axis-tick-values(theta-trained)

  // Full-sweep domain endpoints can land on the same canvas angle (e.g., 0
  // and 24 on a 24-hour clock both sit at 12 o'clock); group them so we
  // draw one spoke and one merged "end/start" label per shared angle.
  let theta-groups = group-theta-breaks(
    theta-breaks,
    b => map-break(theta-trained, b, theta-range),
  )

  if _grid-radial != none and theta-trained != none {
    for group in theta-groups {
      let theta = group.first().theta
      line(
        (cx, cy),
        (cx + r-max * calc.cos(theta), cy + r-max * calc.sin(theta)),
        stroke: _grid-radial,
      )
    }
  }

  // The angular axis: its arc, its tick weights and its labels, drawn from the
  // stack the panel laid out before it knew its own radius. Only `place` is
  // added here, because that is the one thing the circle decides.
  if panel.theta-band.node != none {
    compose-draw(
      panel.theta-band.node,
      (..panel.theta-band.ctx, place: place-theta(outer-radial)),
      panel.theta-band.layout,
    )
  }
}

// The radial `draw-background`: the panel fill as a disc, then the grid and
// the angular axis.
#let draw-radial-background(panel) = {
  let outer-radial = panel.outer-radial
  let _panel = _rect-style(
    panel.theme,
    "panel-background",
    fallback-fill: panel.theme.paper,
    outset-ref-w: panel.canvas-w,
    outset-ref-h: panel.canvas-h,
  )
  if _panel.fill != none or _panel.stroke != none {
    cetz.draw.circle(
      outer-radial.centre,
      radius: outer-radial.r-max,
      fill: _panel.fill,
      stroke: _panel.stroke,
    )
  }
  _draw-radial-panel(panel)
}

// The entry table the radial axis annotates: one row per break that lands
// inside the circle, at the fraction of the radius it marks.
//
// A radial label sits on the radius rather than beside it, which is why the
// stack carries neither a tick row nor a spine: there is nothing for either to
// annotate along a spoke the grid already draws.
#let _r-entries(trained, disp, style, r-max, r-range, ext) = {
  if r-max <= 0 or trained == none or trained.type != "continuous" { return () }
  if style.size == 0pt { return () }
  let rows = ()
  for (idx, b) in _axis-breaks(trained).enumerate() {
    let r = map-axis-data(trained, b, r-range)
    if r < 0 or r > r-max { continue }
    let label = resolve-label(
      disp.labels,
      b,
      idx,
      _axis-label(trained, b),
      typst-mark: disp.typst-mark,
    )
    rows.push((
      ..entry(b, label: resolve-prose(label, eval-strings: style.typst)),
      frac: r / r-max,
      width: ext.width,
      height: ext.height,
    ))
  }
  rows
}

// Post-geom radial pass: the radial axis, drawn after the layers so filled
// wedges, lines, and points cannot mask its labels: the radial
// `draw-foreground`. It reads `spec`, `theme`, `outer-radial`,
// `x-trained`/`y-trained`, `x-disp`/`y-disp`, `ax-text`, and
// `x-extents`/`y-extents` off `panel`. Like the angular labels, these stay on
// every faceted panel.
#let draw-radial-foreground(panel) = {
  let outer-radial = panel.outer-radial
  if _read-r-guide(panel.spec).suppress { return }
  let cat-is-theta = outer-radial.cat-is-theta
  let axis = if cat-is-theta { "y" } else { "x" }
  let trained = if cat-is-theta { panel.y-trained } else { panel.x-trained }
  let disp = if cat-is-theta { panel.y-disp } else { panel.x-disp }
  let style = if cat-is-theta { panel.ax-text.yl } else { panel.ax-text.xb }
  let entries = _r-entries(
    trained,
    disp,
    style,
    outer-radial.r-max,
    outer-radial.r-range,
    _resolve-extents(
      if cat-is-theta { panel.y-extents } else { panel.x-extents },
      style.size,
    ),
  )
  if entries.len() == 0 { return }
  let node = train(compose-stack(prim-labels(), entries: entries, spacing: 0.0))
  let ctx = guide-gctx(
    panel.theme,
    "r",
    axis,
    place: place-r(outer-radial),
  )
  compose-draw(node, ctx, layout-of(node, ctx))
}
