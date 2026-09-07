// Guide extraction and legend drawing.
//
// Per-aesthetic candidates are built first, then grouped: candidates that
// describe the same underlying scale (same column, type, levels/domain,
// labels and title) collapse into a single guide whose key glyph carries
// every merged aesthetic. Each guide carries a `placement` record (side,
// alignment, direction, byrow, order) that drives where it renders and how
// the swatch grid flows.

#import "../deps.typ": cetz
#import "../utils/extended.typ": extended
#import "../utils/format.typ": format-break
#import "../utils/colour.typ": (
  bin-edges, edge-midpoints, resolve-continuous-colour,
)
#import "../utils/palette.typ": spec-attr, spec-palette
#import "../utils/level-resolve.typ": resolve-level
#import "../utils/errors.typ": fail, fail-type
#import "../theme/defaults.typ": default-theme, resolve-colour
#import "../theme/theme.typ": (
  _line-stroke, _rect-outset-cm, _rect-style, _text-args, _text-style,
  _zero-margin-cm, resolve-geom-defaults, resolve-theme-palette,
)
#import "../guide/draw-key.typ": default-key-for, draw-glyph
#import "../guide/legend.typ": _normalise-position
#import "../utils/label-geometry.typ": _rotated-extent
#import "../guide/gctx.typ": gctx
#import "../guide/compose.typ": (
  compose-stack, draw as compose-draw, has-part, layout-of as compose-layout-of,
)
#import "../guide/grid.typ": (
  COL-GAP-MIN, column-widths, flat-rows, grid-shape, key-metrics, row-overflows,
  uniform-columns,
)
#import "../guide/gizmo/bar.typ": bar-lead, prim-bar
#import "../guide/primitive/content.typ": prim-content
#import "../guide/primitive/keys.typ": prim-keys
#import "../guide/primitive/spacer.typ": prim-spacer
#import "../guide/primitive/title.typ": prim-title
#import "../scale/train.typ": mapping-display-name
#import "../utils/typst-markup.typ": resolve-prose
#import "../utils/margin.typ": length-to-cm, opposite-side
#import "../utils/aes-resolve.typ": merge-mapping, resolve-label
#import "../utils/margin.typ": resolve-margin-side-cm

// Aesthetic emission order. `x` and `y` train but never produce a guide; the
// rest are emitted in this fixed order so merged guides land at the position
// of their earliest member.
#let _aesthetic-order = (
  "colour",
  "fill",
  "size",
  "alpha",
  "linewidth",
  "stroke",
  "shape",
  "linetype",
)

// Default placement when a candidate has no user override. Mirrors the
// defaults on `guide-legend()` / `guide-custom()`.
#let _default-placement = (
  side: "right",
  align: none,
  dx: 0pt,
  dy: 0pt,
  direction: "vertical",
  order: none,
  byrow: false,
)

// Layer `over`'s placement onto `base`, treating an `auto` side / direction as
// "inherit from `base`". Lets `guide-legend(position: auto)` fall through to a
// `guides(default: ...)` placement and then to the natural default. An `auto`
// position carries no positional information, so the inherited side, corner
// (`align`), and offsets (`dx` / `dy`) all come from `base`; a `direction`
// override still applies on its own.
//
// `order` inherits the same way: a placement built from a `position` alone
// always carries `order: none`, so spreading it over the layer below would drop
// an order that layer set. `byrow` cannot inherit, because its default `false`
// is indistinguishable from an explicit `false`, so the top layer keeps it.
#let _merge-placement(base, over) = {
  let direction = if over.at("direction", default: auto) == auto {
    base.direction
  } else { over.direction }
  let order = if over.at("order", default: none) == none {
    base.at("order", default: none)
  } else { over.order }
  if over.at("side", default: auto) == auto {
    (
      (
        ..base,
        ..over,
        side: base.side,
        align: base.align,
        dx: base.dx,
        dy: base.dy,
        direction: direction,
        order: order,
      )
    )
  } else {
    (..base, ..over, direction: direction, order: order)
  }
}

// Resolve placement: per-guide override over `guides(default: ...)` over
// `theme(legend-position:)` over the natural default. `auto` side / direction
// inherit from the layer below, so `guide-legend(ncolumn: 2)` still picks up a
// `default:` (or theme) side.
//
// Every guide resolves through here, scale-driven or not: a `guide-custom`
// block follows the side a theme or a `default:` sets exactly as a legend does.
#let _resolve-placement(override, default-guide, theme) = {
  let placement = _default-placement
  let theme-position = if theme != none {
    theme.at("legend-position", default: auto)
  } else { auto }
  if theme-position != auto {
    placement = _merge-placement(
      placement,
      _normalise-position(theme-position, auto, none, false),
    )
  }
  let default-placement = if default-guide != none {
    default-guide.at("placement", default: none)
  } else { none }
  if default-placement != none {
    placement = _merge-placement(placement, default-placement)
  }
  let override-placement = if override != none {
    override.at("placement", default: none)
  } else { none }
  if override-placement != none {
    placement = _merge-placement(placement, override-placement)
  }
  let resolved-direction = if placement.direction == auto {
    if placement.side == "top" or placement.side == "bottom" {
      "horizontal"
    } else { "vertical" }
  } else { placement.direction }
  (..placement, direction: resolved-direction)
}

// Equality key for placement comparisons. Two candidates with different keys
// never merge into a single guide.
#let _placement-key(placement) = (
  placement.side,
  placement.align,
  placement.direction,
  placement.order,
  placement.byrow,
)

#let _guide-title(t, spec, aes-name) = {
  // `labels(colour: none)` sets `spec.blank` to suppress the legend title and
  // collapse the space it would reserve.
  if spec-attr(t, "blank", fallback: false) {
    return none
  }
  let from-scale = spec-attr(t, "name")
  if from-scale != none {
    from-scale
  } else if spec.mapping != none {
    mapping-display-name(spec.mapping.at(aes-name, default: aes-name))
  } else {
    aes-name
  }
}

// Grid shape for a guide laying `count` keys out under its `nrow`/`ncolumn` and
// flow direction. Shared by every swatch and size-ladder layout site so the
// width estimate, height estimate, and draw all agree on the grid.
#let _guide-shape(g, count) = grid-shape(
  count,
  g.nrow,
  g.ncolumn,
  g.placement.direction,
)

// Geom-driven fallback priority: when no aesthetic-driven rule applies,
// points dominate paths dominate lines dominate rects, so the swatch
// reflects the most distinctive mark drawn for the merged group.
#let _key-priority(key) = {
  if key == "point" { return 4 }
  if key == "path" { return 3 }
  if key == "line" { return 2 }
  if key == "rect" { return 1 }
  0
}

// Geoms that genuinely consume `fill`. Other geoms inherit it through plot
// mapping but don't draw anything filled, so they should not steer the legend
// glyph. Pure stroke geoms still consume `colour`.
#let _geom-uses-fill(geom) = (
  "col",
  "bar",
  "histogram",
  "rect",
  "tile",
  "area",
  "ribbon",
  "polygon",
  "boxplot",
  "violin",
  "density-ridges",
  "crossbar",
  "smooth",
  "point",
  "label",
).contains(geom)

// Aesthetics that only render meaningfully on certain geoms. `none` means no
// structural restriction (the layer contributes if it maps the aesthetic).
#let _geom-uses-aesthetic(geom, aes-name) = {
  if aes-name == "fill" { return _geom-uses-fill(geom) }
  if aes-name == "shape" { return geom == "point" or geom == "jitter" }
  if aes-name == "stroke" { return geom == "point" or geom == "jitter" }
  if aes-name == "linetype" or aes-name == "linewidth" {
    return not (
      "col",
      "bar",
      "histogram",
      "rect",
      "tile",
      "area",
      "ribbon",
      "polygon",
      "label",
    ).contains(geom)
  }
  true
}

#let _layer-pins(layer, aes-name) = {
  let v = layer.params.at(aes-name, default: auto)
  v != auto
}


// Layers that contribute to the guide for `aes-name`: those whose merged
// mapping consumes the aesthetic, that match the structural eligibility for
// the geom, and that do not pin the aesthetic locally.
#let _mapped-contributors(spec, aes-name) = {
  let layers = spec.at("layers", default: ())
  let plot-mapping = spec.at("mapping", default: none)
  let out = ()
  for layer in layers {
    let merged = merge-mapping(layer, plot-mapping)
    if merged == none { continue }
    if merged.at(aes-name, default: none) == none { continue }
    let geom = layer.at("name", default: "")
    if not _geom-uses-aesthetic(geom, aes-name) { continue }
    if _layer-pins(layer, aes-name) { continue }
    out.push(layer)
  }
  out
}

// Resolve the column name driving an aesthetic: read from any contributor's
// merged mapping; they all agree because the scale was trained from them.
#let _column-for(spec, aes-name) = {
  let plot-mapping = spec.at("mapping", default: none)
  for layer in spec.at("layers", default: ()) {
    let merged = merge-mapping(layer, plot-mapping)
    if merged == none { continue }
    let raw = merged.at(aes-name, default: none)
    if raw != none { return mapping-display-name(raw) }
  }
  none
}

