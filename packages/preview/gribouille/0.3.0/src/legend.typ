// Guide extraction and legend drawing.
//
// Per-aesthetic candidates are built first, then grouped: candidates that
// describe the same underlying scale (same column, type, levels/domain,
// labels and title) collapse into a single guide whose key glyph carries
// every merged aesthetic. Each guide carries a `placement` record (side,
// alignment, direction, byrow, order) that drives where it renders and how
// the swatch grid flows.

#import "deps.typ": cetz
#import "utils/pretty.typ": pretty
#import "utils/format.typ": format-break
#import "utils/measure.typ": measure-text-cm
#import "utils/colour.typ": resolve-continuous-colour
#import "utils/palette.typ": default-discrete, spec-attr, spec-palette
#import "utils/level-resolve.typ": resolve-level
#import "utils/errors.typ": fail, fail-type
#import "theme/defaults.typ": resolve-colour
#import "theme/theme.typ": (
  _line-stroke, _rect-outset-cm, _rect-style, _text-args, _text-style,
)
#import "guide/draw-key.typ": default-key-for, draw-glyph
#import "scale/train.typ": mapping-display-name
#import "utils/typst-markup.typ": resolve-prose
#import "utils/margin.typ": length-to-cm, opposite-side
#import "utils/aes-resolve.typ": merge-mapping, resolve-label
#import "utils/margin.typ": resolve-margin-side-cm

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
#let _merge-placement(base, over) = {
  let direction = if over.at("direction", default: auto) == auto {
    base.direction
  } else { over.direction }
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
      )
    )
  } else {
    (..base, ..over, direction: direction)
  }
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
  // `labs(colour: none)` sets `spec.blank` to suppress the legend title and
  // collapse the space it would reserve.
  if (
    t.at("spec", default: none) != none and t.spec.at("blank", default: false)
  ) {
    return none
  }
  if (
    t.at("spec", default: none) != none
      and t.spec.at("name", default: none) != none
  ) {
    t.spec.name
  } else if spec.mapping != none {
    mapping-display-name(spec.mapping.at(aes-name, default: aes-name))
  } else {
    aes-name
  }
}

#let _grid-shape(n, nrow, ncol, direction) = {
  if ncol != none {
    let cols = calc.max(1, ncol)
    let rows = calc.max(1, calc.ceil(n / cols))
    (rows: rows, cols: cols)
  } else if nrow != none {
    let rows = calc.max(1, nrow)
    let cols = calc.max(1, calc.ceil(n / rows))
    (rows: rows, cols: cols)
  } else if direction == "horizontal" {
    (rows: 1, cols: n)
  } else {
    (rows: n, cols: 1)
  }
}

// Grid shape for a guide laying `count` keys out under its `nrow`/`ncolumn` and
// flow direction. Shared by every swatch and size-ladder layout site so the
// width estimate, height estimate, and draw all agree on the grid.
#let _guide-shape(g, count) = _grid-shape(
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
    let geom = layer.at("geom", default: "")
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
    key-override != auto and key-override != none and key-override.key == "path"
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
      let geom = layer.at("geom", default: "")
      let key-override = layer.at("key", default: auto)
      let candidate = if key-override != auto and key-override != none {
        key-override.key
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

#let _candidate(spec, trained, overrides, aes-name) = {
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

  // Resolve placement: per-aesthetic override over `guides(default: ...)` over
  // the natural default. `auto` side / direction inherit from the layer below,
  // so `guide-legend(ncolumn: 2)` still picks up a `default:` side.
  let placement = _default-placement
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
  placement = (..placement, direction: resolved-direction)
  if placement.side == "none" { return none }

  let contributors = _mapped-contributors(spec, aes-name)
  if contributors.len() == 0 { return none }

  // Per-aesthetic override wins, then `guides(default: ...)`, then the value
  // trained from the scale / labs.
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

  let cand = (
    aes: aes-name,
    t: t,
    title: title,
    nrow: nrow,
    ncolumn: ncolumn,
    reverse: reverse,
    align: align,
    placement: placement,
    contributors: contributors,
    column: _column-for(spec, aes-name),
    typst-mark: t.at("typst-mark", default: false),
  )

  if t.type == "discrete" {
    let levels = t.domain
    let labels = if (
      t.at("spec", default: none) != none
    ) { t.spec.at("labels", default: auto) } else { auto }
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
#let _swatch-lead-cm(size-pt) = _GLYPH-DIAMETER-CM + _font-cm(size-pt) * 0.5
#let _ladder-lead-cm(size-pt) = _GLYPH-DIAMETER-CM + _font-cm(size-pt) * 0.8

// Label width in cm at the given font size. Strings use a font-size-aware
// char-count heuristic (~0.55em per char) so the helper works outside a
// `context` block (unit tests). Non-string content (typst-markup labels)
// goes through Typst's `measure()`, which requires a context. Empty /
// `none` labels report `0`. The full label width is reserved so a long
// label widens its column instead of overflowing into the next swatch.
#let _label-width(label, size-pt) = {
  if label == none { return 0.0 }
  if type(label) == str {
    if label == "" { return 0.0 }
    return label.len() * _font-cm(size-pt) * 0.55 + 0.05
  }
  let m = measure(text(size: size-pt * 1pt)[#label])
  m.width / 1cm + 0.05
}

// Resolve the label a guide actually draws, for measurement. `_guide-width` /
// `_guide-height` are theme-less, so `eval-strings: false`; a `typst-mark`
// label is already converted to content by `resolve-label`. A plain string
// label under a `legend-text` typst-eval theme is drawn as markup but measured
// as a string, the one case where measurement can lag the drawn glyph.
#let _display-label(labels, value, i, fallback, typst-mark) = resolve-prose(
  resolve-label(labels, value, i, fallback, typst-mark: typst-mark),
  eval-strings: false,
)

// The label a size-ladder / colourbar break draws (custom `labels:` resolved
// against the break value, falling back to its formatted number).
#let _break-label(g, value, i) = _display-label(
  g.at("labels", default: auto),
  value,
  i,
  format-break(value),
  g.at("typst-mark", default: false),
)

// Widest break label (cm) across `breaks` at the supplied font size. Shared by
// the ladder / colourbar width estimate and their draw passes so reserved and
// drawn label slots agree.
#let _max-break-label-width(g, breaks, size-pt) = {
  let label-w = 0.0
  for (i, b) in breaks.enumerate() {
    let w = _label-width(_break-label(g, b, i), size-pt)
    if w > label-w { label-w = w }
  }
  label-w
}

