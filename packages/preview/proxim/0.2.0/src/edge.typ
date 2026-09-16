#import "@preview/cetz:0.5.2"
#import "util.typ" as util

// Parse a label-pos value into (seg-num, pos-ratio, dist).
//
// label-pos may be:
//   ratio              -> (default-seg, ratio, default-dist)
//   float              -> (default-seg, 50%,   float)
//   (ratio,)           -> (default-seg, ratio, default-dist)
//   (ratio, dist)      -> (default-seg, ratio, dist)
//   (seg, ratio)       -> (seg,         ratio, default-dist)
//   (seg, ratio, dist) -> (seg,         ratio, dist)
//
// seg is an integer (1-based segment number).
// ratio is a Typst ratio (e.g. 50%).
// dist is a plain float in CeTZ units.
//
// default-seg and default-dist are supplied by the caller.
#let _parse-label-pos(label-pos, default-seg: 1, default-dist: 0.3) = {
  if type(label-pos) == ratio {
    (default-seg, label-pos, default-dist)
  } else if type(label-pos) == float or type(label-pos) == int {
    (default-seg, 50%, float(label-pos))
  } else if type(label-pos) == array {
    if label-pos.len() == 1 {
      (default-seg, label-pos.at(0), default-dist)
    } else if label-pos.len() == 2 {
      let (a, b) = (label-pos.at(0), label-pos.at(1))
      if type(a) == int {
        (a, b, default-dist)
      } else {
        (default-seg, a, float(b))
      }
    } else if label-pos.len() == 3 {
      (label-pos.at(0), label-pos.at(1), float(label-pos.at(2)))
    } else {
      panic("label-pos array must have 1-3 elements")
    }
  } else {
    panic("label-pos must be a ratio, float, or array")
  }
}

#let _rotated-rect-support(width, height, angle, nx, ny) = {
  let cos-a = calc.cos(angle)
  let sin-a = calc.sin(angle)
  let width-support = calc.abs(nx * cos-a - ny * sin-a) * width / 2
  let height-support = calc.abs(nx * sin-a + ny * cos-a) * height / 2

  width-support + height-support
}

#let _resolve-label-angle-from-delta(dx, dy, label-angle) = {
  if label-angle == auto {
    let angle = calc.atan2(dx, -dy)
    if calc.abs(angle) > 90deg and calc.abs(angle) < 180deg { angle + 180deg } else { angle }
  } else {
    label-angle
  }
}

#let _resolve-label-angle(p0, p1, label-angle) = {
  _resolve-label-angle-from-delta(p1.at(0) - p0.at(0), p1.at(1) - p0.at(1), label-angle)
}

#let _place-label-content(ctx, pt, label, dist, label-align, resolved-label-angle, normal-x, normal-y) = {
  // We use reflow here to ensure that the rotated label’s bounding box affects the canvas bounding
  // box. Without reflow, the label’s bounding box would remain horizontal.
  let label-content = rotate(resolved-label-angle, reflow: true)[#label]

  if dist == 0.0 {
    cetz.draw.content(pt, anchor: "center", align(label-align)[#label-content])
  } else {
    let (label-width, label-height) = cetz.util.measure(ctx, label)
    let sign = if dist > 0 { 1.0 } else { -1.0 }
    let support = _rotated-rect-support(label-width, label-height, resolved-label-angle, normal-x, normal-y)
    let offset = calc.abs(dist) + support
    let label-pt = (
      pt.at(0) + sign * normal-x * offset,
      pt.at(1) + sign * normal-y * offset,
      pt.at(2),
    )
    cetz.draw.content(label-pt, anchor: "center", align(label-align)[#label-content])
  }
}

#let _clamp(v, low, high) = {
  calc.max(low, calc.min(high, v))
}

#let _is-bezier-control-dir(control) = {
  // Ordinary CeTZ coordinates can also be dictionaries, so only treat
  // `control` specially if the caller explicitly opts into the auto-control
  // variant via a `dir` key.
  type(control) == dictionary and "dir" in control
}

#let _resolve-bezier-control-dist(ctx, control, default) = {
  if not _is-bezier-control-dir(control) or not ("dist" in control) {
    return default
  }

  cetz.util.resolve-number(ctx, control.at("dist"))
}

#let _resolve-bezier-bend-dir(a, b, bend-dir) = {
  if bend-dir == auto {
    let dx = b.at(0) - a.at(0)
    let dy = b.at(1) - a.at(1)
    if calc.abs(dx) >= calc.abs(dy) { "north" } else { "east" }
  } else {
    assert(
      bend-dir == "north" or bend-dir == "south" or bend-dir == "east" or bend-dir == "west",
      message: "bezier bend-dir must be auto, \"north\", \"south\", \"east\", or \"west\"",
    )
    bend-dir
  }
}