// True when both candidates describe the same underlying scale and so should
// collapse into a single merged guide. See plan §1 for the predicate.
#let _can-merge(a, b) = {
  if a.column != b.column { return false }
  if a.column == none { return false }
  if a.t.type != b.t.type { return false }
  if a.title != b.title { return false }
  if a.align != b.align { return false }
  if a.nrow != b.nrow { return false }
  if a.ncolumn != b.ncolumn { return false }
  if a.reverse != b.reverse { return false }
  if _placement-key(a.placement) != _placement-key(b.placement) { return false }
  if a.t.type == "discrete" {
    if a.levels != b.levels { return false }
    if a.labels != b.labels { return false }
    return true
  }
  if a.domain != b.domain { return false }
  if a.transform != b.transform { return false }
  if a.temporal != b.temporal { return false }
  true
}

// Cross-panel merge predicate used by `compose()` on the final guide dicts
// returned by `guides-for`. Two guides are equivalent across panels when they
// share kind, title, aesthetic mix, and the user-visible content (levels +
// labels for swatches; domain + breaks + labels for ladders and colourbars).
// Placement and per-panel grid shape (`nrow`/`ncolumn`) are deliberately ignored
// because compose forces a single shared side and grid shape on its own.
// Custom guides never hoist (no scale to compare).
#let can-merge-cross-panel(a, b) = {
  if a.kind != b.kind { return false }
  if a.kind == "custom" { return false }
  if a.title != b.title { return false }
  if a.at("align", default: none) != b.at("align", default: none) {
    return false
  }
  if a.aesthetics != b.aesthetics { return false }
  if a.kind == "swatch" {
    return a.levels == b.levels and a.labels == b.labels
  }
  a.domain == b.domain and a.breaks == b.breaks and a.labels == b.labels
}

// Pass-A precedence: aesthetic-driven first, geom fallback last. See plan §2.
#let _key-kind-for-group(members) = {
  let aesthetics = members.map(c => c.aes)
  let has = aes-name => aesthetics.contains(aes-name)

  let prefers-path = members.any(c => c.contributors.any(layer => {
    let key-override = layer.at("key", default: auto)
    (
      key-override != auto
        and key-override != none
        and key-override.name == "path"
    )
  }))

  if has("shape") { return "point" }
  if has("linetype") {
    return if prefers-path { "path" } else { "line" }
  }
  if has("linewidth") {
    return if prefers-path { "path" } else { "line" }
  }
  if has("size") { return "point" }
  if has("stroke") { return "point" }

  let best = "rect"
  let best-prio = 0
  for c in members {
    for layer in c.contributors {
      let geom = layer.at("name", default: "")
      let key-override = layer.at("key", default: auto)
      let candidate = if key-override != auto and key-override != none {
        key-override.name
      } else {
        default-key-for(geom)
      }
      let prio = _key-priority(candidate)
      if prio > best-prio {
        best = candidate
        best-prio = prio
      }
    }
  }
  best
}

#let _candidate(spec, trained, overrides, aes-name, theme: none) = {
  let t = trained.at(aes-name, default: none)
  if t == none { return none }
  if t.type == "identity" { return none }
  let override = overrides.at(aes-name, default: none)
  let default-guide = overrides.at("default", default: none)
  if override != none and override.at("suppress", default: false) {
    return none
  }
  // `guides(default: none)` hides every legend that has no override of
  // its own.
  if (
    override == none
      and default-guide != none
      and default-guide.at("suppress", default: false)
  ) {
    return none
  }

  let placement = _resolve-placement(override, default-guide, theme)
  if placement.side == "none" { return none }

  let contributors = _mapped-contributors(spec, aes-name)
  if contributors.len() == 0 { return none }

  // Per-aesthetic override wins, then `guides(default: ...)`, then the value
  // trained from the scale / labels.
  let _pick(name, fallback) = if (
    override != none and override.at(name, default: none) != none
  ) {
    override.at(name)
  } else if (
    default-guide != none and default-guide.at(name, default: none) != none
  ) {
    default-guide.at(name)
  } else { fallback }

  let title = _guide-title(t, spec, aes-name)
  let title-override = _pick("title", none)
  if title-override != none { title = title-override }
  let nrow = _pick("nrow", none)
  let ncolumn = _pick("ncolumn", none)
  let reverse = _pick("reverse", false)
  let align = _pick("align", none)
  let key-size = _pick("key-size", none)

  let cand = (
    aes: aes-name,
    t: t,
    title: title,
    nrow: nrow,
    ncolumn: ncolumn,
    reverse: reverse,
    align: align,
    key-size: key-size,
    placement: placement,
    contributors: contributors,
    column: _column-for(spec, aes-name),
    typst-mark: t.at("typst-mark", default: false),
  )

  if t.type == "discrete" {
    let levels = t.domain
    // A scale with no levels has no key to draw, so it is not a guide. The
    // domain is empty when the user pins `limits: ()`, or when every value in
    // the mapped column is `none` or empty, which `_discrete-domain-from-cache`
    // skips. Letting it through reserves a box holding a title and nothing
    // else.
    if levels.len() == 0 { return none }
    let labels = spec-attr(t, "labels", fallback: auto)
    cand.insert("levels", levels)
    cand.insert("labels", labels)
  } else {
    cand.insert("domain", t.domain)
    cand.insert("transform", t.at("transform", default: "identity"))
    cand.insert("temporal", t.at("temporal", default: none))
  }
  cand
}

// Extract user-labels, binned-flag, and n-breaks from a trained scale's spec.
// Returns sane defaults when the spec is absent (auto-defaulted scales).
#let _bin-info(t, default-n: 5) = {
  let spec = t.at("spec", default: none)
  if spec == none {
    return (labels: auto, binned: false, n-breaks: default-n, breaks: auto)
  }
  let breaks = spec.at("breaks", default: auto)
  if breaks != auto and type(breaks) != array { breaks = (breaks,) }
  (
    labels: spec.at("labels", default: auto),
    binned: spec.at("binned", default: false),
    n-breaks: spec.at("n-breaks", default: default-n),
    breaks: breaks,
  )
}

// Convert a `text(size:)` value in pt to its cap-height extent in cm,
// matching `_ax-text-cm` in render.typ.
#let _font-cm(size-pt) = size-pt * 0.0353

// Glyph diameter used by _draw-swatch and _draw-size-ladder. Kept in
// sync with their hardcoded glyph-size value so reserved width matches
// drawn width.
#let _GLYPH-DIAMETER-CM = 0.24

// Lead before the first label character: glyph diameter + half-em gap.
#let _swatch-lead-cm(diam, size-pt) = diam + _font-cm(size-pt) * 0.5
#let _ladder-lead-cm(size-pt) = _GLYPH-DIAMETER-CM + _font-cm(size-pt) * 0.8

// Slack past the measured ink so a label never sits flush against whatever
// the layout puts next to it.
#let _LABEL-SLACK-CM = 0.05

// Ink box (cm) of a label as the legend draws it: measured through the whole
// resolved surface, so the weight, the font, and a plain string evaluated as
// markup under an `element-typst` surface all reach the reservation the way
// they reach `cetz.draw.content`. `measure()` needs a `context`, which every
// caller is already inside. Empty / `none` labels report zero. A `typst-mark`
// label reaches here as content, already converted by `resolve-label`; a plain
// string reaches here as a string and is evaluated against its own surface, so
// measurement and draw agree on what the markup renders to.
#let _label-extents(label, style) = {
  if label == none or label == "" { return (width: 0.0, height: 0.0) }
  let m = measure(
    text(.._text-args(style))[#resolve-prose(label, eval-strings: style.typst)],
  )
  (width: m.width / 1cm, height: m.height / 1cm)
}

// Label width in cm on the given surface. The full label width is reserved so
// a long label widens its column instead of overflowing into the next swatch.
#let _label-width(label, style) = {
  let e = _label-extents(label, style)
  if e.width == 0.0 { 0.0 } else { e.width + _LABEL-SLACK-CM }
}

// The label a size-ladder / colourbar break draws (custom `labels:` resolved
// against the break value, falling back to its formatted number).
#let _break-label(g, value, i) = resolve-label(
  g.at("labels", default: auto),
  value,
  i,
  format-break(value),
  typst-mark: g.at("typst-mark", default: false),
)

// The largest of a list of cm, or zero for an empty one. Every band a legend
// reserves is the widest or tallest of something, so the fold lives once.
#let _largest(values) = {
  let max-v = 0.0
  for v in values {
    if v > max-v { max-v = v }
  }
  max-v
}

