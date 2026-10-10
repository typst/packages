// Helpers shared by all renderers.

#import "../geom.typ" as g
#import "../colors.typ": colors as default-palette

/// Resolve a sticker's color name through the palette. `none` means the
/// sticker is masked and is drawn with `hidden`; when that is `auto`, the
/// palette's own `hidden` entry is used.
#let fill-of(name, palette, hidden) = {
  if name == none {
    if hidden == auto { palette.at("hidden", default: default-palette.hidden) } else { hidden }
  } else {
    assert(name in palette, message: "cubst: palette has no color named " + repr(name))
    palette.at(name)
  }
}

/// Lengths used for geometry must be absolute so they can be turned into numbers.
#let abs-pt(value, what) = {
  assert(type(value) == length, message: "cubst: " + what + " must be a length, got " + repr(value))
  value.pt()
}

/// A filled shape placed at absolute coordinates (floats in pt, y down).
/// Axis-aligned rectangles are drawn with `rect` so that `radius` applies.
#let shape(poly, fill, stroke, radius) = {
  if g.is-axis-rect(poly) {
    let (min, max) = g.bbox(poly)
    place(
      top + left,
      dx: min.at(0) * 1pt,
      dy: min.at(1) * 1pt,
      rect(width: (max.at(0) - min.at(0)) * 1pt, height: (max.at(1) - min.at(1)) * 1pt, fill: fill, stroke: stroke, radius: radius),
    )
  } else {
    place(top + left, polygon(fill: fill, stroke: stroke, ..poly.map(p => (p.at(0) * 1pt, p.at(1) * 1pt))))
  }
}

/// A face name for `labels: "faces"`: text on a small white pill, since the
/// centre of a face is where its sticker outlines meet. `s` is the unit in pt.
#let name-label(name, s) = box(
  fill: white,
  inset: (x: 0.12 * s * 1pt, y: 0.05 * s * 1pt),
  radius: 0.1 * s * 1pt,
  text(size: 0.55 * s * 1pt, name),
)

/// An arrow between two points (floats in pt), with a filled head at the end
/// and, if `double`, at the start as well.
#let arrow(from, to, head, color, thickness, double: false) = {
  let (x1, y1) = from
  let (x2, y2) = to
  let (dx, dy) = (x2 - x1, y2 - y1)
  let len = calc.sqrt(dx * dx + dy * dy)
  assert(len > 0, message: "cubst: arrow from and to must differ")
  let (ux, uy) = (dx / len, dy / len)
  let w = head * 0.5
  let tip(tx, ty, ux, uy) = place(
    top + left,
    polygon(
      fill: color,
      stroke: none,
      (tx * 1pt, ty * 1pt),
      ((tx - head * ux + w * uy) * 1pt, (ty - head * uy - w * ux) * 1pt),
      ((tx - head * ux - w * uy) * 1pt, (ty - head * uy + w * ux) * 1pt),
    ),
  )
  let (sx, sy) = if double { (x1 + 0.7 * head * ux, y1 + 0.7 * head * uy) } else { (x1, y1) }
  let (ex, ey) = (x2 - 0.7 * head * ux, y2 - 0.7 * head * uy)
  place(top + left, line(start: (sx * 1pt, sy * 1pt), end: (ex * 1pt, ey * 1pt), stroke: thickness + color))
  tip(x2, y2, ux, uy)
  if double { tip(x1, y1, -ux, -uy) }
}
