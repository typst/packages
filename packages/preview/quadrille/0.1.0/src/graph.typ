#import "style.typ": default-style
#import "ticks.typ": nice-step, multiples, formatter
#import "geom.typ": finite, value-at, spaced, sample-fn, visible-runs, robust-range

// ---------------------------------------------------------------- helpers

#let _pt(v, base: 0pt) = {
  if type(v) == length { v.to-absolute() / 1pt }
  else if type(v) == ratio { (v * base) / 1pt }
  else if type(v) == relative { (v.ratio * base + v.length.to-absolute()) / 1pt }
  else { panic("quadrille: expected a length such as 8cm, got " + repr(v)) }
}

// A user stroke on top of a default one: `red` keeps the default thickness.
#let _stroke(user, paint, thickness, dash: auto) = {
  let s = if user == auto { stroke(paint) } else { stroke(user) }
  (
    paint: if s.paint == auto { paint } else { s.paint },
    thickness: if s.thickness == auto { thickness } else { s.thickness },
    dash: if s.dash == auto { dash } else { s.dash },
    cap: "round",
    join: "round",
  )
}

#let _range(who, r) = {
  if r == auto { return auto }
  assert(type(r) == array and r.len() == 2 and r.all(v => type(v) in (int, float)) and r.at(0) < r.at(1),
    message: "quadrille: " + who + " is written (from, to) with from < to, got " + repr(r))
  (float(r.at(0)), float(r.at(1)))
}

// Automatic range around the data: never empty, and reaching 0 when it is close.
#let _extent(lo, hi) = {
  let (lo, hi) = (float(lo), float(hi))
  if hi - lo < 1e-12 { (lo, hi) = (lo - 1, hi + 1) }
  if lo > 0 and lo <= hi - lo { lo = 0.0 }
  if hi < 0 and -hi <= hi - lo { hi = 0.0 }
  (lo, hi)
}

// ... then rounded out to whole steps, so it starts and ends on a grid line.
#let _round-out(lo, hi, s) = (calc.floor(lo / s + 1e-9) * s, calc.ceil(hi / s - 1e-9) * s)

#let _curve(pts, stroke: none, fill: none, closed: false) = {
  let (first, ..rest) = pts
  place(top + left, curve(stroke: stroke, fill: fill,
    curve.move((first.at(0) * 1pt, first.at(1) * 1pt)),
    ..rest.map(p => curve.line((p.at(0) * 1pt, p.at(1) * 1pt))),
    ..if closed { (curve.close(),) }))
}

// Many separate straight lines as a single curve (grid lines, tick marks).
#let _lines(pairs, stroke) = {
  if pairs.len() == 0 { return }
  place(top + left, curve(stroke: stroke, ..pairs.map(((a, b)) => (
    curve.move((a.at(0) * 1pt, a.at(1) * 1pt)), curve.line((b.at(0) * 1pt, b.at(1) * 1pt)))).flatten()))
}

#let _arrowhead(tip, dir, size, paint) = {
  let n = calc.sqrt(dir.at(0) * dir.at(0) + dir.at(1) * dir.at(1))
  let (ux, uy) = (dir.at(0) / n, dir.at(1) / n)
  let (bx, by) = (tip.at(0) - size * ux, tip.at(1) - size * uy)
  let w = size * 0.38
  _curve(((tip.at(0), tip.at(1)), (bx - w * uy, by + w * ux), (bx + w * uy, by - w * ux)),
    fill: paint, closed: true)
}

#let _mark(kind, at, d, paint) = {
  if kind == none { return }
  let (x, y) = at
  let r = d / 2
  let ring = 0.9pt + white
  let s = (paint: paint, thickness: calc.max(0.8, d / 7) * 1pt, cap: "round")
  if kind == "dot" {
    place(top + left, dx: (x - r) * 1pt, dy: (y - r) * 1pt, circle(radius: r * 1pt, fill: paint, stroke: ring))
  } else if kind == "circle" {
    place(top + left, dx: (x - r) * 1pt, dy: (y - r) * 1pt, circle(radius: r * 1pt, fill: white, stroke: s))
  } else if kind == "square" {
    let r = r * 0.9
    place(top + left, dx: (x - r) * 1pt, dy: (y - r) * 1pt, rect(width: 2 * r * 1pt, height: 2 * r * 1pt,
      fill: paint, stroke: ring))
  } else if kind == "diamond" {
    let r = r * 1.2
    _curve(((x, y - r), (x + r, y), (x, y + r), (x - r, y)), fill: paint, stroke: ring, closed: true)
  } else if kind == "triangle" {
    let r = r * 1.2
    _curve(((x, y - r), (x + r * 0.87, y + r / 2), (x - r * 0.87, y + r / 2)), fill: paint, stroke: ring, closed: true)
  } else if kind == "cross" {
    let r = r * 0.8
    _lines((((x - r, y - r), (x + r, y + r)), ((x - r, y + r), (x + r, y - r))), s)
  } else if kind == "plus" {
    _lines((((x - r, y), (x + r, y)), ((x, y - r), (x, y + r))), s)
  }
}