// Box (cm) the largest break label across `breaks` occupies on the entry-label
// surface, turned by the surface `angle` the draw applies, as `_title-box`
// already turns a title.
//
// Both axes are composed, because a turned label presents its height to the
// flank a vertical colour bar reserves and its width to the band a horizontal
// one reserves. The widest and the tallest need not be the same label, so each
// axis takes its own largest.
//
// The slack a label is given past its ink is carried on both axes here, so a
// caller reserves the box it can spend rather than a bare ink extent.
#let _max-break-label-box(g, breaks, style) = {
  let angle = if style.angle != none { style.angle / 1deg } else { 0 }
  let width = 0.0
  let height = 0.0
  for (i, b) in breaks.enumerate() {
    let e = _label-extents(_break-label(g, b, i), style)
    if e.width == 0.0 and e.height == 0.0 { continue }
    let turned = _rotated-extent(e.width, e.height, angle)
    if turned.width > width { width = turned.width }
    if turned.height > height { height = turned.height }
  }
  if width == 0.0 and height == 0.0 { return (width: 0.0, height: 0.0) }
  (width: width + _LABEL-SLACK-CM, height: height + _LABEL-SLACK-CM)
}

// The `legend-title` surface every title metric resolves against. A theme-less
// caller (unit tests) falls back to the merged defaults.
#let _legend-title-style(theme) = _text-style(
  if theme == none { default-theme } else { theme },
  "legend-title",
)

// The `legend-text` surface the entry labels are measured and drawn on, with
// the same theme-less fallback.
#let _legend-text-style(theme) = _text-style(
  if theme == none { default-theme } else { theme },
  "legend-text",
)

// Box (cm) the title occupies, turned by the surface `angle` the draw applies.
// A quarter-turned title presents its height to the guide width and its width
// to the title band, so both axes are composed rather than the upright one.
// The turn is the one the axis labels take, solved by `_rotated-extent`, which
// takes its angle in degrees.
#let _title-box(g, style) = {
  let e = _label-extents(g.at("title", default: none), style)
  if e.width == 0.0 and e.height == 0.0 { return (width: 0.0, height: 0.0) }
  let turned = _rotated-extent(
    e.width,
    e.height,
    if style.angle != none { style.angle / 1deg } else { 0 },
  )
  (width: turned.width + _LABEL-SLACK-CM, height: turned.height)
}

// Vertical band the legend title occupies: the `legend-title` bottom margin,
// which is the gap the draw lays the first entry out below, grown to the drawn
// title's own height whenever the surface turns it past that gap. `title-h` is
// the measured box from `_title-box`, which the caller also spends on the guide
// width, so the title is measured once for the two of them.
#let _legend-title-h(style, title-h) = calc.max(
  resolve-margin-side-cm(
    style.margin.bottom,
    1.6em,
    size-pt: style.size / 1pt,
  ),
  title-h,
)

// The label a swatch cell draws (custom `labels:` resolved against the level,
// falling back to the level itself), as measured for sizing.
#let _swatch-label(guide, i) = resolve-label(
  guide.at("labels", default: auto),
  guide.levels.at(i),
  i,
  guide.levels.at(i),
  typst-mark: guide.at("typst-mark", default: false),
)

// Default footprint (cm) for `guide-custom` when the user did not supply an
// explicit length. Two columns wide so it sits next to the standard legends
// without forcing the page to grow.
#let _CUSTOM-DEFAULT-WIDTH = 3.0
#let _CUSTOM-DEFAULT-HEIGHT = 2.0

// Resolve a `guide-custom` width or height field to a cm float. Accepts a
// length or `auto`; anything else panics so user typos surface loudly.
#let _custom-dim-cm(value, fallback) = {
  if value == auto { return fallback }
  if type(value) == length { return length-to-cm(value, 0) }
  fail-type("guide-custom", "width/height", value, "a length or `auto`")
}

// Per-line vertical extent of swatch / ladder rows: cap-height plus a
// half-em of breathing. Returned as a cm float at the supplied font size.
#let _swatch-line-h-cm(size-pt) = _font-cm(size-pt) * 1.4
#let _ladder-line-h-cm(size-pt) = _font-cm(size-pt) * 1.55

// Tight slack below the last row so the glyph isn't flush with the rect edge.
#let _glyph-bottom-slack(size-pt) = _font-cm(size-pt) * 0.2

// Swatch row stride: the font line height, grown so a glyph wider than the
// line never overlaps the row below (matches the size-ladder stride).
#let _swatch-stride-cm(diam, size-pt) = calc.max(
  _swatch-line-h-cm(size-pt),
  diam + _glyph-bottom-slack(size-pt),
)

// Nominal half-extent (cm) for a ladder key glyph, used to place and size the
// fallback glyph and as the per-row centring offset. The drawn `point` key may
// override its radius from the resolved `size` aesthetic (see `_ladder-key-diam-cm`).
#let _LADDER-GLYPH-CM = 0.16

// Largest key-glyph diameter (cm) a size ladder will draw. The `size` channel
// resolves each break to a marker radius that can far exceed the fixed swatch
// glyph, so the row stride and reserved height must follow it. `size-trained`
// is the group's `size` scale (or `none` for an alpha/linewidth/stroke ladder);
// a non-point key keeps the fixed glyph. The ladder glyph encodes the `size`
// scale, so it floors at the fixed swatch diameter and ignores the themed key
// size / `key-size` override.
#let _ladder-key-diam-cm(size-trained, breaks, key-kind) = {
  if key-kind != "point" or size-trained == none {
    return _GLYPH-DIAMETER-CM
  }
  let max-r = 0.0
  for b in breaks {
    let r = resolve-level("size", size-trained, b)
    if type(r) != length { continue }
    let r-cm = length-to-cm(r, 0)
    if r-cm > max-r { max-r = r-cm }
  }
  calc.max(_GLYPH-DIAMETER-CM, 2 * max-r)
}

// Resolve a swatch key glyph diameter (cm). A per-legend `key-size` length
// wins; otherwise the themed `base-cm`.
#let _swatch-key-diam-cm(key-size, base-cm) = {
  if type(key-size) == length { length-to-cm(key-size, 0) } else { base-cm }
}

// Number of rendered lines in a label, resolved on its own surface first so an
// `element-typst` string is counted as the markup it renders to. A plain string
// stays on one line; content is measured against a single-line sample and
// rounded, so a `\`-broken two-line label reports two. At least one line so
// every item reserves a row.
#let _label-lines(label, style) = {
  let resolved = resolve-prose(label, eval-strings: style.typst)
  if resolved == none or resolved == "" or type(resolved) == str { return 1 }
  let args = _text-args(style)
  let one = measure(text(..args)[x]).height
  if one == 0pt { return 1 }
  let h = measure(text(..args)[#resolved]).height
  calc.max(1, calc.round(h / one))
}

#let _LADDER-H-COL-H = 0.32
#let _LADDER-H-LABEL-H = 0.4
#let _COLOURBAR-V-W = 0.35
#let _COLOURBAR-V-H = 3.0
#let _COLOURBAR-H-W = 3.0
#let _COLOURBAR-H-H = 0.35
#let _COLOURBAR-PAD-V = 0.3
// Room between a colour bar and its tick labels, read from the same `bar-lead`
// the draw places them with, so the reservation cannot say one thing while the
// draw does another.
//
// Both directions read it. A vertical bar spends it across its flank and a
// horizontal one down its band, and what sits past it either way is the turned
// label box from `_max-break-label-box`.
#let _COLOURBAR-LABEL-LEAD = bar-lead(gctx("right", "legend"))

// Resolve the displayed break positions for a continuous guide: keep the
// explicit in-domain breaks when the scale supplies them, otherwise fall back
// to `computed` (the binned edges/midpoints or `pretty` ticks).
#let _guide-breaks(info, lo, hi, computed) = {
  if info.breaks == auto { return computed }
  let kept = info.breaks.filter(b => (
    b >= calc.min(lo, hi) and b <= calc.max(lo, hi)
  ))
  if kept.len() > 0 { kept } else { computed }
}

// Read back a colourbar guide's resolved breaks (stored by `guides-for`),
// falling back to `extended` over the domain only when none were stored.
#let _colourbar-breaks(g) = {
  let breaks = g.at("breaks", default: none)
  if breaks != none { return breaks }
  let (lo, hi) = g.domain
  extended(lo, hi, m: 5)
}

// Horizontal size-ladder glyph band height (cm), shared by the height estimate
// and the draw so the reserved column never drifts from the drawn glyph.
#let _ladder-h-band(guide) = calc.max(
  _LADDER-H-COL-H,
  guide.at("key-diam-cm", default: _GLYPH-DIAMETER-CM),
)

// Width (cm) of one horizontal size-ladder column, shared by the width estimate
// and the draw. A wider `size` channel grows the glyph band, so the column must
// clear the band as well as the label.
#let _ladder-h-col-w(guide, label-w, size-pt) = {
  let lead = _ladder-lead-cm(size-pt)
  if guide.at("key-diam-cm", default: _GLYPH-DIAMETER-CM) > _GLYPH-DIAMETER-CM {
    calc.max(lead, label-w, _ladder-h-band(guide) + 0.1)
  } else { calc.max(lead, label-w) }
}