#let _title-width(g, size-pt) = _label-width(
  g.at("title", default: none),
  size-pt,
)

// Index of the level at (row, col). Column-major (`byrow: false`) numbers
// items down each column; row-major (`byrow: true`) numbers items across
// each row.
#let _swatch-index(row, col, shape, byrow) = {
  if byrow { row * shape.cols + col } else { col * shape.rows + row }
}

// Inverse of `_swatch-index`: recover (row, col) from a linear index.
#let _swatch-rc(i, shape, byrow) = {
  if byrow {
    (row: calc.quo(i, shape.cols), col: calc.rem(i, shape.cols))
  } else {
    (row: calc.rem(i, shape.rows), col: calc.quo(i, shape.rows))
  }
}

// The label a swatch cell draws (custom `labels:` resolved against the level,
// falling back to the level itself), as measured for sizing.
#let _swatch-label(guide, i) = _display-label(
  guide.at("labels", default: auto),
  guide.levels.at(i),
  i,
  guide.levels.at(i),
  guide.at("typst-mark", default: false),
)

// Swatch column gap: at least `MIN` cm, growing with the widest column by
// `RATIO` so dense legends keep breathing room.
#let _SWATCH-COL-GAP-MIN = 0.15
#let _SWATCH-COL-GAP-RATIO = 0.1

// Per-column widths, gap, cumulative left-offsets, and total grid width.
// Each column sizes to its own widest label (measured at the supplied
// font size) so a single oversized level doesn't pad every other column
// unnecessarily. Widths come from the resolved display labels, so a custom
// `labels:` wider than its level still gets the column space it draws into.
#let _swatch-layout(guide, shape, byrow, size-pt) = {
  let lead = _swatch-lead-cm(size-pt)
  let widths = range(shape.cols).map(col => {
    let max-w = 0.0
    for row in range(shape.rows) {
      let i = _swatch-index(row, col, shape, byrow)
      if i >= guide.levels.len() { continue }
      let w = _label-width(_swatch-label(guide, i), size-pt)
      if w > max-w { max-w = w }
    }
    lead + max-w
  })
  let gap = calc.max(
    _SWATCH-COL-GAP-MIN,
    _SWATCH-COL-GAP-RATIO * calc.max(..widths),
  )
  let offsets = ()
  let acc = 0.0
  for w in widths {
    offsets.push(acc)
    acc += w + gap
  }
  (widths: widths, gap: gap, offsets: offsets, total: acc - gap)
}

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

// Nominal half-extent (cm) for a ladder key glyph, used to place and size the
// fallback glyph and as the per-row centring offset. The drawn `point` key may
// override its radius from the resolved `size` aesthetic (see `_ladder-key-diam-cm`).
#let _LADDER-GLYPH-CM = 0.16

// Largest key-glyph diameter (cm) a size ladder will draw. The `size` channel
// resolves each break to a marker radius that can far exceed the fixed swatch
// glyph, so the row stride and reserved height must follow it. `size-trained`
// is the group's `size` scale (or `none` for an alpha/linewidth/stroke ladder);
// a non-point key keeps the fixed glyph.
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

// Number of rendered lines in a label. Strings stay on one line; content is
// measured against a single-line sample and rounded, so a `\`-broken two-line
// label reports two. At least one line so every item reserves a row.
#let _label-lines(label, size-pt) = {
  if label == none or label == "" or type(label) == str { return 1 }
  let one = measure(text(size: size-pt * 1pt)[x]).height
  if one == 0pt { return 1 }
  let h = measure(text(size: size-pt * 1pt)[#label]).height
  calc.max(1, calc.round(h / one))
}

// Extra vertical space a multi-line label needs beyond a single row: a full
// row stride per extra line, so multi-line rows keep the same inter-row gap as
// single-line ones. Zero for every string / single-line label, so single-line
// legends keep their geometry.
#let _label-overflow(label, line-h, size-pt) = (
  (_label-lines(label, size-pt) - 1) * line-h
)

// Turn a per-row label-overflow list into stacking data: `extra` per row, the
// cumulative overflow `before` each row (how far that row is pushed down), and
// the `total` overflow added to the single-line stack height. Shared by the
// vertical swatch grid and the vertical size-ladder.
#let _stack-offsets(overflows) = {
  let before = ()
  let acc = 0.0
  for e in overflows {
    before.push(acc)
    acc += e
  }
  (extra: overflows, before: before, total: acc)
}

// Tallest multi-line overflow across a break list, measured against a single
// line. Grows a horizontal ladder / colourbar label band beyond its single-line
// default; zero when every label fits one line.
#let _breaks-overflow(g, breaks, size-pt) = {
  let line-h = _swatch-line-h-cm(size-pt)
  let max-e = 0.0
  for (i, b) in breaks.enumerate() {
    let e = _label-overflow(_break-label(g, b, i), line-h, size-pt)
    if e > max-e { max-e = e }
  }
  max-e
}

