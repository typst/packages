// Faceting: strip styling/drawing, facet keyers, label measurement, and the
// per-panel layer preparation that partitions data into facet panels.

#import "../deps.typ": cetz
#import "../theme/theme.typ": _rect-style, _text-args, _text-style
#import "../utils/typst-markup.typ": eval-as-markup, resolve-prose
#import "../utils/measure.typ": longest-unbreakable-cm, measure-text-cm
#import "../utils/gutter.typ": resolve-gutter
#import "../geom/label-draw.typ" as label-draw
#import "../facet/labellers.typ" as labellers
#import "../data.typ": group-by
#import "common.typ": _per-side, _resolve-data
#import "prestat.typ": _raw-levels-for
#import "layer-prep.typ": prepare-layers
#import "extents.typ": _title-boxed

// The gutter a facet spec asks for, resolved against the theme's panel
// spacing. Lives here rather than in the canvas builder so the chrome can
// reserve against the same tracks the builder lays out.
#let _facet-gutter(facet, theme, scope) = resolve-gutter(
  if facet.at("gutter", default: auto) == auto {
    theme.at("panel-spacing", default: 0.5cm)
  } else { facet.gutter },
  scope: scope,
)

// The gutter a grid of `count` tracks can afford across `extent` cm.
// Whitespace between panels is the first thing a small plot gives up, but it
// never takes more than half the grid: past that the panels it separates have
// nothing left to separate.
#let _fit-gutter(gutter, extent, count) = {
  if count <= 1 { return gutter }
  calc.min(gutter, calc.max(0.0, extent) / (2 * (count - 1)))
}

// Column and row counts a `facet-wrap` over `n` levels lays out: an explicit
// `ncolumn` wins, then `nrow`, then the squarest grid holding the levels.
#let _wrap-tracks(facet, n) = {
  let ncol = if facet.ncolumn != none {
    facet.ncolumn
  } else if facet.nrow != none {
    calc.ceil(n / facet.nrow)
  } else {
    calc.max(1, int(calc.ceil(calc.sqrt(n))))
  }
  (ncol, calc.max(1, int(calc.ceil(n / ncol))))
}

#let _render-style(theme) = (
  strip-text: _text-style(theme, "strip-text"),
  ax-title: _per-side(
    (p, s, _) => _text-style(theme, p + "-" + s),
    "axis-title",
  ),
)

// Draw one facet strip: a filled rectangle with the labeller text centred
// inside. Shared between facet-wrap (top strip) and facet-grid (top + side
// strips). `angle` is `-90deg` for the rotated row-strip, else `0deg`. Text
// stays centred on the natural band so themed inset offsets paint past
// the band without dragging the label with them. `%` on inset resolves
// against the band's own dims (band-w x band-h) so a 5% inset paints
// inside the band rather than overflowing onto neighbouring panels.
#let _draw-strip(
  corner-lo,
  corner-hi,
  label-text,
  style,
  theme,
  angle: 0deg,
  along-cm: none,
) = {
  let strip = _rect-style(
    theme,
    "strip-background",
    fallback-fill: theme.paper,
  )
  cetz.draw.rect(
    corner-lo,
    corner-hi,
    fill: strip.fill,
    stroke: strip.stroke,
  )
  let (cx, cy) = (
    (corner-lo.at(0) + corner-hi.at(0)) / 2,
    (corner-lo.at(1) + corner-hi.at(1)) / 2,
  )
  // Default centred. `left`/`right` slide the label to the matching end of
  // the band: along x for the top strip, along the reading direction (top
  // strip rotated, bottom is `right`) for the -90deg row strip.
  let a = style.strip-text.align
  let (sx, sy, s-anchor) = if angle == 0deg {
    if a == left {
      (corner-lo.at(0), cy, "west")
    } else if a == right {
      (corner-hi.at(0), cy, "east")
    } else { (cx, cy, "center") }
  } else {
    if a == left {
      (cx, corner-hi.at(1), "north")
    } else if a == right {
      (cx, corner-lo.at(1), "south")
    } else { (cx, cy, "center") }
  }
  // The orientation angle fixes the band's reading direction; a theme
  // `strip-text` angle spins the glyphs further within the chosen anchor.
  let user-angle = style.strip-text.angle
  // A label longer than the band it names is drawn in the box the band was
  // measured against, so it wraps onto further lines instead of running off
  // the panel grid. `_strip-band` measures through the same box.
  let body = {
    let resolved = text(.._text-args(style.strip-text))[#resolve-prose(
      label-text,
      eval-strings: style.strip-text.typst,
    )]
    if along-cm == none { resolved } else {
      _title-boxed(resolved, along-cm, if a == none { center } else { a })
    }
  }
  cetz.draw.content(
    (sx, sy),
    body,
    angle: angle + (if user-angle != none { user-angle } else { 0deg }),
    anchor: s-anchor,
  )
}

