// Axis label measurement: tick-label extents, depth/width geometry, title
// placement, and reserved secondary-axis extents used to size panel chrome.

#import "../utils/margin.typ": resolve-margin-side-cm
#import "../utils/typst-markup.typ": resolve-prose
#import "../utils/aes-resolve.typ": resolve-label
#import "../theme/theme.typ": _text-args
#import "../utils/measure.typ": (
  longest-unbreakable-cm, measure-labels-cm, measure-text-cm,
)
#import "../utils/palette.typ": spec-attr
#import "../utils/radial.typ": (
  THETA-LABEL-PAD, group-theta-breaks, theta-axis-of, theta-range-of,
)
#import "../scale/train.typ": map-break
#import "../utils/format.typ": format-break
// Re-exported so the chrome stage keeps reading the label geometry from here
// while the guide primitives read it straight from `utils/`.
#import "../utils/label-geometry.typ": (
  _label-reach, _rotated-extent, _x-label-anchor,
)
#import "../scale/secondary.typ" as secondary-mod
#import "axis-format.typ": (
  _axis-breaks, _axis-tick-values, _secondary-breaks, _theta-group-label,
  _tick-label-fallback,
)

// Convert the axis-text font size in pt to cm. Used as a fallback ink-height
// when no actual labels are measured (e.g., an axis with no breaks).
#let _ax-text-cm(size-pt) = size-pt / 1pt * 0.0353

// Map a horizontal-axis title alignment to its coordinate along the panel's
// x span (`lo`/`hi` are the left/right canvas x) and the cetz anchor that
// pins it there. `none` keeps the default of centred.
#let _x-title-place(align, lo, hi) = if align == left {
  (lo, "south-west")
} else if align == right {
  (hi, "south-east")
} else {
  ((lo + hi) / 2, "south")
}

// Same for a vertical-axis title; it is drawn rotated 90deg, so along its
// reading direction `left` is the panel bottom (`lo`) and `right` the top
// (`hi`). `none` keeps the default of centred.
#let _y-title-place(align, lo, hi) = if align == left {
  (lo, "south")
} else if align == right {
  (hi, "north")
} else {
  ((lo + hi) / 2, "center")
}

// Resolve a text style's rotation: the explicit `angle` field when the theme
// sets one, otherwise the surface's natural default in degrees (x titles read
// horizontally at 0deg, y titles read bottom-to-top at 90deg).
#let _title-angle(style, default-deg) = if style.angle != none {
  style.angle
} else { default-deg * 1deg }

// The exact box a wrapped axis title is drawn in, shared by the measuring and
// the drawing side so the two cannot drift. cetz stamps `top-edge:
// "cap-height"` / `bottom-edge: "baseline"` onto the bodies it lays out and
// sizes its own frame from a body measured that way, adding a descender
// allowance when the body does not already carry those edges. Setting them
// here makes `measure()` on this box predict the cetz frame exactly, which is
// what lets the canvas stay inside the requested plot size.
#let _title-boxed(body, along-cm, align-to) = box(
  width: along-cm * 1cm,
  align(align-to, text(top-edge: "cap-height", bottom-edge: "baseline", body)),
)