// Per-row stacking offsets for a grid: each row's overflow is the tallest
// multi-line overflow across its columns. `label-of(i)` returns the i-th cell's
// label; `count` bounds the populated cells. Shared by the swatch grid and the
// grid size-ladder.
#let _grid-row-overflows(count, label-of, shape, byrow, line-h, size-pt) = {
  let overflows = range(shape.rows).map(row => {
    let max-e = 0.0
    for col in range(shape.cols) {
      let i = _swatch-index(row, col, shape, byrow)
      if i >= count { continue }
      let e = _label-overflow(label-of(i), line-h, size-pt)
      if e > max-e { max-e = e }
    }
    max-e
  })
  _stack-offsets(overflows)
}

#let _swatch-rows(guide, shape, byrow, size-pt) = _grid-row-overflows(
  guide.levels.len(),
  i => _swatch-label(guide, i),
  shape,
  byrow,
  _swatch-line-h-cm(size-pt),
  size-pt,
)

#let _LADDER-H-COL-H = 0.32
#let _LADDER-H-LABEL-H = 0.4
#let _COLOURBAR-V-W = 0.35
#let _COLOURBAR-V-H = 3.0
#let _COLOURBAR-H-W = 3.0
#let _COLOURBAR-H-H = 0.35
#let _COLOURBAR-H-LABEL-H = 0.45
#let _GUIDE-PAD-V = 0.2
#let _COLOURBAR-PAD-V = 0.3
// Width-estimate gap between a vertical colourbar and its tick labels; the
// renderer positions labels at `tick-len + tick-gap`, this approximates it.
#let _COLOURBAR-V-LABEL-GAP = 0.3

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
// falling back to `pretty` over the domain only when none were stored.
#let _colourbar-breaks(g) = {
  let breaks = g.at("breaks", default: none)
  if breaks != none { return breaks }
  let (lo, hi) = g.domain
  pretty(lo, hi, n: 5)
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

// Vertical stride (cm) between rows of a horizontal size-ladder grid: the glyph
// band, the label row, and any multi-line label overflow. Uniform across rows
// so a wrapped horizontal legend keeps even rows.
#let _ladder-h-row-stride(guide, size-pt) = (
  _ladder-h-band(guide)
    + _LADDER-H-LABEL-H
    + _breaks-overflow(guide, guide.breaks, size-pt)
)

// Per-row stacking offsets for a vertical size-ladder grid (the break analogue
// of `_swatch-rows`).
#let _ladder-rows(guide, shape, byrow, line-h, size-pt) = _grid-row-overflows(
  guide.breaks.len(),
  i => _break-label(guide, guide.breaks.at(i), i),
  shape,
  byrow,
  line-h,
  size-pt,
)

// Per-guide width estimate. Stored on each guide so `estimate-width` is
// O(1). `size-pt` is the legend-text font size; label widths are
// measured against it.
#let _guide-width(g, size-pt) = {
  if g.kind == "swatch" {
    let shape = _guide-shape(g, g.levels.len())
    let layout = _swatch-layout(g, shape, g.placement.byrow, size-pt)
    return calc.max(_title-width(g, size-pt), layout.total)
  }
  if g.kind == "size-ladder" {
    let label-w = _max-break-label-width(g, g.breaks, size-pt)
    let shape = _guide-shape(g, g.breaks.len())
    if g.placement.direction == "horizontal" {
      let col-w = _ladder-h-col-w(g, label-w, size-pt)
      return calc.max(_title-width(g, size-pt), col-w * shape.cols)
    }
    let col-w = _ladder-lead-cm(size-pt) + label-w
    let grid-w = shape.cols * col-w + (shape.cols - 1) * _SWATCH-COL-GAP-MIN
    return calc.max(_title-width(g, size-pt), grid-w)
  }
  if g.kind == "colourbar" {
    let breaks = _colourbar-breaks(g)
    let label-w = _max-break-label-width(g, breaks, size-pt)
    if g.placement.direction == "horizontal" {
      return calc.max(
        _title-width(g, size-pt),
        _COLOURBAR-H-W + label-w,
      )
    }
    return calc.max(
      _title-width(g, size-pt),
      _COLOURBAR-V-W + _COLOURBAR-V-LABEL-GAP + label-w,
    )
  }
  if g.kind == "custom" { return g.cm-width }
  fail("legend._guide-width", "unknown guide kind " + repr(g.kind))
}

// Approximate title-h used only by `_guide-height` for margin sizing. The
// renderer uses the exact value via `_legend-title-h`.
#let _estimated-title-h(g, size-pt) = if g.title == none {
  0.0
} else { _font-cm(size-pt) * 1.8 }

// A titleless guide (`labs(... : none)`) reserves no title height; otherwise
// the resolved `title-h` applies.
#let _title-prefix(g, title-h) = if g.title == none { 0.0 } else { title-h }

// Tight slack below the last row so the glyph isn't flush with the rect
// edge.
#let _glyph-bottom-slack(size-pt) = _font-cm(size-pt) * 0.2

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

// Vertical height (cm) of a row-stack guide: full line-h for every row
// except the last (which reserves only the glyph diameter), plus a
// font-derived bottom slack so the rect doesn't graze the glyph.
#let _row-stack-height(n-rows, line-h, size-pt) = (
  (n-rows - 1) * line-h + _GLYPH-DIAMETER-CM + _glyph-bottom-slack(size-pt)
)

