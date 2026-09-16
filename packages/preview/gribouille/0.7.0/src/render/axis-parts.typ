// The band a cartesian axis is: its tick rows, the gap that holds them off the
// panel edge, and its label rows. Built here so the chrome stage that reserves
// the band and the panel that draws it read one record.
//
// The spine and the axis title are not part of it. The spine spans the whole
// panel rather than the data area inside it and paints over the layers, and the
// title is drawn once per facet grid rather than once per panel, so both stay
// with the sites that already own them.

#import "../guide/axis-build.typ": axis-node, axis-row
#import "../guide/compose.typ": draw as compose-draw, layout-of
#import "../guide/entry.typ": entry, train-entries
#import "../guide/gctx.typ": gctx, place-cartesian
#import "../scale/train.typ": map-axis-data, map-break
#import "../theme/defaults.typ": resolve-colour
#import "../theme/theme.typ": (
  _line-stroke, _text-args, _text-style, _tick-length,
)
#import "axis-format.typ": (
  LOG10-MID-MANTISSAS, LOG10-SHORT-MANTISSAS, _log10-tier-positions,
  _visible-domain,
)
#import "extents.typ": _TICK-LABEL-GAP, _axis-guide-rows

// The primary edge each axis carries its band on.
#let AXIS-SIDE = (x: "bottom", y: "left")

// `frac` runs 0 to 1 across the data area, so a break is trained against that
// unit range once and `place` spreads it over whichever panel draws it. The
// reservation has no panel to spread it over, which is the other reason the
// fraction rather than the canvas position is what an entry carries.
#let _UNIT = (0.0, 1.0)

// The sub-decade tick positions a log axis draws, as `(mid, minor)`. Empty for
// every axis that draws none: the tiers are opt-in through
// `guide-axis-logticks()` and apply to a log10 scale alone.
#let _log-tiers(trained, guide) = {
  if not guide.logticks or guide.suppress { return ((), ()) }
  if trained == none or trained.type != "continuous" { return ((), ()) }
  if trained.at("transform", default: "identity") != "log10" { return ((), ()) }
  // A pre-transformed scale holds its domain in stat space, so the positions
  // come from the unwarped domain the gridlines already use.
  let (lo, hi) = _visible-domain(trained)
  if lo <= 0 or hi <= 0 { return ((), ()) }
  (
    _log10-tier-positions(lo, hi, LOG10-MID-MANTISSAS),
    _log10-tier-positions(lo, hi, LOG10-SHORT-MANTISSAS),
  )
}

// The entry table an axis annotates: one major row per break, plus one row per
// sub-decade tick a log axis adds below them.
//
// `labels` is one label per break, `none` where nothing is drawn: a suppressed
// axis, a blanked `axis-text`, or a sub-decade tick, which marks a position
// without naming it. `extent` is the widest label in centimetres, stamped on
// every row, which is the figure the band has always been sized from.
//
// The two tiers are trained through different maps because they stand for
// different things: a break is a tick value the scale places, a sub-decade
// position is raw data.
#let axis-entries(trained, guide, breaks, labels: (), extent: (0.0, 0.0)) = {
  if trained == none or guide.suppress { return () }
  let (w, h) = extent
  let major = breaks
    .enumerate()
    .map(((i, b)) => (
      ..entry(b, label: labels.at(i, default: none)),
      width: w,
      height: h,
    ))
  let (mid, minor) = _log-tiers(trained, guide)
  let sub = (
    ..mid.map(v => entry(v, tier: "mid")),
    ..minor.map(v => entry(v, tier: "minor")),
  )
  (
    ..train-entries(major, b => map-break(trained, b, _UNIT)),
    ..train-entries(sub, v => map-axis-data(trained, v, _UNIT)),
  )
}

// The stack an axis band is, over the label rows the guide dodges and stacks.
//
// `line: false` leaves the spine to the panel, and no title is passed: the
// chrome stage adds the title band outside this record, where the facet
// builders can drop it and keep the ticks.
#let axis-band(guide, entries) = axis-node(
  entries: entries,
  rows: _axis-guide-rows(guide).map(s => axis-row(
    angle: s.angle,
    n-dodge: s.n-dodge,
  )),
  tiers: if guide.logticks { ("major", "mid", "minor") } else { ("major",) },
  band-gap: _TICK-LABEL-GAP,
  stack-gap: if guide.stack { guide.spacing } else { 0 },
  line: false,
)

// The context a guide is measured and drawn under, with the theme read through
// the closures the guide layer takes rather than reached for. `place` stays
// `none` to measure, since a measurement never asks where a point lands.
//
// The four cartesian sides and the two radial positions share it: only `place`
// and `sweep` tell an arc from an edge.
#let guide-gctx(theme, position, axis, place: none, sweep: none) = gctx(
  position,
  axis,
  axis: axis,
  place: place,
  sweep: sweep,
  tick-length: surface => _tick-length(theme, surface) / 1cm,
  surface-stroke: surface => _line-stroke(
    theme,
    surface,
    fallback-colour: resolve-colour(theme, "ink"),
  ),
  text-style: surface => {
    let style = _text-style(theme, surface)
    (render: label => text(.._text-args(style))[#label])
  },
  tick-gap: _TICK-LABEL-GAP,
)

// The context a cartesian band is measured and drawn under.
//
// The two ranges `place-cartesian` takes are not the same box: a break sits
// inside the data area, which `view-pad-cm` insets, while the edge the band
// grows from is the panel bound.
#let axis-gctx(theme, axis, place: none) = guide-gctx(
  theme,
  AXIS-SIDE.at(axis),
  axis,
  place: place,
)

// The centimetres an axis band takes between the panel edge and whatever sits
// past it. Zero where the axis draws nothing at all.
#let axis-band-cm(theme, axis, guide, entries) = {
  if entries.len() == 0 { return 0.0 }
  layout-of(axis-band(guide, entries), axis-gctx(theme, axis)).across
}

// Draw one axis band against a panel. `along-range` is the data area the breaks
// sit in, which `view-pad-cm` insets; `across-range` is the panel bound the band
// grows away from, which it does not.
#let draw-axis-band(theme, axis, guide, entries, along-range, across-range) = {
  if entries.len() == 0 { return }
  let horizontal = axis == "x"
  let ctx = axis-gctx(
    theme,
    axis,
    place: place-cartesian(
      AXIS-SIDE.at(axis),
      if horizontal { along-range } else { across-range },
      if horizontal { across-range } else { along-range },
    ),
  )
  let node = axis-band(guide, entries)
  compose-draw(node, ctx, layout-of(node, ctx))
}