#let _resolve-auto-bezier-control(ctx, a, b, control) = {
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)
  let mid = ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2, a.at(2))
  let span = (calc.abs(dx) + calc.abs(dy)) / 2
  // Keep the current heuristic simple and deterministic: bow by one third of
  // the average axis span, but move along the normal of the a->b segment so the
  // control point stays perpendicular to the edge itself.
  let offset = _resolve-bezier-control-dist(ctx, control, span / 3)
  let bend-dir = if _is-bezier-control-dir(control) { control.at("dir") } else { auto }
  let bend-dir = _resolve-bezier-bend-dir(a, b, bend-dir)
  let len = calc.sqrt(dx * dx + dy * dy)
  let raw-normal = if len < 1e-6 { (0, 1) } else { (-dy / len, dx / len) }
  // `dir` now selects which side of the line to use. For horizontal/vertical
  // cases this matches the named cardinal direction exactly; for diagonal lines
  // we choose the sign whose normal points most strongly toward that direction.
  let sign = if bend-dir == "north" {
    if raw-normal.at(1) >= 0 { 1 } else { -1 }
  } else if bend-dir == "south" {
    if raw-normal.at(1) <= 0 { 1 } else { -1 }
  } else if bend-dir == "east" {
    if raw-normal.at(0) >= 0 { 1 } else { -1 }
  } else {
    if raw-normal.at(0) <= 0 { 1 } else { -1 }
  }
  let nx = sign * raw-normal.at(0)
  let ny = sign * raw-normal.at(1)
  (mid.at(0) + nx * offset, mid.at(1) + ny * offset, mid.at(2))
}

#let _resolve-bezier-control(ctx, a, b, control) = {
  if control == auto or _is-bezier-control-dir(control) {
    (true, _resolve-auto-bezier-control(ctx, a, b, control))
  } else {
    // Anything else is treated as a normal CeTZ coordinate, including
    // dictionary coordinates such as `(rel: ..., to: ...)`.
    (false, cetz.coordinate.resolve(ctx, control).at(1))
  }
}

#let _quadratic-bezier-point(a, control, b, t) = {
  let u = 1 - t
  (
    u * u * a.at(0) + 2 * u * t * control.at(0) + t * t * b.at(0),
    u * u * a.at(1) + 2 * u * t * control.at(1) + t * t * b.at(1),
    u * u * a.at(2) + 2 * u * t * control.at(2) + t * t * b.at(2),
  )
}

#let _quadratic-bezier-derivative(a, control, b, t) = {
  let u = 1 - t
  (
    2 * (u * (control.at(0) - a.at(0)) + t * (b.at(0) - control.at(0))),
    2 * (u * (control.at(1) - a.at(1)) + t * (b.at(1) - control.at(1))),
    2 * (u * (control.at(2) - a.at(2)) + t * (b.at(2) - control.at(2))),
  )
}

