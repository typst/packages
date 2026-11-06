#import "utility.typ": (
  is-node, is-edge, is-content, tight-text, split-direction,
  vadd, vscale,
)
#import "geometry.typ": to-screen, num, resolve-inset, dir-vector
#import "style.typ": (
  merge-style, merge-per-kind, scale-stroke, resolve-edge-style-unchecked,
  validate-edge-style,
)
#import "theme.typ": neutral-theme, resolve-theme
#import "node.typ": (
  node-visual-spec, node-outline, draw-outline, outline-size,
  shape-radius, gate-port-on-outline, scale-inset,
)
#import "config.typ": current-defaults
#import "edge.typ": (
  resolve-edge-path, point-on-segment, point-on-path, path-start-direction,
  path-end-direction, trim-resolved, trim-resolved-at, normalize-highlight,
  path-metrics,
)

#let curve-elements-for(resolved, unit) = {
  let els = (curve.move(to-screen(resolved.start, unit)),)
  for seg in resolved.segments {
    let end = to-screen(seg.end, unit)
    if seg.kind == "line" {
      els.push(curve.line(end))
    } else if seg.kind == "quad" {
      els.push(curve.quad(to-screen(seg.ctrl.at(0), unit), end))
    } else {
      els.push(curve.cubic(to-screen(seg.ctrl.at(0), unit), to-screen(seg.ctrl.at(1), unit), end))
    }
  }
  els
}

// An edge's own `stroke:` wins over the style bag; either way the thickness
// tracks the diagram's zoom, so a scaled-down diagram gets finer wires rather
// than the same heavy ones.
// An edge's label is typeset like a node's: tight ink bounds so it centres
// visually, and sized by the diagram's `font-size` times its zoom — the same
// `k` a node label uses. Without this an edge label would keep the document's
// size while everything around it scaled.
#let prepare-edge-label(
  label,
  label-size,
  label-fill,
  label-inset,
  font-size,
  factor,
) = {
  let own-size = label-size
  let base-size = if own-size != auto { own-size } else if font-size != auto { font-size } else { 1em }
  let body = std.box(
    fill: label-fill,
    inset: scale-inset(label-inset, factor),
    tight-text(text(size: base-size * factor, label)),
  )
  (body: body, size: measure(body))
}

#let edge-label-position(resolved, t, unit, offset, metrics: auto) = {
  let p = to-screen(point-on-path(resolved, t, metrics: metrics), unit)
  if offset == 0pt or offset == 0 { return p }
  // A small two-sided sample gives a stable local tangent for line, quadratic
  // and cubic segments, including at joins and endpoints.
  let lo = calc.max(0, t - 0.001)
  let hi = calc.min(1, t + 0.001)
  let a = to-screen(point-on-path(resolved, lo, metrics: metrics), unit)
  let b = to-screen(point-on-path(resolved, hi, metrics: metrics), unit)
  let dx = num(b.at(0) - a.at(0))
  let dy = num(b.at(1) - a.at(1))
  let magnitude = calc.sqrt(dx * dx + dy * dy)
  if magnitude == 0 { return p }
  let amount = if type(offset) == length { offset } else { offset * 1pt }
  (p.at(0) - dy / magnitude * amount, p.at(1) + dx / magnitude * amount)
}

#let stroke-thickness(spec) = {
  if spec == none or spec == auto { return 0pt }
  if type(spec) == length { return spec }
  let value = stroke(spec)
  if value.thickness == auto { 1pt } else { value.thickness }
}

// Conservative axis-aligned stroke outset. Smooth/orthogonal closed node
// outlines need half the thickness; a mitered polygon or wire can protrude up
// to its stroke's miter limit at an acute join.
#let stroke-outset(spec, miter: false) = {
  let half = stroke-thickness(spec) / 2
  if not miter or half == 0pt { return half }
  let value = stroke(spec)
  let joined = value.join == auto or value.join == "miter"
  let limit = if value.miter-limit == auto { 4 } else { value.miter-limit }
  // Typst defines the miter limit as protrusion / full stroke thickness.
  if joined { 2 * half * limit } else { half }
}

#let edge-visual-radius(style, highlight, factor, miter: false) = {
  let radius = stroke-outset(style.stroke, miter: miter) * factor
  if highlight.len() > 0 {
    let width = style.highlight-width * factor
    let offset = calc.abs(style.highlight-offset * factor + width / 4)
    radius = calc.max(radius, offset + width / 4)
  }
  radius
}

// ---------------------------------------------------------------------
// `highlight:` rendering — two thin bands straddling the wire. A one-colour
// highlight is normalized to the same colour on both sides, keeping this
// renderer branch-free. Curves are sampled in screen space; polygonal paths
// reuse their exact joints.
// ---------------------------------------------------------------------

// A path of straight segments is described exactly by its joints, so there is
// nothing to gain from sampling it — and that is by far the common case. Only
// curved paths pay for a fixed sample walk per curved segment.
#let sample-path-screen(resolved, unit, samples-per-curve: 16) = {
  if resolved.straight {
    return (to-screen(resolved.start, unit),) + resolved.segments.map(seg => to-screen(seg.end, unit))
  }
  let points = (to-screen(resolved.start, unit),)
  let start = resolved.start
  for seg in resolved.segments {
    let count = if seg.kind == "line" { 1 } else { samples-per-curve }
    for i in range(1, count + 1) {
      points.push(to-screen(point-on-segment(start, seg, i / count), unit))
    }
    start = seg.end
  }
  points
}

