// Cartesian panel furniture split out of `_draw-axis-and-layers`: the panel
// rect, the gridlines, both axis bands, both secondary axes, and the primary
// axis lines, drawn before the geoms. `panel` is the record the panel builds
// (GLOSSARY.md "panel").

#import "../deps.typ": cetz
#import "../scale/train.typ": map-axis-data, map-break
#import "../theme/theme.typ": (
  _line-stroke, _rect-style, _text-args, surface-set-below,
)
#import "../utils/typst-markup.typ": resolve-prose
#import "../utils/aes-resolve.typ": resolve-label
#import "../utils/format.typ": format-break
#import "../scale/secondary.typ" as secondary-mod
#import "common.typ": _should-draw-tick
#import "axis-format.typ": (
  _axis-breaks, _axis-minor-breaks, _axis-tick-values, _sec-spec,
  _secondary-breaks, _tick-label-fallback,
)
#import "axis-parts.typ": axis-entries, draw-axis-band
#import "extents.typ": (
  _TICK-LABEL-GAP, _resolve-extents, _sec-title-offset-cm, _title-angle,
  _title-body, _title-extent-cm, _x-title-place, _y-title-place,
)

// What one cartesian axis walks: the breaks, where they map to.
// `none` where the axis has no scale to walk.
//
// Continuous and discrete axes share everything except where the breaks come
// from, so only that branches here.
#let _cartesian-walk(panel, axis, trained) = {
  if trained == none { return none }
  let is-continuous = trained.type == "continuous"
  if not is-continuous and trained.type != "discrete" { return none }
  let cached = if panel.axis-breaks == none { none } else {
    panel.axis-breaks.at(axis, default: none)
  }
  (
    is-continuous: is-continuous,
    breaks: if is-continuous and cached != none {
      cached
    } else { _axis-tick-values(trained) },
    range: (panel.coord.axis-range)(panel, axis),
  )
}

// Gridlines for one axis. They are panel furniture rather than part of the
// axis band: they mark where a break crosses the panel, so they stay with the
// panel whatever draws the ticks and the labels outside it.
//
// A discrete axis draws majors only when the theme asks for them per weight or
// per axis, and never draws minors: a gap between levels has no subdivision.
#let _draw-cartesian-grid(panel, grid, axis, trained, walk) = {
  import cetz.draw: line
  if walk == none { return }
  let px-lo = panel.px-lo
  let px-hi = panel.px-hi
  let py-lo = panel.py-lo
  let py-hi = panel.py-hi
  let major-stroke = if axis == "x" { grid.major.x } else { grid.major.y }
  let minor-stroke = if axis == "x" { grid.minor.x } else { grid.minor.y }
  let major-discrete = if axis == "x" {
    grid.discrete.x
  } else { grid.discrete.y }
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
#let _band-labels(trained, walk, disp, style, shown) = {
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
#let _band-entries(trained, walk, guide, disp, style, shown, extents) = {
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

