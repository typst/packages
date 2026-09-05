// Shape builders: pure functions from geometry to op dicts. No engine calls
// here — `sketch` and `annotate` resolve styles and render. Adding a shape
// never touches Rust.
#import "style.typ": validate-style

#let _pt(p) = (float(p.at(0)), float(p.at(1)))
#let _sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let _add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let _mul(a, s) = (a.at(0) * s, a.at(1) * s)
#let _len(a) = calc.sqrt(a.at(0) * a.at(0) + a.at(1) * a.at(1))

#let _stroke-op(points, closed, style) = {
  validate-style(style)
  ((op: "stroke", points: points.map(_pt), closed: closed, style: style),)
}

#let _fill-op(boundaries, style) = {
  validate-style(style)
  ((op: "fill", boundaries: boundaries.map(b => b.map(_pt)), style: style),)
}

/// Draws a hand-sketched line segment.
///
/// ```typst
/// line((10, 20), (120, 20), width: 2, roughness: 1.4)
/// ```
///
/// - a (array): Start point `(x, y)` in canvas points.
/// - b (array): End point `(x, y)` in canvas points.
/// - ..style (arguments): Shared stroke style overrides such as `width`,
///   `smoothness`, `roughness`, `taper`, `passes`, `color`, `opacity`, and
///   `seed`.
#let line(a, b, ..style) = _stroke-op((a, b), false, style.named())

/// Draws one hand-sketched curve through an ordered sequence of points.
///
/// ```typst
/// path(((10, 50), (45, 10), (85, 45)), smoothness: 0.8, width: 2)
/// ```
///
/// `path` has no geometric `radius` parameter. Use `width: 2 * radius` when
/// radius means half the stroke thickness, or `smoothness` when it means how
/// roundly the curve passes through its points. Fixed-radius corner rounding
/// is not currently supported.
///
/// - points (array): Two or more `(x, y)` points in canvas points. The curve
///   passes through them in order.
/// - closed (bool): Connect the final point back to the first. Default: `false`.
/// - ..style (arguments): Shared stroke style overrides: `width` is the full
///   nominal stroke width; `smoothness` controls interpolation from `0`
///   (sharper) to `1` (flowing); `roughness` controls wobble; `taper` controls
///   end pressure; `passes` overlays strokes; `color`, `opacity`, and `seed`
///   control rendering and reproducibility.
#let path(points, closed: false, ..style) = _stroke-op(points, closed, style.named())

/// Draws and optionally fills a hand-sketched polygon.
///
/// ```typst
/// polygon(((10, 10), (90, 20), (70, 70)), fill: "hachure")
/// ```
///
/// - points (array): Polygon vertices `(x, y)` in canvas points.
/// - fill (none, str): `none`, `"hachure"`, or `"shade"`. Default: `none`.
/// - closed (bool): Connect the outline's final point to its first. Default: `true`.
/// - ..style (arguments): Shared stroke/fill style overrides.
#let polygon(points, fill: none, closed: true, ..style) = {
  let s = style.named()
  let ops = ()
  if fill != none { ops += _fill-op((points,), s + (pattern: fill)) }
  ops + _stroke-op(points, closed, s)
}

/// Draws and optionally fills a hand-sketched rectangle.
///
/// Sharp corners are the default: a hand-drawn rectangle is four
/// straight-ish segments, so `smoothness` defaults to `0.15` unless overridden.
///
/// - origin (array): Top-left `(x, y)` in canvas points.
/// - size (array): `(width, height)` in canvas points.
/// - fill (none, str): `none`, `"hachure"`, or `"shade"`. Default: `none`.
/// - ..style (arguments): Shared stroke/fill style overrides.
#let rect(origin, size, fill: none, ..style) = {
  let (x, y) = _pt(origin)
  let (w, h) = _pt(size)
  let corners = ((x, y), (x + w, y), (x + w, y + h), (x, y + h))
  polygon(corners, fill: fill, ..((smoothness: 0.15) + style.named()))
}

/// Draws and optionally fills a hand-sketched ellipse.
///
/// - center (array): Center `(x, y)` in canvas points.
/// - radii (array): Horizontal and vertical radii `(rx, ry)` in points.
/// - fill (none, str): `none`, `"hachure"`, or `"shade"`. Default: `none`.
/// - n (int): Number of control points used for the outline. Default: `12`.
/// - ..style (arguments): Shared stroke/fill style overrides.
#let ellipse(center, radii, fill: none, n: 12, ..style) = {
  let (cx, cy) = _pt(center)
  let (rx, ry) = _pt(radii)
  let pts = range(n).map(i => {
    let a = 360deg * i / n
    (cx + rx * calc.cos(a), cy + ry * calc.sin(a))
  })
  polygon(pts, fill: fill, ..((smoothness: 1.0) + style.named()))
}

/// Draws and optionally fills a hand-sketched circle.
///
/// ```typst
/// circle((50, 50), 30, fill: "shade", width: 1.5)
/// ```
///
/// - center (array): Center `(x, y)` in canvas points.
/// - r (float): Circle radius in points.
/// - fill (none, str): `none`, `"hachure"`, or `"shade"`. Default: `none`.
/// - ..style (arguments): Shared stroke/fill style overrides.
#let circle(center, r, fill: none, ..style) = ellipse(center, (r, r), fill: fill, ..style)