// Measure an axis title string at its font size, returning `(width, height)`
// in cm. Zero extents when no title renders. Caller must already be inside a
// `context { ... }` block, since `measure` requires it.
//
// `along-cm` bounds the title's reading direction, which is what the panel
// constrains: cetz lays a title out before rotating it, so a y title's
// pre-rotation width becomes its extent up the panel. Pass the available
// reading length and a longer title wraps instead of growing the canvas past
// the requested plot size; the record then carries `along` (the box the draw
// side must reproduce) and `min-width` (the widest unbreakable run, for the
// caller's overrun guard). Leave it `none` to measure a single unbounded line.
//
// Only the wrapped branch measures through the full text style; the unwrapped
// one keeps the size-only measurement every existing layout is calibrated to.
// The reservation still matches the drawing either way, because both sides go
// through `_title-boxed`.
//
// The unbounded extents do not move as the panel does, so a caller that fits a
// title over several passes measures them once and hands them back on `natural`
// rather than paying for them per pass.
#let _axis-title-extents(title, style, along-cm: none, natural: none) = {
  if title == none { return (width: 0.0, height: 0.0, along: none) }
  let resolved = resolve-prose(title, eval-strings: style.typst)
  let natural = if natural != none { natural } else {
    measure-labels-cm((resolved,), style.size)
  }
  // A title that already fits needs no box: measuring and drawing it exactly
  // as before keeps every existing layout bit-identical.
  if along-cm == none or natural.width <= along-cm {
    return natural + (along: none)
  }
  let boxed = measure(_title-boxed(
    text(.._text-args(style))[#resolved],
    along-cm,
    center,
  ))
  (
    // A box reports the width it was given, not the ink inside it. That is the
    // honest figure here: the drawn title occupies exactly this box.
    width: along-cm,
    height: boxed.height / 1cm,
    min-width: longest-unbreakable-cm(resolved, style.size),
    along: along-cm,
  )
}

// Resolve a margin side on a text-style record to a cm float, falling back to
// the supplied default length when the user has not overridden the side. The
// surface's font size is forwarded so em values scale with it.
#let _text-margin-cm(style, side, default-length) = {
  resolve-margin-side-cm(
    style.margin.at(side),
    default-length,
    size-pt: style.size / 1pt,
  )
}

// Default extents for an axis without labels: zero width, font-height as a
// safe fallback so layouts that ask for a depth before measurement is
// possible still leave room for a single line of text.
#let _empty-extents(size) = (
  width: 0.0,
  height: _ax-text-cm(size),
)

// The cm below which two layout extents count as the same. Every band that
// settles against the box it shrinks, and every check that reports a band the
// box cannot hold, reads the same slack rather than open-coding one.
#let _LAYOUT-TOLERANCE = 1e-6

// Fold a list of extent records onto a base one: the widest and the tallest
// win, and every record keeps its break list rather than being folded into a
// single max. A break carries the position it is drawn at as well as its
// extent, so the reservation compares each label against its own break.
#let _merge-extents(base, exts) = (
  width: exts.fold(base.width, (m, e) => calc.max(m, e.width)),
  height: exts.fold(base.height, (m, e) => calc.max(m, e.height)),
  breaks: exts.fold(
    base.at("breaks", default: ()),
    (acc, e) => acc + e.at("breaks", default: ()),
  ),
)

// Either the supplied extents record or `_empty-extents(size)` when caller
// did not measure any labels (e.g., callers that skip measurement or have no secondary axis).
#let _resolve-extents(extents, size) = if extents != none {
  extents
} else { _empty-extents(size) }

// Resolve a single tick label to its rendered form so measurement matches
// what the axis-draw path will emit.
#let _resolve-tick(labels-cb, typst-mark, idx, value, fallback, typst-eval) = (
  resolve-prose(
    resolve-label(labels-cb, value, idx, fallback, typst-mark: typst-mark),
    eval-strings: typst-eval,
  )
)

#let _trained-labels-cb(trained) = spec-attr(
  trained,
  "labels",
  fallback: auto,
)

// Measure a set of resolved tick labels in one walk, for the primary axis and
// the secondary alike. Returns the widest and tallest ink box (cm) and, per
// break, that box with where the break lands.
//
// Each break keeps its own extent and where it lands, the way the radial groups
// in `_axis-label-extents` do. A label is centred on its break, so it reaches
// past the panel edge the break sits near, and the reservation for that reach
// can only be solved per break: the widest label is not always the outermost
// one. `map-break` into (0, 1) is affine on both branches and folds `reverse`
// in, so the fraction is the canvas position, not the data one.
//
// A label that lands nowhere still counts toward the band the axis reserves,
// but carries no reach, so it folds into the maximum without reaching `breaks`.
// `labels` arrive resolved from `_resolve-tick`, so they measure as they draw.
#let _break-records(trained, values, labels, size) = {
  let max-w = 0.0
  let max-h = 0.0
  let breaks = ()
  for (b, label) in values.zip(labels) {
    let m = measure-text-cm(label, size)
    if m.width > max-w { max-w = m.width }
    if m.height > max-h { max-h = m.height }
    if label == none { continue }
    let frac = map-break(trained, b, (0.0, 1.0))
    if frac == none { continue }
    breaks.push((frac: frac, width: m.width, height: m.height))
  }
  (width: max-w, height: max-h, breaks: breaks)
}