#let draw-cartesian-background(panel) = {
  import cetz.draw: *
  let theme = panel.theme
  let coord = panel.coord
  let x-trained = panel.x-trained
  let y-trained = panel.y-trained
  let px-lo = panel.px-lo
  let px-hi = panel.px-hi
  let py-lo = panel.py-lo
  let py-hi = panel.py-hi
  let px-range = (coord.axis-range)(panel, "x")
  let py-range = (coord.axis-range)(panel, "y")
  let axis-breaks = panel.axis-breaks
  let _ink = panel.ink
  let _ax-text = panel.ax-text
  let _ax-title = panel.ax-title
  let _ax-line = panel.ax-line
  let _ax-ticks = panel.ax-ticks
  let _tick-len = panel.tick-len
  let _x-disp = panel.x-disp
  let _y-disp = panel.y-disp

  let _panel = _rect-style(
    theme,
    "panel-background",
    fallback-fill: theme.paper,
    outset-ref-w: panel.canvas-w,
    outset-ref-h: panel.canvas-h,
  )
  // Panel rect stays glued to the natural panel canvas so a themed `inset`
  // cannot bleed past adjacent facets or chrome. Visible breathing room
  // around a panel is the job of `outset` (chrome reservation upstream).
  if _panel.fill != none or _panel.stroke != none {
    rect(
      (px-lo, py-lo),
      (px-hi, py-hi),
      fill: _panel.fill,
      stroke: _panel.stroke,
    )
  }

  let _grid-stroke = surface => _line-stroke(
    theme,
    surface,
    fallback-colour: _ink,
  )
  // A discrete axis draws no gridlines by default, since its ticks already mark
  // every level. A grid element set on the major weight or on one axis is a
  // deliberate request, so it wins; an inherited `panel-grid` is not.
  let grid = (
    major: (
      x: _grid-stroke("panel-grid-major-x"),
      y: _grid-stroke("panel-grid-major-y"),
    ),
    minor: (
      x: _grid-stroke("panel-grid-minor-x"),
      y: _grid-stroke("panel-grid-minor-y"),
    ),
    discrete: (
      x: surface-set-below(theme, "panel-grid-major-x", "panel-grid"),
      y: surface-set-below(theme, "panel-grid-major-y", "panel-grid"),
    ),
  )

  let _x-walk = _cartesian-walk(panel, "x", x-trained)
  let _y-walk = _cartesian-walk(panel, "y", y-trained)
  _draw-cartesian-grid(panel, grid, "x", x-trained, _x-walk)
  draw-axis-band(
    theme,
    "x",
    panel.x-guide,
    _band-entries(
      x-trained,
      _x-walk,
      panel.x-guide,
      _x-disp,
      _ax-text.xb,
      panel.show-x-labels,
      panel.x-extents,
    ),
    px-range,
    (py-lo, py-hi),
  )
  _draw-cartesian-grid(panel, grid, "y", y-trained, _y-walk)
  draw-axis-band(
    theme,
    "y",
    panel.y-guide,
    _band-entries(
      y-trained,
      _y-walk,
      panel.y-guide,
      _y-disp,
      _ax-text.yl,
      panel.show-y-labels,
      panel.y-extents,
    ),
    py-range,
    (px-lo, px-hi),
  )

  // Secondary x-axis: draw on top edge if the trained x scale carries a
  // secondary spec. Breaks are its own when set, else the primary axis grid;
  // their labels go through the user's transformation function.
  let _x-sec = _sec-spec(x-trained, coord: coord)
  if _x-sec != none and panel.show-x-sec {
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
    if (
      panel.show-x-sec-title and _x-sec.name != none and _ax-title.xt.size > 0pt
    ) {
      let x-sec-offset = _sec-title-offset-cm(
        _tick-len.xt,
        _resolve-extents(panel.x-sec-extents, _ax-text.xt.size),
        _ax-title.xt,
        "x",
      )
      let (cx, x-anchor) = _x-title-place(_ax-title.xt.align, px-lo, px-hi)
      content(
        (cx, py-hi + x-sec-offset),
        _title-body(
          _x-sec.name,
          _ax-title.xt,
          panel.x-sec-title-extents,
        ),
        anchor: x-anchor,
        angle: _title-angle(_ax-title.xt, 0),
      )
    }
  }

  // Secondary y-axis: draw on right edge if the trained y scale carries a
  // secondary spec.
  let _y-sec = _sec-spec(y-trained, coord: coord)
  if _y-sec != none and panel.show-y-sec {
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
    if (
      panel.show-y-sec-title and _y-sec.name != none and _ax-title.yr.size > 0pt
    ) {
      let y-sec-offset = _sec-title-offset-cm(
        _tick-len.yr,
        _resolve-extents(panel.y-sec-extents, _ax-text.yr.size),
        _ax-title.yr,
        "y",
      )
      let title-text-cm = _title-extent-cm(
        _ax-title.yr,
        panel.y-sec-title-extents,
        "y",
      )
      let (cy, y-anchor) = _y-title-place(_ax-title.yr.align, py-lo, py-hi)
      content(
        (px-hi + y-sec-offset + title-text-cm / 2, cy),
        _title-body(
          _y-sec.name,
          _ax-title.yr,
          panel.y-sec-title-extents,
        ),
        angle: _title-angle(_ax-title.yr, 90),
        anchor: y-anchor,
      )
    }
  }

  if _ax-line.xb != none {
    line((px-lo, py-lo), (px-hi, py-lo), stroke: _ax-line.xb)
  }
  if _ax-line.yl != none {
    line((px-lo, py-lo), (px-lo, py-hi), stroke: _ax-line.yl)
  }
}