#let _place-bezier-label(line-name, label, pos-ratio, dist, label-align, label-angle, a, control, b) = {
  let t = _clamp(float(pos-ratio), 0.0, 1.0)
  let pt = _quadratic-bezier-point(a, control, b, t)
  let deriv = _quadratic-bezier-derivative(a, control, b, t)
  let _eps = 1e-6
  let raw-dx = deriv.at(0)
  let raw-dy = deriv.at(1)
  // A quadratic Bezier can have a zero derivative at isolated points. When that
  // happens, fall back to the overall start->end direction so auto-rotation and
  // normal placement remain well-defined.
  let dx = if calc.sqrt(raw-dx * raw-dx + raw-dy * raw-dy) < _eps { b.at(0) - a.at(0) } else { raw-dx }
  let dy = if calc.sqrt(raw-dx * raw-dx + raw-dy * raw-dy) < _eps { b.at(1) - a.at(1) } else { raw-dy }
  let len = calc.sqrt(dx * dx + dy * dy)

  let (normal-x, normal-y) = if len < _eps {
    (0.0, 1.0)
  } else {
    (-dy / len, dx / len)
  }
  let resolved-label-angle = _resolve-label-angle-from-delta(dx, dy, label-angle)

  cetz.draw.get-ctx(ctx => {
    _place-label-content(ctx, pt, label, dist, label-align, resolved-label-angle, normal-x, normal-y)
  })
}

// Place a label alongside a named CeTZ line segment.
//
// seg-names  - array of named auxiliary line names, one per segment, in order.
// seg-num    - 1-based index into seg-names.
// pos-ratio  - position along the chosen segment (e.g. 50%).
// dist       - signed perpendicular offset in CeTZ units, using a canonical
//              convention based on the segment's axis (not its travel direction):
//                horizontal segment: positive = north (up),  negative = south (down)
//                vertical segment:   positive = east  (right), negative = west (left)
//                0 -> center of label box placed directly on the line.
#let _place-label(
  seg-names,
  label,
  seg-num,
  pos-ratio,
  dist,
  label-align,
  label-angle,
) = {
  let seg-idx = seg-num - 1
  assert(
    seg-idx >= 0 and seg-idx < seg-names.len(),
    message: "label-pos segment number "
      + repr(seg-num)
      + " is out of range (edge has "
      + repr(seg-names.len())
      + " segment(s))",
  )
  let seg-name = seg-names.at(seg-idx)

  cetz.draw.get-ctx(ctx => {
    let p0 = cetz.coordinate.resolve(ctx, (name: seg-name, anchor: "0%")).at(1)
    let p1 = cetz.coordinate.resolve(ctx, (name: seg-name, anchor: "100%")).at(1)
    let resolved-label-angle = _resolve-label-angle(p0, p1, label-angle)
    let pos-pct = calc.round(float(pos-ratio) * 100)
    let pt = cetz.coordinate.resolve(ctx, (name: seg-name, anchor: str(pos-pct) + "%")).at(1)
    let dx = calc.abs(p1.at(0) - p0.at(0))
    let dy = calc.abs(p1.at(1) - p0.at(1))
    let _eps = 1e-6

    let (normal-x, normal-y) = if dy < _eps {
      (0.0, 1.0)
    } else if dx < _eps {
      (1.0, 0.0)
    } else {
      let raw-dx = p1.at(0) - p0.at(0)
      let raw-dy = p1.at(1) - p0.at(1)
      let len = calc.sqrt(raw-dx * raw-dx + raw-dy * raw-dy)
      (-raw-dy / len, raw-dx / len)
    }

    _place-label-content(ctx, pt, label, dist, label-align, resolved-label-angle, normal-x, normal-y)
  })
}

#let _draw-label(seg-names, label, label-pos, default-seg, label-align, label-angle) = {
  if label == none {
    return
  }

  let (seg-num, pos-ratio, dist) = _parse-label-pos(label-pos, default-seg: default-seg, default-dist: 0.3)
  _place-label(seg-names, label, seg-num, pos-ratio, dist, label-align, label-angle)
}

#let _resolve-shift-pair(ctx, shift) = {
  if type(shift) == array {
    (cetz.util.resolve-number(ctx, shift.at(0)), cetz.util.resolve-number(ctx, shift.at(1)))
  } else {
    let s = cetz.util.resolve-number(ctx, shift)
    (s, s)
  }
}