#let offset-polyline(pts, amount) = {
  if pts.len() < 2 or amount == 0pt { return pts }
  // Repeated waypoints have no direction and add no visible geometry.
  let points = ()
  for point in pts {
    if points.len() == 0 or point != points.last() { points.push(point) }
  }
  if points.len() < 2 { return points }

  let normals = range(points.len() - 1).map(i => {
    let dx = num(points.at(i + 1).at(0) - points.at(i).at(0))
    let dy = num(points.at(i + 1).at(1) - points.at(i).at(1))
    let length = calc.sqrt(dx * dx + dy * dy)
    (-dy / length, dx / length)
  })
  let shifted(point, normal, scale: 1) = (
    point.at(0) + normal.at(0) * amount * scale,
    point.at(1) + normal.at(1) * amount * scale,
  )

  range(points.len()).map(i => {
    let point = points.at(i)
    if i == 0 { return shifted(point, normals.first()) }
    if i == points.len() - 1 { return shifted(point, normals.last()) }

    let before = normals.at(i - 1)
    let after = normals.at(i)
    let sum = (before.at(0) + after.at(0), before.at(1) + after.at(1))
    let length = calc.sqrt(sum.at(0) * sum.at(0) + sum.at(1) * sum.at(1))
    if length <= 1e-9 { return shifted(point, before) }
    let miter = (sum.at(0) / length, sum.at(1) / length)
    let projection = miter.at(0) * before.at(0) + miter.at(1) * before.at(1)
    shifted(point, miter, scale: calc.min(1 / projection, 4))
  })
}

#let curve-through(pts, stroke) = {
  let els = (curve.move(pts.at(0)),)
  for p in pts.slice(1) { els.push(curve.line(p)) }
  curve(..els, stroke: stroke)
}

#let draw-highlight(
  resolved,
  colors,
  unit,
  styles,
  origin,
  size-factor,
) = {
  let width = styles.highlight-width * size-factor
  let band(c) = stroke(
    paint: c.transparentize(100% - styles.highlight-opacity),
    thickness: width / 2, cap: "butt", join: "miter", miter-limit: 4,
  )
  let base = sample-path-screen(resolved, unit)
  let put(c) = place(top + left, dx: origin.at(0), dy: origin.at(1), c)
  let off = styles.highlight-offset * size-factor + width / 4
  put(curve-through(offset-polyline(base, off), band(colors.at(0))))
  put(curve-through(offset-polyline(base, -off), band(colors.at(1))))
}

// A light debug overlay showing the integer diagram-coordinate grid. `x`
// increases rightward, `y` upward (screen bottom = smallest y).
#let draw-grid(bounds, unit, origin) = {
  let (ox, oy) = origin
  let x-min = bounds.left / unit
  let x-max = bounds.right / unit
  let y-min = -bounds.bottom / unit
  let y-max = -bounds.top / unit

  for gx in range(calc.ceil(x-min), calc.floor(x-max) + 1) {
    let px = gx * unit
    place(top + left, dx: ox, dy: oy, line(start: (px, bounds.top), end: (px, bounds.bottom), stroke: .3pt + gray))
    place(top + left, dx: px + ox, dy: bounds.bottom + oy, place(top + center, dy: 1pt, text(.4em, fill: gray, str(gx))))
  }
  for gy in range(calc.ceil(y-min), calc.floor(y-max) + 1) {
    let py = -gy * unit
    place(top + left, dx: ox, dy: oy, line(start: (bounds.left, py), end: (bounds.right, py), stroke: .3pt + gray))
    place(top + left, dx: bounds.left + ox, dy: py + oy, place(left + horizon, dx: -2pt, text(.4em, fill: gray, str(gy))))
  }
}

// Diagram-unit direction -> screen angle, matching the convention the
// shape outlines in `node.typ` are built in (0deg = +x, 90deg = +y-down).
// Note Typst's `calc.atan2` takes x first, then y.
#let screen-angle(dir) = calc.atan2(dir.at(0), -dir.at(1))

// A cheap bucket key for node identity. Names are already unique identifiers;
// using them prevents co-located named nodes from degrading to a quadratic
// equality scan. Unnamed nodes include their inexpensive visual fields to
// split the common co-located cases. Exact equality remains authoritative:
// `repr` intentionally elides function bodies and custom metadata is open.
#let node-key(n) = if n.name != none {
  repr(("named", n.name))
} else {
  repr((
    n.x, n.y, n.kind, n.label, n.style,
    n.at("base-style", default: (:)), n.size-scale,
    n.at("port-layout", default: none), n.at("legs", default: (:)),
    n.at("size", default: auto),
  ))
}

#let outline-for(bucket, node) = {
  for entry in bucket {
    if entry.node == node { return entry.outline }
  }
  none
}

// Looks up a waypoint's node outline by identity, or `none` for a plain
// coordinate endpoint (no node to look up) — the shared shape behind both
// ends of an edge, so the two lookups cannot drift out of step.
#let lookup-outline(outline-at, node) = {
  if node == none { return none }
  outline-for(outline-at.at(node-key(node), default: ()), node)
}

#let outline-core(outline) = {
  if outline == none { return none }
  if outline.kind == "parts" { outline.base.outline } else { outline }
}

// Whether an outline has a genuine silhouette to clip against — a
// zero-radius circle or a zero-extent ellipse/rect is a point, not a shape,
// and clipping against it would manufacture an artificial epsilon-sized disk
// instead of a true no-op.
#let outline-is-usable(outline) = (
  outline != none and outline-core(outline).kind not in ("empty", "bare")
    and if outline-core(outline).kind == "circle" { outline-core(outline).radius > 0pt }
      else if outline-core(outline).kind in ("ellipse", "rect") {
        outline-core(outline).half-width > 0pt or outline-core(outline).half-height > 0pt
      } else { true }
)

// Whether an edge endpoint has an explicit from:/to: direction to anchor on
// the node's actual silhouette, rather than falling through to automatic
// curve clipping.
#let is-directed-anchor(clip, direction, outline) = (
  clip and direction != auto and outline != none
    and outline-core(outline).kind not in ("empty", "bare")
)

// The math axis: the height above the text baseline at which `=`, `+`, `-`
// and fraction bars are drawn. It is a font metric — OpenType calls it
// `MathConstants.AxisHeight` — and equals 0.25em in every common math font,
// the value TeX uses too. Typst neither exposes it nor auto-aligns embedded
// content in math (a bare box, a `block` and an `image` all sit on the
// baseline), so a diagram has to position itself against it.
#let math-axis-height = 0.25em