#let _swatch-height(guide, title-h, size-pt) = {
  let shape = _guide-shape(guide, guide.levels.len())
  (
    _title-prefix(guide, title-h)
      + _row-stack-height(
        shape.rows,
        _swatch-line-h-cm(size-pt),
        size-pt,
      )
      + _swatch-rows(guide, shape, guide.placement.byrow, size-pt).total
  )
}

#let _size-ladder-height(guide, title-h, size-pt) = {
  let prefix = _title-prefix(guide, title-h)
  let shape = _guide-shape(guide, guide.breaks.len())
  if guide.placement.direction == "horizontal" {
    prefix + shape.rows * _ladder-h-row-stride(guide, size-pt)
  } else {
    let m = _ladder-vmetrics(guide, size-pt)
    let rows = _ladder-rows(
      guide,
      shape,
      guide.placement.byrow,
      m.line-h,
      size-pt,
    )
    (
      prefix
        + (shape.rows - 1) * m.line-h
        + m.last
        + _glyph-bottom-slack(size-pt)
        + rows.total
    )
  }
}

#let _colourbar-height(guide, title-h, size-pt) = {
  let prefix = _title-prefix(guide, title-h)
  if guide.placement.direction == "horizontal" {
    let breaks = _colourbar-breaks(guide)
    (
      prefix
        + _COLOURBAR-H-H
        + _COLOURBAR-H-LABEL-H
        + _breaks-overflow(guide, breaks, size-pt)
    )
  } else {
    prefix + _COLOURBAR-V-H + _COLOURBAR-PAD-V
  }
}

#let _custom-height(guide, title-h) = {
  _title-prefix(guide, title-h) + guide.cm-height + 0.2
}

#let _guide-height(g, size-pt) = {
  let title-h = _estimated-title-h(g, size-pt)
  if g.kind == "swatch" { return _swatch-height(g, title-h, size-pt) }
  if g.kind == "size-ladder" {
    return _size-ladder-height(g, title-h, size-pt)
  }
  if g.kind == "colourbar" { return _colourbar-height(g, title-h, size-pt) }
  if g.kind == "custom" { return _custom-height(g, title-h) }
  fail("legend._guide-height", "unknown guide kind " + repr(g.kind))
}

// Recompute `width` and `height` after `placement.direction` has been mutated.
// Used by `compose()` whenever it coerces a hoisted guide's side because
// horizontal vs vertical layouts have different footprints.
#let recompute-extent(g, size-pt) = {
  let out = g
  out.width = _guide-width(out, size-pt)
  out.height = _guide-height(out, size-pt)
  out
}

#let guides-for(spec, trained, size-pt: 9) = {
  let overrides = spec.at("guides", default: (:))

  let candidates = ()
  for aes-name in _aesthetic-order {
    let cand = _candidate(spec, trained, overrides, aes-name)
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
        typst-mark: typst-mark,
      )
    } else if aesthetics.contains("colour") or aesthetics.contains("fill") {
      // A colour/fill continuous member governs rendering; any size/alpha
      // members in the same group are intentionally dropped from the bar
      // because compositing them on a smooth gradient is awkward and rare.
      // Stepped scales (binned: true) emit n-breaks discrete patches with
      // ticks at the bin boundaries; smooth scales fall back to pretty().
      let info = _bin-info(first.t)
      let lo = first.domain.first()
      let hi = first.domain.last()
      let computed = if info.binned {
        range(info.n-breaks + 1).map(i => lo + i * (hi - lo) / info.n-breaks)
      } else { pretty(lo, hi, n: 5) }
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
      // one glyph per bin at the midpoint; smooth scales fall back to pretty().
      let info = _bin-info(first.t)
      let lo = first.domain.first()
      let hi = first.domain.last()
      let computed = if info.binned {
        range(info.n-breaks).map(i => (
          lo + (i + 0.5) * (hi - lo) / info.n-breaks
        ))
      } else { pretty(lo, hi, n: 5) }
      let breaks = _guide-breaks(info, lo, hi, computed)
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
    g.insert("width", _guide-width(g, size-pt))
    g.insert("height", _guide-height(g, size-pt))
    guides.push(g)
  }

  // Free-form `guide-custom` slots have no scale, so the merge loop above
  // never sees them; surface them here in the order they appear in
  // `spec.guides`. Cm dimensions are resolved up-front so the dispatch and
  // measurement helpers stay O(1).
  for g in overrides.values() {
    if type(g) != dictionary { continue }
    if g.at("kind", default: none) != "guide-custom" { continue }
    let placement = g.at("placement", default: _default-placement)
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
    custom.insert("width", _guide-width(custom, size-pt))
    custom.insert("height", _guide-height(custom, size-pt))
    guides.push(custom)
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

// Vertical gap between the legend title and the first guide entry, resolved
// against the `legend-title` surface so em values track its font size.
#let _legend-title-h(theme) = {
  let s = _text-style(theme, "legend-title")
  resolve-margin-side-cm(
    s.margin.bottom,
    1.6em,
    size-pt: s.size / 1pt,
  )
}

// Gap (cm) `render-plot` inserts between a plot panel and its side legend.
// Exposed so `compose()` can match the same offset when the panel-margin
// override leaves no intrinsic cetz padding (right-side default placement).
#let legend-gap(theme) = {
  let s = _text-style(theme, "legend-title")
  resolve-margin-side-cm(s.margin.left, 1.6em, size-pt: s.size / 1pt)
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

// Place a label drawn to the right of a mark, justified within a slot of width
// `slot-w` whose left edge is `start`. `left` keeps the current west anchor at
// `start`; `center` / `right` shift toward the slot's far edge. Returns
// `(x, anchor)` for `cetz.draw.content`.
#let _hjust-right-of(align, start, slot-w) = {
  if align == right {
    (start + slot-w, "east")
  } else if align == center {
    (start + slot-w / 2, "center")
  } else {
    (start, "west")
  }
}

