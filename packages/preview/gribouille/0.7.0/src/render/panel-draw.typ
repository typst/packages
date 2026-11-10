// Panel renderer: the geom-dispatch table and `_draw-axis-and-layers`, which
// draws one panel's background, gridlines, axes (cartesian + radial), geom
// marks, axis titles, and any panel-local legend.

#import "../deps.typ": cetz
#import "../utils/errors.typ": fail
#import "../scale/train.typ": map-axis-data, map-break, mapping-display-name
#import "../theme/defaults.typ": resolve-colour
#import "../theme/theme.typ": (
  _line-stroke, _rect-style, _text-args, resolve-theme-palette,
  surface-set-below,
)
#import "../utils/radial.typ": radial-ctx, theta-axis-of
#import "../utils/typst-markup.typ": resolve-prose
#import "../utils/aes-resolve.typ": resolve-label
#import "../utils/format.typ": format-break
#import "../utils/palette.typ": spec-attr
#import "../scale/secondary.typ" as secondary-mod
#import "legend.typ" as legend-mod
#import "common.typ": (
  _per-side, _resolve-data, _resolve-mapping, _should-draw-tick, _text-sides,
  _tick-cm-sides,
)
#import "colour.typ": _make-resolve-colour
#import "panel-radial.typ": (
  _draw-radial-panel, _draw-radial-r-labels, theta-band,
)
#import "axis-format.typ": (
  _axis-breaks, _axis-minor-breaks, _axis-tick-values, _axis-title, _sec-spec,
  _secondary-breaks, _tick-label-fallback,
)
#import "axis-parts.typ": axis-entries, draw-axis-band
#import "guides.typ": _axis-text-angle, _read-axis-guide, _read-theta-guide
#import "extents.typ": (
  _AX-TITLE-LABEL-GAP, _TICK-LABEL-GAP, _resolve-extents, _sec-title-offset-cm,
  _text-margin-cm, _theta-label-bounds, _title-angle, _title-body,
  _title-extent-cm, _x-title-place, _y-title-place,
)

#import "../geom/point.typ" as point-geom
#import "../geom/line.typ" as line-geom
#import "../geom/path.typ" as path-geom
#import "../geom/step.typ" as step-geom
#import "../geom/area.typ" as area-geom
#import "../geom/rect.typ" as rect-geom
#import "../geom/tile.typ" as tile-geom
#import "../geom/segment.typ" as segment-geom
#import "../geom/curve.typ" as curve-geom
#import "../geom/spoke.typ" as spoke-geom
#import "../geom/polygon.typ" as polygon-geom
#import "../geom/ellipse.typ" as ellipse-geom
#import "../geom/mark.typ" as mark-geom
#import "../geom/col.typ" as col-geom
#import "../geom/ribbon.typ" as ribbon-geom
#import "../geom/smooth.typ" as smooth-geom
#import "../geom/hline.typ" as hline-geom
#import "../geom/vline.typ" as vline-geom
#import "../geom/abline.typ" as abline-geom
#import "../geom/text.typ" as text-geom
#import "../geom/typst.typ" as typst-geom
#import "../geom/label.typ" as label-geom
#import "../geom/boxplot.typ" as boxplot-geom
#import "../geom/violin.typ" as violin-geom
#import "../geom/density-ridges.typ" as density-ridges-geom
#import "../geom/errorbar.typ" as errorbar-geom
#import "../geom/errorbarh.typ" as errorbarh-geom
#import "../geom/linerange.typ" as linerange-geom
#import "../geom/crossbar.typ" as crossbar-geom
#import "../geom/pointrange.typ" as pointrange-geom
#import "../geom/blank.typ" as blank-geom
#import "../geom/rug.typ" as rug-geom
#import "../geom/function.typ" as function-geom
#import "../geom/dotplot.typ" as dotplot-geom
#import "../geom/hex.typ" as hex-geom