// Resolve the strip text for every facet level once. The labeller text is
// needed both to size the strip band and (in facet-grid) to draw it, so it
// is computed up front rather than inside the cetz canvas closure, which
// cannot `measure` (the operation `_strip-band` relies on). `count-of` maps
// a level index to the row count fed to a context labeller.
#let _strip-texts(labeller, var, levels, count-of) = {
  levels
    .enumerate()
    .map(((i, lv)) => labellers.format(labeller, var, lv, count: count-of(i)))
}

// cm extent of a strip band sized to the tallest label, floored at `base`.
// A wrapped labeller (`label-wrap`) emits `\n`-joined lines, so the rendered
// height grows with the line count; `pad` keeps the same breathing room the
// old fixed constants gave a single line. For the rotated row-strip the
// measured height is the band's *width*, which is exactly what the caller
// wants.
//
// Returns `(band, text, alongs, min-width)`: the band to lay out, the label
// height alone, which is the floor no budget gets under, the box the draw side
// must reproduce for each label (`none` for a label that needed none), and the
// widest unbreakable run among the labels that took a box. `budget` is the room
// the grid can spare for one band: the fixed `base` gives way to it first,
// since it is breathing room rather than ink, and the label height last. Leave
// it `none` and the band is measured exactly as it always was. `along-cm`
// bounds the label's reading direction, the way `_axis-title-extents` bounds a
// title, so a label wider than its panel wraps instead of running off the
// canvas. The decision is per label: a label that fits is left alone even when
// the one beside it wraps.
#let _strip-band(labels, style, base, budget: none, along-cm: none) = {
  let size = style.strip-text.size
  let pad = 0.16
  let text-cm = 0.0
  let alongs = ()
  let min-width = 0.0
  for label in labels {
    let prose = resolve-prose(label, eval-strings: style.strip-text.typst)
    let natural = measure-text-cm(prose, size)
    if along-cm == none or natural.width <= along-cm {
      text-cm = calc.max(text-cm, natural.height)
      alongs.push(none)
      continue
    }
    // A label wider than its band is drawn boxed to it, so it is measured
    // through that same box and the band holds the lines it wraps onto. A word
    // wider than the box cannot wrap into it, which `min-width` reports.
    let boxed = measure(_title-boxed(
      text(.._text-args(style.strip-text))[#prose],
      along-cm,
      center,
    ))
    text-cm = calc.max(text-cm, boxed.height / 1cm)
    alongs.push(along-cm)
    min-width = calc.max(min-width, longest-unbreakable-cm(prose, size))
  }
  text-cm += pad
  let band = if budget == none {
    calc.max(base, text-cm)
  } else {
    calc.max(text-cm, calc.min(calc.max(base, text-cm), budget))
  }
  (band: band, text: text-cm, alongs: alongs, min-width: min-width)
}


// ASCII Unit Separator joins the two grid-facet level strings into a single
// dict key. Assumed absent from any user-facing facet level.
#let _facet-key-sep = "\u{1F}"

// Build a (row-key-fn, panel-key-fn) pair for a grid facet spec, specialised
// on which of `rows` / `cols` is set. The row-key-fn is invoked once per data
// row inside `group-by` and must avoid per-row allocation. `none` values are
// coerced to "" so rows with missing facet variables drop out (panel levels
// from `_raw-levels-for` exclude `none`).
#let _facet-cell-str(row, col) = {
  let v = row.at(col, default: none)
  if v == none { "" } else { str(v) }
}

#let _grid-facet-keyers(spec) = {
  let r = spec.facet.rows
  let c = spec.facet.columns
  if r != none and c != none {
    return (
      row: row => (
        _facet-cell-str(row, r) + _facet-key-sep + _facet-cell-str(row, c)
      ),
      panel: (rl, cl) => rl + _facet-key-sep + cl,
    )
  }
  if r != none {
    return (
      row: row => _facet-cell-str(row, r),
      panel: (rl, _) => rl,
    )
  }
  (
    row: row => _facet-cell-str(row, c),
    panel: (_, cl) => cl,
  )
}