// Which side of an anchor a text goes, as (h, v) in -1, 0, 1 (right/down positive).
#let _side(pos) = {
  let h = if pos.x == left { -1 } else if pos.x == right { 1 } else { 0 }
  let v = if pos.y == top { -1 } else if pos.y == bottom { 1 } else { 0 }
  (h, v)
}

// Where a w x h text goes when it sits on side `pos` of anchor `at`, `g` away.
#let _rect(at, pos, w, h, g) = {
  let (sh, sv) = _side(pos)
  let x = if sh < 0 { at.at(0) - g - w } else if sh > 0 { at.at(0) + g } else { at.at(0) - w / 2 }
  let y = if sv < 0 { at.at(1) - g - h } else if sv > 0 { at.at(1) + g } else { at.at(1) - h / 2 }
  (x: x, y: y, w: w, h: h)
}

// The page is divided into small cells; a cell is taken when ink or text is on it.
// Texts and the legend go where they cover the fewest taken cells.
#let _cell = 4.0
#let _key(i, j) = str(i * 100003 + j)
#let _cells-of-rect(r) = {
  let out = ()
  for i in range(calc.floor(r.x / _cell), calc.floor((r.x + r.w) / _cell) + 1) {
    for j in range(calc.floor(r.y / _cell), calc.floor((r.y + r.h) / _cell) + 1) { out.push(_key(i, j)) }
  }
  out
}
#let _cells-of-path(pts) = {
  let out = ()
  let last = none
  for k in range(pts.len()) {
    let a = pts.at(k)
    let b = if k + 1 < pts.len() { pts.at(k + 1) } else { a }
    let (dx, dy) = (b.at(0) - a.at(0), b.at(1) - a.at(1))
    let n = calc.max(1, calc.ceil(calc.max(calc.abs(dx), calc.abs(dy)) / _cell))
    for t in range(n) {
      let c = (calc.floor((a.at(0) + dx * t / n) / _cell), calc.floor((a.at(1) + dy * t / n) / _cell))
      if c != last {
        out.push(_key(..c))
        last = c
      }
    }
  }
  out
}
// How bad it is to put r here: taken cells under it, and the part outside the window.
#let _cost(taken, r, w, h) = {
  let c = _cells-of-rect(r).filter(k => k in taken).len()
  let out-w = calc.max(0, -r.x) + calc.max(0, r.x + r.w - w)
  let out-h = calc.max(0, -r.y) + calc.max(0, r.y + r.h - h)
  c + 0.3 * (out-w * r.h + out-h * r.w) / (_cell * _cell)
}

// ---------------------------------------------------------------- graph