// Place a label drawn below a mark sitting at x `cx`. `center` keeps the label
// centred on the mark (the current north anchor); `left` / `right` pin an edge
// to `cx`. Returns `(x, anchor)` for `cetz.draw.content`.
#let _hjust-below(align, cx) = {
  if align == right {
    (cx, "north-east")
  } else if align == center {
    (cx, "north")
  } else {
    (cx, "north-west")
  }
}

// Resolve the legend title alignment: a per-guide `align` (from
// `guide-legend(align:)`) wins over the `legend-title` theme align; `none`
// falls through to the left default in `_draw-title`.
#let _title-align(guide-align, theme-align) = if guide-align != none {
  guide-align
} else { theme-align }

// The title's effective alignment with the `none -> left` default applied. The
// key graphic of a horizontal legend is justified by the same value so the two
// always share a centre (see `_draw-title` and the `_draw-*` graphic origins).
#let _title-resolved-align(guide, theme) = {
  let a = _title-align(
    guide.at("align", default: none),
    _text-style(theme, "legend-title").align,
  )
  if a == none { left } else { a }
}

// Horizontal offset (cm) that justifies a graphic of width `graphic-w` within a
// block of width `total-w`: `0` for left, half the slack for centre, all of it
// for right. Mirrors `_draw-title`'s justification so a horizontal legend's key
// graphic shares the title's centre / edges.
#let _align-offset(align, total-w, graphic-w) = if align == right {
  total-w - graphic-w
} else if align == center {
  (total-w - graphic-w) / 2
} else { 0.0 }

#let _draw-title(guide, ox, cursor, theme) = {
  let s = _text-style(theme, "legend-title")
  // A per-guide `align` (from `guide-legend(align:)`) wins over the theme.
  // Default left-aligned at the legend's left edge; `center`/`right` offset
  // within the legend block `width`. The key graphic uses the same alignment.
  let a = _title-resolved-align(guide, theme)
  let (tx, t-anchor) = if a == right {
    (ox + guide.width, "north-east")
  } else if a == center {
    (ox + guide.width / 2, "north")
  } else {
    (ox, "north-west")
  }
  cetz.draw.content(
    (tx, cursor),
    text(.._text-args(s))[#resolve-prose(guide.title, eval-strings: s.typst)],
    anchor: t-anchor,
  )
}

#let _draw-swatch(guide, ctx, ox, cursor, theme, title-h) = {
  let ink = resolve-colour(theme, "ink")
  let _legend-text = _text-style(theme, "legend-text")
  let legend-text-args = _text-args(_legend-text)
  let text-size = _legend-text.size
  let size-pt = text-size / 1pt
  let line-h = _swatch-line-h-cm(size-pt)
  let glyph-size = 0.12

  if guide.title != none {
    _draw-title(guide, ox, cursor, theme)
  }
  let top = cursor - _title-prefix(guide, title-h)
  let byrow = guide.placement.byrow
  let shape = _guide-shape(guide, guide.levels.len())
  let layout = _swatch-layout(guide, shape, byrow, size-pt)
  let rows = _swatch-rows(guide, shape, byrow, size-pt)
  let key-kind = guide.at("key", default: "rect")
  let labels = guide.at("labels", default: auto)
  let align = _label-align(guide, _legend-text.align)
  let lead = _swatch-lead-cm(size-pt)
  // Horizontal legends centre / right-justify the key row under the title; the
  // vertical column stays pinned at the left edge.
  let bx = if guide.placement.direction == "horizontal" {
    (
      ox
        + _align-offset(
          _title-resolved-align(guide, theme),
          guide.width,
          layout.total,
        )
    )
  } else { ox }
  for (i, level) in guide.levels.enumerate() {
    let rc = _swatch-rc(i, shape, byrow)
    let cx = bx + layout.offsets.at(rc.col)
    // Push the row down by the overflow of every multi-line row above it, and
    // centre this item on its own block (`anchor: "west"`) by dropping it half
    // its overflow so the block grows downward and the glyph stays centred.
    let cy = top - rc.row * line-h - rows.before.at(rc.row)
    let cm = cy - glyph-size - rows.extra.at(rc.row) / 2
    let bundle = _bundle-for(level, guide.aesthetics, ctx, ink)
    draw-glyph(
      key-kind,
      cx + glyph-size,
      cm,
      glyph-size,
      bundle,
      ink: ink,
    )
    let label-text = resolve-prose(
      resolve-label(
        labels,
        level,
        i,
        level,
        typst-mark: guide.at("typst-mark", default: false),
      ),
      eval-strings: _legend-text.typst,
    )
    let label-start = cx + glyph-size * 2 + 0.15
    let slot-w = layout.widths.at(rc.col) - lead
    let (lx, l-anchor) = _hjust-right-of(align, label-start, slot-w)
    cetz.draw.content(
      (lx, cm),
      text(..legend-text-args)[#label-text],
      anchor: l-anchor,
    )
  }
}