// Single source of truth for layer dispatch in `_draw-axis-and-layers`.
// Each entry maps a layer's `geom` string to its `draw(layer, ctx)` function.
// Adding a new geom only requires importing it above and adding an entry here.
#let _geom-draw = (
  point: point-geom.draw,
  line: line-geom.draw,
  path: path-geom.draw,
  step: step-geom.draw,
  area: area-geom.draw,
  rect: rect-geom.draw,
  tile: tile-geom.draw,
  segment: segment-geom.draw,
  curve: curve-geom.draw,
  spoke: spoke-geom.draw,
  polygon: polygon-geom.draw,
  ellipse: ellipse-geom.draw,
  mark: mark-geom.draw,
  col: col-geom.draw,
  ribbon: ribbon-geom.draw,
  smooth: smooth-geom.draw,
  hline: hline-geom.draw,
  vline: vline-geom.draw,
  abline: abline-geom.draw,
  text: text-geom.draw,
  typst: typst-geom.draw,
  label: label-geom.draw,
  boxplot: boxplot-geom.draw,
  violin: violin-geom.draw,
  "density-ridges": density-ridges-geom.draw,
  errorbar: errorbar-geom.draw,
  errorbarh: errorbarh-geom.draw,
  linerange: linerange-geom.draw,
  crossbar: crossbar-geom.draw,
  pointrange: pointrange-geom.draw,
  blank: blank-geom.draw,
  rug: rug-geom.draw,
  function: function-geom.draw,
  dotplot: dotplot-geom.draw,
  hex: hex-geom.draw,
)

// Layers whose `geom` is missing from this set panic under `coord-radial`
// rather than silently falling back to cartesian rendering. Every registered
// geom is currently radial-aware; the check below guards against typos and
// future geoms that intentionally opt out. Stored as a dict-set so per-layer
// membership tests are O(1) instead of an array scan.
#let _RADIAL-AWARE = {
  let s = (:)
  for k in _geom-draw.keys() { s.insert(k, true) }
  s
}