#let _resolve-2w-points(a, b, routing, routing-dir, s1, s2) = {
  if routing-dir == "north" or routing-dir == "south" {
    let ax = a.at(0) + s1
    let bx = b.at(0)
    let ay = a.at(1)
    let by = b.at(1) + s2
    let a-shifted = (ax, ay, a.at(2))
    let elbow = (ax, by, a.at(2))
    let b-shifted = (bx, by, b.at(2))
    (a-shifted, b-shifted, elbow)
  } else if routing-dir == "east" or routing-dir == "west" {
    let ay = a.at(1) + s1
    let by = b.at(1)
    let ax = a.at(0)
    let bx = b.at(0) + s2
    let a-shifted = (ax, ay, a.at(2))
    let elbow = (bx, ay, a.at(2))
    let b-shifted = (bx, by, b.at(2))
    (a-shifted, b-shifted, elbow)
  } else {
    panic("edge: unsupported 2-way routing \"" + routing + "\"")
  }
}

#let _resolve-3w-bend(ctx, a, b, routing-dir, bend) = {
  let _eps = 1e-10

  if bend != auto {
    if type(bend) == str {
      assert(
        bend == "same-dir" or bend == "opposite-dir",
        message: "bend must be auto, \"same-dir\", \"opposite-dir\", or a non-zero length",
      )

      let primary-y-axis = routing-dir == "south" or routing-dir == "north"
      let use-y-span = if bend == "same-dir" { primary-y-axis } else { not primary-y-axis }
      let span = if use-y-span { calc.abs(b.at(1) - a.at(1)) } else { calc.abs(b.at(0) - a.at(0)) }
      return span / 2
    }

    let v = cetz.util.resolve-number(ctx, bend)
    assert(v != 0, message: "bend must be non-zero")
    return v
  }

  let primary-y-axis = routing-dir == "south" or routing-dir == "north"
  let same-axis = if primary-y-axis {
    calc.abs(b.at(1) - a.at(1)) < _eps
  } else {
    calc.abs(b.at(0) - a.at(0)) < _eps
  }
  let use-y-span = if primary-y-axis { not same-axis } else { same-axis }
  let span = if use-y-span { calc.abs(b.at(1) - a.at(1)) } else { calc.abs(b.at(0) - a.at(0)) }
  span / 2
}

#let _resolve-3w-points(a, b, routing, routing-dir, sa, sb, bend-val) = {
  if routing-dir == "south" {
    let ax = a.at(0) + sa
    let bx = b.at(0) + sb
    (
      (ax, a.at(1), a.at(2)),
      (bx, b.at(1), b.at(2)),
      (ax, a.at(1) - bend-val, a.at(2)),
      (bx, a.at(1) - bend-val, a.at(2)),
    )
  } else if routing-dir == "north" {
    let ax = a.at(0) + sa
    let bx = b.at(0) + sb
    (
      (ax, a.at(1), a.at(2)),
      (bx, b.at(1), b.at(2)),
      (ax, a.at(1) + bend-val, a.at(2)),
      (bx, a.at(1) + bend-val, a.at(2)),
    )
  } else if routing-dir == "west" {
    let ay = a.at(1) + sa
    let by = b.at(1) + sb
    (
      (a.at(0), ay, a.at(2)),
      (b.at(0), by, b.at(2)),
      (a.at(0) - bend-val, ay, a.at(2)),
      (a.at(0) - bend-val, by, a.at(2)),
    )
  } else if routing-dir == "east" {
    let ay = a.at(1) + sa
    let by = b.at(1) + sb
    (
      (a.at(0), ay, a.at(2)),
      (b.at(0), by, b.at(2)),
      (a.at(0) + bend-val, ay, a.at(2)),
      (a.at(0) + bend-val, by, a.at(2)),
    )
  } else {
    panic("edge: unsupported 3-way routing \"" + routing + "\"")
  }
}

#let _draw-straight(points, line-name, style, label, label-pos, label-align, label-angle) = {
  cetz.draw.line(
    ..points,
    name: line-name,
    ..style,
  )
  _draw-label((line-name,), label, label-pos, 1, label-align, label-angle)
}

// Find the border point on `name` in the direction of `b`.
#let _element-line-intersection(ctx, name, b) = {
  util.resolve-element-border(ctx, name, b)
}

// Returns true if `name` is an element name with the default anchor
#let _is-element-with-def-anchor(name) = {
  if type(name) != str {
    return false
  }
  return not util.has-explicit-anchor-ref(name)
}