// `scale` is a zoom factor as well as a spacing unit: node sizes and label
// text scale with it, so a diagram looks the same at every size rather than
// growing sparser. The pt values in `style.typ` are calibrated for this
// reference scale, and `size-factor` below is simply `scale / reference`.
#let reference-scale = 1cm

// `scale:` may be given either way round, so you never have to think in
// centimetres:
//
//   * a plain number — a multiple of the reference scale. `scale: 0.8` is
//     "80% of normal size", which is what you usually want, and is unit-free.
//   * any Typst length — `20pt`, `1.5em`, `5mm`, `1cm` — when you need the
//     coordinate unit to be an exact size. `em` makes the whole diagram track
//     the surrounding font size.
//
// The two agree by construction: `scale: 1` and `scale: 1cm` are the same.
#let resolve-scale(spec) = if type(spec) == length { spec } else { spec * reference-scale }

// How far to shift a diagram's baseline so its `y = anchor` line lands on
// the math axis.
//
// A box's baseline defaults to its own bottom edge and a positive shift
// moves the content down. `bounds.bottom` is, in screen pt, exactly the
// distance from the diagram's `y = 0` line down to that bottom edge, so
// shifting by it puts `y = 0` on the text baseline; subtracting the axis
// height then lifts it to the math axis.
//
// Anchoring a *named coordinate line* rather than the bounding box's centre
// is what makes this stable: the result no longer depends on how much of the
// diagram happens to lie above or below its wires, so diagrams of different
// heights still line up with each other and with `=`.
#let baseline-shift(bounds, anchor, unit, axis) = bounds.bottom + anchor * unit - axis

// ---------------------------------------------------------------------
// Deferred endpoints. `port()`, `ref()` and `rel()` cannot know their
// coordinates when the edge is written: a port depends on the gate's rendered
// size, a ref on a node declared elsewhere, and a rel on whatever precedes
// it. They are resolved once layout knows all three — which is why this takes
// the laid-out lookup tables rather than reading any global state, and so is
// directly testable.
// ---------------------------------------------------------------------

// How far back a wire must stop from a node's centre, in diagram units, for
// it to land on that node's silhouette along `dir`.
#let clip-radius(outline, dir, unit) = {
  if outline == none { return 0 }
  num(shape-radius(outline, screen-angle(dir))) / num(unit)
}

// Moves one explicit from:/to: endpoint from its node centre to the exact
// boundary point selected by that outward direction. This happens before
// Bézier construction, so handle strength is still measured from the visible
// endpoint and remains correct even when a node is wider than the handle.
#let anchor-directed-waypoint(item, index, direction, outline, unit) = {
  let (angle, _) = split-direction(direction)
  let outward = dir-vector(angle)
  let radius = clip-radius(outline, outward, unit)
  let waypoint = item.waypoints.at(index)
  waypoint.end = vadd(waypoint.end, vscale(outward, radius))
  // The endpoint is already on the silhouette; do not clip it a second time.
  waypoint.clip-to = none
  item.waypoints.at(index) = waypoint
  item
}

// Converts one outline to numeric screen-space points once per clipped end.
// Re-running length conversion and trigonometric radial queries at every
// bisection probe was substantially more expensive than the intersection.
#let numeric-outline(outline) = {
  let shape = outline-core(outline)
  if shape.kind == "circle" {
    (kind: "circle", radius: num(shape.radius))
  } else if shape.kind == "ellipse" {
    (
      kind: "ellipse",
      half-width: num(shape.half-width),
      half-height: num(shape.half-height),
    )
  } else if shape.kind == "rect" {
    (
      kind: "rect",
      half-width: num(shape.half-width),
      half-height: num(shape.half-height),
      radius: num(shape.radius),
    )
  } else {
    (
      kind: "polygon",
      points: shape.points.map(point => (num(point.at(0)), num(point.at(1)))),
    )
  }
}

// Direct screen-space containment for every supported silhouette. This is
// O(1) for native circle/ellipse/rectangle outlines and one edge walk for a
// polygon. Unlike a radial approximation, the predicate remains correct in
// every filled and unfilled region of a concave silhouette.
#let outline-contains-point(outline, center, point, unit-size) = {
  let shape = outline-core(outline)
  let x = (point.at(0) - center.at(0)) * unit-size
  let y = -(point.at(1) - center.at(1)) * unit-size
  let epsilon = 1e-7
  if shape.kind == "circle" {
    return x * x + y * y <= shape.radius * shape.radius + epsilon
  }
  if shape.kind == "ellipse" {
    if shape.half-width <= epsilon and shape.half-height <= epsilon {
      return calc.abs(x) <= epsilon and calc.abs(y) <= epsilon
    }
    if shape.half-width <= epsilon {
      return calc.abs(x) <= epsilon and calc.abs(y) <= shape.half-height + epsilon
    }
    if shape.half-height <= epsilon {
      return calc.abs(y) <= epsilon and calc.abs(x) <= shape.half-width + epsilon
    }
    return (
      (x / shape.half-width) * (x / shape.half-width)
        + (y / shape.half-height) * (y / shape.half-height)
        <= 1 + epsilon
    )
  }
  if shape.kind == "rect" {
    let ax = calc.abs(x)
    let ay = calc.abs(y)
    if ax > shape.half-width + epsilon or ay > shape.half-height + epsilon {
      return false
    }
    let radius = calc.min(
      calc.max(shape.radius, 0),
      shape.half-width,
      shape.half-height,
    )
    if (
      radius <= epsilon
        or ax <= shape.half-width - radius
        or ay <= shape.half-height - radius
    ) { return true }
    let dx = ax - (shape.half-width - radius)
    let dy = ay - (shape.half-height - radius)
    return dx * dx + dy * dy <= radius * radius + epsilon
  }

  let inside = false
  let on-boundary = false
  for index in range(shape.points.len()) {
    let a = shape.points.at(index)
    let b = shape.points.at(calc.rem(index + 1, shape.points.len()))
    let cross = (
      (b.at(0) - a.at(0)) * (y - a.at(1))
        - (b.at(1) - a.at(1)) * (x - a.at(0))
    )
    if (
      calc.abs(cross) <= epsilon
        and x >= calc.min(a.at(0), b.at(0)) - epsilon
        and x <= calc.max(a.at(0), b.at(0)) + epsilon
        and y >= calc.min(a.at(1), b.at(1)) - epsilon
        and y <= calc.max(a.at(1), b.at(1)) + epsilon
    ) { on-boundary = true }
    if (a.at(1) > y) != (b.at(1) > y) {
      let crossing-x = (
        a.at(0)
          + (y - a.at(1)) * (b.at(0) - a.at(0)) / (b.at(1) - a.at(1))
      )
      if x < crossing-x { inside = not inside }
    }
  }
  inside or on-boundary
}

