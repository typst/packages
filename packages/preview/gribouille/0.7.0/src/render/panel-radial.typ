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
#import "../utils/radial.typ": (
  THETA-LABEL-PAD, group-theta-breaks, theta-range-of,
)
#import "../utils/typst-markup.typ": resolve-prose
#import "../utils/aes-resolve.typ": resolve-label
#import "axis-format.typ": (
  _axis-breaks, _axis-label, _axis-tick-values, _theta-group-label,
)
#import "axis-parts.typ": guide-gctx
#import "extents.typ": _resolve-extents
#import "guides.typ": _THETA-CAP-FRAC, _THETA-CAP-MAX-RAD, _read-r-guide

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

// Pre-geom radial pass: the grid circles and the spokes, which are panel
// furniture, and then the angular axis. `rctx` carries the enclosing panel
// state: `outer-radial`, `x-trained`/`y-trained`, `grid-radial`,
// `grid-radial-discrete`, and `theta`, the band `theta-band` built.
//
// A faceted radial panel keeps its own tick labels, both weights, where a
// cartesian one gives them up to the panel on its edge. `show-x-labels` and
// `show-y-labels` mean "bottom row" and "first column", and they exist because
// neighbouring cartesian panels share the axis along the edge between them. A
// radial panel rings its labels inside its own circle, sharing them with
// nobody, so dropping them would leave an interior panel with no scale to read
// against. `radial-ctx` reserves the ring in every panel either way, so
// keeping them costs no room.
#let _draw-radial-panel(rctx) = {
  import cetz.draw: circle, line
  let outer-radial = rctx.outer-radial
  let _grid-radial = rctx.grid-radial
  let _grid-radial-discrete = rctx.grid-radial-discrete

  let (cx, cy) = outer-radial.centre
  let r-max = outer-radial.r-max
  let theta-range = outer-radial.theta-range
  let r-range = outer-radial.r-range

  // The angular axis owns the sweep, so the radius runs along whichever scale
  // does not: `y` on a rose or radar, `x` on a pie.
  let (theta-trained, r-trained) = if outer-radial.cat-is-theta {
    (rctx.x-trained, rctx.y-trained)
  } else {
    (rctx.y-trained, rctx.x-trained)
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
  if rctx.theta.node != none {
    compose-draw(
      rctx.theta.node,
      (..rctx.theta.ctx, place: place-theta(outer-radial)),
      rctx.theta.layout,
    )
  }
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
// wedges, lines, and points cannot mask its labels. `rctx` carries `spec`,
// `theme`, `outer-radial`, `x-trained`/`y-trained`, `x-disp`/`y-disp`,
// `ax-text`, and `x-extents`/`y-extents`. Like the angular labels, these stay
// on every faceted panel.
#let _draw-radial-r-labels(rctx) = {
  let outer-radial = rctx.outer-radial
  if _read-r-guide(rctx.spec).suppress { return }
  let cat-is-theta = outer-radial.cat-is-theta
  let axis = if cat-is-theta { "y" } else { "x" }
  let trained = if cat-is-theta { rctx.y-trained } else { rctx.x-trained }
  let disp = if cat-is-theta { rctx.y-disp } else { rctx.x-disp }
  let style = if cat-is-theta { rctx.ax-text.yl } else { rctx.ax-text.xb }
  let entries = _r-entries(
    trained,
    disp,
    style,
    outer-radial.r-max,
    outer-radial.r-range,
    _resolve-extents(
      if cat-is-theta { rctx.y-extents } else { rctx.x-extents },
      style.size,
    ),
  )
  if entries.len() == 0 { return }
  let node = train(compose-stack(prim-labels(), entries: entries, spacing: 0.0))
  let ctx = guide-gctx(
    rctx.theme,
    "r",
    axis,
    place: place-r(outer-radial),
  )
  compose-draw(node, ctx, layout-of(node, ctx))
}