// The guide kinds built from primitives, which carry a laid-out stack and read
// their box off it. Every kind is one now, so a guide that is not on this list
// is a typo rather than a guide the renderer still sizes itself.
// Vertical size-ladder row metrics, shared by the height estimate and the draw
// so the reserved space matches the drawn glyphs. When the resolved key glyph
// stays within the fixed swatch diameter the values reproduce the original
// layout exactly; a larger `size` channel grows the stride, the centring offset
// (half the glyph), and the last-row reservation so big glyphs never overlap.
#let _ladder-vmetrics(guide, size-pt) = {
  let glyph-diam = guide.at("key-diam-cm", default: _GLYPH-DIAMETER-CM)
  let base = _ladder-line-h-cm(size-pt)
  if glyph-diam <= _GLYPH-DIAMETER-CM {
    return (line-h: base, off: _LADDER-GLYPH-CM, last: _GLYPH-DIAMETER-CM)
  }
  (
    line-h: calc.max(base, glyph-diam + _glyph-bottom-slack(size-pt)),
    off: glyph-diam / 2,
    last: glyph-diam,
  )
}

// Resolve the horizontal alignment for a guide's entry labels: a per-guide
// `align` (from `guide-legend(align:)`) wins, then the `legend-text` theme
// align, then the per-direction default (horizontal centres labels, vertical
// keeps them left). Returns a Typst alignment (`left` / `center` / `right`).
#let _label-align(guide, theme-align) = {
  let a = guide.at("align", default: none)
  if a == none { a = theme-align }
  if a == none {
    a = if guide.placement.direction == "horizontal" { center } else { left }
  }
  a
}

// The title's effective alignment with the `none -> left` default applied: a
// per-guide `align` (from `guide-legend(align:)`) wins over the `legend-title`
// theme align. The key graphic of a horizontal legend is justified by the same
// value so the two always share a centre.
//
// `style` is the resolved `legend-title` surface rather than the theme, because
// the sizing pass reads it as well and runs with no theme at all under a
// theme-less caller.
#let _title-resolved-align(guide, style) = {
  let a = guide.at("align", default: none)
  if a == none { a = style.align }
  if a == none { left } else { a }
}

// Lead past a key glyph before the label beside it, which is not the lead the
// column reserves. The two have differed since before the guide layer;
// `key-metrics` carries both rather than reconciling them, because reconciling
// them moves every legend.
#let _KEY-LABEL-LEAD = 0.15

// One row of a key grid, carrying the label it shows and the geometry that
// label was measured at. Measurement happens here because the theme and the
// Typst measurement context live here; the grid reads the numbers back.
#let _key-entry(value, label, style) = (
  value: value,
  label: label,
  // The reserved width, not the raw ink: a label is given slack so it never
  // sits flush against the next column.
  width: _label-width(label, style),
  lines: _label-lines(label, style),
)

// The entry table a swatch grid draws: one row per level.
#let _swatch-entries(g, style) = (
  g
    .levels
    .enumerate()
    .map(((i, level)) => (
      _key-entry(level, _swatch-label(g, i), style)
    ))
)

// The entry table a size ladder draws: one row per break.
#let _ladder-entries(g, style) = (
  g
    .breaks
    .enumerate()
    .map(((i, value)) => (
      _key-entry(value, _break-label(g, value, i), style)
    ))
)

// The title a legend box stacks above its keys, or nothing when the guide has
// none. Shared by every box that carries one.
#let _box-title(g, title-style, title-w, title-h) = {
  if g.title == none { return () }
  (
    prim-title(
      g.title,
      align: g.at("align", default: none),
      // The band the theme resolved, not the raw text box: a surface that turns
      // its title, or grows the gap below it, grows this with it.
      extent: (title-w, title-h),
      angle: if title-style.angle != none { title-style.angle / 1deg } else {
        0
      },
    ),
  )
}

// How a legend box justifies its key grid: a horizontal one shares the title's
// centre or edge, a vertical one keeps its left edge.
#let _grid-justify(g, title-style) = if (
  g.placement.direction == "horizontal"
) { _title-resolved-align(g, title-style) } else { none }

// The stack a swatch guide is: its title above its key grid. Each column sizes
// to its own widest label, so one long level does not pad the rest.
#let _swatch-node(g, style, title-style, title-w, title-h) = {
  let size-pt = style.size / 1pt
  let diam = g.key-diam-cm
  let entries = _swatch-entries(g, style)
  let shape = _guide-shape(g, g.levels.len())
  let line-h = _swatch-stride-cm(diam, size-pt)
  // One lead serves the metric and the column sizing: the room a column
  // reserves before its label is the room the metric spends on the glyph.
  let lead = _swatch-lead-cm(diam, size-pt)
  compose-stack(
    .._box-title(g, title-style, title-w, title-h),
    prim-keys(
      entries: entries,
      shape: shape,
      byrow: g.placement.byrow,
      key: g.at("key", default: "rect"),
      metrics: key-metrics(
        off: diam / 2,
        last: diam,
        line-h: line-h,
        slack: _glyph-bottom-slack(size-pt),
        lead: lead,
        label-lead: diam + _KEY-LABEL-LEAD,
      ),
      columns: column-widths(
        entries.len(),
        i => entries.at(i).width,
        shape,
        g.placement.byrow,
        lead,
      ),
      rows: row-overflows(
        entries.len(),
        i => (entries.at(i).lines - 1) * line-h,
        shape,
        g.placement.byrow,
      ),
      angle: if style.angle != none { style.angle / 1deg } else { 0 },
      label-align: _label-align(g, style.align),
      justify: _grid-justify(g, title-style),
    ),
    // The title band already carries the gap below the title, so the parts sit
    // flush.
    spacing: 0.0,
  )
}

// Drop below a horizontal ladder's glyph band before its label.
#let _LADDER-H-LABEL-DROP = 0.1

// The widest label in a table, which is what a size ladder sizes every column
// to, against the swatch, which sizes each column to its own.
#let _widest(entries) = _largest(entries.map(e => e.width))

// The tallest multi-line overflow across a table, which a horizontal ladder
// folds into a stride uniform across its rows rather than stacking per row.
#let _tallest-overflow(entries, line-h) = _largest(
  entries.map(e => (e.lines - 1) * line-h),
)

// The stack a size-ladder guide is: its title above its key grid.
//
// The two directions are the same grid under different metrics. A vertical
// ladder reads like a swatch, except that every column takes the widest label
// in the guide and the glyph follows the `size` scale, so its centring offset
// and its last row are their own numbers rather than half and all of a fixed
// diameter. A horizontal one puts its label under its glyph, packs its columns
// edge to edge, and gives every row one stride with the tallest label already
// in it.
#let _ladder-node(g, style, title-style, title-w, title-h) = {
  let size-pt = style.size / 1pt
  let entries = _ladder-entries(g, style)
  let shape = _guide-shape(g, g.breaks.len())
  let byrow = g.placement.byrow
  let label-w = _widest(entries)
  let horizontal = g.placement.direction == "horizontal"
  let glyph-diam = g.at("key-diam-cm", default: _GLYPH-DIAMETER-CM)
  let grows = glyph-diam > _GLYPH-DIAMETER-CM
  let band = _ladder-h-band(g)
  let vm = _ladder-vmetrics(g, size-pt)
  let stride = if horizontal {
    let overflow = _tallest-overflow(entries, _swatch-line-h-cm(size-pt))
    band + _LADDER-H-LABEL-H + overflow
  } else { vm.line-h }
  let lead = _ladder-lead-cm(size-pt)
  compose-stack(
    .._box-title(g, title-style, title-w, title-h),
    prim-keys(
      entries: entries,
      shape: shape,
      byrow: byrow,
      key: g.at("key", default: "point"),
      metrics: if horizontal {
        key-metrics(
          off: if grows { band / 2 } else { _LADDER-GLYPH-CM },
          // The glyph hangs a full band down, or twice its own radius when the
          // band is the fixed one, which is where it has always been drawn.
          drop: if grows { band / 2 } else { _LADDER-GLYPH-CM * 2 },
          // A uniform row spends its whole stride, so the last row reserves one
          // too and there is no slack under it.
          last: stride,
          line-h: stride,
          label-drop: (
            if grows { band } else { _LADDER-GLYPH-CM * 3 }
          )
            + _LADDER-H-LABEL-DROP,
        )
      } else {
        key-metrics(
          off: vm.off,
          last: vm.last,
          line-h: stride,
          slack: _glyph-bottom-slack(size-pt),
          lead: lead,
          label-lead: vm.off * 2 + _KEY-LABEL-LEAD,
        )
      },
      columns: if horizontal {
        uniform-columns(shape.cols, _ladder-h-col-w(g, label-w, size-pt))
      } else {
        uniform-columns(shape.cols, lead + label-w, gap: COL-GAP-MIN)
      },
      rows: if horizontal { flat-rows(shape.rows) } else {
        row-overflows(
          entries.len(),
          i => (entries.at(i).lines - 1) * stride,
          shape,
          byrow,
        )
      },
      flow: if horizontal { "below" } else { "right" },
      angle: if style.angle != none { style.angle / 1deg } else { 0 },
      label-align: _label-align(g, style.align),
      justify: _grid-justify(g, title-style),
    ),
    spacing: 0.0,
  )
}