#let _resolve-axis-points(a, b, routing, shift) = {
  if routing == "horizontal" {
    (
      (a.at(0), a.at(1) + shift, a.at(2)),
      (b.at(0), a.at(1) + shift, a.at(2)),
    )
  } else {
    (
      (a.at(0) + shift, a.at(1), a.at(2)),
      (a.at(0) + shift, b.at(1), a.at(2)),
    )
  }
}

#let _draw-axis(points, line-name, style, label, label-pos, label-align, label-angle, routing, shift) = {
  assert(points.len() == 2, message: "horizontal/vertical routing requires exactly 2 points")
  let (pt-start, pt-end) = (points.at(0), points.at(1))

  cetz.draw.get-ctx(ctx => {
    let first-is-elem = _is-element-with-def-anchor(pt-start)
    let last-is-elem = _is-element-with-def-anchor(pt-end)

    let (ctx, a, b) = cetz.coordinate.resolve(ctx, pt-start, pt-end)
    let s = cetz.util.resolve-number(ctx, shift)

    // First, determine the axis points using raw resolved coordinates (centers)
    let (a-shifted, target) = _resolve-axis-points(a, b, routing, s)

    // If start/end are elements, we want to find the intersection with the border
    // but the neighbor for 'a' is 'target', and for 'b' (used for target) it is 'a-shifted'.
    if first-is-elem {
      a = _element-line-intersection(ctx, pt-start, target)
      // Recalculate shifted start
      a-shifted = if routing == "horizontal" {
        (a.at(0), a.at(1) + s, a.at(2))
      } else {
        (a.at(0) + s, a.at(1), a.at(2))
      }
    }
    if last-is-elem {
      b = _element-line-intersection(ctx, pt-end, a-shifted)
      // Recalculate target
      target = if routing == "horizontal" {
        (b.at(0), a.at(1) + s, a.at(2))
      } else {
        (a.at(0) + s, b.at(1), a.at(2))
      }
    }

    cetz.draw.line(
      a-shifted,
      target,
      name: line-name,
      ..style,
    )

    _draw-label((line-name,), label, label-pos, 1, label-align, label-angle)
  })
}

#let _draw-2w(
  points,
  line-name,
  style,
  label,
  label-pos,
  label-align,
  label-angle,
  routing,
  routing-dir,
  shift,
) = {
  assert(points.len() == 2, message: "2-way routing requires exactly 2 points")
  let (pt-start, pt-end) = (points.at(0), points.at(1))

  cetz.draw.get-ctx(ctx => {
    let first-is-elem = _is-element-with-def-anchor(pt-start)
    let last-is-elem = _is-element-with-def-anchor(pt-end)

    let (ctx, a, b) = cetz.coordinate.resolve(ctx, pt-start, pt-end)
    let (s1, s2) = _resolve-shift-pair(ctx, shift)

    // Preliminary elbows and shifts using centers
    let (a-shifted, b-shifted, elbow) = _resolve-2w-points(a, b, routing, routing-dir, s1, s2)

    if first-is-elem {
      a = _element-line-intersection(ctx, pt-start, elbow)
      // Recalculate a-shifted (elbow depends on a-shifted and b-shifted, but
      // in 2w-north/south, elbow-x = a-shifted-x, elbow-y = b-shifted-y)
      if routing-dir == "north" or routing-dir == "south" {
        a-shifted = (a.at(0) + s1, a.at(1), a.at(2))
        elbow = (a-shifted.at(0), elbow.at(1), a-shifted.at(2))
      } else {
        a-shifted = (a.at(0), a.at(1) + s1, a.at(2))
        elbow = (elbow.at(0), a-shifted.at(1), a-shifted.at(2))
      }
    }
    if last-is-elem {
      b = _element-line-intersection(ctx, pt-end, elbow)
      // Recalculate b-shifted
      if routing-dir == "north" or routing-dir == "south" {
        b-shifted = (b.at(0), b.at(1) + s2, b.at(2))
        elbow = (elbow.at(0), b-shifted.at(1), b-shifted.at(2))
      } else {
        b-shifted = (b.at(0) + s2, b.at(1), b.at(2))
        elbow = (b-shifted.at(0), elbow.at(1), b-shifted.at(2))
      }
    }

    cetz.draw.line(
      a-shifted,
      elbow,
      b-shifted,
      name: line-name,
      ..style,
    )

    if label != none {
      let seg1-name = line-name + "__seg1__"
      let seg2-name = line-name + "__seg2__"
      cetz.draw.line(a-shifted, elbow, name: seg1-name, stroke: (thickness: 0pt))
      cetz.draw.line(elbow, b-shifted, name: seg2-name, stroke: (thickness: 0pt))
      _draw-label((seg1-name, seg2-name), label, label-pos, 2, label-align, label-angle)
    }
  })
}