#let _draw-size-ladder(guide, ctx, ox, cursor, theme, title-h) = {
  let ink = resolve-colour(theme, "ink")
  let _legend-text = _text-style(theme, "legend-text")
  let legend-text-args = _text-args(_legend-text)
  let text-size = _legend-text.size
  let size-pt = text-size / 1pt
  let glyph-size = _LADDER-GLYPH-CM
  let glyph-diam = guide.at("key-diam-cm", default: _GLYPH-DIAMETER-CM)
  let labels = guide.at("labels", default: auto)
  let typst-mark = guide.at("typst-mark", default: false)
  let key-kind = guide.at("key", default: "point")
  let align = _label-align(guide, _legend-text.align)

  if guide.title != none {
    _draw-title(guide, ox, cursor, theme)
  }
  let top = cursor - _title-prefix(guide, title-h)

  let label-w = _max-break-label-width(guide, guide.breaks, size-pt)
  let shape = _guide-shape(guide, guide.breaks.len())
  let byrow = guide.placement.byrow
  let break-text-of = (value, i) => resolve-prose(
    resolve-label(
      labels,
      value,
      i,
      format-break(value),
      typst-mark: typst-mark,
    ),
    eval-strings: _legend-text.typst,
  )

  if guide.placement.direction == "horizontal" {
    // A wider `size` channel grows the glyph band; centre the glyph in it and
    // push the column and label clear so neighbouring keys never overlap. Breaks
    // wrap into rows when `nrow`/`ncolumn` is set; `_ladder-h-col-w` and
    // `_ladder-h-row-stride` are shared with `_size-ladder-height` so reserve
    // and draw stay locked.
    let grows = glyph-diam > _GLYPH-DIAMETER-CM
    let band = _ladder-h-band(guide)
    let hoff = if grows { band / 2 } else { glyph-size }
    let col-w = _ladder-h-col-w(guide, label-w, size-pt)
    let row-stride = _ladder-h-row-stride(guide, size-pt)
    // Centre / right-justify the glyph band under the title.
    let bx = (
      ox
        + _align-offset(
          _title-resolved-align(guide, theme),
          guide.width,
          col-w * shape.cols,
        )
    )
    for (i, value) in guide.breaks.enumerate() {
      let rc = _swatch-rc(i, shape, byrow)
      let row-top = top - rc.row * row-stride
      let cx = bx + hoff + rc.col * col-w
      let gcy = if grows { row-top - band / 2 } else {
        row-top - glyph-size * 2
      }
      let label-y = if grows { row-top - band - 0.1 } else {
        row-top - glyph-size * 3 - 0.1
      }
      let bundle = _bundle-for(value, guide.aesthetics, ctx, ink)
      draw-glyph(key-kind, cx, gcy, hoff, bundle, ink: ink)
      let (lx, l-anchor) = _hjust-below(align, cx)
      cetz.draw.content(
        (lx, label-y),
        text(..legend-text-args)[#break-text-of(value, i)],
        anchor: l-anchor,
      )
    }
  } else {
    let m = _ladder-vmetrics(guide, size-pt)
    let line-h = m.line-h
    let off = m.off
    let rows = _ladder-rows(guide, shape, byrow, line-h, size-pt)
    let col-w = _ladder-lead-cm(size-pt) + label-w + _SWATCH-COL-GAP-MIN
    for (i, value) in guide.breaks.enumerate() {
      // Same row-stacking as the swatch: push each row down by the overflow
      // above, then centre the break on its block by dropping half its own.
      let rc = _swatch-rc(i, shape, byrow)
      let cy = top - rc.row * line-h - rows.before.at(rc.row)
      let cm = cy - off - rows.extra.at(rc.row) / 2
      let cx0 = ox + rc.col * col-w
      let bundle = _bundle-for(value, guide.aesthetics, ctx, ink)
      draw-glyph(key-kind, cx0 + off, cm, off, bundle, ink: ink)
      let (lx, l-anchor) = _hjust-right-of(align, cx0 + off * 2 + 0.15, label-w)
      cetz.draw.content(
        (lx, cm),
        text(..legend-text-args)[#break-text-of(value, i)],
        anchor: l-anchor,
      )
    }
  }
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

#let _draw-colourbar(guide, ctx, ox, cursor, theme, title-h) = {
  let horizontal = guide.placement.direction == "horizontal"
  let bar-w = if horizontal { _COLOURBAR-H-W } else { _COLOURBAR-V-W }
  let bar-h = if horizontal { _COLOURBAR-H-H } else { _COLOURBAR-V-H }
  let tick-gap = 0.08
  let tick-len = 0.1
  let bar-aes = if guide.aesthetics.contains("colour") {
    "colour"
  } else { "fill" }
  let trained = ctx.trained.at(bar-aes)
  let ink = resolve-colour(theme, "ink")
  let _legend-text = _text-style(theme, "legend-text")
  let legend-text-args = _text-args(_legend-text)
  let text-size = _legend-text.size
  let size-pt = text-size / 1pt
  let (lo, hi) = guide.domain

  if guide.title != none {
    _draw-title(guide, ox, cursor, theme)
  }
  let bar-top = cursor - _title-prefix(guide, title-h)
  let bar-bottom = bar-top - bar-h
  // Horizontal bars centre / right-justify under the title; vertical bars stay
  // at the left edge with their labels to the right.
  let bar-x = if horizontal {
    ox + _align-offset(_title-resolved-align(guide, theme), guide.width, bar-w)
  } else { ox }
  let bar-left = bar-x
  let bar-right = bar-x + bar-w
  let bar-frame = _rect-style(
    theme,
    "legend-bar",
    fallback-colour: ink,
    outset-ref-w: ctx.at("canvas-w", default: 0),
    outset-ref-h: ctx.at("canvas-h", default: 0),
  )
  // Frame rect stays glued to the bar bounds so themed `inset` cannot
  // bleed past the colourbar slot.
  let frame-lo = (bar-left, bar-bottom)
  let frame-hi = (bar-right, bar-top)
  // Backstop fill (visible through transparent gradient stops only).
  if bar-frame.fill != none {
    cetz.draw.rect(
      frame-lo,
      frame-hi,
      fill: bar-frame.fill,
      stroke: none,
    )
  }
  let pal = spec-palette(trained, ctx.palette)
  if guide.at("binned", default: false) {
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
      (bar-left, bar-bottom),
      (bar-right, bar-top),
      fill: gradient.linear(..stops, dir: if horizontal { ltr } else { btt }),
      stroke: none,
    )
  }
  if bar-frame.stroke != none {
    cetz.draw.rect(
      frame-lo,
      frame-hi,
      fill: none,
      stroke: bar-frame.stroke,
    )
  }
  let tick-stroke = _line-stroke(theme, "legend-ticks", fallback-colour: ink)
  let breaks = _colourbar-breaks(guide)
  let labels = guide.at("labels", default: auto)
  let typst-mark = guide.at("typst-mark", default: false)
  let align = _label-align(guide, _legend-text.align)
  let label-w = _max-break-label-width(guide, breaks, size-pt)
  for (i, b) in breaks.enumerate() {
    if hi == lo { continue }
    let t = (b - lo) / (hi - lo)
    if t < 0 or t > 1 { continue }
    let tick-text = resolve-prose(
      resolve-label(
        labels,
        b,
        i,
        format-break(b),
        typst-mark: typst-mark,
      ),
      eval-strings: _legend-text.typst,
    )
    let (tick-from, tick-to, label-pos, label-anchor) = if horizontal {
      let cx = bar-left + t * bar-w
      let (lx, l-anchor) = _hjust-below(align, cx)
      (
        (cx, bar-bottom),
        (cx, bar-bottom - tick-len),
        (lx, bar-bottom - tick-len - tick-gap),
        l-anchor,
      )
    } else {
      let cy = bar-bottom + t * bar-h
      let (lx, l-anchor) = _hjust-right-of(
        align,
        bar-right + tick-len + tick-gap,
        label-w,
      )
      (
        (bar-right, cy),
        (bar-right + tick-len, cy),
        (lx, cy),
        l-anchor,
      )
    }
    if tick-stroke != none {
      cetz.draw.line(tick-from, tick-to, stroke: tick-stroke)
    }
    cetz.draw.content(
      label-pos,
      text(..legend-text-args)[#tick-text],
      anchor: label-anchor,
    )
  }
}

#let _draw-custom(guide, ox, cursor, theme, title-h) = {
  let has-title = guide.title != none
  if has-title {
    _draw-title(guide, ox, cursor, theme)
  }
  let top = cursor - if has-title { title-h } else { 0.0 }
  cetz.draw.content(
    (ox, top),
    box(
      width: guide.cm-width * 1cm,
      height: guide.cm-height * 1cm,
      guide.content,
    ),
    anchor: "north-west",
  )
}