// The entry table a colour bar ticks: one row per break that lands inside the
// domain, at the fraction of the strip it marks.
//
// A degenerate domain marks nothing, which is what the draw has always done
// rather than dividing by a zero span.
#let _colourbar-entries(g, breaks) = {
  let (lo, hi) = g.domain
  if hi == lo { return () }
  let rows = ()
  for (i, b) in breaks.enumerate() {
    let frac = (b - lo) / (hi - lo)
    if frac < 0 or frac > 1 { continue }
    rows.push((
      value: b,
      frac: frac,
      label: _break-label(g, b, i),
      tier: "major",
    ))
  }
  rows
}

// The stack a colour-bar guide is: its title above its strip.
//
// The strip is one primitive rather than a stack of them, because the flank of
// a vertical bar reads across the guide while the guide stacks down it. The
// room past the strip is reserved here, and each direction spends the same two
// terms on its own axes: the lead the draw places a label at, and the box that
// label was measured to occupy.
#let _colourbar-node(g, style, title-style, title-w, title-h) = {
  let horizontal = g.placement.direction == "horizontal"
  let breaks = _colourbar-breaks(g)
  let label = _max-break-label-box(g, breaks, style)
  compose-stack(
    .._box-title(g, title-style, title-w, title-h),
    prim-bar(
      entries: _colourbar-entries(g, breaks),
      direction: g.placement.direction,
      bar: if horizontal {
        (_COLOURBAR-H-W, _COLOURBAR-H-H)
      } else { (_COLOURBAR-V-W, _COLOURBAR-V-H) },
      band: if horizontal {
        _COLOURBAR-LABEL-LEAD + label.height
      } else { _COLOURBAR-PAD-V },
      label-reserve: if horizontal { label.width } else {
        _COLOURBAR-LABEL-LEAD + label.width
      },
      label-w: label.width,
      angle: if style.angle != none { style.angle / 1deg } else { 0 },
      label-align: _label-align(g, style.align),
      justify: _grid-justify(g, title-style),
    ),
    spacing: 0.0,
  )
}

// Slack below a custom block, so its content is not flush with the edge of the
// slot the legend gave it.
#let _CUSTOM-PAD-V = 0.2

// The stack a custom guide is: its title, its block, and that slack. The guide
// carries it so the sizing pass and the draw read one layout.
//
// The context stacks downward: a legend box puts its title above its block
// whichever side the box itself sits on, which is why `axes` comes from here
// rather than from the side.
#let _custom-node(g, title-style, title-w, title-h) = compose-stack(
  .._box-title(g, title-style, title-w, title-h),
  prim-content(g.content, width: g.cm-width, height: g.cm-height),
  prim-spacer(_CUSTOM-PAD-V),
  // The parts of a custom block sit flush; the slack is the trailing spacer.
  spacing: 0.0,
)

// Which builder makes the stack each guide kind is. Adding a guide is a builder
// and a row here; everything that sizes, places or draws one reads the record
// that stack laid out instead of the kind it came from.
//
// A custom block carries no entry labels, so it takes no entry text style,
// which is the one signature the table has to bridge.
#let _NODE-BUILDERS = (
  swatch: _swatch-node,
  "size-ladder": _ladder-node,
  colourbar: _colourbar-node,
  custom: (g, style, title-style, title-w, title-h) => _custom-node(
    g,
    title-style,
    title-w,
    title-h,
  ),
)

// A legend box is laid out in a box of its own, not against a panel edge, so
// its context carries only the orientation the stack needs.
// The side is nominal: a legend box stacks downward whichever side it lands on,
// which is what the context gives a legend by default.
//
// The aesthetic decides the theme surfaces, and every legend box paints on the
// legend ones, so the name here only has to be one no axis answers to.
#let _LEGEND-GCTX = gctx("right", "legend")

// The layout a guide reserves and draws from. Built once per guide in
// `_stamp-sizes` and read back by both, so the two cannot drift.
//
// `span` is left unset: a measurement never asks where a point lands, and the
// span is the width this record is about to decide.
#let _stack-layout(node) = (
  node: node,
  layout: compose-layout-of(node, _LEGEND-GCTX),
)

// Stamp the cm a guide occupies on the surfaces `theme` paints it with: its
// width, the `legend-title` band above its first key, and the height of the
// whole box. Every consumer reads these back rather than measuring again, so a
// guide is stamped wherever the theme it is drawn under is settled.
//
// The band and the stack both feed the width and the height, so they are
// stamped first and in that order.
#let _stamp-sizes(g, theme) = {
  let text-style = _legend-text-style(theme)
  let title-style = _legend-title-style(theme)
  // The guide width has to clear the title, and the band above the first key is
  // the title's own height, so the one box serves both and is measured once.
  let title = _title-box(g, title-style)
  let out = g
  out.insert("title-h", _legend-title-h(title-style, title.height))
  // The one place a guide kind decides anything: which builder makes its
  // stack. Everything downstream reads the record that stack laid out, so a new
  // kind is a builder and an entry here rather than an arm at every site that
  // sizes, places or draws a guide.
  if type(out.kind) != str or out.kind not in _NODE-BUILDERS {
    fail("legend._stamp-sizes", "unknown guide kind " + repr(out.kind))
  }
  let node = (_NODE-BUILDERS.at(out.kind))(
    out,
    text-style,
    title-style,
    title.width,
    out.title-h,
  )
  out.insert("stack", _stack-layout(node))
  // The width is the wider of the title and whatever the guide puts under it,
  // and the height is the whole box; both come off that one layout, so the room
  // the sizing pass reserves is the room the draw consumes.
  out.insert("width", out.stack.layout.along)
  out.insert("height", out.stack.layout.across)
  out
}

// Whether a guide paints a colour bar, read off the stack it was laid out as.
// The chrome stage reserves the `legend-bar` outset for one, and asks this
// rather than testing the kind, so a new guide that paints a bar is reserved
// for by building one.
#let paints-bar(g) = has-part(g.stack.node, "bar")