// Collect the formatted tick labels for the trained scale and measure them
// via Typst. Returns `(width, height)` in cm of the longest label's ink box.
// Caller must already be inside a `context { ... }` block.
// `typst-eval` mirrors the axis-text style's `typst` flag so typst-marked
// labels measure at their rendered width.
//
// `axis` and `coord` are both required, because together they are what tells
// this apart from the angular axis of a `coord-radial`: there the breaks are
// grouped by canvas angle and each group measured as the single merged label
// the draw emits. Defaulting either would silently hand a radial plot the
// per-break measurement, which reserves about half the band a merged label
// needs.
#let _axis-label-extents(trained, size, axis, coord, typst-eval: false) = {
  if trained == none { return _empty-extents(size) }
  let values = _axis-tick-values(trained)
  // Only an axis with no breaks at all takes the single-line fallback. Breaks
  // whose labels all resolve away draw nothing and owe nothing, which is what
  // `_break-records` answers for the empty boxes they leave behind.
  if values.len() == 0 { return _empty-extents(size) }
  let labels-cb = _trained-labels-cb(trained)
  let typst-mark = trained.at("typst-mark", default: false)
  // `theta-axis-of` is `none` off a radial coord and `axis` never is, so this
  // is false for every cartesian axis without a guard of its own.
  if theta-axis-of(coord) == axis {
    let theta-range = theta-range-of(coord)
    // Each group is measured on its own and keeps the canvas angle it is drawn
    // at, so the reservation can be solved per angle rather than as one max
    // over the circle. The max stays on the record for the callers that only
    // need a band.
    let groups = group-theta-breaks(
      values,
      b => map-break(trained, b, theta-range),
    )
      .map(group => (
        theta: group.first().theta,
        label: _theta-group-label(trained, labels-cb, typst-mark, group),
      ))
      .filter(g => g.label != none)
      .map(g => {
        let m = measure-text-cm(
          resolve-prose(g.label, eval-strings: typst-eval),
          size,
        )
        (theta: g.theta, width: m.width, height: m.height)
      })
    let widest = groups.fold(0.0, (m, g) => calc.max(m, g.width))
    let tallest = groups.fold(0.0, (m, g) => calc.max(m, g.height))
    return (width: widest, height: tallest, groups: groups)
  }
  let labels = values
    .enumerate()
    .map(((idx, b)) => (
      _resolve-tick(
        labels-cb,
        typst-mark,
        idx,
        b,
        _tick-label-fallback(trained, b),
        typst-eval,
      )
    ))
  _break-records(trained, values, labels, size)
}

// Same as `_axis-label-extents` but for the secondary axis: each break is
// routed through the user's transformation before formatting. Returns zero
// extents when no secondary axis is configured. Mirrors the draw in
// `panel-draw.typ`, so the secondary's own breaks and labels win here too and
// the reserved margin matches the labels actually drawn.
#let _secondary-label-extents(trained, sec, size, typst-eval: false) = {
  if trained == none or sec == none { return (width: 0.0, height: 0.0) }
  if trained.type != "continuous" { return (width: 0.0, height: 0.0) }
  let labels-cb = sec.at("labels", default: auto)
  let typst-mark = trained.at("typst-mark", default: false)
  let sec-breaks = _secondary-breaks(trained, sec, _axis-breaks(trained))
  let labels = sec-breaks
    .enumerate()
    // The transformed value is what the draw formats and what the reservation
    // measures; the untransformed break is what places it on the axis.
    .map(((idx, b)) => {
      let transformed = secondary-mod.apply-transform(sec, b)
      _resolve-tick(
        labels-cb,
        typst-mark,
        idx,
        transformed,
        format-break(transformed),
        typst-eval,
      )
    })
  if labels.len() == 0 { return (width: 0.0, height: 0.0) }
  _break-records(trained, sec-breaks, labels, size)
}