#let _draw-guide-body(g, ctx, ox, cursor, theme, title-h) = {
  if g.kind == "swatch" {
    _draw-swatch(g, ctx, ox, cursor, theme, title-h)
  } else if g.kind == "size-ladder" {
    _draw-size-ladder(g, ctx, ox, cursor, theme, title-h)
  } else if g.kind == "colourbar" {
    _draw-colourbar(g, ctx, ox, cursor, theme, title-h)
  } else if g.kind == "custom" {
    _draw-custom(g, ox, cursor, theme, title-h)
  } else {
    fail("legend.draw", "unknown guide kind " + repr(g.kind))
  }
}

// `_guide-render-height` is intentionally the same as `_guide-height` but
// takes the resolved (renderer-measured) title-h so the rendered legend
// uses real font metrics rather than the margin-sizing estimate.
#let _guide-render-height(g, title-h, size-pt) = {
  if g.kind == "swatch" { return _swatch-height(g, title-h, size-pt) }
  if g.kind == "size-ladder" {
    return _size-ladder-height(g, title-h, size-pt)
  }
  if g.kind == "colourbar" { return _colourbar-height(g, title-h, size-pt) }
  if g.kind == "custom" { return _custom-height(g, title-h) }
  fail("legend", "unknown guide kind " + repr(g.kind))
}

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
  let title-h = _legend-title-h(theme)
  let size-pt = _text-style(theme, "legend-text").size / 1pt
  let total = 0.0
  for g in side-guides {
    total += _guide-render-height(g, title-h, size-pt)
  }
  (
    total
      + _side-stack-gap(side, ctx, theme, legend-gap) * (side-guides.len() - 1)
  )
}