#let _draw-axis-and-layers(
  prepared,
  trained,
  theme,
  spec,
  origin,
  inner-size,
  guides: (),
  legend-args: none,
  show-x-labels: true,
  show-y-labels: true,
  show-x-title: true,
  show-y-title: true,
  show-x-sec: true,
  show-y-sec: true,
  // Facet builders draw one secondary title for the whole grid, the way they
  // already do for the primary pair, so their panels keep the secondary ticks
  // and labels but drop the title.
  show-x-sec-title: true,
  show-y-sec-title: true,
  flipped: false,
  axis-breaks: none,
  x-extents: none,
  y-extents: none,
  x-title-extents: none,
  y-title-extents: none,
  x-sec-title-extents: none,
  y-sec-title-extents: none,
  x-sec-extents: none,
  y-sec-extents: none,
  // Band between the panel edge and its axis title, gap included, as
  // `_chrome-margins` reserved it. Carried rather than recomputed so the title
  // cannot land outside its own margin. The facet builders draw one title for
  // the whole grid and pass `show-x-title: false`, so these go unread there.
  x-edge-band: 0.0,
  y-edge-band: 0.0,
  canvas-w: 0,
  canvas-h: 0,
) = {
  import cetz.draw: *
  let (ox, oy) = origin
  let (iw, ih) = inner-size
  let px-lo = ox
  let px-hi = ox + iw
  let py-lo = oy
  let py-hi = oy + ih
  // `px-range`/`py-range` carry the inset *data area* (panel bounds shrunk by
  // any canvas-cm padding from `view-pad-cm`), so geoms and ticks land on the
  // correct data positions. Bare `px-lo`/`py-lo`/`px-hi`/`py-hi` keep the
  // outer panel bounds and are used for axis lines, panel fill, and gridline
  // endpoints that span the full panel.
  let _read-pad(t) = if t == none { (0, 0) } else {
    t.at("view-pad-cm", default: (0, 0))
  }
  let (x-pad-lo, x-pad-hi) = _read-pad(trained.at("x", default: none))
  let (y-pad-lo, y-pad-hi) = _read-pad(trained.at("y", default: none))
  let px-range = (px-lo + x-pad-lo, px-hi - x-pad-hi)
  let py-range = (py-lo + y-pad-lo, py-hi - y-pad-hi)

  let _ink = resolve-colour(theme, "ink")
  let _ax-text = _text-sides(theme, "axis-text")
  let _ax-title = _text-sides(theme, "axis-title")

  let _resolve-mapping-flipped(layer) = {
    let m = _resolve-mapping(layer, spec.mapping)
    if not flipped or m == none { return m }
    let x = m.at("x", default: none)
    let y = m.at("y", default: none)
    let out = m
    out.insert("x", y)
    out.insert("y", x)
    out
  }

  // Canonical per-draw context handed to every geom's `draw(layer, ctx)`
  // (GLOSSARY.md "ctx"): `trained`, `px-range`/`py-range` (panel extents in
  // canvas cm), `palette`, the `resolve-mapping`/`resolve-data`/
  // `resolve-colour` closures, `theme`, `flipped`, `canvas-w`/`canvas-h`.
  // The geom-dispatch copy (`inner-ctx`, below) additionally carries
  // `radial` (`none` on cartesian panels); read optional keys with
  // `ctx.at(key, default: ...)`.
  let ctx = (
    trained: trained,
    px-range: px-range,
    py-range: py-range,
    palette: resolve-theme-palette(theme),
    resolve-mapping: layer => _resolve-mapping-flipped(layer),
    resolve-data: layer => _resolve-data(layer, spec.data),
    resolve-colour: _make-resolve-colour(_ink),
    theme: theme,
    flipped: flipped,
    canvas-w: canvas-w,
    canvas-h: canvas-h,
  )

  let x-trained = trained.at("x", default: none)
  let y-trained = trained.at("y", default: none)

  let coord = spec.at("coord", default: none)
  // How a scale's own `labels` and its typst marking reach the tick labels of
  // every axis the panel draws, angular and radial included.
  let _axis-display(trained) = (
    typst-mark: if trained != none {
      trained.at("typst-mark", default: false)
    } else { false },
    labels: spec-attr(trained, "labels", fallback: auto),
  )
  let _x-disp = _axis-display(x-trained)
  let _y-disp = _axis-display(y-trained)

  // The theta tick labels ring the circle just outside it, so the circle has
  // to leave them room inside the panel: the panel is all the room the chrome
  // granted, and a label past its edge grows the whole figure past the
  // requested `width`/`height`. Gate the band on the same conditions the draw
  // does, so a suppressed or blank theta axis gives it back.
  let _theta-guide = _read-theta-guide(spec)
  let _theta-key = theta-axis-of(coord)
  let _label-bounds = if _theta-key == none { () } else {
    let _theta-text = if _theta-key == "x" { _ax-text.xb } else { _ax-text.yl }
    if (
      _theta-text.size > 0pt
        and not (_theta-guide != none and _theta-guide.suppress)
    ) {
      _theta-label-bounds(
        _resolve-extents(
          if _theta-key == "x" { x-extents } else { y-extents },
          _theta-text.size,
        ).at("groups", default: ()),
        if _theta-guide == none { 0 } else { _theta-guide.angle },
      )
    } else { () }
  }
  // The theta ticks sit between the circle and those labels, so the angular
  // axis is laid out here rather than with the cartesian sides below: the
  // radius owes its ticks their length before either can be placed.
  let _theta-y = _theta-key == "y"
  let _theta-band = theta-band(
    theme,
    coord,
    _theta-guide,
    if _theta-y { y-trained } else { x-trained },
    _theta-key,
    if _theta-y { _y-disp } else { _x-disp },
    if _theta-y { _ax-text.yl } else { _ax-text.xb },
    _resolve-extents(
      if _theta-y { y-extents } else { x-extents },
      if _theta-y { _ax-text.yl.size } else { _ax-text.xb.size },
    ),
  )
  let outer-radial = radial-ctx(
    coord,
    x-trained,
    y-trained,
    px-range,
    py-range,
    label-bounds: _label-bounds,
    tick-cm: _theta-band.reach,
  )
  let is-radial = outer-radial != none

  let _panel = _rect-style(
    theme,
    "panel-background",
    fallback-fill: theme.paper,
    outset-ref-w: canvas-w,
    outset-ref-h: canvas-h,
  )
  // Panel rect stays glued to the natural panel canvas so a themed `inset`
  // cannot bleed past adjacent facets or chrome. Visible breathing room
  // around a panel is the job of `outset` (chrome reservation upstream).
  if _panel.fill != none or _panel.stroke != none {
    if is-radial {
      cetz.draw.circle(
        outer-radial.centre,
        radius: outer-radial.r-max,
        fill: _panel.fill,
        stroke: _panel.stroke,
      )
    } else {
      rect(
        (px-lo, py-lo),
        (px-hi, py-hi),
        fill: _panel.fill,
        stroke: _panel.stroke,
      )
    }
  }

  let _grid-stroke = surface => _line-stroke(
    theme,
    surface,
    fallback-colour: _ink,
  )
  let _grid-major = (
    x: _grid-stroke("panel-grid-major-x"),
    y: _grid-stroke("panel-grid-major-y"),
  )
  let _grid-minor = (
    x: _grid-stroke("panel-grid-minor-x"),
    y: _grid-stroke("panel-grid-minor-y"),
  )
  // A discrete axis draws no gridlines by default, since its ticks already mark
  // every level. A grid element set on the major weight or on one axis is a
  // deliberate request, so it wins; an inherited `panel-grid` is not.
  let _grid-discrete = (
    x: surface-set-below(theme, "panel-grid-major-x", "panel-grid"),
    y: surface-set-below(theme, "panel-grid-major-y", "panel-grid"),
  )
  // Radial panels draw one grid weight for both circles and spokes; the
  // per-axis split and minor lines apply to cartesian panels only.
  let _grid-radial = _grid-stroke("panel-grid-major")
  let _grid-radial-discrete = surface-set-below(
    theme,
    "panel-grid-major",
    "panel-grid",
  )
  let _stroke-side = (p, s, _) => _line-stroke(
    theme,
    p + "-" + s,
    fallback-colour: _ink,
  )
  let _ax-line = _per-side(_stroke-side, "axis-line")
  let _ax-ticks = _per-side(_stroke-side, "axis-ticks")
  let _tick-len = _tick-cm-sides(theme)

  let x-guide = _read-axis-guide(spec, "x", default-angle: _axis-text-angle(
    theme,
    "x",
  ))
  let y-guide = _read-axis-guide(spec, "y", default-angle: _axis-text-angle(
    theme,
    "y",
  ))
  // What one cartesian axis walks: the breaks, where they map to, and whether
  // the guide suppressed the band. `none` where the panel draws no cartesian
  // axis at all, which is every radial panel and every axis without a scale.
  //
  // Continuous and discrete axes share everything except where the breaks come
  // from, so only that branches here.
  let _cartesian-walk(axis, trained) = {
    if is-radial or trained == none { return none }
    let is-continuous = trained.type == "continuous"
    if not is-continuous and trained.type != "discrete" { return none }
    let cached = if axis-breaks == none { none } else {
      axis-breaks.at(axis, default: none)
    }
    (
      is-continuous: is-continuous,
      breaks: if is-continuous and cached != none {
        cached
      } else { _axis-tick-values(trained) },
      range: if axis == "x" { px-range } else { py-range },
      suppress: if axis == "x" { x-guide.suppress } else { y-guide.suppress },
    )
  }

  // Gridlines for one axis. They are panel furniture rather than part of the
  // axis band: they mark where a break crosses the panel, so they stay with the
  // panel whatever draws the ticks and the labels outside it.
  //
  // A discrete axis draws majors only when the theme asks for them per weight or
  // per axis, and never draws minors: a gap between levels has no subdivision.
  let _draw-cartesian-grid(axis, trained, walk) = {
    if walk == none { return }
    let major-stroke = if axis == "x" { _grid-major.x } else { _grid-major.y }
    let minor-stroke = if axis == "x" { _grid-minor.x } else { _grid-minor.y }
    let major-discrete = if axis == "x" {
      _grid-discrete.x
    } else { _grid-discrete.y }
    // Minor gridlines sit under the majors, so draw them first.
    if walk.is-continuous and minor-stroke != none {
      for mb in _axis-minor-breaks(trained, walk.breaks) {
        let mc = map-axis-data(trained, mb, walk.range)
        if axis == "x" {
          line((mc, py-lo), (mc, py-hi), stroke: minor-stroke)
        } else {
          line((px-lo, mc), (px-hi, mc), stroke: minor-stroke)
        }
      }
    }
    if major-stroke == none or not (walk.is-continuous or major-discrete) {
      return
    }
    for b in walk.breaks {
      let c = map-break(trained, b, walk.range)
      if axis == "x" {
        line((c, py-lo), (c, py-hi), stroke: major-stroke)
      } else {
        line((px-lo, c), (px-hi, c), stroke: major-stroke)
      }
    }
  }

  // The label one break reads, or nothing where the band draws no labels at
  // all: a facet cell that leaves them to the edge panel, or a theme that
  // blanked `axis-text`. An entry with no label still ticks.
  let _band-labels(trained, walk, disp, style, shown) = {
    if not shown or style.size == 0pt { return () }
    walk
      .breaks
      .enumerate()
      .map(((idx, b)) => resolve-prose(
        resolve-label(
          disp.labels,
          b,
          idx,
          _tick-label-fallback(trained, b),
          typst-mark: disp.typst-mark,
        ),
        eval-strings: style.typst,
      ))
  }

  // The entry table one axis band annotates: one row per break, plus the
  // sub-decade rows a log axis ticks. Every row carries the widest label the
  // chrome stage measured, which is the figure the band it reserved was sized
  // from, so the panel draws inside the room it was given.
  let _band-entries(axis, trained, walk, guide, disp, style, shown, extents) = {
    if walk == none { return () }
    let ext = _resolve-extents(extents, style.size)
    let labels = _band-labels(trained, walk, disp, style, shown)
    axis-entries(
      trained,
      guide,
      walk.breaks,
      labels: labels,
      extent: if labels.len() == 0 { (0.0, 0.0) } else {
        (ext.width, ext.height)
      },
    )
  }
  let _x-walk = _cartesian-walk("x", x-trained)
  let _y-walk = _cartesian-walk("y", y-trained)
  _draw-cartesian-grid("x", x-trained, _x-walk)
  draw-axis-band(
    theme,
    "x",
    x-guide,
    _band-entries(
      "x",
      x-trained,
      _x-walk,
      x-guide,
      _x-disp,
      _ax-text.xb,
      show-x-labels,
      x-extents,
    ),
    px-range,
    (py-lo, py-hi),
  )
  _draw-cartesian-grid("y", y-trained, _y-walk)
  draw-axis-band(
    theme,
    "y",
    y-guide,
    _band-entries(
      "y",
      y-trained,
      _y-walk,
      y-guide,
      _y-disp,
      _ax-text.yl,
      show-y-labels,
      y-extents,
    ),
    py-range,
    (px-lo, px-hi),
  )

  // Secondary x-axis: draw on top edge if the trained x scale carries a
  // secondary spec. Breaks are its own when set, else the primary axis grid;
  // their labels go through the user's transformation function.
  let _x-sec = _sec-spec(x-trained, coord: coord)
  if _x-sec != none and show-x-sec {
    let breaks = if axis-breaks != none and axis-breaks.x-sec != none {
      axis-breaks.x-sec
    } else {
      _secondary-breaks(x-trained, _x-sec, _axis-breaks(x-trained))
    }
    for (idx, b) in breaks.enumerate() {
      let cx = map-axis-data(x-trained, b, px-range)
      if _should-draw-tick(_ax-ticks.xt, _tick-len.xt) {
        line((cx, py-hi), (cx, py-hi + _tick-len.xt), stroke: _ax-ticks.xt)
      }
      if _ax-text.xt.size > 0pt {
        let mapped = secondary-mod.apply-transform(_x-sec, b)
        content(
          (cx, py-hi + _tick-len.xt + _TICK-LABEL-GAP),
          text(.._text-args(_ax-text.xt))[#resolve-prose(
            resolve-label(
              _x-sec.at("labels", default: auto),
              mapped,
              idx,
              format-break(mapped),
              typst-mark: _x-disp.typst-mark,
            ),
            eval-strings: _ax-text.xt.typst,
          )],
          anchor: "south",
        )
      }
    }
    if _ax-line.xt != none {
      line((px-lo, py-hi), (px-hi, py-hi), stroke: _ax-line.xt)
    }
    if show-x-sec-title and _x-sec.name != none and _ax-title.xt.size > 0pt {
      let x-sec-offset = _sec-title-offset-cm(
        _tick-len.xt,
        _resolve-extents(x-sec-extents, _ax-text.xt.size),
        _ax-title.xt,
        "x",
      )
      let (cx, x-anchor) = _x-title-place(_ax-title.xt.align, px-lo, px-hi)
      content(
        (cx, py-hi + x-sec-offset),
        _title-body(
          _x-sec.name,
          _ax-title.xt,
          x-sec-title-extents,
        ),
        anchor: x-anchor,
        angle: _title-angle(_ax-title.xt, 0),
      )
    }
  }

  // Secondary y-axis: draw on right edge if the trained y scale carries a
  // secondary spec.
  let _y-sec = _sec-spec(y-trained, coord: coord)
  if _y-sec != none and show-y-sec {
    let breaks = if axis-breaks != none and axis-breaks.y-sec != none {
      axis-breaks.y-sec
    } else {
      _secondary-breaks(y-trained, _y-sec, _axis-breaks(y-trained))
    }
    for (idx, b) in breaks.enumerate() {
      let cy = map-axis-data(y-trained, b, py-range)
      if _should-draw-tick(_ax-ticks.yr, _tick-len.yr) {
        line((px-hi, cy), (px-hi + _tick-len.yr, cy), stroke: _ax-ticks.yr)
      }
      if _ax-text.yr.size > 0pt {
        let mapped = secondary-mod.apply-transform(_y-sec, b)
        content(
          (px-hi + _tick-len.yr + _TICK-LABEL-GAP, cy),
          text(.._text-args(_ax-text.yr))[#resolve-prose(
            resolve-label(
              _y-sec.at("labels", default: auto),
              mapped,
              idx,
              format-break(mapped),
              typst-mark: _y-disp.typst-mark,
            ),
            eval-strings: _ax-text.yr.typst,
          )],
          anchor: "mid-west",
        )
      }
    }
    if _ax-line.yr != none {
      line((px-hi, py-lo), (px-hi, py-hi), stroke: _ax-line.yr)
    }
    if show-y-sec-title and _y-sec.name != none and _ax-title.yr.size > 0pt {
      let y-sec-offset = _sec-title-offset-cm(
        _tick-len.yr,
        _resolve-extents(y-sec-extents, _ax-text.yr.size),
        _ax-title.yr,
        "y",
      )
      let title-text-cm = _title-extent-cm(
        _ax-title.yr,
        y-sec-title-extents,
        "y",
      )
      let (cy, y-anchor) = _y-title-place(_ax-title.yr.align, py-lo, py-hi)
      content(
        (px-hi + y-sec-offset + title-text-cm / 2, cy),
        _title-body(
          _y-sec.name,
          _ax-title.yr,
          y-sec-title-extents,
        ),
        angle: _title-angle(_ax-title.yr, 90),
        anchor: y-anchor,
      )
    }
  }

  if not is-radial and _ax-line.xb != none {
    line((px-lo, py-lo), (px-hi, py-lo), stroke: _ax-line.xb)
  }
  if not is-radial and _ax-line.yl != none {
    line((px-lo, py-lo), (px-lo, py-hi), stroke: _ax-line.yl)
  }

  if is-radial {
    _draw-radial-panel((
      outer-radial: outer-radial,
      x-trained: x-trained,
      y-trained: y-trained,
      grid-radial: _grid-radial,
      grid-radial-discrete: _grid-radial-discrete,
      theta: _theta-band,
    ))
  }

  // Render geoms into a sibling cetz canvas whose origin is (0, 0) and whose
  // bounds match the panel rectangle, then clip via Typst's `box(clip: true)`
  // before placing it back at the panel's south-west corner. cetz 0.5.0 has
  // no native clip primitive, so this nested-canvas hop is the only way to
  // bound geom marks to the panel.
  // Floored at zero: `box(clip: true, width: panel-w * 1cm, ...)` below is the
  // one place a negative extent would reach Typst.
  let panel-w = calc.max(0.0, px-hi - px-lo)
  let panel-h = calc.max(0.0, py-hi - py-lo)
  let inner-ctx = ctx
  inner-ctx.px-range = (x-pad-lo, panel-w - x-pad-hi)
  inner-ctx.py-range = (y-pad-lo, panel-h - y-pad-hi)
  let inner-radial = radial-ctx(
    coord,
    x-trained,
    y-trained,
    inner-ctx.px-range,
    inner-ctx.py-range,
    label-bounds: _label-bounds,
    tick-cm: _theta-band.reach,
  )
  inner-ctx.radial = inner-radial
  if inner-radial != none {
    for layer in prepared {
      if not _RADIAL-AWARE.at(layer.name, default: false) {
        fail("coord-radial", "does not support geom-" + layer.name)
      }
    }
  }
  // Every geom is drawn `floating`, so it never contributes to the canvas
  // bounds; only the `hide(rect ...)` does. Each subset canvas is therefore
  // exactly panel-sized with its origin at the south-west corner, so the
  // clipped and unclipped passes overlay in perfect register.
  let _draw-subset = subset => cetz.canvas({
    import cetz.draw: floating, hide, rect
    hide(rect((0, 0), (panel-w, panel-h)), bounds: true)
    for layer in subset {
      let draw = _geom-draw.at(layer.name, default: none)
      if draw != none {
        floating({ draw(layer, inner-ctx) })
      }
    }
  })
  // `annotate(clip: false)` opts a layer out of the panel clip; render it in a
  // sibling pass with no clip box so it can overflow the panel deliberately.
  // The sibling pass paints after the clipped one, so unclipped marks always
  // sit above clipped layers (documented on `annotate`'s `clip`).
  let clipped = prepared.filter(l => l.at("clip", default: true))
  let unclipped = prepared.filter(l => not l.at("clip", default: true))
  let clip-on = if inner-radial != none {
    inner-radial.clip
  } else if coord != none {
    coord.at("clip", default: true)
  } else { true }
  let clipped-geoms = _draw-subset(clipped)
  content(
    (px-lo, py-lo),
    if clip-on {
      box(
        clip: true,
        width: panel-w * 1cm,
        height: panel-h * 1cm,
        clipped-geoms,
      )
    } else { clipped-geoms },
    anchor: "south-west",
  )
  if unclipped.len() > 0 {
    content((px-lo, py-lo), _draw-subset(unclipped), anchor: "south-west")
  }

  // Radial-axis tick labels render after geoms so filled wedges, lines, and
  // points cannot mask them.
  if is-radial {
    _draw-radial-r-labels((
      spec: spec,
      theme: theme,
      outer-radial: outer-radial,
      x-trained: x-trained,
      y-trained: y-trained,
      x-disp: _x-disp,
      y-disp: _y-disp,
      ax-text: _ax-text,
      x-extents: x-extents,
      y-extents: y-extents,
    ))
  }

  // When flipped, the bottom axis shows the user's original y mapping and
  // the left axis shows the user's original x mapping; trained.x and
  // trained.y already carry the swapped scale specs (and labels labels), so
  // only the mapping-name fallback needs an explicit swap here.
  let _mapping-x-name = if spec.mapping == none { none } else if flipped {
    mapping-display-name(spec.mapping.at("y", default: none))
  } else { mapping-display-name(spec.mapping.at("x", default: none)) }
  let _mapping-y-name = if spec.mapping == none { none } else if flipped {
    mapping-display-name(spec.mapping.at("x", default: none))
  } else { mapping-display-name(spec.mapping.at("y", default: none)) }
  let x-title = _axis-title(x-trained, _mapping-x-name)
  let y-title = _axis-title(y-trained, _mapping-y-name)
  let x-title-cm = _title-extent-cm(_ax-title.xb, x-title-extents, "x")
  let y-title-cm = _title-extent-cm(_ax-title.yl, y-title-extents, "y")
  let x-title-gap = _text-margin-cm(_ax-title.xb, "top", _AX-TITLE-LABEL-GAP)
  let y-title-gap = _text-margin-cm(_ax-title.yl, "right", _AX-TITLE-LABEL-GAP)
  // A suppressed axis (`guides(x: none)`) draws no ticks or labels and a radial
  // panel draws neither band outside the panel, so in both cases the title
  // slides up to the panel edge. Both gates already ran in `_chrome-margins`,
  // which is why the band arrives rather than being derived a second time.
  let x-edge-offset = x-edge-band + x-title-gap
  let y-edge-offset = y-edge-band + y-title-gap
  if show-x-title and x-title != none and _ax-title.xb.size > 0pt {
    let (cx, x-anchor) = _x-title-place(_ax-title.xb.align, px-lo, px-hi)
    content(
      (cx, oy - (x-edge-offset + x-title-cm)),
      _title-body(
        x-title,
        _ax-title.xb,
        x-title-extents,
      ),
      anchor: x-anchor,
      angle: _title-angle(_ax-title.xb, 0),
    )
  }
  if show-y-title and y-title != none and _ax-title.yl.size > 0pt {
    let (cy, y-anchor) = _y-title-place(_ax-title.yl.align, py-lo, py-hi)
    content(
      (px-lo - (y-edge-offset + y-title-cm / 2), cy),
      _title-body(
        y-title,
        _ax-title.yl,
        y-title-extents,
      ),
      angle: _title-angle(_ax-title.yl, 90),
      anchor: y-anchor,
    )
  }

  if guides.len() > 0 and legend-args != none {
    legend-mod.draw(
      guides,
      ctx,
      panel-rect: legend-args.panel-rect,
      margin: legend-args.margin,
      legend-gap: legend-args.legend-gap,
      sec-y-extent: legend-args.sec-y-extent,
      sec-x-extent: legend-args.sec-x-extent,
      right-strip: legend-args.right-strip,
      theme: theme,
    )
  }
}