// Typst `measure()` is unreachable inside cetz canvas closures, so size each
// row's final label here and stash the result on the layer. The segment
// router consumes the sizes to clip connectors at the label edge and to
// detect crossings against sibling labels.
#let _measure-label-sizes(layer) = {
  let geom = layer.at("name", default: none)
  if geom not in label-draw.LABEL-GEOMS { return layer }
  let params = layer.at("params", default: (:))
  if not (
    params.at("segment", default: false) or params.at("repel", default: false)
  ) { return layer }
  let mapping = layer.at("mapping", default: none)
  if mapping == none { return layer }
  let label-col = mapping.at("label", default: none)
  let const-label = params.at("label", default: none)
  let use-const = const-label != none
  if not use-const and label-col == none { return layer }
  let label-typst = (
    layer.at("typst-marks", default: (:)).at("label", default: false)
      or geom == "typst"
  )
  let size = params.at("size", default: 8pt)
  let inset = params.at("inset", default: 0pt)
  let inset-cm = if type(inset) == length { inset / 1cm } else { 0.0 }
  // Measure each distinct label once; repeated per-row values (and the
  // constant-label case) reuse the cached extent.
  let measure-entry = label => {
    let rendered = if label-typst and type(label) == str {
      eval-as-markup(label)
    } else { label }
    let m = measure-text-cm(rendered, size)
    (w: m.width + 2 * inset-cm, h: m.height + 2 * inset-cm)
  }
  let const-entry = if use-const { measure-entry(const-label) } else { none }
  let cache = (:)
  let sizes = ()
  for row in layer.at("data", default: ()) {
    if use-const {
      sizes.push(const-entry)
      continue
    }
    let label = row.at(label-col, default: none)
    if label == none {
      sizes.push((w: 0.0, h: 0.0))
      continue
    }
    if type(label) == str {
      if label not in cache { cache.insert(label, measure-entry(label)) }
      sizes.push(cache.at(label))
    } else {
      sizes.push(measure-entry(label))
    }
  }
  let new = layer
  new.insert("_label-sizes", sizes)
  new
}

#let _render-prepare(spec, theme) = {
  let facet-wrap-mode = spec.facet != none and spec.facet.name == "wrap"
  let facet-grid-mode = spec.facet != none and spec.facet.name == "grid"
  let coord = spec.at("coord", default: none)

  let wrap-levels = if facet-wrap-mode {
    _raw-levels-for(spec, spec.facet.variable)
  } else { () }

  let grid-row-levels = if facet-grid-mode and spec.facet.rows != none {
    _raw-levels-for(spec, spec.facet.rows)
  } else if facet-grid-mode { ("",) } else { () }
  let grid-col-levels = if facet-grid-mode and spec.facet.columns != none {
    _raw-levels-for(spec, spec.facet.columns)
  } else if facet-grid-mode { ("",) } else { () }

  // Partition each layer's data once by the facet key, then look up each
  // panel's subset in O(1).
  let panels = if facet-wrap-mode {
    let var = spec.facet.variable
    let layer-groups = spec.layers.map(l => group-by(
      _resolve-data(l, spec.data),
      row => _facet-cell-str(row, var),
    ))
    wrap-levels.map(level => (
      level: level,
      layers: prepare-layers(
        spec
          .layers
          .enumerate()
          .map(((i, l)) => {
            let with-subset = l
            with-subset.data = layer-groups.at(i).at(level, default: ())
            with-subset.insert("data-trusted", true)
            with-subset
          }),
        spec.mapping,
        spec.data,
        theme: theme,
        coord: coord,
      ),
    ))
  } else if facet-grid-mode {
    let keyers = _grid-facet-keyers(spec)
    let layer-groups = spec.layers.map(l => group-by(
      _resolve-data(l, spec.data),
      keyers.row,
    ))
    let out = ()
    for row-lv in grid-row-levels {
      for col-lv in grid-col-levels {
        let key = (keyers.panel)(row-lv, col-lv)
        out.push((
          row-level: row-lv,
          col-level: col-lv,
          layers: prepare-layers(
            spec
              .layers
              .enumerate()
              .map(((i, l)) => {
                let with-subset = l
                with-subset.data = layer-groups.at(i).at(key, default: ())
                with-subset.insert("data-trusted", true)
                with-subset
              }),
            spec.mapping,
            spec.data,
            theme: theme,
            coord: coord,
          ),
        ))
      }
    }
    out
  } else { () }

  let prepared = if facet-wrap-mode or facet-grid-mode {
    let union = ()
    for panel in panels { union += panel.layers }
    union
  } else {
    prepare-layers(
      spec.layers,
      spec.mapping,
      spec.data,
      theme: theme,
      coord: coord,
    )
  }

  (
    facet-wrap-mode: facet-wrap-mode,
    facet-grid-mode: facet-grid-mode,
    wrap-levels: wrap-levels,
    grid-row-levels: grid-row-levels,
    grid-col-levels: grid-col-levels,
    panels: panels,
    prepared: prepared,
  )
}