#let _draw-3w(
  points,
  line-name,
  style,
  label,
  label-pos,
  label-align,
  label-angle,
  routing,
  routing-dir,
  bend,
  shift,
) = {
  assert(points.len() == 2, message: "3-way routing requires exactly 2 points")
  let (pt-start, pt-end) = (points.at(0), points.at(1))

  cetz.draw.get-ctx(ctx => {
    let first-is-elem = _is-element-with-def-anchor(pt-start)
    let last-is-elem = _is-element-with-def-anchor(pt-end)

    let (ctx, a, b) = cetz.coordinate.resolve(ctx, pt-start, pt-end)
    let (sa, sb) = _resolve-shift-pair(ctx, shift)
    let bend-val = _resolve-3w-bend(ctx, a, b, routing-dir, bend)
    let _eps = 1e-10

    if bend-val < _eps {
      panic(
        "edge: routing \""
          + routing
          + "\" requires the two endpoints to differ in X/Y, "
          + "but both have the same X/Y coordinate. Either use a different routing "
          + "direction or supply an explicit (and larger) bend value.",
      )
    }

    let (a-shifted, b-shifted, p1, p2) = _resolve-3w-points(a, b, routing, routing-dir, sa, sb, bend-val)

    if first-is-elem {
      a = _element-line-intersection(ctx, pt-start, p1)
      // Recalculate a-shifted and p1
      let res = _resolve-3w-points(a, b, routing, routing-dir, sa, sb, bend-val)
      a-shifted = res.at(0)
      p1 = res.at(2)
    }
    if last-is-elem {
      b = _element-line-intersection(ctx, pt-end, p2)
      // Recalculate b-shifted and p2
      let res = _resolve-3w-points(a, b, routing, routing-dir, sa, sb, bend-val)
      b-shifted = res.at(1)
      p2 = res.at(3)
    }

    cetz.draw.line(
      a-shifted,
      p1,
      p2,
      b-shifted,
      name: line-name,
      ..style,
    )

    if label != none {
      let seg1-name = line-name + "__seg1__"
      let seg2-name = line-name + "__seg2__"
      let seg3-name = line-name + "__seg3__"
      cetz.draw.line(a-shifted, p1, name: seg1-name, stroke: (thickness: 0pt))
      cetz.draw.line(p1, p2, name: seg2-name, stroke: (thickness: 0pt))
      cetz.draw.line(p2, b-shifted, name: seg3-name, stroke: (thickness: 0pt))
      _draw-label((seg1-name, seg2-name, seg3-name), label, label-pos, 2, label-align, label-angle)
    }
  })
}