/// A coordinate system with a grid, and everything given to it drawn inside.
///
/// Every axis option has an x- and a y- version; the plain name sets both axes:
/// `step: 1` is `x-step: 1, y-step: 1`.
///
/// - x, y: the visible window (from, to). Anything outside is cut off.
/// - step: distance between grid lines / numbered ticks, in graph units.
/// - minor: grid lines between two numbered ones (minor: 5 -> every 0.2 of a step).
/// - scale: length of one unit on paper (scale: 1cm). Overrides width / height.
/// - width, height: size of the gridded area; height: auto keeps both axes at the
///   same scale when that gives a reasonable shape.
/// - ticks: auto, none, or the values to number: (1, 2, 5) or ((1, $a$), (2, $b$)).
/// - format: how ticks are written: auto, "pi" (pi/2, pi ...) or a function v => [..].
/// - x-label, y-label: names written at the end of each axis.
/// - axes: "origin" (crossing at 0 when it is in view), "edge" (bottom and left) or none.
/// - grid: true / false. legend: auto (the emptiest corner), a corner (top + left ...) or none.
/// - clip: cut everything off at the window (true), or let it run over (false).
#let graph(
  ..elements,
  x: auto, y: auto,
  step: auto, x-step: auto, y-step: auto,
  minor: none, x-minor: auto, y-minor: auto,
  scale: auto, x-scale: auto, y-scale: auto,
  width: 10cm, height: auto,
  ticks: auto, x-ticks: auto, y-ticks: auto,
  format: auto, x-format: auto, y-format: auto,
  x-label: none, y-label: none,
  axes: "origin",
  grid: true,
  legend: auto,
  clip: true,
  style: (:),
) = layout(size => {
  assert(elements.named().len() == 0, message: "quadrille: graph: unknown option "
    + repr(elements.named().keys().at(0, default: "")))
  assert(axes in ("origin", "edge", none), message: "quadrille: graph: axes must be \"origin\", \"edge\" or none")
  let st = default-style + style
  let els = elements.pos().flatten().filter(e => e != none)
  for e in els {
    assert(type(e) == dictionary and "kind" in e,
      message: "quadrille: graph: expected fn(..), points(..), segment(..) and so on, got " + repr(e))
  }
  let pick(one, both) = if one != auto { one } else { both }
  let (xstep, ystep) = (pick(x-step, step), pick(y-step, step))
  let (xminor, yminor) = (pick(x-minor, minor), pick(y-minor, minor))
  let (xscale, yscale) = (pick(x-scale, scale), pick(y-scale, scale))
  let (xticks, yticks) = (pick(x-ticks, ticks), pick(y-ticks, ticks))
  let (xformat, yformat) = (pick(x-format, format), pick(y-format, format))
  let xr = _range("graph: x", x)
  let yr = _range("graph: y", y)
  for (name, s) in (("x-step", xstep), ("y-step", ystep)) {
    assert(s == auto or (type(s) in (int, float) and s > 0),
      message: "quadrille: graph: " + name + " must be a positive number, got " + repr(s))
  }
  let wfix = if xscale == auto { _pt(width, base: size.width) }
  // a grid line about every 0.6 cm, like graph paper (numbers that would collide are thinned out)
  let target(len) = if len == none { 8 } else { calc.max(3, calc.min(15, len / (0.6cm / 1pt))) }

  // -------- the x window, and the x step
  let xauto = xr == auto
  if xauto {
    let xs = ()
    for e in els {
      if e.kind == "points" { xs += e.pts.map(p => p.at(0)) }
      if e.kind in ("segment", "vector") { xs += (e.a.at(0), e.b.at(0)) }
      if e.kind == "vline" { xs.push(e.v) }
      if e.kind == "annotate" { xs.push(e.p.at(0)) }
      if e.kind in ("fn", "area", "points") and e.domain != auto { xs += e.domain }
      if e.kind == "parametric" {
        for t in spaced(..e.domain, auto, 60) {
          let p = (e.f)(t)
          if type(p) == array and p.len() == 2 and finite(p.at(0)) { xs.push(p.at(0)) }
        }
      }
    }
    xr = if xs.len() == 0 { (-5.0, 5.0) } else { _extent(calc.min(..xs), calc.max(..xs)) }
  }
  let W-of(span) = if xscale != auto { span * _pt(xscale) } else { wfix }
  let xstep = if xstep != auto { float(xstep) } else { nice-step(xr.at(1) - xr.at(0), target(W-of(xr.at(1) - xr.at(0)))) }
  if xauto { xr = _round-out(..xr, xstep) }
  let (x0, x1) = xr
  let W = W-of(x1 - x0)

  // -------- the y window (functions are sampled over the x window), and the y step
  let yauto = yr == auto
  let fn-xs(e) = {
    let (a, b) = if e.domain == auto { (x0, x1) } else { (calc.max(x0, e.domain.at(0)), calc.min(x1, e.domain.at(1))) }
    if a >= b { () } else { spaced(a, b, auto, 150) }
  }
  if yr == auto {
    let ys = ()
    let curve-ys = ()
    for e in els {
      if e.kind == "points" { ys += e.pts.map(p => p.at(1)) }
      if e.kind in ("segment", "vector") { ys += (e.a.at(1), e.b.at(1)) }
      if e.kind == "hline" { ys.push(e.v) }
      if e.kind == "annotate" { ys.push(e.p.at(1)) }
      if e.kind in ("fn", "points") and e.f != none {
        for xv in fn-xs(e) { let v = value-at(e.f, xv, e.kind); if v != none { curve-ys.push(v) } }
      }
      if e.kind == "area" {
        for h in (e.f, e.g) {
          if type(h) == function {
            for xv in fn-xs(e) { let v = value-at(h, xv, "area"); if v != none { curve-ys.push(v) } }
          } else { ys.push(h) }
        }
      }
      if e.kind == "parametric" {
        for t in spaced(..e.domain, auto, 60) {
          let p = (e.f)(t)
          if type(p) == array and p.len() == 2 and finite(p.at(1)) { ys.push(p.at(1)) }
        }
      }
    }
    let cr = robust-range(curve-ys)
    if cr != none { ys += cr }
    yr = if ys.len() == 0 { (-5.0, 5.0) } else { _extent(calc.min(..ys), calc.max(..ys)) }
  }
  let H-of(span) = if yscale != auto { span * _pt(yscale) }
    else if height != auto { _pt(height, base: size.width) }
    else {
      let same = span * W / (x1 - x0)          // same scale as x, if that gives a sensible shape
      if same >= 0.35 * W and same <= 1.4 * W { same } else { 0.65 * W }
    }
  let ystep = if ystep != auto { float(ystep) } else { nice-step(yr.at(1) - yr.at(0), target(H-of(yr.at(1) - yr.at(0)))) }
  if yauto { yr = _round-out(..yr, ystep) }
  let (y0, y1) = yr
  let H = H-of(y1 - y0)
  let X(v) = (v - x0) / (x1 - x0) * W
  let Y(v) = (y1 - v) / (y1 - y0) * H
  let P(p) = (X(p.at(0)), Y(p.at(1)))
  let inside(p) = p.at(0) >= x0 - 1e-9 * (x1 - x0) and p.at(0) <= x1 + 1e-9 * (x1 - x0) and p.at(1) >= y0 - 1e-9 * (y1 - y0) and p.at(1) <= y1 + 1e-9 * (y1 - y0)
  // Curves are cut a little outside the window; the box clip trims the rest.
  let (mx, my) = ((x1 - x0) * 0.02, (y1 - y0) * 0.02)
  let window = (x0 - mx, x1 + mx, y0 - my, y1 + my)

  // -------- ticks and grid
  let xgrid = multiples(x0, x1, xstep)
  let ygrid = multiples(y0, y1, ystep)
  let fine(lo, hi, s, n) = if n == none or n <= 1 { () } else {
    multiples(lo, hi, s / n).filter(v => calc.abs(v / s - calc.round(v / s)) > 1e-6)
  }
  let ax = if axes == "origin" and x0 <= 0 and 0 <= x1 { 0.0 } else { x0 }   // where the y axis is
  let ay = if axes == "origin" and y0 <= 0 and 0 <= y1 { 0.0 } else { y0 }   // where the x axis is

  // (value, content) for each numbered tick, and the axis' shared power of ten
  let tick-list(spec, grid-values, fmt-spec, lo, hi, s, who) = {
    let f = formatter(fmt-spec, lo, hi, s)
    if spec == none { return ((), none) }
    if spec == auto { return (grid-values.map(v => (v, (f.fmt)(v))), f.factor) }
    assert(type(spec) == array, message: "quadrille: graph: " + who + " must be auto, none or an array")
    let custom = spec.map(t => if type(t) == array { (float(t.at(0)), t.at(1)) } else { (float(t), (f.fmt)(t)) })
    (custom.filter(t => t.at(0) >= lo - 1e-9 * (hi - lo) and t.at(0) <= hi + 1e-9 * (hi - lo)), f.factor)
  }
  let (xt, xfactor) = tick-list(xticks, xgrid, xformat, x0, x1, xstep, "x-ticks")
  let (yt, yfactor) = tick-list(yticks, ygrid, yformat, y0, y1, ystep, "y-ticks")
  let origin-shared = axes != none and ax == 0 and ay == 0
  let near(a, b, s) = calc.abs(a - b) < 1e-9 * s

  // -------- everything that is drawn, in layers
  let under = ()     // area fills (clipped)
  let lines = ()     // curves and helper lines (clipped)
  let marks = ()     // point marks (not clipped, but only drawn inside the window)
  let ink = ()       // polylines in pt, for placing texts around them
  let texts = ()     // (ats, prefs, body, size, pad) - placed after everything is drawn
  let keys = ()      // legend entries: (swatch, label)
  let series = 0     // next palette slot
  let last-color = st.palette.at(0)
  let any-side = (right, top + right, bottom + right, top, bottom, top + left, bottom + left, left)
  // The element's own text as a list of zero or one texts. `ats` are the points it
  // may name (the first is preferred), `prefs` the sides of them to try.
  let caption(e, ats, prefs, pad: 0) = {
    if e.at("body", default: none) == none { return () }
    let prefs = if e.pos == auto { prefs + any-side.filter(p => p not in prefs) } else { (e.pos,) }
    let ats = if type(ats.first()) == array { ats } else { (ats,) }
    ((ats: ats, prefs: prefs, body: e.body, size: 1em, pad: pad),)
  }
  // Where a curve can be named: near its end, else further back along it
  // (points squeezed against the edge of the window are skipped).
  let spots-on(pts) = {
    let m = 10
    let free(p) = p.at(0) >= m and p.at(0) <= W - m and p.at(1) >= m and p.at(1) <= H - m
    let out = ()
    for f in (1, 0.8, 0.6, 0.4) {
      let i = int(f * (pts.len() - 1))
      while i > 0 and not free(pts.at(i)) { i -= 1 }
      if free(pts.at(i)) and pts.at(i) not in out { out.push(pts.at(i)) }
    }
    if out.len() == 0 { (pts.last(),) } else { out }
  }

  for e in els {
    let k = e.kind
    if k in ("fn", "parametric", "points") {
      let paint = if e.stroke == auto { auto } else { stroke(e.stroke).paint }
      let color = if paint == auto { st.palette.at(calc.rem(series, st.palette.len())) } else { paint }
      if paint == auto { series += 1 }
      last-color = color
      let s = _stroke(e.stroke, color, st.line)
      let runs = ()
      if k == "fn" {
        let (a, b) = if e.domain == auto { (x0, x1) } else { (calc.max(x0 - mx, e.domain.at(0)), calc.min(x1 + mx, e.domain.at(1))) }
        if a < b {
          let pts = sample-fn(e.f, spaced(a, b, e.step, e.samples), (y1 - y0), "fn")
          runs = visible-runs(pts, window)
        }
      } else if k == "parametric" {
        let pts = spaced(..e.domain, e.step, e.samples).map(t => {
          let p = (e.f)(t)
          assert(type(p) == array and p.len() == 2, message: "quadrille: parametric: the function must return (x, y), got " + repr(p))
          if finite(p.at(0)) and finite(p.at(1)) { (float(p.at(0)), float(p.at(1))) }
        })
        runs = visible-runs(pts, window)
      }
      for r in runs {
        let pr = r.map(P)
        lines.push(_curve(pr, stroke: s))
        ink.push(pr)
      }
      if runs.len() > 0 { texts += caption(e, spots-on(ink.last()), (right, top + right, bottom + right, top + left)) }
      if k == "points" {
        let pts = if e.f != none {
          let (a, b) = if e.domain == auto { (x0, x1) } else { e.domain }
          let xs = spaced(a, b, if e.step == auto { xstep } else { e.step }, 1)
          xs.map(xv => { let v = value-at(e.f, xv, "points"); if v != none { (xv, v) } }).filter(p => p != none)
        } else { e.pts }
        if e.connect and pts.len() > 1 {
          let path = pts.map(p => (float(p.at(0)), float(p.at(1))))
          if e.close { path.push(path.first()) }
          if e.close and e.fill != none {
            under.push(_curve(path.map(P), fill: if e.fill == auto { color.transparentize(st.area) } else { e.fill }, closed: true))
          }
          for r in visible-runs(path, window) {
            let pr = r.map(P)
            lines.push(_curve(pr, stroke: s))
            ink.push(pr)
          }
        }
        let d = _pt(if e.size == auto { st.mark } else { e.size })
        for p in pts.filter(inside) {
          marks.push(_mark(e.mark, P(p), d, color))
          let (px, py) = P(p)
          ink.push(((px - d / 2, py - d / 2), (px + d / 2, py + d / 2)))
        }
        // names: the third value of a point, first tried away from the middle of the group
        let (cx, cy) = if pts.len() == 0 { (0, 0) } else {
          (pts.map(p => p.at(0)).sum() / pts.len(), pts.map(p => p.at(1)).sum() / pts.len())
        }
        for p in pts.filter(p => p.len() == 3 and inside(p)) {
          let (dx, dy) = (p.at(0) - cx, p.at(1) - cy)
          let h = if calc.abs(dx) < 1e-9 * (x1 - x0) { none } else if dx > 0 { right } else { left }
          let v = if dy < -1e-9 * (y1 - y0) { bottom } else { top }
          let away = if h == none { v } else { h + v }
          let prefs = if e.pos != auto { (e.pos,) } else { (away,) + any-side.filter(q => q != away) }
          texts.push((ats: (P(p),), prefs: prefs, body: p.at(2), size: 1em, pad: d / 2))
        }
        if pts.len() > 0 and inside(pts.last()) {
          texts += caption(e, P(pts.last()), (right, top + right, bottom + right), pad: d / 2)
        }
      }
      if e.label != none {
        let key = if k == "points" {
          box(width: 1.6em, height: 0.8em, {
            if e.connect { place(horizon + left, line(length: 100%, stroke: s)) }
            place(center + horizon, box(width: 0pt, height: 0pt,
              _mark(e.mark, (0, 0), _pt(if e.size == auto { st.mark } else { e.size }), color)))
          })
        } else { box(width: 1.6em, height: 0.8em, place(horizon + left, line(length: 100%, stroke: s))) }
        keys.push((key, e.label))
      }
    } else if k == "area" {
      let color = if e.fill == auto { last-color.transparentize(st.area) } else { e.fill }
      let (a, b) = if e.domain == auto { (x0, x1) } else { e.domain }
      let (a, b) = (calc.max(a, x0 - mx), calc.min(b, x1 + mx))
      if a < b {
        let at(h, xv) = if type(h) == function { value-at(h, xv, "area") } else { float(h) }
        let clamp(v) = calc.max(y0 - (y1 - y0), calc.min(y1 + (y1 - y0), v))
        // one polygon per piece where both f and g are defined
        let pieces = ((),)
        for xv in spaced(a, b, auto, 300) {
          let (fv, gv) = (at(e.f, xv), at(e.g, xv))
          if fv == none or gv == none {
            if pieces.last().len() > 0 { pieces.push(()) }
          } else { pieces.last().push((xv, clamp(fv), clamp(gv))) }
        }
        let s = if e.stroke == none { none } else { _stroke(e.stroke, last-color, st.helper) }
        for pc in pieces.filter(pc => pc.len() > 1) {
          let top-edge = pc.map(t => P((t.at(0), t.at(1))))
          let bottom-edge = pc.rev().map(t => P((t.at(0), t.at(2))))
          under.push(_curve(top-edge + bottom-edge, fill: color, stroke: s, closed: true))
        }
        let mid = (a + b) / 2
        let (fm, gm) = (at(e.f, mid), at(e.g, mid))
        if fm != none and gm != none and inside((mid, (fm + gm) / 2)) {
          texts += caption(e, P((mid, (fm + gm) / 2)), (center,))
        }
      }
      if e.label != none { keys.push((box(width: 1.6em, height: 0.8em, fill: color), e.label)) }
    } else if k in ("segment", "vector", "hline", "vline") {
      let dash = if k in ("hline", "vline") { "dashed" } else { auto }
      let s = _stroke(e.stroke, st.ink, st.helper, dash: dash)
      let (a, b) = if k == "hline" { ((x0 - mx, e.v), (x1 + mx, e.v)) }
        else if k == "vline" { ((e.v, y0 - my), (e.v, y1 + my)) }
        else { (e.a.slice(0, 2).map(float), e.b.slice(0, 2).map(float)) }
      if k == "segment" and e.extend {
        // the line through a and b, long enough to cross the whole window
        let (dx, dy) = (b.at(0) - a.at(0), b.at(1) - a.at(1))
        let n = calc.sqrt(dx * dx + dy * dy)
        let big = 4 * ((x1 - x0) + (y1 - y0) + calc.abs(a.at(0)) + calc.abs(a.at(1)))
        (a, b) = ((a.at(0) - dx / n * big, a.at(1) - dy / n * big), (a.at(0) + dx / n * big, a.at(1) + dy / n * big))
      }
      if k == "vector" {
        let (pa, pb) = (P(a), P(b))
        let (dx, dy) = (pb.at(0) - pa.at(0), pb.at(1) - pa.at(1))
        let len = calc.sqrt(dx * dx + dy * dy)
        let head = calc.min(_pt(st.arrow) * calc.max(1, _pt(s.thickness) / 0.8), len * 0.5)
        if len > 0 {
          let base = (pb.at(0) - dx / len * head * 0.8, pb.at(1) - dy / len * head * 0.8)
          lines.push(_curve((pa, base), stroke: s))
          lines.push(_arrowhead(pb, (dx, dy), head, s.paint))
          ink.push((pa, pb))
          if inside(b) {
            let h = if calc.abs(dx) < 0.3 * len { none } else if dx > 0 { right } else { left }
            let v = if calc.abs(dy) < 0.3 * len { none } else if dy > 0 { bottom } else { top }
            texts += caption(e, pb, (if h == none { v } else if v == none { h } else { h + v },), pad: head * 0.3)
          }
        }
      } else {
        for r in visible-runs((a, b), window) {
          let pr = r.map(P)
          lines.push(_curve(pr, stroke: s))
          ink.push(pr)
        }
        if k == "segment" {
          let m = if e.extend { none } else { ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2) }
          if m != none and inside(m) { texts += caption(e, P(m), (top, bottom, top + left, top + right)) }
        } else if k == "hline" and e.v >= y0 and e.v <= y1 {
          texts += caption(e, (W, Y(e.v)), (top + left, bottom + left))
        } else if k == "vline" and e.v >= x0 and e.v <= x1 {
          texts += caption(e, (X(e.v), 0), (bottom + right, bottom + left))
        }
      }
      if e.label != none {
        keys.push((box(width: 1.6em, height: 0.8em, place(horizon + left, line(length: 100%, stroke: s))), e.label))
      }
    } else if k == "annotate" {
      if inside(e.p) { texts.push((ats: (P(e.p),), prefs: (e.pos,), body: e.body, size: 1em, pad: 0)) }
    }
  }

  // -------- axes
  let axis-items = ()
  let (tick, over, head) = (_pt(st.tick), _pt(st.overhang), _pt(st.arrow))
  let (axx, axy) = if axes == none { (0, H) } else { (X(ax), Y(ay)) }   // y axis column, x axis row
  if axes != none {
    let axis-stroke = (paint: st.ink, thickness: st.axis, cap: "butt")
    axis-items.push(_lines((((0, axy), (W + over - head * 0.6, axy)), ((axx, H), (axx, -over + head * 0.6))), axis-stroke))
    axis-items.push(_arrowhead((W + over, axy), (1, 0), head, st.ink))
    axis-items.push(_arrowhead((axx, -over), (0, -1), head, st.ink))
    let tick-marks = ()
    for (v, _) in xt { tick-marks.push(((X(v), axy - tick / 2), (X(v), axy + tick / 2))) }
    for (v, _) in yt { tick-marks.push(((axx - tick / 2, Y(v)), (axx + tick / 2, Y(v)))) }
    axis-items.push(_lines(tick-marks, (paint: st.ink, thickness: st.axis * 0.8)))
    ink.push(((0, axy), (W + over, axy)))
    ink.push(((axx, H), (axx, -over)))
  }

  // -------- measure texts; numbers are always left-to-right (also on a Hebrew page)
  let gap = _pt(st.gap)
  let styled(body, size) = text(size: size, if type(body) in (int, float) { str(body) } else { body })
  let halo(body) = if st.halo == none { body } else { box(fill: st.halo, outset: 1pt, radius: 1pt, body) }
  let measured(body) = { let m = measure(body); (m.width / 1pt, m.height / 1pt) }
  let number(body) = text(dir: ltr, styled(body, st.tick-label))

  // Numbers that would overlap are thinned out: every 2nd, 3rd ... is kept, 0 always.
  let thin(ticks, along) = {
    if ticks.len() < 2 { return ticks }
    let sizes = ticks.map(t => measured(number(t.at(1))).at(along))
    let pos = ticks.map(t => if along == 0 { X(t.at(0)) } else { Y(t.at(0)) })
    let zero = ticks.position(t => near(t.at(0), 0, 1)) 
    let zero = if zero == none { 0 } else { zero }
    for every in range(1, ticks.len() + 1) {
      let keep = range(ticks.len()).filter(i => calc.rem(calc.abs(i - zero), every) == 0)
      let fits = range(keep.len() - 1).all(n => {
        let (i, j) = (keep.at(n), keep.at(n + 1))
        calc.abs(pos.at(j) - pos.at(i)) >= (sizes.at(i) + sizes.at(j)) / 2 + 2 * gap
      })
      if fits { return keep.map(i => ticks.at(i)) }
    }
    ticks
  }
  let placed = ()     // (x, y, w, h, body)
  let taken = (:)
  if texts.len() > 0 or (legend == auto and keys.len() > 0) {   // only needed to choose places
    for path in ink { for c in _cells-of-path(path) { taken.insert(c, true) } }
  }
  let put(body, r) = (x: r.x, y: r.y, w: r.w, h: r.h, body: body)

  // tick numbers, the lonely 0 of a shared origin, and the axis names: fixed places
  let fixed = ()
  for (v, body) in thin(xt, 0) {
    if origin-shared and near(v, 0, x1 - x0) { continue }
    fixed.push((at: (X(v), axy + tick / 2), pos: bottom, body: halo(number(body))))
  }
  for (v, body) in thin(yt, 1) {
    if origin-shared and near(v, 0, y1 - y0) { continue }
    fixed.push((at: (axx - tick / 2, Y(v)), pos: left, body: halo(number(body))))
  }
  if origin-shared and (xt.any(t => near(t.at(0), 0, x1 - x0)) or yt.any(t => near(t.at(0), 0, y1 - y0))) {
    fixed.push((at: (axx, axy), pos: bottom + left, body: halo(number($0$))))
  }
  let with-factor(name, factor) = {
    if factor == none { return name }
    let f = text(dir: ltr, styled(factor, st.tick-label))
    if name == none { f } else { styled(name, st.axis-label) + h(0.4em) + f }
  }
  let xname = with-factor(x-label, xfactor)
  let yname = with-factor(y-label, yfactor)
  if xname != none {
    fixed.push((at: (if axes == none { W } else { W + over }, axy), pos: right, body: styled(xname, st.axis-label)))
  }
  if yname != none {
    fixed.push((at: (axx, if axes == none { 0 } else { -over }), pos: top, body: styled(yname, st.axis-label)))
  }
  for t in fixed {
    let (w, h) = measured(t.body)
    let r = _rect(t.at, t.pos, w, h, gap)
    placed.push(put(t.body, r))
    for c in _cells-of-rect(r) { taken.insert(c, true) }
  }

  // captions and names: the listed side that covers the least ink and text
  for t in texts {
    let body = halo(styled(t.body, t.size))
    let (w, h) = measured(body)
    let best = none
    for (i, at) in t.ats.enumerate() {
      for (n, side) in t.prefs.enumerate() {
        let r = _rect(at, side, w, h, gap + t.pad)
        let cost = _cost(taken, r, W, H) + n * 0.5 + i * 1.5
        if best == none or cost < best.at(0) { best = (cost, r) }
      }
    }
    let r = best.at(1)
    placed.push(put(body, r))
    for c in _cells-of-rect(r) { taken.insert(c, true) }
  }

  // -------- legend: in the corner with the least on it (or where it was asked for)
  let legend-item = if legend != none and keys.len() > 0 {
    let body = box(fill: white.transparentize(8%), stroke: 0.4pt + luma(200), inset: 5pt, radius: 2pt,
      text(size: 0.85em, std.grid(columns: 2, column-gutter: 0.5em, row-gutter: 0.45em, align: start + horizon,
        ..keys.flatten())))
    let (w, h) = measured(body)
    let pad = 4
    let spot(a) = {
      let (sh, sv) = _side(a)
      let x = if sh < 0 { pad } else if sh > 0 { W - pad - w } else { (W - w) / 2 }
      let y = if sv < 0 { pad } else if sv > 0 { H - pad - h } else { (H - h) / 2 }
      (x: x, y: y, w: w, h: h)
    }
    let r = if legend != auto { spot(legend) } else {
      let best = none
      for (n, corner) in (top + right, top + left, bottom + right, bottom + left).enumerate() {
        let r = spot(corner)
        let cost = _cost(taken, r, W, H) + n * 0.5
        if best == none or cost < best.at(0) { best = (cost, r) }
      }
      best.at(1)
    }
    put(body, r)
  }

  // -------- grow the figure so that nothing hangs out, then assemble
  let reach-x = if axes == none { () } else { (W + over,) }
  let reach-y = if axes == none { () } else { (-over,) }
  let min-x = calc.min(0, ..placed.map(p => p.x))
  let max-x = calc.max(W, ..reach-x, ..placed.map(p => p.x + p.w))
  let min-y = calc.min(0, ..reach-y, ..placed.map(p => p.y))
  let max-y = calc.max(H, ..placed.map(p => p.y + p.h))
  let (ox, oy) = (-min-x, -min-y)
  box(width: (max-x - min-x) * 1pt, height: (max-y - min-y) * 1pt, {
    let at(dx, dy, body) = place(top + left, dx: (ox + dx) * 1pt, dy: (oy + dy) * 1pt, body)
    if grid {
      at(0, 0, _lines(fine(x0, x1, xstep, xminor).map(v => ((X(v), 0), (X(v), H)))
        + fine(y0, y1, ystep, yminor).map(v => ((0, Y(v)), (W, Y(v)))), st.minor-grid))
      at(0, 0, _lines(xgrid.map(v => ((X(v), 0), (X(v), H))) + ygrid.map(v => ((0, Y(v)), (W, Y(v)))), st.grid))
      at(0, 0, _curve(((0, 0), (W, 0), (W, H), (0, H)), stroke: st.grid, closed: true))   // the window's edge
    }
    at(0, 0, box(width: W * 1pt, height: H * 1pt, clip: clip, under.join()))
    at(0, 0, axis-items.join())
    at(0, 0, box(width: W * 1pt, height: H * 1pt, clip: clip, lines.join()))
    at(0, 0, marks.join())
    for p in placed { at(p.x, p.y, p.body) }
    if legend-item != none { at(legend-item.x, legend-item.y, legend-item.body) }
  })
})