// Perpendicular extent of x-axis tick labels (cm). Inputs are the measured
// ink-bbox width and height of the longest label; rotating composes them
// trigonometrically, and `n-dodge > 1` adds the staggered rows.
#let _x-label-depth(angle, n-dodge, label-w-cm, label-h-cm) = (
  _rotated-extent(label-w-cm, label-h-cm, angle).height + (n-dodge - 1) * 0.35
)

// Perpendicular extent of y-axis tick labels (cm). At angle 0 the labels
// extend leftward by their full measured width; rotating swaps the extents
// according to the rotated bounding box, and `n-dodge > 1` adds dodge cols.
#let _y-label-width(angle, n-dodge, label-w-cm, label-h-cm) = (
  _rotated-extent(label-w-cm, label-h-cm, angle).width + (n-dodge - 1) * 0.5
)

// The cm a run of tick labels reaches past each end of the panel, given one
// record per drawn break (`frac`, `width`, `height`), a `reach-of` that turns a
// record into a `(lo, hi)` pair along this axis, the panel `span`, the
// `view-pad-cm` the data area is already inset by, and the `slack` the panel
// leaves unused at each end of its box.
//
// Seeded at zero and folded with `calc.max`, so a break far enough inside the
// panel owes exactly nothing: on a plot with room the expansion gap already
// covers the reach, and the reservation is the identity. The fold runs over
// every break rather than the outermost, because a wide label one break in can
// reach further than a narrow one at the edge.
#let _label-overhang(recs, reach-of, span, pad, slack) = {
  let inner = calc.max(0.0, span - pad.at(0) - pad.at(1))
  let over = (lo: 0.0, hi: 0.0)
  for r in recs {
    let reach = reach-of(r)
    over.lo = calc.max(
      over.lo,
      reach.lo - (slack.at(0) + pad.at(0) + r.frac * inner),
    )
    over.hi = calc.max(
      over.hi,
      reach.hi - (slack.at(1) + pad.at(1) + (1 - r.frac) * inner),
    )
  }
  over
}

// Half-extents (cm) each radial theta label reaches from the point it is drawn
// on, one record per label group: `hw` to either side, `hh` above and below,
// carrying the canvas angle `theta` the group sits at. The labels are drawn
// centred `THETA-LABEL-PAD` beyond `r-max`, so `radial-ctx` solves each of
// these against the panel half-spans and keeps the whole ring inside the panel
// rather than spilling out of it.
//
// A theta label is drawn centred, which is `_label-reach`'s `center` anchor:
// the halves it answers are term for term the rotated bounding box these
// records used to compute on their own, so the radial and cartesian
// reservations solve one geometry rather than two that can drift.
#let _theta-label-bounds(groups, angle) = {
  groups.map(g => {
    let reach = _label-reach(g.width, g.height, angle, "center")
    (theta: g.theta, hw: reach.left, hh: reach.up)
  })
}

// The box width `_axis-title-extents` settled on, or `none` when the title
// fitted on one line and is measured and drawn unboxed as it always was.
#let _ext-along(ext) = if ext == none { none } else {
  ext.at("along", default: none)
}

// Thickness (cm) of the title's own box across its reading direction: one line
// unless `_axis-title-extents` had to wrap it onto more, in which case its
// measured height wins and the single-line case stays untouched.
#let _title-thickness-cm(style, ext) = {
  let line-h = _ax-text-cm(style.size)
  if _ext-along(ext) == none { return line-h }
  calc.max(line-h, ext.height)
}