#let _draw-bezier(points, line-name, style, label, label-pos, label-align, label-angle, control) = {
  assert(points.len() == 2, message: "bezier routing requires exactly 2 points")
  let (pt-start, pt-end) = (points.at(0), points.at(1))

  cetz.draw.get-ctx(ctx => {
    let first-is-elem = _is-element-with-def-anchor(pt-start)
    let last-is-elem = _is-element-with-def-anchor(pt-end)

    let (ctx, start-center, end-center) = cetz.coordinate.resolve(ctx, pt-start, pt-end)
    let a = start-center
    let b = end-center
    let (auto-control, resolved-control) = _resolve-bezier-control(ctx, a, b, control)

    if first-is-elem {
      a = _element-line-intersection(ctx, pt-start, resolved-control)
    }
    if last-is-elem {
      b = _element-line-intersection(ctx, pt-end, resolved-control)
    }

    if auto-control {
      // The automatic control point depends on the actual endpoints. If an
      // endpoint snaps to a node border, recompute the control point from the
      // adjusted coordinates so the curve keeps the intended bend shape.
      resolved-control = _resolve-auto-bezier-control(ctx, a, b, control)

      if first-is-elem {
        a = _element-line-intersection(ctx, pt-start, resolved-control)
      }
      if last-is-elem {
        b = _element-line-intersection(ctx, pt-end, resolved-control)
      }
    }

    cetz.draw.bezier(
      a,
      b,
      resolved-control,
      name: line-name,
      ..style,
    )

    if label != none {
      let (_, pos-ratio, dist) = _parse-label-pos(label-pos, default-seg: 1, default-dist: 0.3)
      _place-bezier-label(line-name, label, pos-ratio, dist, label-align, label-angle, a, resolved-control, b)
    }
  })
}