// Exact intersections for a straight segment and an arbitrary polygon. A
// single containment probe cannot see a line leave and re-enter a concave
// shape, while intersecting each polygon edge is both cheaper and exact.
#let polygon-line-crossing(
  outline,
  center,
  start,
  end,
  unit-size,
  from-end: false,
) = {
  let px = (start.at(0) - center.at(0)) * unit-size
  let py = -(start.at(1) - center.at(1)) * unit-size
  let qx = (end.at(0) - center.at(0)) * unit-size
  let qy = -(end.at(1) - center.at(1)) * unit-size
  let rx = qx - px
  let ry = qy - py
  let rr = rx * rx + ry * ry
  let epsilon = 1e-9
  if rr <= epsilon { return none }

  let candidates = ()
  for index in range(outline.points.len()) {
    let a = outline.points.at(index)
    let b = outline.points.at(calc.rem(index + 1, outline.points.len()))
    let sx = b.at(0) - a.at(0)
    let sy = b.at(1) - a.at(1)
    let ax = a.at(0) - px
    let ay = a.at(1) - py
    let denominator = rx * sy - ry * sx
    if calc.abs(denominator) > epsilon {
      let t = (ax * sy - ay * sx) / denominator
      let u = (ax * ry - ay * rx) / denominator
      if (
        t >= -epsilon and t <= 1 + epsilon
          and u >= -epsilon and u <= 1 + epsilon
      ) {
        candidates.push(calc.min(calc.max(t, 0), 1))
      }
    } else if calc.abs(ax * ry - ay * rx) <= epsilon {
      // Collinear overlap: its projected endpoints delimit any transition
      // from following the boundary to entering or leaving the polygon.
      for point in (a, b) {
        let t = (
          (point.at(0) - px) * rx + (point.at(1) - py) * ry
        ) / rr
        if t >= -epsilon and t <= 1 + epsilon {
          candidates.push(calc.min(calc.max(t, 0), 1))
        }
      }
    }
  }
  if candidates.len() == 0 { return none }

  let unique = ()
  for t in candidates.sorted() {
    if unique.len() == 0 or calc.abs(t - unique.last()) > epsilon {
      unique.push(t)
    }
  }
  let ordered = if from-end { unique.rev() } else { unique }
  let inside = outline-contains-point(
    outline,
    center,
    if from-end { end } else { start },
    unit-size,
  )
  for (index, t) in ordered.enumerate() {
    let next = if index + 1 < ordered.len() {
      ordered.at(index + 1)
    } else if from-end { 0 } else { 1 }
    let beyond = outline-contains-point(
      outline,
      center,
      point-on-segment(start, (kind: "line", ctrl: (), end: end), (t + next) / 2),
      unit-size,
    )
    if inside and not beyond { return t }
    inside = beyond
  }
  none
}

// Finds the first detected outline crossing from one end of a resolved path.
// Polygonal line crossings are analytic, including concave exit/re-entry.
// Curves use bounded sampling followed by physical-accuracy bisection within
// the detected interval. The returned segment/t pair can be split directly
// with de Casteljau; no radial distance is confused with curve arc length.
#let outline-crossing(
  resolved,
  outline,
  center,
  unit,
  from-end: false,
  samples-per-curve: 24,
) = {
  let segment-start(index) = if index == 0 {
    resolved.start
  } else {
    resolved.segments.at(index - 1).end
  }
  let shape = outline-core(outline)
  let outline = numeric-outline(outline)
  let unit-size = num(unit)

  if not from-end {
    for index in range(resolved.segments.len()) {
      let start = segment-start(index)
      let segment = resolved.segments.at(index)
      if segment.kind == "line" and shape.kind == "polygon" {
        let crossing = polygon-line-crossing(
          outline,
          center,
          start,
          segment.end,
          unit-size,
        )
        if crossing != none { return (segment: index, t: crossing) }
      } else {
        let samples = if segment.kind == "line" { 1 } else { samples-per-curve }
        let before-t = 0
        let before-inside = outline-contains-point(outline, center, start, unit-size)
        for step in range(1, samples + 1) {
          let current-t = step / samples
          let current-inside = outline-contains-point(
            outline,
            center,
            point-on-segment(start, segment, current-t),
            unit-size,
          )
          if before-inside and not current-inside {
            let low = before-t
            let high = current-t
            let low-point = point-on-segment(start, segment, low)
            let high-point = point-on-segment(start, segment, high)
            let dx = (high-point.at(0) - low-point.at(0)) * unit-size
            let dy = (high-point.at(1) - low-point.at(1)) * unit-size
            let span = calc.sqrt(dx * dx + dy * dy)
            let count = 10
            let remaining-span = span / 1024
            while remaining-span > 0.002 and count < 30 {
              remaining-span /= 2
              count += 1
            }
            for _ in range(count) {
              let middle = (low + high) / 2
              if outline-contains-point(
                outline,
                center,
                point-on-segment(start, segment, middle),
                unit-size,
              ) {
                low = middle
              } else {
                high = middle
              }
            }
            return (segment: index, t: (low + high) / 2)
          }
          before-t = current-t
          before-inside = current-inside
        }
      }
    }
    return none
  }

  let index = resolved.segments.len() - 1
  while index >= 0 {
    let start = segment-start(index)
    let segment = resolved.segments.at(index)
    if segment.kind == "line" and shape.kind == "polygon" {
      let crossing = polygon-line-crossing(
        outline,
        center,
        start,
        segment.end,
        unit-size,
        from-end: true,
      )
      if crossing != none { return (segment: index, t: crossing) }
    } else {
      let samples = if segment.kind == "line" { 1 } else { samples-per-curve }
      let before-t = 1
      let before-inside = outline-contains-point(
        outline,
        center,
        segment.end,
        unit-size,
      )
      for step in range(1, samples + 1) {
        let current-t = 1 - step / samples
        let current-inside = outline-contains-point(
          outline,
          center,
          point-on-segment(start, segment, current-t),
          unit-size,
        )
        if before-inside and not current-inside {
          let low = current-t
          let high = before-t
          let low-point = point-on-segment(start, segment, low)
          let high-point = point-on-segment(start, segment, high)
          let dx = (high-point.at(0) - low-point.at(0)) * unit-size
          let dy = (high-point.at(1) - low-point.at(1)) * unit-size
          let span = calc.sqrt(dx * dx + dy * dy)
          let count = 10
          let remaining-span = span / 1024
          while remaining-span > 0.002 and count < 30 {
            remaining-span /= 2
            count += 1
          }
          for _ in range(count) {
            let middle = (low + high) / 2
            if outline-contains-point(
              outline,
              center,
              point-on-segment(start, segment, middle),
              unit-size,
            ) {
              high = middle
            } else {
              low = middle
            }
          }
          return (segment: index, t: (low + high) / 2)
        }
        before-t = current-t
        before-inside = current-inside
      }
    }
    index -= 1
  }
  none
}

