// Axis label measurement: tick-label extents, depth/width geometry, title
// placement, and reserved secondary-axis extents used to size panel chrome.

#import "../utils/margin.typ": resolve-margin-side-cm
#import "../utils/typst-markup.typ": resolve-prose
#import "../utils/aes-resolve.typ": resolve-label
#import "../utils/measure.typ": measure-labels-cm
#import "../utils/format.typ": format-break
#import "../scale/secondary.typ" as secondary-mod
#import "axis-format.typ": _axis-breaks, _axis-label

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

#let _trained-labels-cb(trained) = if (
  trained.at("spec", default: none) != none
) {
  trained.spec.at("labels", default: auto)
} else { auto }

// Collect the formatted tick labels for the trained scale and measure them
// via Typst. Returns `(width, height)` in cm of the longest label's ink box.
// Caller must already be inside a `context { ... }` block.
// `typst-eval` mirrors the axis-text style's `typst` flag so typst-marked
// labels measure at their rendered width.
#let _axis-label-extents(trained, size, typst-eval: false) = {
  if trained == none { return _empty-extents(size) }
  let labels-cb = _trained-labels-cb(trained)
  let typst-mark = trained.at("typst-mark", default: false)
  let labels = ()
  if trained.type == "discrete" {
    labels = trained
      .domain
      .enumerate()
      .map(((idx, level)) => (
        _resolve-tick(labels-cb, typst-mark, idx, level, level, typst-eval)
      ))
  } else if trained.type == "continuous" {
    labels = _axis-breaks(trained)
      .enumerate()
      .map(((idx, b)) => (
        _resolve-tick(
          labels-cb,
          typst-mark,
          idx,
          b,
          _axis-label(trained, b),
          typst-eval,
        )
      ))
  }
  if labels.len() == 0 { return _empty-extents(size) }
  measure-labels-cm(labels, size)
}

// Same as `_axis-label-extents` but for the secondary axis: each break is
// routed through the user's transformation before formatting. Returns zero
// extents when no secondary axis is configured.
#let _secondary-label-extents(trained, sec, size, typst-eval: false) = {
  if trained == none or sec == none { return (width: 0.0, height: 0.0) }
  if trained.type != "continuous" { return (width: 0.0, height: 0.0) }
  let labels-cb = _trained-labels-cb(trained)
  let typst-mark = trained.at("typst-mark", default: false)
  let labels = _axis-breaks(trained)
    .enumerate()
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
  measure-labels-cm(labels, size)
}

// Perpendicular extent of x-axis tick labels (cm). Inputs are the measured
// ink-bbox width and height of the longest label; rotating composes them
// trigonometrically, and `n-dodge > 1` adds the staggered rows.
#let _x-label-depth(angle, n-dodge, label-w-cm, label-h-cm) = {
  let a = calc.abs(angle) * 1deg
  label-w-cm * calc.sin(a) + label-h-cm * calc.cos(a) + (n-dodge - 1) * 0.35
}

// Perpendicular extent of y-axis tick labels (cm). At angle 0 the labels
// extend leftward by their full measured width; rotating swaps the extents
// according to the rotated bounding box, and `n-dodge > 1` adds dodge cols.
#let _y-label-width(angle, n-dodge, label-w-cm, label-h-cm) = {
  let a = calc.abs(angle) * 1deg
  label-w-cm * calc.cos(a) + label-h-cm * calc.sin(a) + (n-dodge - 1) * 0.5
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

// One-element tuple for stand-alone guides, so callers can iterate uniformly
// across stacks and singletons. Shared between x and y; placement on either
// axis flows through the same rendering path.
#let _axis-guide-rows(g) = if g.stack { g.guides } else { (g,) }

// Stack-aware variants: a `guide-axis-stack` carries multiple sub-guides
// rendered as separate label rows. Inter-row spacing is added once per gap
// between successive rows; non-stack guides degenerate to a single row.
#let _stacked-extent(g, per-row-fn) = {
  let rows = _axis-guide-rows(g)
  let spacing = if g.stack { g.spacing } else { 0 }
  rows.map(per-row-fn).sum() + (rows.len() - 1) * spacing
}
#let _x-label-depth-stack(g, w, h) = _stacked-extent(
  g,
  s => _x-label-depth(s.angle, s.n-dodge, w, h),
)
#let _y-label-width-stack(g, w, h) = _stacked-extent(
  g,
  s => _y-label-width(s.angle, s.n-dodge, w, h),
)

// Reserved extent between the panel and the canvas edge for the secondary
// axis ticks, labels, and title. `axis` selects orientation: `"y"` (right
// edge, label width) or `"x"` (top edge, label depth). Matches the primary
// formula so the title-to-label gap stays symmetric on opposing edges.
#let _sec-extent(sec, tick-len, sec-extents, ax-title, axis) = {
  if sec == none { return 0.0 }
  let label-extent = if axis == "y" {
    _y-label-width(0, 1, sec-extents.width, sec-extents.height)
  } else {
    _x-label-depth(0, 1, sec-extents.width, sec-extents.height)
  }
  let title-cm = if sec.at("name", default: none) != none {
    _ax-text-cm(ax-title.size)
  } else { 0.0 }
  let gap-side = if axis == "y" { "left" } else { "bottom" }
  let gap = _text-margin-cm(ax-title, gap-side, _AX-TITLE-LABEL-GAP)
  tick-len + 0.1 + label-extent + gap + title-cm + 0.05
}