// Perpendicular extent (cm) reserved for an axis title rotated by its resolved
// angle. `axis` picks both the rotated-bbox formula and the natural default
// angle: `"x"` titles read horizontally (0deg) and occupy a depth below the
// panel, `"y"` titles read bottom-to-top (90deg) and a width beside it. The
// along-reading dimension is the measured title width (`ext.width`, `0` when
// unmeasured), the perpendicular one its thickness, so a title at its natural
// angle on one line reserves exactly `_ax-text-cm(size)` as before.
#let _title-extent-cm(style, ext, axis) = {
  let title-w = if ext != none { ext.width } else { 0.0 }
  let thickness = _title-thickness-cm(style, ext)
  let a = _title-angle(style, if axis == "x" { 0 } else { 90 }).deg()
  if axis == "x" {
    _x-label-depth(a, 1, title-w, thickness)
  } else {
    _y-label-width(a, 1, title-w, thickness)
  }
}

// Extent (cm) a title box actually spans along the panel's own axis: the other
// half of the rotated bounding box from `_title-extent-cm`, which reserves the
// perpendicular half. An x title is bounded by this against the panel width, a
// y title against the panel height.
#let _title-span-cm(style, ext, axis) = {
  let along = _ext-along(ext)
  if along == none { return 0.0 }
  let thickness = _title-thickness-cm(style, ext)
  let a = _title-angle(style, if axis == "x" { 0 } else { 90 }).deg()
  if axis == "x" {
    _y-label-width(a, 1, along, thickness)
  } else {
    _x-label-depth(a, 1, along, thickness)
  }
}

// Smallest panel worth wrapping an axis title against. Below it the panel holds
// no readable title at any width, so bounding one buys nothing; the span check
// in `chrome.typ` is what reports the title that will not fit.
#let _MIN-TITLE-PANEL = 0.5

// How much of a rotated title box's reading length (`along`) and thickness
// (`across`) project onto the panel axis that bounds it. Both the estimate and
// the bisection below solve against these, so they read them from one place.
#let _title-shares(style, axis) = {
  let default-deg = if axis == "x" { 0 } else { 90 }
  let a = calc.abs(_title-angle(style, default-deg).deg()) * 1deg
  if axis == "x" {
    (along: calc.cos(a), across: calc.sin(a))
  } else {
    (along: calc.sin(a), across: calc.cos(a))
  }
}

// The reading length whose span is the smallest any box of this title can
// reach: below it, narrowing the box thickens it faster than it shortens it.
#let _min-span-along-cm(style, shares, natural-cm) = calc.sqrt(
  natural-cm * _ax-text-cm(style.size) * shares.across / shares.along,
)

// Reading length (cm) to box an axis title at so it spans no more than
// `panel-cm` along the panel's own axis. Rotated by `a`, a `len` x `thickness`
// box spans `len * cos(a) + thickness * sin(a)` horizontally and
// `len * sin(a) + thickness * cos(a)` vertically; an x title is bounded by the
// first against the panel width, a y title by the second against the panel
// height. `natural-cm` is the title's unwrapped single-line width.
//
// At the natural angles the thickness lies across the constrained span and
// costs nothing, so the bound is the panel extent divided by the projection.
// Off them both terms count, and shortening the box thickens it: wrapping
// `natural-cm` into a box of width `len` takes about `natural-cm / len` lines,
// so `thickness ~ natural-cm * line / len` and the span becomes
// `len * s + natural-cm * line * c / len`. That is a quadratic in `len`, so
// take its larger root and the title wraps as little as it can while still
// fitting. A span has a floor of `2 * sqrt(natural-cm * line * s * c)`, so when
// the panel is under it no box fits: hand back the length that comes closest
// and let the caller's span check report it.
//
// When the reading direction contributes nothing to the constrained span the
// title reads across its axis rather than along it (a vertical x title, a
// horizontal y title): its length is then reserved as perpendicular depth
// instead, so nothing bounds it and `none` means unbounded.
#let _title-along-cm(style, axis, panel-cm, natural-cm) = {
  // Below the panel minimum the whole layout is already degenerate. Bounding a
  // title to a few millimetres there would turn plots that used to render,
  // however cramped, into failures. Leave them exactly as they were, and let
  // the caller's span check speak for a title that genuinely cannot fit.
  if panel-cm < _MIN-TITLE-PANEL { return none }
  let shares = _title-shares(style, axis)
  if shares.along <= 1e-6 { return none }
  if shares.across <= 1e-6 { return panel-cm / shares.along }
  let bulk = natural-cm * _ax-text-cm(style.size) * shares.across
  let discriminant = panel-cm * panel-cm - 4 * shares.along * bulk
  if discriminant <= 0 {
    return _min-span-along-cm(style, shares, natural-cm)
  }
  (panel-cm + calc.sqrt(discriminant)) / (2 * shares.along)
}