// Clips an already-resolved automatic path. Kept separate from explicit
// anchoring so the renderer can leave the common straight case entirely local
// instead of hashing a full edge through another function boundary.
#let clip-resolved-to-outlines(
  resolved,
  start-outline: none,
  end-outline: none,
  start-center: auto,
  end-center: auto,
  unit: 1cm,
) = {
  // A point-sized shape has no inside/outside transition. Keeping it here
  // would turn the containment epsilon into an artificial clipping disk.
  let remaining-start = if outline-is-usable(start-outline) { start-outline } else { none }
  let remaining-end = if outline-is-usable(end-outline) { end-outline } else { none }

  if remaining-start == none and remaining-end == none { return resolved }

  // The overwhelmingly common single straight segment is radial at both
  // ends, so the existing allocation-light distance trim is exact here.
  if resolved.straight and resolved.segments.len() == 1 {
    let start-amount = if remaining-start == none { 0 } else {
      clip-radius(remaining-start, path-start-direction(resolved), unit)
    }
    let end-amount = if remaining-end == none { 0 } else {
      let direction = path-end-direction(resolved)
      clip-radius(remaining-end, (-direction.at(0), -direction.at(1)), unit)
    }
    return trim-resolved(resolved, start-amount, end-amount)
  }

  let start-location = (segment: 0, t: 0)
  let end-location = (segment: resolved.segments.len() - 1, t: 1)
  if remaining-start != none {
    let crossing = outline-crossing(
      resolved,
      remaining-start,
      start-center,
      unit,
    )
    if crossing != none { start-location = crossing }
  }
  if remaining-end != none {
    let crossing = outline-crossing(
      resolved,
      remaining-end,
      end-center,
      unit,
      from-end: true,
    )
    if crossing != none { end-location = crossing }
  }
  trim-resolved-at(
    resolved,
    start-location: start-location,
    end-location: end-location,
  )
}

// Pure clipping pipeline shared by integration tests and the renderer's
// explicitly directed branch. Explicit directions choose exact anchors;
// automatic curved endpoints retain the original path outside the node.
#let resolve-clipped-edge(
  item,
  start-outline: none,
  end-outline: none,
  unit: 1cm,
  clip: true,
) = {
  if not clip { return resolve-edge-path(item) }

  let work = item
  let start-center = work.waypoints.first().end
  let end-center = work.waypoints.last().end
  let remaining-start = if outline-is-usable(start-outline) { start-outline } else { none }
  let remaining-end = if outline-is-usable(end-outline) { end-outline } else { none }

  if remaining-start != none and work.from != auto {
    work = anchor-directed-waypoint(work, 0, work.from, remaining-start, unit)
    remaining-start = none
  }
  if remaining-end != none and work.to != auto {
    work = anchor-directed-waypoint(
      work,
      work.waypoints.len() - 1,
      work.to,
      remaining-end,
      unit,
    )
    remaining-end = none
  }

  clip-resolved-to-outlines(
    resolve-edge-path(work),
    start-outline: remaining-start,
    end-outline: remaining-end,
    start-center: start-center,
    end-center: end-center,
    unit: unit,
  )
}

// Resolves every deferred waypoint on one edge, left to right so that a
// chain of `rel()`s each builds on the point before it.
#let resolve-deferred-waypoints(
  item, outline-at, by-name, unit,
  port-spacing: auto,
  size-factor: 1,
) = {
  let done = ()
  let previous = none
  for wp in item.waypoints {
    let resolved = wp
    if wp.defer != none {
      let deferred = wp.defer
      if deferred.type == "port" {
        // Pass only the small identity bucket through the function boundary.
        // Typst memoizes calls from their arguments; passing the complete
        // diagram-wide index here made hashing dwarf the actual lookup.
        let outline = outline-for(
          outline-at.at(node-key(deferred.node), default: ()),
          deferred.node,
        )
        assert(
          outline != none,
          message: "port() refers to a gate that is not in this diagram — is it connected, or emitted?",
        )
        let resolved-port-spacing = deferred.node.at("port-spacing", default: auto)
        if resolved-port-spacing == auto { resolved-port-spacing = port-spacing }
        if resolved-port-spacing != auto {
          resolved-port-spacing *= deferred.node.size-scale * size-factor
        }
        let (dx, dy) = gate-port-on-outline(
          outline,
          deferred.node.legs,
          deferred.side,
          deferred.index,
          rotate: deferred.at("rotate", default: 0deg),
          port-spacing: resolved-port-spacing,
        )
        // Offsets come back in pt; edge geometry works in diagram units.
        resolved.end = (
          deferred.node.x + num(dx) / num(unit),
          deferred.node.y + num(dy) / num(unit),
        )
      } else if deferred.type == "ref" {
        let hit = by-name.at(deferred.name, default: none)
        if hit == none {
          panic(
            "ref(" + repr(deferred.name) + ") found no node with that name in this diagram."
              + " Known names: " + repr(by-name.keys())
              + ". (A named node still has to be emitted — write it as a bare statement.)",
          )
        }
        resolved.end = (hit.x, hit.y)
        resolved.clip-to = hit
      } else {
        assert(previous != none, message: "rel() has no preceding waypoint to offset from")
        resolved.end = (
          previous.at(0) + deferred.dx,
          previous.at(1) + deferred.dy,
        )
      }
    }
    done.push(resolved)
    previous = resolved.end
  }
  item.waypoints = done
  item
}

