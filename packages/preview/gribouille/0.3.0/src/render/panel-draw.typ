// Panel renderer: the geom-dispatch table and `_draw-axis-and-layers`, which
// draws one panel's background, gridlines, axes (cartesian + radial), geom
// marks, axis titles, and any panel-local legend.

#import "../deps.typ": cetz
#import "../utils/errors.typ": fail
#import "../scale/train.typ": (
  map-axis-data, map-position, mapping-display-name, transform-inv,
)
#import "../theme/defaults.typ": resolve-colour
#import "../theme/theme.typ": (
  _line-stroke, _rect-style, _scalar-cascade, _text-args, _text-style,
)
#import "../utils/radial.typ": (
  group-theta-breaks, polar-canvas, radial-arc, radial-ctx,
)
#import "../utils/typst-markup.typ": resolve-prose
#import "../utils/aes-resolve.typ": resolve-label
#import "../utils/format.typ": format-break
#import "../utils/palette.typ": default-discrete
#import "../scale/secondary.typ" as secondary-mod
#import "../legend.typ" as legend-mod
#import "common.typ": (
  _per-side, _resolve-data, _resolve-mapping, _should-draw-tick,
)
#import "colour.typ": _make-resolve-colour
#import "axis-format.typ": _axis-breaks, _axis-label, _axis-title, _sec-spec
#import "guides.typ": (
  _THETA-CAP-FRAC, _THETA-CAP-MAX-RAD, _THETA-MINOR-TICK-FRAC, _axis-text-angle,
  _read-axis-guide, _read-r-guide, _read-theta-guide,
)
#import "extents.typ": (
  _AX-TITLE-LABEL-GAP, _X-LABEL-ROW-GAP, _Y-LABEL-COL-GAP, _ax-text-cm,
  _axis-guide-rows, _resolve-extents, _text-margin-cm, _x-label-depth,
  _x-label-depth-stack, _x-title-place, _y-label-width, _y-label-width-stack,
  _y-title-place,
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
  flipped: false,
  axis-breaks: none,
  x-extents: none,
  y-extents: none,
  x-sec-extents: none,
  y-sec-extents: none,
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
  let _surface-style = (p, s, _) => _text-style(theme, p + "-" + s)
  let _ax-text = _per-side(_surface-style, "axis-text")
  let _ax-title = _per-side(_surface-style, "axis-title")

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

  let ctx = (
    trained: trained,
    px-range: px-range,
    py-range: py-range,
    palette: default-discrete,
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
  let outer-radial = radial-ctx(coord, x-trained, y-trained, px-range, py-range)
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

  let grid-stroke = _line-stroke(theme, "panel-grid", fallback-colour: _ink)
  let _stroke-side = (p, s, _) => _line-stroke(
    theme,
    p + "-" + s,
    fallback-colour: _ink,
  )
  let _ax-line = _per-side(_stroke-side, "axis-line")
  let _ax-ticks = _per-side(_stroke-side, "axis-ticks")
  let _len-side = (p, s, a) => _scalar-cascade(theme, p, s, a) / 1cm
  let _tick-len = _per-side(_len-side, "tick-length")

  let x-guide = _read-axis-guide(spec, "x", default-angle: _axis-text-angle(
    theme,
    "x",
  ))
  let y-guide = _read-axis-guide(spec, "y", default-angle: _axis-text-angle(
    theme,
    "y",
  ))
  let _x-label-anchor(angle) = {
    if angle == 0 { "north" } else if angle > 0 { "north-east" } else {
      "north-west"
    }
  }
  // Pre-compute row metadata for each axis: the sub-guide, the cumulative
  // dodge offset (in row units) up to this sub-guide, and the inter-row gap
  // offset (in cm). Lifted out of the per-break draw loops so flat plots
  // walk a single tuple instead of rebuilding it every label.
  let _stack-rows(g, gap) = {
    let rows = _axis-guide-rows(g)
    let spacing = if g.stack { g.spacing } else { 0 }
    let row-base = 0
    let metas = ()
    for (i, sub) in rows.enumerate() {
      metas.push((sub: sub, dodge-base: row-base, stack-offset: i * spacing))
      row-base += sub.n-dodge
    }
    metas
  }
  let _x-rows = _stack-rows(x-guide, _X-LABEL-ROW-GAP)
  let _y-rows = _stack-rows(y-guide, _Y-LABEL-COL-GAP)
  let _draw-x-label(cx, label-text, idx) = {
    if not (show-x-labels and theme.tick-labels) { return }
    for r in _x-rows {
      let dodge-row = calc.rem(idx, r.sub.n-dodge)
      let cy = (
        py-lo
          - _tick-len.xb
          - 0.1
          - (r.dodge-base + dodge-row) * _X-LABEL-ROW-GAP
          - r.stack-offset
      )
      content(
        (cx, cy),
        text(.._text-args(_ax-text.xb))[#label-text],
        anchor: _x-label-anchor(r.sub.angle),
        angle: r.sub.angle * 1deg,
      )
    }
  }
  let _draw-y-label(cy, label-text, idx) = {
    if not (show-y-labels and theme.tick-labels) { return }
    for r in _y-rows {
      let dodge-col = calc.rem(idx, r.sub.n-dodge)
      let cx = (
        px-lo
          - _tick-len.yl
          - 0.1
          - (r.dodge-base + dodge-col) * _Y-LABEL-COL-GAP
          - r.stack-offset
      )
      content(
        (cx, cy),
        text(.._text-args(_ax-text.yl))[#label-text],
        anchor: "east",
        angle: r.sub.angle * 1deg,
      )
    }
  }

  let _axis-display(trained) = (
    typst-mark: if trained != none {
      trained.at("typst-mark", default: false)
    } else { false },
    labels: if trained != none and trained.at("spec", default: none) != none {
      trained.spec.at("labels", default: auto)
    } else { auto },
  )
  let _x-disp = _axis-display(x-trained)
  let _y-disp = _axis-display(y-trained)

  // Draw the cartesian axis ticks, gridlines, and labels for one axis.
  // Continuous and discrete axes share everything except how `cx`/`cy` is
  // mapped, where the labels come from, and whether gridlines are drawn
  // (continuous only, since discrete ticks already mark every level).
  let _draw-cartesian-axis(axis, trained, disp, ax-text-typst, draw-label) = {
    if is-radial or trained == none { return }
    let is-continuous = trained.type == "continuous"
    if not is-continuous and trained.type != "discrete" { return }
    let stroke = if axis == "x" { _ax-ticks.xb } else { _ax-ticks.yl }
    let tick-len = if axis == "x" { _tick-len.xb } else { _tick-len.yl }
    let suppress = if axis == "x" { x-guide.suppress } else { y-guide.suppress }
    let range = if axis == "x" { px-range } else { py-range }
    let breaks = if is-continuous {
      if axis-breaks != none and axis-breaks.at(axis, default: none) != none {
        axis-breaks.at(axis)
      } else { _axis-breaks(trained) }
    } else { trained.domain }
    for (idx, b) in breaks.enumerate() {
      let c = if is-continuous {
        map-axis-data(trained, b, range)
      } else { map-position(trained, b, range) }
      if is-continuous and grid-stroke != none {
        if axis == "x" {
          line((c, py-lo), (c, py-hi), stroke: grid-stroke)
        } else {
          line((px-lo, c), (px-hi, c), stroke: grid-stroke)
        }
      }
      if _should-draw-tick(stroke, tick-len) and not suppress {
        if axis == "x" {
          line((c, py-lo), (c, py-lo - tick-len), stroke: stroke)
        } else {
          line((px-lo - tick-len, c), (px-lo, c), stroke: stroke)
        }
      }
      if not suppress {
        let fallback = if is-continuous { _axis-label(trained, b) } else { b }
        draw-label(
          c,
          resolve-prose(
            resolve-label(
              disp.labels,
              b,
              idx,
              fallback,
              typst-mark: disp.typst-mark,
            ),
            eval-strings: ax-text-typst,
          ),
          idx,
        )
      }
    }
  }
  _draw-cartesian-axis(
    "x",
    x-trained,
    _x-disp,
    _ax-text.xb.typst,
    _draw-x-label,
  )
  _draw-cartesian-axis(
    "y",
    y-trained,
    _y-disp,
    _ax-text.yl.typst,
    _draw-y-label,
  )

  // Minor log ticks: opt-in via guide-axis-logticks() on a log10-trans axis.
  // Emits half-length, unlabelled ticks at sub-decade positions (2, 3, ..., 9
  // within each decade) covered by the visible domain.
  let _draw-log-minors(trained, guide, axis, range, stroke, tick-len) = {
    if not guide.logticks or guide.suppress { return }
    if trained == none { return }
    if trained.type != "continuous" { return }
    if trained.at("transform", default: "identity") != "log10" { return }
    if not _should-draw-tick(stroke, tick-len) { return }
    let view-transform = trained.at("view-transform", default: none)
    let (lo, hi) = if view-transform != none {
      (
        transform-inv("log10", view-transform.at(0)),
        transform-inv("log10", view-transform.at(1)),
      )
    } else { trained.domain }
    if lo <= 0 or hi <= 0 { return }
    let minor-len = tick-len * 0.5
    let k-lo = int(calc.floor(calc.log(lo, base: 10)))
    let k-hi = int(calc.ceil(calc.log(hi, base: 10)))
    let k = k-lo
    while k <= k-hi {
      let scale = calc.pow(10.0, k)
      for c in (2, 3, 4, 5, 6, 7, 8, 9) {
        let v = c * scale
        if v >= lo and v <= hi {
          if axis == "x" {
            let cx = map-axis-data(trained, v, range)
            line((cx, py-lo), (cx, py-lo - minor-len), stroke: stroke)
          } else {
            let cy = map-axis-data(trained, v, range)
            line((px-lo - minor-len, cy), (px-lo, cy), stroke: stroke)
          }
        }
      }
      k = k + 1
    }
  }
  if not is-radial {
    _draw-log-minors(
      x-trained,
      x-guide,
      "x",
      px-range,
      _ax-ticks.xb,
      _tick-len.xb,
    )
    _draw-log-minors(
      y-trained,
      y-guide,
      "y",
      py-range,
      _ax-ticks.yl,
      _tick-len.yl,
    )
  }

  // Secondary x-axis: draw on top edge if the trained x scale carries a
  // secondary spec. Breaks reuse the primary axis grid; their labels go
  // through the user's transformation function.
  let _x-sec = _sec-spec(x-trained)
  if not is-radial and _x-sec != none and show-x-sec {
    let breaks = if axis-breaks != none and axis-breaks.x-sec != none {
      axis-breaks.x-sec
    } else { _axis-breaks(x-trained) }
    for b in breaks {
      let cx = map-axis-data(x-trained, b, px-range)
      if _should-draw-tick(_ax-ticks.xt, _tick-len.xt) {
        line((cx, py-hi), (cx, py-hi + _tick-len.xt), stroke: _ax-ticks.xt)
      }
      if theme.tick-labels {
        let mapped = secondary-mod.apply-transform(_x-sec, b)
        content(
          (cx, py-hi + _tick-len.xt + 0.1),
          text(.._text-args(_ax-text.xt))[#resolve-prose(
            format-break(mapped),
            eval-strings: _ax-text.xt.typst,
          )],
          anchor: "south",
        )
      }
    }
    if _ax-line.xt != none {
      line((px-lo, py-hi), (px-hi, py-hi), stroke: _ax-line.xt)
    }
    if _x-sec.name != none and _ax-title.xt.size > 0pt {
      let _x-sec-ext = _resolve-extents(x-sec-extents, _ax-text.xt.size)
      let x-sec-depth = _x-label-depth(
        0,
        1,
        _x-sec-ext.width,
        _x-sec-ext.height,
      )
      let x-sec-gap = _text-margin-cm(
        _ax-title.xt,
        "bottom",
        _AX-TITLE-LABEL-GAP,
      )
      let (cx, x-anchor) = _x-title-place(_ax-title.xt.align, px-lo, px-hi)
      content(
        (cx, py-hi + _tick-len.xt + 0.1 + x-sec-depth + x-sec-gap),
        text(.._text-args(_ax-title.xt))[#resolve-prose(
          _x-sec.name,
          eval-strings: _ax-title.xt.typst,
        )],
        anchor: x-anchor,
      )
    }
  }

  // Secondary y-axis: draw on right edge if the trained y scale carries a
  // secondary spec.
  let _y-sec = _sec-spec(y-trained)
  if not is-radial and _y-sec != none and show-y-sec {
    let breaks = if axis-breaks != none and axis-breaks.y-sec != none {
      axis-breaks.y-sec
    } else { _axis-breaks(y-trained) }
    for b in breaks {
      let cy = map-axis-data(y-trained, b, py-range)
      if _should-draw-tick(_ax-ticks.yr, _tick-len.yr) {
        line((px-hi, cy), (px-hi + _tick-len.yr, cy), stroke: _ax-ticks.yr)
      }
      if theme.tick-labels {
        let mapped = secondary-mod.apply-transform(_y-sec, b)
        content(
          (px-hi + _tick-len.yr + 0.1, cy),
          text(.._text-args(_ax-text.yr))[#resolve-prose(
            format-break(mapped),
            eval-strings: _ax-text.yr.typst,
          )],
          anchor: "west",
        )
      }
    }
    if _ax-line.yr != none {
      line((px-hi, py-lo), (px-hi, py-hi), stroke: _ax-line.yr)
    }
    if _y-sec.name != none and _ax-title.yr.size > 0pt {
      let _y-sec-ext = _resolve-extents(y-sec-extents, _ax-text.yr.size)
      let y-sec-width = _y-label-width(
        0,
        1,
        _y-sec-ext.width,
        _y-sec-ext.height,
      )
      let title-text-cm = _ax-text-cm(_ax-title.yr.size)
      let y-sec-gap = _text-margin-cm(_ax-title.yr, "left", _AX-TITLE-LABEL-GAP)
      let (cy, y-anchor) = _y-title-place(_ax-title.yr.align, py-lo, py-hi)
      content(
        (
          px-hi
            + _tick-len.yr
            + 0.1
            + y-sec-width
            + y-sec-gap
            + title-text-cm / 2,
          cy,
        ),
        text(.._text-args(_ax-title.yr))[#resolve-prose(
          _y-sec.name,
          eval-strings: _ax-title.yr.typst,
        )],
        angle: 90deg,
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
    let theta-guide = _read-theta-guide(spec)
    let theta-suppress = theta-guide != none and theta-guide.suppress
    let (cx, cy) = outer-radial.centre
    let r-max = outer-radial.r-max
    let theta-range = outer-radial.theta-range
    let r-range = outer-radial.r-range

    let (theta-trained, r-trained, theta-disp, theta-text) = if (
      outer-radial.cat-is-theta
    ) {
      (x-trained, y-trained, _x-disp, _ax-text.xb)
    } else {
      (y-trained, x-trained, _y-disp, _ax-text.yl)
    }

    let _radial-theta-of(trained, value) = if trained.type == "continuous" {
      map-axis-data(trained, value, theta-range)
    } else {
      map-position(trained, value, theta-range)
    }

    if grid-stroke != none and r-trained != none {
      if r-trained.type == "continuous" {
        for b in _axis-breaks(r-trained) {
          let r = map-axis-data(r-trained, b, r-range)
          if r > 0 and r <= r-max {
            circle((cx, cy), radius: r, fill: none, stroke: grid-stroke)
          }
        }
      }
    }

    let theta-breaks = if theta-trained == none { () } else if (
      theta-trained.type == "continuous"
    ) {
      _axis-breaks(theta-trained)
    } else { theta-trained.domain }

    // Full-sweep domain endpoints can land on the same canvas angle (e.g., 0
    // and 24 on a 24-hour clock both sit at 12 o'clock); group them so we
    // draw one spoke and one merged "end/start" label per shared angle.
    let theta-groups = group-theta-breaks(
      theta-breaks,
      b => _radial-theta-of(theta-trained, b),
    )

    if grid-stroke != none and theta-trained != none {
      for group in theta-groups {
        let theta = group.first().theta
        line(
          (cx, cy),
          (cx + r-max * calc.cos(theta), cy + r-max * calc.sin(theta)),
          stroke: grid-stroke,
        )
      }
    }

    // Outer axis arc plus optional minor ticks (the `guide-axis-theta`
    // guide). Spoke-only plots (no theta guide) skip this whole block.
    if theta-guide != none and not theta-suppress and _ax-line.xb != none {
      let (theta-lo, theta-hi) = (theta-range.at(0), theta-range.at(1))
      let span = calc.abs(theta-hi - theta-lo)
      let trim = if theta-guide.cap == "none" { 0 } else {
        calc.min(span * _THETA-CAP-FRAC, _THETA-CAP-MAX-RAD)
      }
      let direction = if theta-hi >= theta-lo { 1 } else { -1 }
      let arc-lo = if theta-guide.cap == "lower" or theta-guide.cap == "both" {
        theta-lo + direction * trim
      } else { theta-lo }
      let arc-hi = if theta-guide.cap == "upper" or theta-guide.cap == "both" {
        theta-hi - direction * trim
      } else { theta-hi }
      let arc-pts = radial-arc(arc-lo, arc-hi, r-max, outer-radial)
      line(..arc-pts, stroke: _ax-line.xb)

      if theta-guide.minor-ticks and theta-groups.len() >= 2 {
        let minor-r = r-max * (1 + _THETA-MINOR-TICK-FRAC)
        let prev = theta-groups.first().first().theta
        for i in range(1, theta-groups.len()) {
          let cur = theta-groups.at(i).first().theta
          let mid = (prev + cur) / 2
          line(
            polar-canvas(outer-radial, mid, r-max),
            polar-canvas(outer-radial, mid, minor-r),
            stroke: _ax-line.xb,
          )
          prev = cur
        }
      }
    }

    if (
      show-x-labels
        and theme.tick-labels
        and theta-trained != none
        and not theta-suppress
    ) {
      let pad = 0.2
      for group in theta-groups {
        // `labels` callbacks may return `none` to drop a wrap-side break from
        // the merged label (e.g., hide "6" so a 0..6 radar shows "0", not "6/0").
        let labels = group
          .map(rec => {
            let raw = if theta-trained.type == "continuous" {
              _axis-label(theta-trained, rec.b)
            } else { rec.b }
            resolve-label(
              theta-disp.labels,
              rec.b,
              rec.idx,
              raw,
              typst-mark: theta-disp.typst-mark,
            )
          })
          .filter(l => l != none)
        if labels.len() == 0 { continue }
        // Higher-domain break first: "24/0", not "0/24".
        let label-text = labels.rev().join([/])
        let theta = group.first().theta
        let lr = r-max + pad
        content(
          (cx + lr * calc.cos(theta), cy + lr * calc.sin(theta)),
          text(.._text-args(theta-text))[#resolve-prose(
            label-text,
            eval-strings: theta-text.typst,
          )],
          anchor: "center",
          angle: if theta-guide == none { 0deg } else {
            theta-guide.angle * 1deg
          },
        )
      }
    }
  }

  // Render geoms into a sibling cetz canvas whose origin is (0, 0) and whose
  // bounds match the panel rectangle, then clip via Typst's `box(clip: true)`
  // before placing it back at the panel's south-west corner. cetz 0.5.0 has
  // no native clip primitive, so this nested-canvas hop is the only way to
  // bound geom marks to the panel.
  let panel-w = px-hi - px-lo
  let panel-h = py-hi - py-lo
  let inner-ctx = ctx
  inner-ctx.px-range = (x-pad-lo, panel-w - x-pad-hi)
  inner-ctx.py-range = (y-pad-lo, panel-h - y-pad-hi)
  let inner-radial = radial-ctx(
    coord,
    x-trained,
    y-trained,
    inner-ctx.px-range,
    inner-ctx.py-range,
  )
  inner-ctx.radial = inner-radial
  if inner-radial != none {
    for layer in prepared {
      if not _RADIAL-AWARE.at(layer.geom, default: false) {
        fail("coord-radial", "does not support geom-" + layer.geom)
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
      let draw = _geom-draw.at(layer.geom, default: none)
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
    coord.at("clip", default: "on") != "off"
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
    let (cx, cy) = outer-radial.centre
    let r-max = outer-radial.r-max
    let theta-range = outer-radial.theta-range
    let r-range = outer-radial.r-range
    let r-trained = if outer-radial.cat-is-theta {
      y-trained
    } else { x-trained }
    let r-disp = if outer-radial.cat-is-theta { _y-disp } else { _x-disp }
    let r-text = if outer-radial.cat-is-theta {
      _ax-text.yl
    } else { _ax-text.xb }
    if (
      show-y-labels
        and theme.tick-labels
        and r-trained != none
        and r-trained.type == "continuous"
        and not _read-r-guide(spec).suppress
    ) {
      let start-angle = theta-range.at(0)
      let dx = calc.cos(start-angle)
      let dy = calc.sin(start-angle)
      for (idx, b) in _axis-breaks(r-trained).enumerate() {
        let r = map-axis-data(r-trained, b, r-range)
        if r < 0 or r > r-max { continue }
        let label-text = resolve-label(
          r-disp.labels,
          b,
          idx,
          _axis-label(r-trained, b),
          typst-mark: r-disp.typst-mark,
        )
        content(
          (cx + r * dx, cy + r * dy),
          text(.._text-args(r-text))[#resolve-prose(
            label-text,
            eval-strings: r-text.typst,
          )],
          anchor: "center",
        )
      }
    }
  }

  // When flipped, the bottom axis shows the user's original y mapping and
  // the left axis shows the user's original x mapping; trained.x and
  // trained.y already carry the swapped scale specs (and labs labels), so
  // only the mapping-name fallback needs an explicit swap here.
  let _mapping-x-name = if spec.mapping == none { none } else if flipped {
    mapping-display-name(spec.mapping.at("y", default: none))
  } else { mapping-display-name(spec.mapping.at("x", default: none)) }
  let _mapping-y-name = if spec.mapping == none { none } else if flipped {
    mapping-display-name(spec.mapping.at("x", default: none))
  } else { mapping-display-name(spec.mapping.at("y", default: none)) }
  let x-title = _axis-title(x-trained, _mapping-x-name)
  let y-title = _axis-title(y-trained, _mapping-y-name)
  let _x-ext = _resolve-extents(x-extents, _ax-text.xb.size)
  let _y-ext = _resolve-extents(y-extents, _ax-text.yl.size)
  // A suppressed axis (`guides(x: none)`) reserves no tick or label depth, so
  // the title slides up to the panel edge.
  let x-label-depth = if x-guide.suppress { 0.0 } else {
    _x-label-depth-stack(x-guide, _x-ext.width, _x-ext.height)
  }
  let y-label-width = if y-guide.suppress { 0.0 } else {
    _y-label-width-stack(y-guide, _y-ext.width, _y-ext.height)
  }
  let x-tick-cm = if x-guide.suppress { 0.0 } else { _tick-len.xb }
  let y-tick-cm = if y-guide.suppress { 0.0 } else { _tick-len.yl }
  let x-title-cm = _ax-text-cm(_ax-title.xb.size)
  let y-title-cm = _ax-text-cm(_ax-title.yl.size)
  let x-title-gap = _text-margin-cm(_ax-title.xb, "top", _AX-TITLE-LABEL-GAP)
  let y-title-gap = _text-margin-cm(_ax-title.yl, "right", _AX-TITLE-LABEL-GAP)
  let x-edge-offset = x-tick-cm + 0.1 + x-label-depth + x-title-gap
  let y-edge-offset = y-tick-cm + 0.1 + y-label-width + y-title-gap
  if show-x-title and x-title != none and _ax-title.xb.size > 0pt {
    let (cx, x-anchor) = _x-title-place(_ax-title.xb.align, px-lo, px-hi)
    content(
      (cx, oy - (x-edge-offset + x-title-cm)),
      text(.._text-args(_ax-title.xb))[#resolve-prose(
        x-title,
        eval-strings: _ax-title.xb.typst,
      )],
      anchor: x-anchor,
    )
  }
  if show-y-title and y-title != none and _ax-title.yl.size > 0pt {
    let (cy, y-anchor) = _y-title-place(_ax-title.yl.align, py-lo, py-hi)
    content(
      (px-lo - (y-edge-offset + y-title-cm / 2), cy),
      text(.._text-args(_ax-title.yl))[#resolve-prose(
        y-title,
        eval-strings: _ax-title.yl.typst,
      )],
      angle: 90deg,
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