// Bisection steps spent narrowing an oblique title's box onto the panel. The
// estimate above assumes lines pack perfectly; real ones are ragged and round
// up to whole lines, so the estimate can still overrun by a line's projection.
// Five halvings take that to a thirty-second of the starting bracket.
#let _TITLE-FIT-STEPS = 5

// The largest reading length whose *measured* span fits `panel-cm`, and the
// extents that go with it. At the natural angles the estimate is exact and
// this is a single measurement. Off them it brackets: the estimate is the
// widest box worth trying, and `sqrt(bulk / along-share)` is the box that
// minimises the span, so if anything fits it lies between the two. Bisect
// towards the wider end, keeping the widest box measured to fit, because a
// wider box is a title on fewer lines.
#let _fit-title-extents(title, style, axis, panel-cm, natural) = {
  let natural-cm = natural.width
  let along = _title-along-cm(style, axis, panel-cm, natural-cm)
  let ext = _axis-title-extents(
    title,
    style,
    along-cm: along,
    natural: natural,
  )
  let fits = ext => (
    _title-span-cm(style, ext, axis) <= panel-cm + _LAYOUT-TOLERANCE
  )
  if along == none or fits(ext) { return (along: along, ext: ext) }
  let shares = _title-shares(style, axis)
  if shares.across <= 1e-6 { return (along: along, ext: ext) }
  let floor = _min-span-along-cm(style, shares, natural-cm)
  // Nothing between the two fits, so settle on the span minimum and let the
  // caller report a title this panel cannot hold at this angle.
  let best = (
    along: floor,
    ext: _axis-title-extents(
      title,
      style,
      along-cm: floor,
      natural: natural,
    ),
  )
  let (lo, hi) = (calc.min(floor, along), calc.max(floor, along))
  for _ in range(_TITLE-FIT-STEPS) {
    let mid = (lo + hi) / 2
    let probe = _axis-title-extents(
      title,
      style,
      along-cm: mid,
      natural: natural,
    )
    if fits(probe) {
      best = (along: mid, ext: probe)
      lo = mid
    } else { hi = mid }
  }
  best
}

// The drawable body for an axis title: the same box `_axis-title-extents`
// measured, so what the canvas reserves and what cetz lays out agree. A title
// that fitted on one line carries no `along` and is drawn bare, exactly as
// before.
//
// Once it wraps, the lines take the theme's `align`, the same field
// `_x-title-place` / `_y-title-place` read to pin the block as a whole, so a
// ragged edge falls on the side the title is already pushed to. Unset means
// centred on both axes, which is what those two produce as well.
#let _title-body(title, style, ext) = {
  let body = text(.._text-args(style))[#resolve-prose(
    title,
    eval-strings: style.typst,
  )]
  let along = _ext-along(ext)
  if along == none { return body }
  let align-to = if style.align != none { style.align } else { center }
  _title-boxed(body, along, align-to)
}

// How far (cm) a title still overruns its box once wrapped: the widest run the
// layout cannot break, less the box. Zero when it fits, and zero for content
// titles, whose break opportunities `longest-unbreakable-cm` cannot see.
#let _title-overrun-cm(ext) = {
  let along = _ext-along(ext)
  if along == none { return 0.0 }
  calc.max(0.0, ext.at("min-width", default: 0.0) - along)
}