#let guides-for(
  spec,
  trained,
  key-diam-cm: _GLYPH-DIAMETER-CM,
  theme: none,
) = {
  let overrides = spec.at("guides", default: (:))

  let candidates = ()
  for aes-name in _aesthetic-order {
    let cand = _candidate(spec, trained, overrides, aes-name, theme: theme)
    if cand != none { candidates.push(cand) }
  }

  let groups = ()
  for cand in candidates {
    let placed = false
    let i = 0
    while i < groups.len() and not placed {
      let grp = groups.at(i)
      if _can-merge(cand, grp.members.first()) {
        grp.members.push(cand)
        groups.at(i) = grp
        placed = true
      }
      i += 1
    }
    if not placed { groups.push((members: (cand,))) }
  }

  let guides = ()
  for grp in groups {
    let members = grp.members
    let first = members.first()
    let aesthetics = members.map(c => c.aes)
    let key-kind = _key-kind-for-group(members)

    let typst-mark = members.any(m => m.at("typst-mark", default: false))
    let g = if first.t.type == "discrete" {
      let levels = first.levels
      if first.reverse { levels = levels.rev() }
      (
        kind: "swatch",
        aesthetics: aesthetics,
        title: first.title,
        levels: levels,
        labels: first.labels,
        nrow: first.nrow,
        ncolumn: first.ncolumn,
        key: key-kind,
        key-diam-cm: _swatch-key-diam-cm(first.key-size, key-diam-cm),
        typst-mark: typst-mark,
      )
    } else if aesthetics.contains("colour") or aesthetics.contains("fill") {
      // A colour/fill continuous member governs rendering; any size/alpha
      // members in the same group are intentionally dropped from the bar
      // because compositing them on a smooth gradient is awkward and rare.
      // Stepped scales (binned: true) emit n-breaks discrete patches with
      // ticks at the bin boundaries; smooth scales fall back to extended().
      let info = _bin-info(first.t)
      let lo = first.domain.first()
      let hi = first.domain.last()
      let computed = if info.binned {
        range(info.n-breaks + 1).map(i => lo + i * (hi - lo) / info.n-breaks)
      } else {
        extended(lo, hi, m: 5, integer: first.t.at("integer", default: false))
      }
      let breaks = _guide-breaks(info, lo, hi, computed)
      (
        kind: "colourbar",
        aesthetics: aesthetics,
        title: first.title,
        domain: first.domain,
        breaks: breaks,
        labels: info.labels,
        typst-mark: typst-mark,
        binned: info.binned,
        n-breaks: info.n-breaks,
      )
    } else {
      // Numeric ladder for size/alpha/linewidth/stroke. Binned scales emit
      // one glyph per bin at the midpoint; smooth scales fall back to extended().
      let info = _bin-info(first.t)
      let lo = first.domain.first()
      let hi = first.domain.last()
      // A binned ladder shows one glyph per bin at its midpoint. Explicit
      // `breaks` (bin edges) become interval midpoints; otherwise the bins are
      // `n-breaks` equal-width slices. (The colourbar instead keeps the edges
      // as boundary ticks.)
      let breaks = if info.binned and type(info.breaks) == array {
        edge-midpoints(bin-edges(first.t.spec, lo, hi))
      } else {
        let computed = if info.binned {
          range(info.n-breaks).map(i => (
            lo + (i + 0.5) * (hi - lo) / info.n-breaks
          ))
        } else {
          extended(lo, hi, m: 5, integer: first.t.at("integer", default: false))
        }
        _guide-breaks(info, lo, hi, computed)
      }
      // Resolve the key glyph size against the group's own `size` scale (not
      // `first`, which is whichever aesthetic sorts first), or `none` when the
      // ladder carries no `size` channel.
      let size-member = members.find(m => m.aes == "size")
      let size-trained = if size-member == none { none } else {
        size-member.t
      }
      (
        kind: "size-ladder",
        aesthetics: aesthetics,
        title: first.title,
        domain: first.domain,
        breaks: breaks,
        nrow: first.nrow,
        ncolumn: first.ncolumn,
        labels: info.labels,
        key: key-kind,
        key-diam-cm: _ladder-key-diam-cm(size-trained, breaks, key-kind),
        typst-mark: typst-mark,
        binned: info.binned,
        n-breaks: info.n-breaks,
      )
    }
    g.insert("placement", first.placement)
    g.insert("align", first.align)
    guides.push(_stamp-sizes(g, theme))
  }

  // Free-form `guide-custom` slots have no scale, so the merge loop above
  // never sees them; surface them here in the order they appear in
  // `spec.guides`. Cm dimensions are resolved up-front so the dispatch and
  // measurement helpers stay O(1).
  //
  // Placement resolves through the same layering the scale-driven guides use,
  // so a theme side or a `guides(default: ...)` side reaches a custom block as
  // it reaches every other guide.
  let shared-guide = overrides.at("default", default: none)
  for g in overrides.values() {
    if type(g) != dictionary { continue }
    if g.at("name", default: none) != "custom" { continue }
    let placement = _resolve-placement(g, shared-guide, theme)
    if placement.side == "none" { continue }
    let cm-w = _custom-dim-cm(g.width, _CUSTOM-DEFAULT-WIDTH)
    let cm-h = _custom-dim-cm(g.height, _CUSTOM-DEFAULT-HEIGHT)
    let custom = (
      kind: "custom",
      content: g.content,
      cm-width: cm-w,
      cm-height: cm-h,
      title: g.title,
      placement: placement,
    )
    guides.push(_stamp-sizes(custom, theme))
  }

  // Stable sort: ties (no `order`, or equal `order`) preserve insertion order,
  // so the default flow matches `_aesthetic-order` with custom guides last.
  guides.sorted(key: g => (
    if g.placement.order == none { calc.inf } else { g.placement.order }
  ))
}

// Compose an aesthetic bundle for one level/value across every member of the
// merged group. Returns a dict consumable by `draw-glyph`.
#let _bundle-for(value, aesthetics, ctx, ink) = {
  let bundle = (:)
  for aes-name in aesthetics {
    let trained = ctx.trained.at(aes-name, default: none)
    if trained == none { continue }
    let v = resolve-level(
      aes-name,
      trained,
      value,
      palette: ctx.palette,
      ink: ink,
    )
    if v == none { continue }
    bundle.insert(aes-name, v)
  }
  bundle
}

// Per-side cm totals consumed by the renderer to grow the panel margin on
// each occupied side. Inside legends contribute nothing to margins; their
// anchor data is returned in `inside` so the draw pass can place each one
// independently.
#let estimate-extents(guides) = {
  let extents = (top: 0.0, right: 0.0, bottom: 0.0, left: 0.0, inside: ())
  for (i, g) in guides.enumerate() {
    let side = g.placement.side
    if side == "right" or side == "left" {
      let w = g.at("width", default: 0.0)
      if w > extents.at(side) { extents.insert(side, w) }
    } else if side == "top" or side == "bottom" {
      let h = g.at("height", default: 0.0)
      if h > extents.at(side) { extents.insert(side, h) }
    } else if side == "inside" {
      extents.inside.push((
        idx: i,
        align: g.placement.align,
        dx: g.placement.dx,
        dy: g.placement.dy,
      ))
    }
  }
  extents
}

// Gap (cm) `render-plot` inserts between a plot panel and its side legend.
// Exposed so `compose()` can match the same offset when the panel-margin
// override leaves no intrinsic cetz padding (right-side default placement).
#let legend-gap(theme) = {
  let s = _legend-title-style(theme)
  resolve-margin-side-cm(s.margin.left, 1.6em, size-pt: s.size / 1pt)
}

// The `(surface) -> (render:, align:)` closure a guide context is drawn under.
// A primitive asks for rendered content rather than resolving a surface itself,
// because the theme and the measurement context both live at this stage.
#let _guide-text-styles(theme) = surface => {
  let s = _text-style(theme, surface)
  (
    render: body => text(.._text-args(s))[#resolve-prose(
      body,
      eval-strings: s.typst,
    )],
    align: s.align,
  )
}

// Build positioned gradient stops for a continuous colourbar. Diverging
// palettes (with `midpoint`) pin the middle stop at the midpoint's normalised
// position; degenerate palettes flatten to a single colour across the bar.
#let _gradient-stops(pal, midpoint, lo, hi, ink) = {
  if pal.len() == 0 { return ((ink, 0%), (ink, 100%)) }
  if pal.len() == 1 {
    return ((pal.first(), 0%), (pal.first(), 100%))
  }
  if midpoint != none and pal.len() >= 3 and hi > lo {
    let mid-pos = calc.max(0.0, calc.min(1.0, (midpoint - lo) / (hi - lo)))
    return (
      (pal.first(), 0%),
      (pal.at(1), mid-pos * 100%),
      (pal.last(), 100%),
    )
  }
  pal
}

// Paint the body of a colour bar between the two corners the layer resolved:
// the backstop fill, the gradient or the bins, and the frame stroke over them.
//
// This is what the guide layer cannot do for itself. Every colour here is
// resolved from a palette and a trained scale, which live downstream of the
// layer, so it reaches the strip as a closure on the context.
#let _paint-bar(guide, ctx, theme, lo-pt, hi-pt, horizontal) = {
  let bar-aes = if guide.aesthetics.contains("colour") {
    "colour"
  } else { "fill" }
  let trained = ctx.trained.at(bar-aes)
  let ink = resolve-colour(theme, "ink")
  let (lo, hi) = guide.domain
  let (bar-left, bar-bottom) = lo-pt
  let (bar-right, bar-top) = hi-pt
  let bar-w = bar-right - bar-left
  let bar-h = bar-top - bar-bottom
  // The frame stays glued to the strip bounds so a themed `inset` cannot bleed
  // past the slot the guide reserved.
  let bar-frame = _rect-style(
    theme,
    "legend-bar",
    fallback-colour: ink,
    outset-ref-w: ctx.at("canvas-w", default: 0),
    outset-ref-h: ctx.at("canvas-h", default: 0),
  )
  // Backstop fill, visible through transparent gradient stops only.
  if bar-frame.fill != none {
    cetz.draw.rect(lo-pt, hi-pt, fill: bar-frame.fill, stroke: none)
  }
  let pal = spec-palette(trained, ctx.palette)
  let spec = trained.at("spec", default: none)
  let user-breaks = if spec == none { auto } else {
    spec.at("breaks", default: auto)
  }
  if guide.at("binned", default: false) and type(user-breaks) == array {
    // Explicit `breaks` give (possibly non-uniform) bin edges: one patch per
    // bin, its width tracking the edge spacing and its fill the colour the
    // interval midpoint resolves to, so the bar matches the per-row colour.
    let edges = bin-edges(spec, lo, hi)
    let span = hi - lo
    for i in range(edges.len() - 1) {
      let e0 = edges.at(i)
      let e1 = edges.at(i + 1)
      let colour = resolve-continuous-colour(trained, (e0 + e1) / 2, pal, ink)
      let t0 = if span == 0 { 0 } else { (e0 - lo) / span }
      let t1 = if span == 0 { 1 } else { (e1 - lo) / span }
      let (rect-lo, rect-hi) = if horizontal {
        ((bar-left + t0 * bar-w, bar-bottom), (bar-left + t1 * bar-w, bar-top))
      } else {
        (
          (bar-left, bar-bottom + t0 * bar-h),
          (bar-right, bar-bottom + t1 * bar-h),
        )
      }
      cetz.draw.rect(rect-lo, rect-hi, fill: colour, stroke: colour)
    }
  } else if guide.at("binned", default: false) {
    let steps = guide.at("n-breaks", default: 5)
    let step-w = bar-w / steps
    let step-h = bar-h / steps
    for i in range(steps) {
      let t = (i + 0.5) / steps
      let value = lo + t * (hi - lo)
      let colour = resolve-continuous-colour(trained, value, pal, ink)
      let (rect-lo, rect-hi) = if horizontal {
        let x-lo = bar-left + i * step-w
        ((x-lo, bar-bottom), (x-lo + step-w, bar-top))
      } else {
        let y-lo = bar-bottom + i * step-h
        ((bar-left, y-lo), (bar-right, y-lo + step-h))
      }
      cetz.draw.rect(rect-lo, rect-hi, fill: colour, stroke: colour)
    }
  } else {
    let stops = _gradient-stops(
      pal,
      spec-attr(trained, "midpoint"),
      lo,
      hi,
      ink,
    )
    cetz.draw.rect(
      lo-pt,
      hi-pt,
      fill: gradient.linear(..stops, dir: if horizontal { ltr } else { btt }),
      stroke: none,
    )
  }
  if bar-frame.stroke != none {
    cetz.draw.rect(lo-pt, hi-pt, fill: none, stroke: bar-frame.stroke)
  }
}