/// Draws a hand-sketched arrow from one point to another.
///
/// Straight by default. `via:` waypoints bend the shaft through them (smoothed
/// like `path`), and the head follows the shaft's direction of arrival at the
/// tip — the way to draw a curved arrow in one call:
///
/// ```typst
/// arrow((10, 60), (150, 60))
/// arrow((10, 60), (150, 50), via: ((50, 15), (110, 12)))
/// ```
///
/// - from (array): Tail point `(x, y)` in canvas points.
/// - to (array): Tip point `(x, y)` in canvas points.
/// - via (none, array): Waypoints the shaft passes through between `from` and
///   `to`, in order: `((x, y), ...)`, or a bare `(x, y)` for a single
///   waypoint. Default: `none`.
/// - head (float): Arrowhead length in points, capped at 40% of the shaft
///   length. Default: `8`.
/// - ..style (arguments): Shared stroke style overrides.
#let arrow(from, to, via: none, head: 8, ..style) = {
  let s = style.named()
  let waypoints = if via == none { () } else if type(via.at(0)) in (int, float) {
    (via,) // a bare (x, y) means one waypoint
  } else { via }
  let pts = (from,) + waypoints + (to,)
  let total = range(pts.len() - 1).map(i => _len(_sub(pts.at(i + 1), pts.at(i)))).sum()
  let total = calc.max(total, 1e-6)
  let d = _sub(to, pts.at(pts.len() - 2))
  let l = calc.max(_len(d), 1e-6)
  let t = _mul(d, 1 / l)
  let n = (-t.at(1), t.at(0))
  let hl = calc.min(float(head), total * 0.4)
  let back = _sub(to, _mul(t, hl))
  let wing = _mul(n, hl * 0.45)
  _stroke-op(pts, false, s) + _stroke-op(
    (_add(back, wing), to, _sub(back, wing)),
    false,
    (smoothness: 0.2) + s,
  )
}

/// Fills explicit closed boundary rings using the even-odd rule.
///
/// Nested rings become holes. Use `polygon`, `rect`, `ellipse`, or `circle`
/// when an outline is also wanted.
///
/// - boundaries (array): Array of rings; each ring is an array of `(x, y)` points.
/// - pattern (str): `"hachure"` or `"shade"`. Default: `"hachure"`.
/// - ..style (arguments): Shared fill style overrides, including `angle`,
///   `spacing`, `width`, `roughness`, `color`, `opacity`, and `seed`.
#let region(boundaries, pattern: "hachure", ..style) = _fill-op(
  boundaries,
  style.named() + (pattern: pattern),
)

/// Curly brace from `from` to `to`, bulging left of the from->to direction.
/// Drawn as two strokes meeting at the cusp — the way a hand draws it —
/// so the cusp stays sharp while each half flows.
///
/// - from (array): First endpoint `(x, y)` in canvas points.
/// - to (array): Second endpoint `(x, y)` in canvas points.
/// - amplitude (float): Perpendicular distance to the cusp in points.
///   Default: `8`.
/// - ..style (arguments): Shared stroke style overrides.
#let brace(from, to, amplitude: 8, ..style) = {
  let s = (smoothness: 0.9) + style.named()
  let d = _sub(to, from)
  let l = calc.max(_len(d), 1e-6)
  let t = _mul(d, 1 / l)
  let n = (-t.at(1), t.at(0))
  let a = float(amplitude)
  let mid = _add(from, _mul(t, l / 2))
  let cusp = _add(mid, _mul(n, a))
  let half(p, dir) = (
    p,
    _add(_add(p, _mul(t, dir * 0.10 * l)), _mul(n, 0.55 * a)),
    _add(_add(mid, _mul(t, -dir * 0.08 * l)), _mul(n, 0.60 * a)),
    cusp,
  )
  _stroke-op(half(from, 1), false, s) + _stroke-op(half(to, -1), false, s)
}

/// Draws a square bracket whose ticks point to the visual left of `from` → `to`.
///
/// Chalks canvas coordinates are y-down by default, so a left-to-right bracket
/// has upward ticks. Reverse the endpoints to place the ticks on the other side.
///
/// - from (array): First endpoint `(x, y)` on the bracket spine.
/// - to (array): Second endpoint `(x, y)` on the bracket spine.
/// - tick (float): Tick length in points. Default: `6`.
/// - ..style (arguments): Shared stroke style overrides.
#let bracket(from, to, tick: 6, ..style) = {
  let s = (smoothness: 0.1) + style.named()
  let d = _sub(to, from)
  let l = calc.max(_len(d), 1e-6)
  // Screen-coordinate left normal: positive y points down in a Typst canvas.
  let n = (d.at(1) / l, -d.at(0) / l)
  let k = _mul(n, float(tick))
  _stroke-op((_add(from, k), from, to, _add(to, k)), false, s)
}