// Inter-row gap between dodged labels on the x and y axes (cm). The depth
// helpers and the per-label draw closures both apply these so the reserved
// axis area stays in sync with the actual ink.
#let _X-LABEL-ROW-GAP = 0.35
#let _Y-LABEL-COL-GAP = 0.5

// Default gap between axis tick labels and axis title (all sides). Used as
// the fallback for `axis-title-*` margin sides left at `auto`. Absolute pt so
// the gap stays stable when users tune the axis-title font size.
#let _AX-TITLE-LABEL-GAP = 5pt

// Gap (cm) between the panel edge and the tick-and-label band it carries, and
// pad (cm) between an axis title and the canvas edge beyond it. Every site
// that reserves either one gates it on the thing it separates actually being
// drawn, so a stripped axis (`theme-void`, `guides(x: none)`) reserves neither
// and the panel keeps the room.
#let _TICK-LABEL-GAP = 0.1
#let _TITLE-EDGE-PAD = 0.05

// Each is owed only when there is something to separate: no band, no gap; no
// title, no pad. Chrome reservation and every draw site read these, so a title
// cannot come to sit outside the margin reserved for it.
#let _band-gap-cm(band) = if band > 0 { _TICK-LABEL-GAP } else { 0.0 }
#let _title-pad-cm(title-cm) = if title-cm > 0 { _TITLE-EDGE-PAD } else { 0.0 }

// One-element tuple for stand-alone guides, so callers can iterate uniformly
// across stacks and singletons. Shared between x and y; placement on either
// axis flows through the same rendering path.
#let _axis-guide-rows(g) = if g.stack { g.guides } else { (g,) }

// Depth (cm) of the secondary axis ink alone, tick mark plus gap plus label
// band, with no title. A facet cell reserves this between the panel edge and
// the strip band that would otherwise be painted over it; the grid draws the
// secondary title once at its outer edge, where the chrome margin holds it.
// `axis` selects orientation: `"y"` (right edge, label width) or `"x"` (top
// edge, label depth).
#let _sec-band-cm(tick-len, sec-extents, axis) = {
  let label-extent = if axis == "y" {
    _y-label-width(0, 1, sec-extents.width, sec-extents.height)
  } else {
    _x-label-depth(0, 1, sec-extents.width, sec-extents.height)
  }
  tick-len + _band-gap-cm(tick-len + label-extent) + label-extent
}

// Distance (cm) from the panel edge a secondary axis sits on to the near edge
// of its title: the band above, plus the title-to-label gap. The reservation
// below and both draw sites (the single panel, and the facet builders' one
// title per grid) measure the title from here, so a change to the stack cannot
// move one without the others.
#let _sec-title-offset-cm(tick-len, sec-extents, ax-title, axis) = {
  let gap-side = if axis == "y" { "left" } else { "bottom" }
  (
    _sec-band-cm(tick-len, sec-extents, axis)
      + _text-margin-cm(
        ax-title,
        gap-side,
        _AX-TITLE-LABEL-GAP,
      )
  )
}

// Reserved extent between the panel and the canvas edge for the secondary
// axis ticks, labels, and title. Matches the primary formula so the
// title-to-label gap stays symmetric on opposing edges. `title-ext` carries
// the secondary title's measured extents when it had to wrap, so the reserved
// thickness follows its line count like the primary's.
#let _sec-extent(
  sec,
  tick-len,
  sec-extents,
  ax-title,
  axis,
  title-ext: none,
) = {
  if sec == none { return 0.0 }
  let title-cm = if sec.at("name", default: none) != none {
    _title-extent-cm(ax-title, title-ext, axis)
  } else { 0.0 }
  let offset = _sec-title-offset-cm(tick-len, sec-extents, ax-title, axis)
  offset + title-cm + _title-pad-cm(title-cm)
}