// The context a legend box is drawn under: its parts read left to right across
// the width the box was given, and stack downward from the cursor.
//
// `key-draw` is where the aesthetics reach the glyph. The layer places a key and
// says which level it stands for; the bundle that inks it is resolved here,
// where the trained scales are.
#let _legend-box-gctx(guide, ctx, ox, cursor, theme) = {
  let ink = resolve-colour(theme, "ink")
  let glyph-font = resolve-geom-defaults(theme).font
  (
    .._LEGEND-GCTX,
    span: guide.width,
    place: (frac, across) => (ox + frac * guide.width, cursor - across),
    text-style: _guide-text-styles(theme),
    surface-stroke: surface => _line-stroke(
      theme,
      surface,
      fallback-colour: ink,
    ),
    key-draw: (key, value, pt, radius) => draw-glyph(
      key,
      pt.at(0),
      pt.at(1),
      radius,
      _bundle-for(value, guide.at("aesthetics", default: ()), ctx, ink),
      ink: ink,
      font: glyph-font,
    ),
    bar-draw: (lo-pt, hi-pt, horizontal) => _paint-bar(
      guide,
      ctx,
      theme,
      lo-pt,
      hi-pt,
      horizontal,
    ),
  )
}

// Every guide is drawn by its own stack, from the record `_stamp-sizes`
// measured, in the box context every legend box shares. Nothing here reads the
// kind: the stack already says what the guide is.
#let _draw-guide-body(guide, ctx, ox, cursor, theme) = compose-draw(
  guide.stack.node,
  _legend-box-gctx(guide, ctx, ox, cursor, theme),
  guide.stack.layout,
)

// Vertical gap between stacked guides on a side: the panel-to-legend gap plus
// the legend-background outset on the panel-facing edge.
#let _side-stack-gap(side, ctx, theme, legend-gap) = (
  legend-gap
    + _rect-outset-cm(
      theme,
      "legend-background",
      ref-w: ctx.at("canvas-w", default: 0),
      ref-h: ctx.at("canvas-h", default: 0),
    ).at(opposite-side.at(side))
)

// Total stacked height (cm) of the guides on a left/right side: every guide's
// rendered height plus an inter-guide gap. Shared by `_draw-side` (centring and
// background) and the renderer's fit check so the two never disagree.
#let side-stacked-height(side, side-guides, ctx, theme, legend-gap) = {
  if side-guides.len() == 0 { return 0.0 }
  let total = side-guides.map(g => g.height).sum(default: 0.0)
  (
    total
      + _side-stack-gap(side, ctx, theme, legend-gap) * (side-guides.len() - 1)
  )
}

// Bounding box (cm) of the guides stacked on one side, repeating `_draw-side`'s
// own arithmetic so the box the background is sized against is the box the draw
// pass walks. A vertical side stacks heights under the widest guide; a
// horizontal side lays widths out beside the tallest one.
#let _side-content-box(side, side-guides, ctx, theme, legend-gap) = {
  if side-guides.len() == 0 { return (w: 0.0, h: 0.0) }
  if side == "right" or side == "left" {
    let w = 0.0
    for g in side-guides {
      let gw = g.at("width", default: 0.0)
      if gw > w { w = gw }
    }
    return (
      w: w,
      h: side-stacked-height(side, side-guides, ctx, theme, legend-gap),
    )
  }
  let w = 0.0
  let h = 0.0
  for g in side-guides {
    w += g.at("width", default: 0.0)
    if g.height > h { h = g.height }
  }
  if side-guides.len() > 1 {
    w += _side-stack-gap(side, ctx, theme, legend-gap) * (side-guides.len() - 1)
  }
  (w: w, h: h)
}

// Resolve the legend-background geometry for a guide-stack bbox of size
// `w` by `h`, once, so both the painted rect and the space reserved for it
// come from a single `_rect-style` call. `painted` gates the rect on it
// having a fill or a stroke; `pad` is the `inset` the painted rect
// grows outward by, zeroed when nothing paints (an absent rect has no
// padding to give); `gap` is the `outset`, resolved whether or not the
// rect paints, matching `_rect-outset-cm` in chrome.typ so `outset`
// reserves whitespace on its own. `%` inset resolves against the bbox
// dims (so 5% means 5% of the legend's own width / height); `%` outset
// resolves against the plot canvas.
#let _bg-metrics(theme, ctx, w, h) = {
  let bg = _rect-style(
    theme,
    "legend-background",
    inset-ref-w: w,
    inset-ref-h: h,
    outset-ref-w: ctx.at("canvas-w", default: 0),
    outset-ref-h: ctx.at("canvas-h", default: 0),
  )
  let painted = bg.fill != none or bg.stroke != none
  (
    fill: bg.fill,
    stroke: bg.stroke,
    painted: painted,
    pad: if painted { bg.inset-cm } else { _zero-margin-cm },
    gap: bg.outset-cm,
  )
}

// Per-side cm the legend-background claims outside the guide bbox: the
// painted inset plus the reserved outset.
#let _bg-edge-cm(bg) = (
  top: bg.pad.top + bg.gap.top,
  right: bg.pad.right + bg.gap.right,
  bottom: bg.pad.bottom + bg.gap.bottom,
  left: bg.pad.left + bg.gap.left,
)

// The whole block a side's legend occupies: the guide-stack content box plus
// the `legend-background` edge painted and reserved around it. This is what the
// draw pass puts on the canvas, so it is what the chrome fit check and
// `compose()` both have to measure against the canvas.
#let side-block-cm(side, side-guides, ctx, theme, legend-gap) = {
  let content-box = _side-content-box(side, side-guides, ctx, theme, legend-gap)
  let edge = _bg-edge-cm(
    _bg-metrics(theme, ctx, content-box.w, content-box.h),
  )
  (
    width: content-box.w + edge.left + edge.right,
    height: content-box.h + edge.top + edge.bottom,
    content-w: content-box.w,
    content-h: content-box.h,
    edge: edge,
  )
}

// Cm the guide-stack origin moves along the slot axis so the painted rect lands
// inside the slot `_chrome-margins` reserved rather than overflowing it.
// `right` and `top` anchor off the panel and already carry the panel-facing
// `outset` in their cursor (`_side-stack-gap`), so they owe only the `inset`;
// `left` and `bottom` anchor off the canvas edge and owe the whole edge.
#let _side-origin-shift(side, bg) = {
  let edge = _bg-edge-cm(bg)
  if side == "right" { (dx: bg.pad.left, dy: 0.0) } else if side == "left" {
    (dx: edge.left, dy: 0.0)
  } else if side == "top" { (dx: 0.0, dy: bg.pad.bottom) } else {
    (dx: 0.0, dy: edge.bottom)
  }
}

// Paint the legend-background rect resolved by `_bg-metrics`, grown
// outward from the bbox corners `(x0, y0)`-`(x1, y1)` by `pad`. Stays
// silent when nothing paints, so plots without a themed legend backdrop
// look the same as before.
#let _paint-bg(bg, x0, y0, x1, y1) = {
  if not bg.painted { return }
  let d = bg.pad
  cetz.draw.rect(
    (x0 - d.left, y0 - d.bottom),
    (x1 + d.right, y1 + d.top),
    fill: bg.fill,
    stroke: bg.stroke,
  )
}