/// Draw a directed or undirected edge (line) between two CeTZ coordinates or
/// named element anchors, with optional label and routing.
///
/// Routing modes (controlled by `routing`):
/// - `none` (default): a straight line between the two positional points.
///   `shift` is ignored in this mode.
///   If a point is a named element (e.g. `"A"`), the line will automatically
///   intersect with the element's border.
/// - `"horizontal"`: a single horizontal segment at the start point's y
///   coordinate. `shift` offsets the line vertically.
///   If a point is a named element, the line automatically intersects with
///   the element's border along the horizontal axis.
/// - `"vertical"`: a single vertical segment at the start point's x
///   coordinate. `shift` offsets the line horizontally.
///   If a point is a named element, the line automatically intersects with
///   the element's border along the vertical axis.
/// - `"2w-north"`, `"2w-south"`, `"2w-east"`, `"2w-west"`: a 2-segment
///   orthogonal route with one elbow. `2w-north`/`2w-south` go vertical first
///   to the end point's y coordinate, then horizontal; `2w-east`/`2w-west` go
///   horizontal first to the end point's x coordinate, then vertical. `shift`
///   offsets the two route segments.
///   If a point is a named element, the route automatically intersects with
///   the element's border along the first/last segment's direction.
/// - `"3w-north"`, `"3w-south"`, `"3w-east"`, `"3w-west"`: a 3-segment
///   orthogonal route. The middle segment runs perpendicular to the named
///   direction (horizontal for north/south, vertical for east/west). `bend`
///   controls how far the route bends before turning.
///   If a point is a named element, the route automatically intersects with
///   the element's border along the first/last segment's direction.
///
/// Note: When passing a named element as a coordinate (e.g., `"A"`), `edge`
/// calculates the intersection with the element's border based on the
/// chosen routing strategy, similar to `cetz.draw.line`. To use a specific
/// anchor instead, use the `"A.anchor"` syntax.
///
/// - `label` (`content` or `none`) -- Label to render alongside the edge.
///   Defaults to `none`.
/// - `label-pos` -- Controls which segment the label appears on, where along
///   it, and how far from it. Accepts the following forms (all components have
///   defaults: segment = last segment of the route, position = `50%`, distance
///   = `0.3` CeTZ units):
///   - bare `ratio` (e.g. `50%`) -- position on the default segment, default
///     distance.
///   - bare `float` (e.g. `0.5`) -- default segment, default position, given
///     distance.
///   - `(ratio,)` -- position on the default segment, default distance.
///   - `(ratio, dist)` -- position and distance on the default segment.
///   - `(seg, ratio)` -- explicit 1-based segment number and position, default
///     distance.
///   - `(seg, ratio, dist)` -- all three explicit.
///
///   `dist` is a signed CeTZ-unit offset perpendicular to the segment:
///   - `dist > 0` -> label north of a horizontal segment / east of a vertical
///     segment; the near edge of the box is `dist` from the line.
///   - `dist < 0` -> label south of a horizontal segment / west of a vertical
///     segment; the near edge of the box is `|dist|` from the line.
///   - `dist = 0` -> center of the label box placed directly on the line.
///
///   For straight/horizontal/vertical routing there is 1 segment. For `2w-*`
///   routing there are 2 segments; the default is segment 2 (the last). For
///   `3w-*` routing there are 3 segments; the default is segment 2 (the
///   middle). Defaults to `0.3` (default segment, 50%, 0.3 CeTZ units north /
///   east of the line).
/// - `label-align` (`alignment`) -- Typst alignment applied to the label
///   content. Defaults to `center`.
/// - `label-angle` (`angle` or `auto`) -- Rotation applied to the label
///   content. `auto` uses the angle of the selected label segment, so the label
///   follows the edge direction. For Bezier edges, it uses the tangent angle at
///   the chosen label position. Defaults to `0deg`.
/// - `routing` (`none` or `string`) -- Routing strategy. One of `none`,
///   `"horizontal"`, `"vertical"`, `"2w-north"`, `"2w-south"`, `"2w-east"`,
///   `"2w-west"`, `"3w-north"`, `"3w-south"`, `"3w-east"`, `"3w-west"`,
///   `"bezier"`.
///   Defaults to `none`.
/// - `bend` (`auto` or `"same-dir"` or `"opposite-dir"` or `length`) -- Bend
///   distance for 3-segment routing. `"same-dir"` keeps both outer legs moving
///   in the routing direction; `"opposite-dir"` returns to the starting axis.
///   Must be non-zero when supplied explicitly as a length. Defaults to `auto`.
/// - `control` (`auto`, `coordinate`, or dictionary) -- Control point for
///   `routing: "bezier"`. `auto` chooses a single quadratic Bezier control
///   point from the endpoints by offsetting their midpoint along a canonical
///   normal. A coordinate places the control point explicitly. A dictionary with
///   `dir` chooses the automatic bend direction, and optional `dist` overrides
///   the control-point distance, e.g. `(dir: "south", dist: 1cm)`. Supported
///   directions are `"north"`, `"south"`, `"east"`, and `"west"`. Defaults
///   to `auto`.
/// - `shift` (`length` or `array`) -- Shift applied to the route segments. For
///   2-segment routing this may be a single value or `(shift-first,
///   shift-second)`. For 3-segment routing this may also be `(shift-a, shift-b)`.
//    Defaults to `0`.
/// - `..args` -- Remaining positional arguments are the line's coordinate
///   points; named arguments are forwarded as CeTZ `line` style options
///   (e.g. `name`, `stroke`, `mark`, ...).
#let edge(
  label: none,
  label-pos: 0.3,
  label-align: center,
  label-angle: 0deg,
  routing: none,
  bend: auto,
  control: auto,
  shift: 0,
  ..args,
) = {
  let points = args.pos()
  let style = args.named()
  let user-name = style.at("name", default: none)
  let line-name = if user-name != none { user-name } else { "__edge__" }
  if "name" in style {
    let _ = style.remove("name")
  }

  cetz.draw.get-ctx(ctx => util.assert-nodes-canvas(ctx))

  let (routing-kind, routing-dir) = if routing != none and type(routing) == str and routing.starts-with("2w-") {
    ("2w", routing.slice(3))
  } else if routing != none and type(routing) == str and routing.starts-with("3w-") {
    ("3w", routing.slice(3))
  } else {
    (none, none)
  }

  if routing == none {
    _draw-straight(points, line-name, style, label, label-pos, label-align, label-angle)
  } else if routing == "bezier" {
    _draw-bezier(points, line-name, style, label, label-pos, label-align, label-angle, control)
  } else if routing == "horizontal" or routing == "vertical" {
    _draw-axis(points, line-name, style, label, label-pos, label-align, label-angle, routing, shift)
  } else if routing-kind == "2w" {
    _draw-2w(points, line-name, style, label, label-pos, label-align, label-angle, routing, routing-dir, shift)
  } else if routing-kind == "3w" {
    _draw-3w(
      points,
      line-name,
      style,
      label,
      label-pos,
      label-align,
      label-angle,
      routing,
      routing-dir,
      bend,
      shift,
    )
  } else {
    panic("edge: unsupported routing " + repr(routing))
  }
}
