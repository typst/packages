// Faceting: strip styling/drawing, facet keyers, label measurement, and the
// per-panel layer preparation that partitions data into facet panels.

#import "../deps.typ": cetz
#import "../theme/theme.typ": _rect-style, _text-args, _text-style
#import "../utils/typst-markup.typ": eval-as-markup, resolve-prose
#import "../utils/measure.typ": measure-labels-cm, measure-text-cm
#import "../utils/label-draw.typ" as label-draw
#import "../facet/labellers.typ" as labellers
#import "../data.typ": group-by
#import "common.typ": _per-side, _resolve-data
#import "prestat.typ": _raw-levels-for
#import "layer-prep.typ": _prepare-layer

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
  cetz.draw.content(
    (sx, sy),
    text(.._text-args(style.strip-text))[#resolve-prose(
      label-text,
      eval-strings: style.strip-text.typst,
    )],
    angle: angle,
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
#let _strip-band(labels, style, base) = {
  let prose = labels.map(l => resolve-prose(
    l,
    eval-strings: style.strip-text.typst,
  ))
  let pad = 0.16
  calc.max(base, measure-labels-cm(prose, style.strip-text.size).height + pad)
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
  let geom = layer.at("geom", default: none)
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
  let sizes = layer
    .at("data", default: ())
    .map(row => {
      let label = if use-const { const-label } else {
        row.at(label-col, default: none)
      }
      if label == none { return (w: 0.0, h: 0.0) }
      if label-typst and type(label) == str { label = eval-as-markup(label) }
      let m = measure-text-cm(label, size)
      (w: m.width + 2 * inset-cm, h: m.height + 2 * inset-cm)
    })
  let new = layer
  new.insert("_label-sizes", sizes)
  new
}

#let _render-prepare(spec, theme) = {
  let facet-wrap-mode = spec.facet != none and spec.facet.facet == "wrap"
  let facet-grid-mode = spec.facet != none and spec.facet.facet == "grid"
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
      layers: spec
        .layers
        .enumerate()
        .map(((i, l)) => {
          let with-subset = l
          with-subset.data = layer-groups.at(i).at(level, default: ())
          with-subset.insert("data-trusted", true)
          _prepare-layer(
            with-subset,
            spec.mapping,
            spec.data,
            theme: theme,
            coord: coord,
          )
        }),
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
          layers: spec
            .layers
            .enumerate()
            .map(((i, l)) => {
              let with-subset = l
              with-subset.data = layer-groups.at(i).at(key, default: ())
              with-subset.insert("data-trusted", true)
              _prepare-layer(
                with-subset,
                spec.mapping,
                spec.data,
                theme: theme,
                coord: coord,
              )
            }),
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
    spec.layers.map(l => _prepare-layer(
      l,
      spec.mapping,
      spec.data,
      theme: theme,
      coord: coord,
    ))
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