/// Lays out and draws a diagram. `body` is a code block that
/// builds up a flat list of nodes/edges/content, e.g.:
/// ```typc
/// #import "@preview/typograph:0.2.1" as typ
/// typ.diagram({
///   let a = typ.box(0, 0, [A])
///   let b = typ.box(1, 0, [B])
///   typ.edge(a, b)
/// })
/// ```
/// Inside the block you can drop the `typ.` prefix entirely with a scoped
/// `import typ: *` (see `docs/quarto/concepts.qmd`).
///
/// Diagram coordinates are math-convention: `x` increases rightward, `y`
/// upward. `scale` sets the on-page length of one coordinate unit and zooms
/// the diagram as a whole — node sizes and label text scale with it, so a
/// diagram keeps its proportions at any size. `scale-edges` then stretches
/// only the coordinate grid, spreading nodes apart without resizing them.
/// `inset` is the margin around the diagram: a single value, or a dict with
/// `left`/`right`/`top`/`bottom`/`x`/`y`/`rest` (numbers are diagram units,
/// lengths are absolute). `grid` overlays coordinate gridlines, handy while
/// composing a diagram.
/// `font-size` sets the inherited label size for every node and edge in this
/// diagram (node `font-size` and edge `label-size` overrides still win);
/// `auto` inherits the surrounding document's size.
/// `node-styles`/`edge-styles` override the
/// default look — see the style dictionaries in `style.typ` for the
/// available keys, e.g. `node-styles: (box: (fill: blue))` or `edge-styles:
/// (highlight-width: 4pt)`.
///
/// Vertical placement: the diagram's `y = anchor` line (by default `y = 0`,
/// where wires usually run) is put on the *math axis*, so it lines up with
/// `=` in an equation and reads correctly inline. `math-axis` is that
/// font metric (0.25em by default); `baseline` overrides the computed shift
/// outright if you need raw control.
///
/// Any argument left `auto` falls back to the enclosing `config()` scope
/// (see `config.typ`), then to the package default.
#let diagram(
  body,
  scale: auto,
  grid: auto,
  font-size: auto,
  node-styles: auto,
  edge-styles: auto,
  inset: auto,
  scale-edges: auto,
  port-spacing: auto,
  anchor: auto,
  math-axis: auto,
  baseline: auto,
  // An atomic, explicit theme. The generic renderer defaults to no semantic
  // presets; bundled appearances are optional modules outside the renderer.
  theme: neutral-theme,
) = context {
  let active-theme = resolve-theme(theme)
  let node-presets = active-theme.node-presets
  let edge-defaults = active-theme.edge-defaults
  let edge-presets = active-theme.edge-presets
  // Every argument left as `auto` falls back to the enclosing `config()`
  // scope, then to the package default.
  let cfg = current-defaults()
  let pick(value, key, fallback) = {
    if value != auto { value } else { cfg.at(key, default: fallback) }
  }
  let grid = pick(grid, "grid", false)
  let font-size = pick(font-size, "font-size", auto)
  let baseline = pick(baseline, "baseline", auto)
  let port-spacing = pick(port-spacing, "port-spacing", 7pt)
  assert(type(grid) == bool, message: "diagram grid must be a boolean")
  assert(
    font-size == auto or (type(font-size) == length and font-size > 0pt),
    message: "diagram font-size must be auto or a positive length",
  )
  assert(type(port-spacing) == length and port-spacing > 0pt, message: "diagram port-spacing must be a positive length")
  // `scale` zooms the whole diagram; `scale-edges` then stretches only the
  // coordinate grid, spreading nodes further apart without resizing them.
  // Resolved to an absolute length here: `scale: 1.2em` is only meaningful
  // once the surrounding font size is known, and `size-factor` below divides
  // by the reference, which a length carrying an em component cannot do.
  let scale-value = pick(scale, "scale", reference-scale)
  assert(
    (type(scale-value) == length and scale-value > 0pt)
      or (type(scale-value) in (int, float) and scale-value > 0),
    message: "diagram scale must be a positive length or number",
  )
  let edge-scale = pick(scale-edges, "scale-edges", 1)
  assert(type(edge-scale) in (int, float) and edge-scale > 0, message: "scale-edges must be positive")
  let zoom = resolve-scale(scale-value).to-absolute()
  let unit = zoom * edge-scale
  let size-factor = zoom / reference-scale
  let inset = resolve-inset(
    pick(inset, "inset", 0.1),
    unit,
    source: "diagram inset",
  )
  let anchor = pick(anchor, "anchor", 0)
  let math-axis = pick(math-axis, "math-axis", math-axis-height)
  assert(type(anchor) in (int, float), message: "diagram anchor must be a number")
  assert(type(math-axis) == length, message: "diagram math-axis must be a length")
  assert(
    baseline == auto or type(baseline) == length,
    message: "diagram baseline must be auto or a length",
  )
  // Style dicts merge (config under the call's own) instead of replacing.
  let node-styles = merge-per-kind(
    cfg.at("node-styles", default: (:)),
    if node-styles == auto { (:) } else { node-styles },
  )
  let edge-styles = merge-style(
    cfg.at("edge-styles", default: (:)),
    if edge-styles == auto { (:) } else { edge-styles },
  )
  let _ = validate-edge-style(edge-styles, source: "diagram edge-styles")

  let items = if body == none { () } else { body }
  assert(type(items) == array, message: "diagram body must produce diagram items")
  let pt(p) = to-screen(p, unit)

  // Bounds are four mutable scalars because returning a dictionary from a
  // helper for every point would allocate in the hottest loops.
  let seen-point = false
  let min-x = 0pt
  let max-x = 0pt
  let min-y = 0pt
  let max-y = 0pt

  // --- Pass 1a: classify once. Edges retain their source node in each
  // waypoint, so `edge(a, b)` still auto-draws both ends without copying node
  // dictionaries into the top-level item stream.
  let pending-nodes = ()
  let work = ()
  for item in items {
    if is-node(item) {
      pending-nodes.push(item)
    } else if is-edge(item) {
      work.push(item)
      for waypoint in item.waypoints {
        if waypoint.node != none { pending-nodes.push(waypoint.node) }
      }
    } else if is-content(item) {
      work.push(item)
    } else {
      panic(
        "typograph.diagram: unexpected item " + repr(item)
          + " — did you forget to build it with node()/edge()/place()/etc.?",
      )
    }
  }

  // --- Pass 1b: de-duplicate and prepare nodes before edges need their
  // outlines. The preparation key excludes x/y/name, allowing Typst to reuse
  // label measurements and geometry for visually identical nodes.
  let drawn-nodes = ()
  let outline-at = (:)
  let by-name = (:)
  let seen = (:)
  for node in pending-nodes {
    let key = node-key(node)
    let bucket = seen.at(key, default: ())
    if bucket.any(previous => previous == node) { continue }
    seen.insert(key, bucket + (node,))

    let visual = node-visual-spec(node)
    let prep = node-outline(
      visual,
      preset: node-presets.at(node.kind, default: (:)),
      override: node-styles.at(node.kind, default: (:)),
      font-size: font-size,
      size-factor: size-factor,
      port-spacing: port-spacing,
    )
    let size = outline-size(prep.outline, prep.measured)
    let outline-kind = if prep.outline.kind == "parts" {
      prep.outline.base.outline.kind
    } else {
      prep.outline.kind
    }
    let outset = stroke-outset(
      prep.style.stroke,
      miter: outline-kind == "polygon",
    )
    if prep.outline.kind == "parts" {
      for part in prep.outline.parts {
        outset = calc.max(
          outset,
          stroke-outset(part.stroke, miter: part.outline.kind == "polygon"),
        )
      }
    }
    let position = pt((node.x, node.y))
    drawn-nodes.push((
      position: position,
      body: draw-outline(
        prep.outline,
        prep.style.fill,
        prep.style.stroke,
        prep.label-body,
      ),
    ))

    // Geometry-only lookup buckets keep content graphs out of endpoint calls.
    let lookup = (node: node, outline: prep.outline)
    outline-at.insert(key, outline-at.at(key, default: ()) + (lookup,))
    if node.name != none {
      assert(
        node.name not in by-name,
        message: "duplicate node name " + repr(node.name) + " in one diagram",
      )
      by-name.insert(node.name, node)
    }

    let (px, py) = position
    let (x0, x1) = (px + size.left - outset, px + size.right + outset)
    let (y0, y1) = (py + size.top - outset, py + size.bottom + outset)
    if seen-point {
      min-x = calc.min(min-x, x0)
      max-x = calc.max(max-x, x1)
      min-y = calc.min(min-y, y0)
      max-y = calc.max(max-y, y1)
    } else {
      seen-point = true
      min-x = x0
      max-x = x1
      min-y = y0
      max-y = y1
    }
  }

  // --- Pass 2: plan only wires and free-standing content, accumulating their
  // bounds. Nothing is emitted until the complete origin offset is known.
  let plan = ()

  for item in work {
    if is-content(item) {
      let sz = measure(item.body)
      let a = item.align
      let ax = if a.x == none { center } else { a.x }
      let ay = if a.y == none { horizon } else { a.y }
      let (px, py) = pt((item.x, item.y))
      plan.push((kind: "content", body: item.body, x: px, y: py, align: ax + ay))

      let dx0 = if ax == right { -sz.width } else if ax == center { -sz.width / 2 } else { 0pt }
      let dy0 = if ay == bottom { -sz.height } else if ay == horizon { -sz.height / 2 } else { 0pt }
      let (x0, y0) = (px + dx0, py + dy0)
      let (x1, y1) = (x0 + sz.width, y0 + sz.height)
      if seen-point {
        min-x = calc.min(min-x, x0); max-x = calc.max(max-x, x1)
        min-y = calc.min(min-y, y0); max-y = calc.max(max-y, y1)
      } else {
        seen-point = true
        min-x = x0; max-x = x1; min-y = y0; max-y = y1
      }
    } else {
      // Keep diagram-wide lookup indexes out of memoized function arguments.
      // Relative-only edges need neither index; lookup edges receive only the
      // buckets and names they actually reference.
      let deferred-kind = item.at("deferred-kind", default: none)
      let item = if deferred-kind == none {
        item
      } else if deferred-kind == "relative" {
        resolve-deferred-waypoints(item, (:), (:), unit)
      } else {
        let local-outlines = (:)
        let local-names = (:)
        for waypoint in item.waypoints {
          if waypoint.defer != none and waypoint.defer.type == "port" {
            let key = node-key(waypoint.defer.node)
            local-outlines.insert(
              key,
              outline-at.at(key, default: ()),
            )
          } else if waypoint.defer != none and waypoint.defer.type == "ref" {
            let name = waypoint.defer.name
            let hit = by-name.at(name, default: none)
            if hit == none {
              panic(
                "ref(" + repr(name) + ") found no node with that name in this diagram."
                  + " Known names: " + repr(by-name.keys())
                  + ". (A named node still has to be emitted — write it as a bare statement.)",
              )
            }
            local-names.insert(name, hit)
          }
        }
        resolve-deferred-waypoints(
          item, local-outlines, local-names, unit,
          port-spacing: port-spacing,
          size-factor: size-factor,
        )
      }
      // Resolve the complete style once. Clipping, bounds and emission all use
      // this same value, preventing precedence drift and repeated dictionary
      // merges on the per-edge hot path.
      let style = resolve-edge-style-unchecked(
        item,
        edge-styles,
        presets: edge-presets,
        defaults: edge-defaults,
      )
      let highlight = normalize-highlight(style.highlight)

      // Resolve only the two small outline records this edge can touch.
      // `clip: false` takes the raw path immediately. The common one-line case
      // stays inline and allocation-light; only directed/curved cases cross the
      // more general clipping helpers below.
      let start-node = if style.clip { item.waypoints.first().clip-to } else { none }
      let end-node = if style.clip { item.waypoints.last().clip-to } else { none }
      let start-outline = lookup-outline(outline-at, start-node)
      let end-outline = lookup-outline(outline-at, end-node)
      let directed-start = is-directed-anchor(style.clip, item.from, start-outline)
      let directed-end = is-directed-anchor(style.clip, item.to, end-outline)
      let resolved = if directed-start or directed-end {
        resolve-clipped-edge(
          item,
          start-outline: start-outline,
          end-outline: end-outline,
          unit: unit,
        )
      } else {
        let raw = resolve-edge-path(item)
        if not style.clip or (start-outline == none and end-outline == none) {
          raw
        } else if raw.straight and raw.segments.len() == 1 {
          let start-amount = if start-outline == none { 0 } else {
            clip-radius(start-outline, path-start-direction(raw), unit)
          }
          let end-amount = if end-outline == none { 0 } else {
            let direction = path-end-direction(raw)
            clip-radius(
              end-outline,
              (-direction.at(0), -direction.at(1)),
              unit,
            )
          }
          trim-resolved(raw, start-amount, end-amount)
        } else {
          clip-resolved-to-outlines(
            raw,
            start-outline: start-outline,
            end-outline: end-outline,
            start-center: item.waypoints.first().end,
            end-center: item.waypoints.last().end,
            unit: unit,
          )
        }
      }

      let k = size-factor * item.size-scale
      let visual-radius = edge-visual-radius(
        style, highlight, k,
        miter: resolved.segments.len() > 1,
      )
      // Control points conservatively bound every supported Bézier. Derive the
      // short-lived list from canonical segment data instead of retaining a
      // duplicate point cache in every render-plan entry.
      let geometry-points = (resolved.start,)
      for segment in resolved.segments {
        for control in segment.ctrl { geometry-points.push(control) }
        geometry-points.push(segment.end)
      }
      for p in geometry-points {
        let (x, y) = pt(p)
        let (x0, x1) = (x - visual-radius, x + visual-radius)
        let (y0, y1) = (y - visual-radius, y + visual-radius)
        if seen-point {
          min-x = calc.min(min-x, x0); max-x = calc.max(max-x, x1)
          min-y = calc.min(min-y, y0); max-y = calc.max(max-y, y1)
        } else {
          seen-point = true
          min-x = x0; max-x = x1; min-y = y0; max-y = y1
        }
      }

      let label = none
      if item.label != none {
        let metrics = path-metrics(resolved)
        let position = edge-label-position(
          resolved,
          item.label-pos,
          unit,
          style.label-offset * k,
          metrics: metrics,
        )
        // Only visual inputs cross this function boundary, allowing Typst to
        // reuse identical label layout across geometry-distinct edges.
        let prepared = prepare-edge-label(
          item.label,
          style.label-size,
          style.label-fill,
          style.label-inset,
          font-size,
          k,
        )
        let (body, size) = (prepared.body, prepared.size)
        let (lx, ly) = position
        let (hw, hh) = (size.width / 2, size.height / 2)
        if seen-point {
          min-x = calc.min(min-x, lx - hw); max-x = calc.max(max-x, lx + hw)
          min-y = calc.min(min-y, ly - hh); max-y = calc.max(max-y, ly + hh)
        } else {
          seen-point = true
          min-x = lx - hw; max-x = lx + hw; min-y = ly - hh; max-y = ly + hh
        }
        label = (position: position, body: body)
      }

      plan.push((
        kind: "edge", resolved: resolved, style: style,
        highlight: highlight, scale: k, label: label,
      ))
    }
  }

  // One dictionary, once, for the code below that reads it by name.
  let bounds = (
    left: min-x - inset.left, right: max-x + inset.right,
    top: min-y - inset.top, bottom: max-y + inset.bottom,
  )
  let origin = (-bounds.left, -bounds.top)
  let (ox, oy) = origin
  // An explicit `baseline:` wins; otherwise derive it from the geometry.
  let baseline = if baseline != auto { baseline } else {
    baseline-shift(bounds, anchor, unit, math-axis)
  }

  // --- Pass 3: emit. Wires and labels first, then nodes on top.
  std.box(
    baseline: baseline,
    width: bounds.right - bounds.left,
    height: bounds.bottom - bounds.top,
    {
      if grid { draw-grid(bounds, unit, origin) }

      for step in plan {
        if step.kind == "content" {
          place(top + left, dx: step.x + ox, dy: step.y + oy, place(step.align, step.body))
        } else {
          let (resolved, style) = (step.resolved, step.style)
          if step.highlight.len() > 0 {
            draw-highlight(
              resolved,
              step.highlight,
              unit,
              style,
              origin,
              step.scale,
            )
          }
          place(
            top + left, dx: ox, dy: oy,
            curve(
              ..curve-elements-for(resolved, unit),
              stroke: scale-stroke(style.stroke, step.scale),
            ),
          )
          if step.label != none {
            let (lx, ly) = step.label.position
            place(
              top + left, dx: lx + ox, dy: ly + oy,
              place(center + horizon, step.label.body),
            )
          }
        }
      }

      for d in drawn-nodes {
        let (px, py) = d.position
        place(top + left, dx: px + ox, dy: py + oy, place(center + horizon, d.body))
      }
    },
  )
}