#let _draw-side(
  side,
  side-guides,
  ctx,
  panel-rect,
  margin,
  legend-gap,
  sec-y-extent,
  sec-x-extent,
  right-strip,
  top-strip,
  theme,
) = {
  if side-guides.len() == 0 { return }
  let _legend-text = _text-style(theme, "legend-text")
  // Panel-to-legend gap plus the `legend-background.outset` on the panel-facing
  // side, so users can dial the spacing from the theme. The same value separates
  // the panel from the legend and stacks the guides within it.
  let gap = _side-stack-gap(side, ctx, theme, legend-gap)
  let stack-gap = gap
  let px = panel-rect.x
  let py = panel-rect.y
  let pw = panel-rect.w
  let ph = panel-rect.h
  // Size the background against the stack it wraps, then move the origin by
  // what the rect paints outside that box, so it lands in the slot
  // `_chrome-margins` reserved instead of growing the canvas past it.
  let content-box = _side-content-box(side, side-guides, ctx, theme, legend-gap)
  let bg = _bg-metrics(theme, ctx, content-box.w, content-box.h)
  let shift = _side-origin-shift(side, bg)

  if side == "right" or side == "left" {
    let anchor-x = if side == "right" {
      px + pw + sec-y-extent + right-strip + gap
    } else {
      px - margin.left + 0.05
    }
    let ox = anchor-x + shift.dx
    // Centre the stack vertically over the panel + col-strip chrome.
    // `top-strip` (facet-grid only) extends the chrome upward; wrap
    // folds the strip into `ph`, single plot leaves both at panel
    // height.
    let chrome-h = ph + top-strip
    let cursor-top = py + (chrome-h + content-box.h) / 2
    _paint-bg(
      bg,
      ox,
      cursor-top - content-box.h,
      ox + content-box.w,
      cursor-top,
    )

    let cursor = cursor-top
    for g in side-guides {
      _draw-guide-body(g, ctx, ox, cursor, theme)
      cursor -= g.height + stack-gap
    }
  } else {
    let anchor-y = if side == "top" {
      py + ph + sec-x-extent + gap
    } else {
      py - margin.bottom + 0.4
    }
    let cursor-y = anchor-y + shift.dy + content-box.h
    // Centre the row of guides horizontally over the panel + row-strip
    // chrome. `right-strip` (facet-grid row facets) extends the chrome
    // rightward; otherwise it's zero and the legend centres over `pw`.
    let chrome-w = pw + right-strip
    let cursor-x = px + (chrome-w - content-box.w) / 2
    _paint-bg(
      bg,
      cursor-x,
      cursor-y - content-box.h,
      cursor-x + content-box.w,
      cursor-y,
    )
    for g in side-guides {
      _draw-guide-body(g, ctx, cursor-x, cursor-y, theme)
      cursor-x += g.width + stack-gap
    }
  }
}

// Resolve a Typst length or ratio against `panel-dim` (cm). Ratios are
// interpreted as fractions of the panel dimension.
#let _resolve-offset(value, panel-dim) = {
  if type(value) == ratio { panel-dim * (value / 100%) } else if (
    type(value) == length
  ) { value / 1cm } else {
    fail-type("legend", "offset", value, "a length or ratio")
  }
}

// Anchor an inside-panel guide so its legend-background -- the painted rect
// grown by `pad`, plus the `gap` reserved around it -- lands inside
// `panel-rect` instead of overflowing it. `edge` is the per-side cm dict
// from `_bg-edge-cm`; with equal sides the centred branches reduce to the
// plain panel centre, and with zero edges every branch reproduces the
// content-box-only anchor. Returns `(x, top)`: the west and north edges of
// the guide bbox.
#let _inside-anchor(panel-rect, w, h, h-align, v-align, edge) = {
  let ox = if h-align == right {
    panel-rect.x + panel-rect.w - w - edge.right
  } else if h-align == center {
    panel-rect.x + (panel-rect.w - w + edge.left - edge.right) / 2
  } else {
    panel-rect.x + edge.left
  }
  let oy-top = if v-align == bottom {
    panel-rect.y + h + edge.bottom
  } else if v-align == horizon {
    panel-rect.y + (panel-rect.h + h + edge.bottom - edge.top) / 2
  } else {
    panel-rect.y + panel-rect.h - edge.top
  }
  (x: ox, top: oy-top)
}

#let _draw-inside(g, ctx, panel-rect, theme) = {
  let align = g.placement.align
  let h-align = if align == none { left } else {
    let a = align.x
    if a == none { left } else { a }
  }
  let v-align = if align == none { top } else {
    let a = align.y
    if a == none { top } else { a }
  }

  let bg = _bg-metrics(theme, ctx, g.width, g.height)
  let anchor = _inside-anchor(
    panel-rect,
    g.width,
    g.height,
    h-align,
    v-align,
    _bg-edge-cm(bg),
  )
  let ox = anchor.x + _resolve-offset(g.placement.dx, panel-rect.w)
  let oy-top = anchor.top - _resolve-offset(g.placement.dy, panel-rect.h)

  _paint-bg(bg, ox, oy-top - g.height, ox + g.width, oy-top)
  _draw-guide-body(g, ctx, ox, oy-top, theme)
}

#let draw(
  guides,
  ctx,
  panel-rect: none,
  margin: none,
  legend-gap: 0.0,
  sec-y-extent: 0.0,
  sec-x-extent: 0.0,
  right-strip: 0.0,
  top-strip: 0.0,
  theme: none,
) = {
  if guides.len() == 0 { return }
  let buckets = (top: (), right: (), bottom: (), left: (), inside: ())
  for g in guides {
    buckets.at(g.placement.side).push(g)
  }
  for side in ("top", "right", "bottom", "left") {
    _draw-side(
      side,
      buckets.at(side),
      ctx,
      panel-rect,
      margin,
      legend-gap,
      sec-y-extent,
      sec-x-extent,
      right-strip,
      top-strip,
      theme,
    )
  }
  for g in buckets.inside {
    _draw-inside(g, ctx, panel-rect, theme)
  }
}

// Size a free-standing legend canvas holding `guides`, all on `side`. Used by
// `compose()` both to reserve the hoisted legend's band off the panel area and
// to size the canvas `standalone` draws into, so the two can never disagree.
//
// The content box repeats `_draw-side`'s own arithmetic (the stamped guide
// heights stacked by `_side-stack-gap`) rather than approximating it, with a zero
// `legend-gap`: `compose()` supplies the panel-to-legend gap itself.
//
// `edge` is the per-side cm the `legend-background` claims outside that content
// box -- the painted `inset` plus the reserved `outset` -- so a themed backdrop
// is sized in instead of being cut off by `standalone`'s `clip: true`.
//
// `canvas-w`/`canvas-h` are the enclosing composition canvas in cm, mirroring
// the renderer's own legend ctx, so `%` outsets resolve against the canvas the
// legend sits on.
//
// `guides` arrive stamped for `theme`, because `guides-for` built them under
// it, so this reports the size that is drawn rather than patching a stamp that
// belongs to another theme.
#let standalone-size(guides, side, theme, canvas-w, canvas-h) = {
  let block = side-block-cm(
    side,
    guides,
    (canvas-w: canvas-w, canvas-h: canvas-h),
    theme,
    0.0,
  )
  block + (canvas-w: canvas-w, canvas-h: canvas-h)
}

// Render a free-standing legend canvas, sized by `size` from `standalone-size`
// over the same `guides`. Used by `compose()` to draw the shared, hoisted
// legend outside any plot panel.
//
// `panel-rect` carries the *content* box, not the canvas: `_draw-side`'s
// centring terms then cancel and the guide stack starts at its origin. Along
// the slot axis that origin is the canvas edge, since `_draw-side` offsets it
// itself by the `legend-background` edge; across the slot it owes that edge
// here, so the whole background -- content grown by `pad`, then the reserved
// `gap` -- lands inside the canvas that `clip: true` would otherwise cut.
// `margin.left: 0.05` cancels `_draw-side`'s own left-side nudge, and
// `margin.bottom: 0.4` cancels its bottom offset.
#let standalone(guides, trained, theme, side, size) = {
  let ctx = (
    trained: trained,
    palette: resolve-theme-palette(theme),
    theme: theme,
    canvas-w: size.canvas-w,
    canvas-h: size.canvas-h,
  )
  let vertical = side == "right" or side == "left"
  let panel-rect = (
    x: if vertical { 0.0 } else { size.edge.left },
    y: if vertical { size.edge.bottom } else { 0.0 },
    w: if vertical { 0.0 } else { size.content-w },
    h: if vertical { size.content-h } else { 0.0 },
  )
  let margin = (
    left: if side == "left" { 0.05 } else { 0.0 },
    right: 0.0,
    top: 0.0,
    bottom: if side == "bottom" { 0.4 } else { 0.0 },
  )
  block(
    width: size.width * 1cm,
    height: size.height * 1cm,
    above: 0pt,
    below: 0pt,
    breakable: false,
    clip: true,
    cetz.canvas(length: 1cm, padding: 0, {
      import cetz.draw: hide, rect
      hide(rect((0, 0), (size.width, size.height)), bounds: true)
      draw(
        guides,
        ctx,
        panel-rect: panel-rect,
        margin: margin,
        theme: theme,
      )
    }),
  )
}