// Paint the legend-background rect when the theme sets a fill or a stroke;
// otherwise stay silent so plots without a themed legend backdrop look the
// same as before. `inset` grows the rect outward from the guide-stack
// bbox so the rectangle frames the legend with extra inner padding; `%`
// inset resolves against the bbox dims (so 5% means 5% of the legend's
// own width / height).
#let _draw-bg(theme, ctx, x0, y0, x1, y1) = {
  let bg = _rect-style(
    theme,
    "legend-background",
    inset-ref-w: x1 - x0,
    inset-ref-h: y1 - y0,
    outset-ref-w: ctx.at("canvas-w", default: 0),
    outset-ref-h: ctx.at("canvas-h", default: 0),
  )
  if bg.fill != none or bg.stroke != none {
    let d = bg.inset-cm
    cetz.draw.rect(
      (x0 - d.left, y0 - d.bottom),
      (x1 + d.right, y1 + d.top),
      fill: bg.fill,
      stroke: bg.stroke,
    )
  }
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
  let title-h = _legend-title-h(theme)
  let _legend-text = _text-style(theme, "legend-text")
  let size-pt = _legend-text.size / 1pt
  // Panel-to-legend gap plus the `legend-background.outset` on the panel-facing
  // side, so users can dial the spacing from the theme. The same value separates
  // the panel from the legend and stacks the guides within it.
  let gap = _side-stack-gap(side, ctx, theme, legend-gap)
  let stack-gap = gap
  let px = panel-rect.x
  let py = panel-rect.y
  let pw = panel-rect.w
  let ph = panel-rect.h

  if side == "right" or side == "left" {
    let ox = if side == "right" {
      px + pw + sec-y-extent + right-strip + gap
    } else {
      px - margin.left + 0.05
    }
    let total-h = side-stacked-height(side, side-guides, ctx, theme, legend-gap)
    let max-w = 0.0
    for g in side-guides {
      if g.width > max-w { max-w = g.width }
    }
    // Centre the stack vertically over the panel + col-strip chrome.
    // `top-strip` (facet-grid only) extends the chrome upward; wrap
    // folds the strip into `ph`, single plot leaves both at panel
    // height.
    let chrome-h = ph + top-strip
    let cursor-top = py + (chrome-h + total-h) / 2
    _draw-bg(theme, ctx, ox, cursor-top - total-h, ox + max-w, cursor-top)

    let cursor = cursor-top
    for g in side-guides {
      _draw-guide-body(g, ctx, ox, cursor, theme, title-h)
      cursor -= _guide-render-height(g, title-h, size-pt) + stack-gap
    }
  } else {
    let max-h = 0.0
    let total-w = 0.0
    for g in side-guides {
      let h = _guide-render-height(g, title-h, size-pt)
      if h > max-h { max-h = h }
      total-w += g.width
    }
    if side-guides.len() > 1 {
      total-w += stack-gap * (side-guides.len() - 1)
    }
    let cursor-y = if side == "top" {
      py + ph + sec-x-extent + gap + max-h
    } else {
      py - margin.bottom + 0.4 + max-h
    }
    // Centre the row of guides horizontally over the panel + row-strip
    // chrome. `right-strip` (facet-grid row facets) extends the chrome
    // rightward; otherwise it's zero and the legend centres over `pw`.
    let chrome-w = pw + right-strip
    let cursor-x = px + (chrome-w - total-w) / 2
    _draw-bg(
      theme,
      ctx,
      cursor-x,
      cursor-y - max-h,
      cursor-x + total-w,
      cursor-y,
    )
    for g in side-guides {
      _draw-guide-body(g, ctx, cursor-x, cursor-y, theme, title-h)
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

#let _draw-inside(g, ctx, panel-rect, theme) = {
  let title-h = _legend-title-h(theme)
  let align = g.placement.align
  let h-align = if align == none { left } else {
    let a = align.x
    if a == none { left } else { a }
  }
  let v-align = if align == none { top } else {
    let a = align.y
    if a == none { top } else { a }
  }

  let ox = if h-align == right {
    panel-rect.x + panel-rect.w - g.width
  } else if h-align == center {
    panel-rect.x + (panel-rect.w - g.width) / 2
  } else {
    panel-rect.x
  }
  let oy-top = if v-align == bottom {
    panel-rect.y + g.height
  } else if v-align == horizon {
    panel-rect.y + (panel-rect.h + g.height) / 2
  } else {
    panel-rect.y + panel-rect.h
  }

  ox += _resolve-offset(g.placement.dx, panel-rect.w)
  oy-top -= _resolve-offset(g.placement.dy, panel-rect.h)

  _draw-bg(theme, ctx, ox, oy-top - g.height, ox + g.width, oy-top)
  _draw-guide-body(g, ctx, ox, oy-top, theme, title-h)
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

// Render a free-standing legend canvas containing `guides`, all on `side`.
// Used by `compose()` to draw the shared, hoisted legend outside any plot
// panel. `panel-rect` and `margin` are tuned per side so `_draw-side`'s cursor
// math lands inside the canvas bounds:
//   right/left → cursor starts at the canvas top, advances downward.
//   top        → labels grow downward from `max-h`; baseline at 0.
//   bottom     → margin.bottom: 0.4 cancels `_draw-side`'s bottom offset.
//
// `width-cm` and `height-cm` size the canvas; the `set-viewport` call shrinks
// the cetz coordinate window to those bounds without leaving cetz's auto-pad
// margin around content (which would show up as visible whitespace).
#let standalone(guides, trained, theme, side, width-cm, height-cm) = {
  let ctx = (
    trained: trained,
    palette: default-discrete,
    theme: theme,
    canvas-w: width-cm,
    canvas-h: height-cm,
  )
  let panel-h = if side == "right" or side == "left" { height-cm } else { 0.0 }
  // Top/bottom guides centre horizontally over the panel width via
  // `_draw-side`'s `px + (chrome-w - total-w) / 2`. With a zero-width panel
  // that origin is negative and `clip: true` cuts the first swatch, so hand
  // the canvas width in as the panel width: the row then centres at
  // `(width-cm - total-w) / 2 >= 0`.
  let panel-w = if side == "top" or side == "bottom" { width-cm } else { 0.0 }
  let margin = (
    left: 0.0,
    right: 0.0,
    top: 0.0,
    bottom: if side == "bottom" { 0.4 } else { 0.0 },
  )
  block(
    width: width-cm * 1cm,
    height: height-cm * 1cm,
    above: 0pt,
    below: 0pt,
    breakable: false,
    clip: true,
    cetz.canvas(length: 1cm, padding: 0, {
      import cetz.draw: hide, rect
      hide(rect((0, 0), (width-cm, height-cm)), bounds: true)
      draw(
        guides,
        ctx,
        panel-rect: (x: 0.0, y: 0.0, w: panel-w, h: panel-h),
        margin: margin,
        theme: theme,
      )
    }),
  )
}
