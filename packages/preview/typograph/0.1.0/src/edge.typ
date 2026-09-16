#import "utility.typ": unwrap-node, is-coord, split-direction, vadd, vsub, vscale, vlen, vmid, vperp, vunit
#import "geometry.typ": dir-vector
#import "style.typ": validate-edge-style

// Default strength of an automatic bend handle, in diagram units.
#let handle-length = 0.5

#let handle-point(point, angle, strength) = {
  if angle == auto { return none }
  vadd(point, vscale(dir-vector(angle), handle-length * strength))
}

// The auto-bend control point for a straight segment: offset the midpoint
// perpendicular to the start->end chord by `amount` diagram units (the
// simple alternative to hand-picking a `quad()` control point).
#let bend-control(start, end, amount) = {
  let chord = vsub(end, start)
  if vlen(chord) == 0 { return start }
  vadd(vmid(start, end), vscale(vperp(vunit(chord)), amount))
}

#let normalize-highlight(highlight) = {
  if highlight == auto { return auto }
  if highlight == none { return () }
  if type(highlight) == color { return (highlight, highlight) }
  assert(
    type(highlight) == array and highlight.len() in (0, 1, 2) and highlight.all(c => type(c) == color),
    message: "highlight: expects none, a color, or an array of 0-2 colors, got " + repr(highlight),
  )
  if highlight.len() == 1 { (highlight.first(), highlight.first()) } else { highlight }
}

// ---------------------------------------------------------------------
// Explicit path elements, for edges that need a custom bend shape beyond
// what `from:`/`to:`/`bend:`/`smooth()` can express.
// ---------------------------------------------------------------------

/// A straight segment to `end` (a coordinate or node).
#let line(end) = (type: "path-el", kind: "line", ctrl: (), end: end)

/// Marks one interior waypoint as a smooth guide. Bare waypoints remain exact
/// corners, so sharp and smooth sections can coexist on one edge:
/// `edge(a, smooth(b), c, smooth(d), e)`.
#let smooth(end) = (type: "smooth-waypoint", end: end)

/// A quadratic-Bézier segment to `end`, bulging towards `control`. The
/// curve starts at the previous waypoint, ends at `end`, and is pulled
/// toward — but does not pass through — `control`; at its midpoint it
/// reaches halfway to `control`. See `docs/API.md` for a picture.
#let quad(control, end) = {
  assert(is-coord(control), message: "quad() control must be a numeric (x, y) coordinate")
  (type: "path-el", kind: "quad", ctrl: (control,), end: end)
}

/// An endpoint given as an offset `(dx, dy)` from the previous waypoint,
/// instead of as an absolute coordinate. Handy when you know the direction
/// and length of a wire but not the exact position it starts from — most
/// often a `port()`, whose coordinate depends on the gate's rendered size:
///
/// ```typc
/// edge(port(g, "left", index: 0), rel(-1, 0))   // straight, one unit left
/// ```
#let rel(dx, dy) = {
  assert(
    type(dx) in (int, float) and type(dy) in (int, float),
    message: "rel() dx/dy must be numbers",
  )
  (type: "rel", dx: dx, dy: dy)
}

/// Refers to a node by its `name:`, so it does not have to be bound to a
/// variable first: `z(1, 0, name: "a")` … `edge(ref("a"), (2, 0))`. The node
/// itself must still be emitted (write it as a bare statement) — a reference
/// only points at it, so unlike `edge(a, ..)` it cannot draw it for you.
#let ref(name) = {
  assert(type(name) == str, message: "ref() name must be a string")
  (type: "ref", name: name)
}

/// A cubic-Bézier segment to `end`, with two absolute control points:
/// `control-start` sets the direction/strength the curve *leaves* the
/// previous waypoint, `control-end` the direction it *arrives* at `end`
/// from. Think of each as a handle pulled out of its endpoint. See
/// `docs/API.md` for a picture.
#let cubic(control-start, control-end, end) = {
  assert(
    is-coord(control-start) and is-coord(control-end),
    message: "cubic() controls must be numeric (x, y) coordinates",
  )
  (type: "path-el", kind: "cubic", ctrl: (control-start, control-end), end: end)
}

// Resolves anything usable as an edge endpoint — a node (or the array a node
// constructor returns), a `port()` result, or a plain coordinate — to its
// `(x, y)`, the node it should cause to be drawn (`node`), and the node its
// end should be pulled back to the outline of (`clip-to`).
//
// Those last two differ for a `port()`: the port's coordinate already lies
// *on* the gate's outline, so the wire must start exactly there. Clipping it
// as if the point were the gate's centre would swallow half the box.
#let resolve-endpoint(item) = {
  let tag = if type(item) == dictionary { item.at("type", default: none) } else { none }
  if tag == "port" {
    // The coordinate depends on the gate's rendered size, so it is worked
    // out during layout. `clip-to: none` because a port already lies *on*
    // the outline — pulling the wire back would swallow half the box.
    return (end: none, defer: item, node: item.node, clip-to: none)
  }
  if tag == "ref" {
    // Resolved against the diagram's name index during layout.
    return (end: none, defer: item, node: none, clip-to: none)
  }
  if tag == "rel" {
    // Resolved against the preceding waypoint during layout.
    return (end: none, defer: item, node: none, clip-to: none)
  }
  let n = unwrap-node(item)
  if n != none { return (end: (n.x, n.y), defer: none, node: n, clip-to: n) }
  (end: item, defer: none, node: none, clip-to: none)
}

#let normalize-waypoint(item) = {
  let tag = if type(item) == dictionary { item.at("type", default: none) } else { none }
  let is-smooth = tag == "smooth-waypoint"
  let source = if is-smooth { item.end } else { item }
  let is-path-el = type(source) == dictionary and source.at("type", default: none) == "path-el"
  assert(
    not is-smooth or not is-path-el,
    message: "smooth() expects a node, port, ref, rel, or coordinate, not a path element",
  )
  if is-path-el {
    let kind = source.at("kind", default: none)
    let controls = source.at("ctrl", default: none)
    let expected = if kind == "line" { 0 }
      else if kind == "quad" { 1 }
      else if kind == "cubic" { 2 }
      else { none }
    assert(
      expected != none,
      message: "path element kind must be line, quad, or cubic",
    )
    assert(
      type(controls) == array and controls.len() == expected
        and controls.all(is-coord),
      message: kind + " path element has invalid control coordinates",
    )
  }
  let target = if is-path-el { source.end } else { source }
  let (end: end, defer: defer, node: n, clip-to: clip-to) = resolve-endpoint(target)
  // Guarded so the `repr(target)` in the message is only paid on failure.
  if defer == none and not is-coord(end) {
    assert(
      false,
      message: (
        if is-path-el { "path element `end` must resolve to a coordinate, node, port or ref, got " }
        else { "edge waypoints must be a node, a port, a ref, a rel, a (x, y) coordinate, or a path element, got " }
      ) + repr(target),
    )
  }
  (
    end: end,
    defer: defer,
    kind: if is-path-el { source.kind } else { auto },
    ctrl: if is-path-el { source.ctrl } else { none },
    smooth: is-smooth,
    node: n,
    clip-to: clip-to,
  )
}

// ---------------------------------------------------------------------
// Construction
// ---------------------------------------------------------------------

/// Connects a chain of nodes/coordinates with straight or curved wire(s).
/// Passing more than two waypoints draws one segment per consecutive pair
/// (e.g. `edge(a, b, c)` is equivalent to `edge(a, b) + edge(b, c)`, drawn
/// as a single continuous path) — handy for routing one wire through a
/// shared intermediate point, or for writing a chain of spiders tersely.
///
/// Four ways to curve a wire, from least to most explicit:
/// - `smooth(point)` — marks one interior waypoint as a Bézier guide. Bare
///   waypoints are exact corners, so one edge can mix smooth and sharp parts.
/// - `bend: <amount>` — a signed diagram-unit offset applied perpendicular
///   to each plain segment (try `0.3`-ish; the sign picks the side).
/// - `from:`/`to:` — pull an outward handle from the start/end of a simple
///   2-waypoint edge, as an angle, an alignment (`left`/`right`/`top`/
///   `bottom`), or `(direction, strength)`. Thus `to: right` attaches to the
///   terminal node's exact right boundary when clipping is enabled; the curve
///   travels leftward into that end. With `clip: false`, the handle starts at
///   the node centre instead.
/// - `line()`/`quad()`/`cubic()` waypoints — full manual control points.
///
/// `bend:`, `smooth()` and `from:`/`to:` are alternatives, not combinable.
/// `label-pos:` is the fraction of the complete path's physical length, so
/// unequal segments and curves do not bias the label toward a segment index.
///
/// `highlight:` overlays a configurable-opacity band along the wire — a Pauli-web
/// or fault-annotation color (or a `(colorA, colorB)` pair, drawn as two
/// thinner bands straddling the wire) — without changing the wire's own
/// `stroke:`, which you're free to restyle directly (color, thickness,
/// dash, ...).
#let edge(
  ..nodes,
  from: auto,
  to: auto,
  bend: 0,
  highlight: auto,
  label: none,
  label-pos: 0.5,
  stroke: auto,
  clip: auto,
  preset: none,
  style: (:),
  base-style: (:),
) = {
  assert(type(style) == dictionary, message: "edge style must be a dictionary")
  assert(type(base-style) == dictionary, message: "edge base-style must be a dictionary")
  let _ = validate-edge-style(style)
  let _ = validate-edge-style(base-style, source: "edge base-style")
  assert(preset == none or type(preset) == str, message: "edge preset must be a string or none")
  assert(clip == auto or type(clip) == bool, message: "edge clip must be auto or a boolean")
  assert(type(bend) in (int, float), message: "edge bend must be a number")
  assert(
    type(label-pos) in (int, float) and label-pos >= 0 and label-pos <= 1,
    message: "edge label-pos must be a number from 0 to 1",
  )
  // Guarded rather than a bare `assert(cond, message: ..)`: Typst evaluates
  // arguments eagerly, so an interpolated message would be built on every
  // call, and this is the hottest constructor in the package.
  if nodes.named().len() != 0 {
    assert(false, message: "unexpected named argument(s): " + repr(nodes.named()))
  }
  assert(
    bend == 0 or (from == auto and to == auto),
    message: "bend: and from:/to: are alternatives — use at most one on a given edge",
  )
  if from != auto { let _ = split-direction(from) }
  if to != auto { let _ = split-direction(to) }

  let raw = nodes.pos()
  if raw.len() < 2 {
    assert(false, message: "edge(..) needs at least 2 waypoints, got " + str(raw.len()))
  }
  let waypoints = raw.map(normalize-waypoint)
  assert(
    waypoints.first().kind == auto,
    message: "an edge's first waypoint cannot be line(), quad(), or cubic()",
  )
  assert(
    waypoints.first().defer == none or waypoints.first().defer.type != "rel",
    message: "rel() is an offset from the previous waypoint, so it cannot be an edge's first one",
  )

  if from != auto or to != auto {
    assert(
      waypoints.len() == 2 and waypoints.at(0).kind == auto and waypoints.at(1).kind == auto,
      message: "from:/to: can only be used on a simple 2-waypoint edge without custom path elements",
    )
  }
  let has-smooth = waypoints.any(wp => wp.smooth)
  if has-smooth {
    assert(
      not waypoints.first().smooth and not waypoints.last().smooth,
      message: "smooth() can only mark an interior edge waypoint",
    )
    assert(
      waypoints.all(wp => wp.kind == auto),
      message: "smooth() cannot be combined with explicit line()/quad()/cubic() waypoints",
    )
    assert(
      bend == 0 and from == auto and to == auto,
      message: "smooth() cannot be combined with bend: or from:/to:",
    )
  }

  // Record whether layout needs no deferred resolution, relative-only
  // resolution (which needs no global indexes), or node lookup data.
  let deferred-kind = none
  for waypoint in waypoints {
    if waypoint.defer != none {
      if waypoint.defer.type in ("port", "ref") {
        deferred-kind = "lookup"
      } else if deferred-kind == none {
        deferred-kind = "relative"
      }
    }
  }

  // Waypoints retain their source nodes. `diagram()` harvests those while it
  // classifies the item stream, preserving `edge(a, b)` auto-drawing without
  // duplicating node dictionaries into the top-level array.
  (
    (
      type: "edge",
      waypoints: waypoints,
      deferred-kind: deferred-kind,
      // Multiplied by `group(scale: ..)`, so a scaled fragment's wires and
      // highlight bands thin out along with its nodes.
      size-scale: 1,
      from: from,
      to: to,
      bend: bend,
      highlight: normalize-highlight(highlight),
      label: label,
      label-pos: label-pos,
      stroke: stroke,
      clip: clip,
      // A named look from `edge-presets`, resolved at draw time so a diagram
      // can redefine one and every edge that names it follows.
      preset: preset,
      // Defaults declared by `edge-type()`. They remain below the injected
      // preset and per-diagram style layers.
      base-style: base-style,
      style: style,
    ),
  )
}

/// Creates a reusable edge constructor. Factory defaults remain themeable:
/// named presets and diagram-wide edge styles override `base-style`, while a
/// call's own `style:` and direct `stroke:`/`highlight:` remain highest.
#let edge-type(preset, base-style: (:)) = {
  assert(preset == none or type(preset) == str, message: "edge-type() preset must be a string or none")
  let _ = validate-edge-style(base-style, source: "edge-type() base-style")
  (..args) => {
    let named = args.named()
    if preset != none and "preset" not in named { named.preset = preset }
    if base-style.len() > 0 { named.base-style = base-style }
    edge(..args.pos(), ..named)
  }
}

// ---------------------------------------------------------------------
// Resolution: turns raw waypoints into absolute curve segments, in
// diagram units (unscaled). Pure / context-free, so it is unit-testable.
// ---------------------------------------------------------------------

#let resolve-edge-path(e) = {
  let wps = e.waypoints
  let segments = ()
  let i = 1
  while i < wps.len() {
    let cur = wps.at(i)

    // Consecutive smooth guides form one tangent-continuous run between the
    // surrounding exact waypoints. A bare waypoint ends the run and remains
    // an exact corner for the following segment.
    if cur.smooth {
      let guides = ()
      while i < wps.len() - 1 and wps.at(i).smooth {
        guides.push(wps.at(i).end)
        i += 1
      }
      let anchor = wps.at(i).end
      for (index, guide) in guides.enumerate() {
        let target = if index + 1 < guides.len() {
          vmid(guide, guides.at(index + 1))
        } else {
          anchor
        }
        segments.push((kind: "quad", ctrl: (guide,), end: target))
      }
      i += 1
      continue
    }

    let start = wps.at(i - 1).end
    let end = cur.end

    let seg = if cur.kind == "line" {
      (kind: "line", ctrl: (), end: end)
    } else if cur.kind == "quad" {
      (kind: "quad", ctrl: cur.ctrl, end: end)
    } else if cur.kind == "cubic" {
      (kind: "cubic", ctrl: cur.ctrl, end: end)
    } else if e.bend != 0 {
      (kind: "quad", ctrl: (bend-control(start, end, e.bend),), end: end)
    } else {
      let cs = if i == 1 and e.from != auto { handle-point(start, ..split-direction(e.from)) } else { none }
      // Both endpoint directions point outward from their node/coordinate.
      // At the terminal end the Bézier travels opposite that outward handle,
      // so place the control in the requested direction from the endpoint.
      let ce = if i == wps.len() - 1 and e.to != auto {
        let (angle, strength) = split-direction(e.to)
        vadd(end, vscale(dir-vector(angle), handle-length * strength))
      } else { none }
      if cs == none and ce == none {
        (kind: "line", ctrl: (), end: end)
      } else {
        // Give an unspecified end a chord tangent instead of a degenerate
        // control point at the endpoint (which previously disabled clipping).
        let chord-third = vscale(vsub(end, start), 1 / 3)
        if cs == none {
          cs = if vlen(chord-third) > 0 { vadd(start, chord-third) }
            else { vadd(start, vsub(end, ce)) }
        }
        if ce == none {
          ce = if vlen(chord-third) > 0 { vsub(end, chord-third) }
            else { vsub(end, vsub(cs, start)) }
        }
        (kind: "cubic", ctrl: (cs, ce), end: end)
      }
    }

    segments.push(seg)
    i += 1
  }

  (
    segments: segments,
    start: wps.at(0).end,
    // Whether the whole path is polygonal. Part of the path's description
    // rather than something consumers should re-derive — the highlight
    // renderer uses it to skip curve sampling entirely.
    straight: segments.all(seg => seg.kind == "line"),
  )
}

// Absolute point at parameter `t` (0..1) along one resolved segment.
#let point-on-segment(start, seg, t) = {
  let u = 1 - t
  if seg.kind == "line" {
    return (
      u * start.at(0) + t * seg.end.at(0),
      u * start.at(1) + t * seg.end.at(1),
    )
  }
  if seg.kind == "quad" {
    let control = seg.ctrl.at(0)
    return (
      u * u * start.at(0) + 2 * u * t * control.at(0) + t * t * seg.end.at(0),
      u * u * start.at(1) + 2 * u * t * control.at(1) + t * t * seg.end.at(1),
    )
  }
  let first = seg.ctrl.at(0)
  let second = seg.ctrl.at(1)
  (
    u * u * u * start.at(0)
      + 3 * u * u * t * first.at(0)
      + 3 * u * t * t * second.at(0)
      + t * t * t * seg.end.at(0),
    u * u * u * start.at(1)
      + 3 * u * u * t * first.at(1)
      + 3 * u * t * t * second.at(1)
      + t * t * t * seg.end.at(1),
  )
}

// Splits one segment at `t` with de Casteljau's construction. Both returned
// segments retain the input kind, and together describe exactly the same
// geometry as the original. This is the key distinction from merely moving an
// endpoint: the retained curve keeps a valid tangent and cannot turn back
// through a control point that trimming jumped over.
#let split-segment(start, seg, t) = {
  let lerp(a, b) = vadd(a, vscale(vsub(b, a), t))
  if seg.kind == "line" {
    let point = lerp(start, seg.end)
    return (
      point: point,
      left: (kind: "line", ctrl: (), end: point),
      right: (kind: "line", ctrl: (), end: seg.end),
    )
  }
  if seg.kind == "quad" {
    let a = lerp(start, seg.ctrl.at(0))
    let b = lerp(seg.ctrl.at(0), seg.end)
    let point = lerp(a, b)
    return (
      point: point,
      left: (kind: "quad", ctrl: (a,), end: point),
      right: (kind: "quad", ctrl: (b,), end: seg.end),
    )
  }
  let a = lerp(start, seg.ctrl.at(0))
  let b = lerp(seg.ctrl.at(0), seg.ctrl.at(1))
  let c = lerp(seg.ctrl.at(1), seg.end)
  let d = lerp(a, b)
  let e = lerp(b, c)
  let point = lerp(d, e)
  (
    point: point,
    left: (kind: "cubic", ctrl: (a, d), end: point),
    right: (kind: "cubic", ctrl: (e, c), end: seg.end),
  )
}

// Curves have no closed-form arc length. Sample each curved segment once and
// retain its cumulative steps; distance-based trimming and labels can then
// locate path positions without repeating the Bézier walk. Lines remain exact.
#let segment-metrics(start, seg, samples: 24) = {
  if seg.kind == "line" {
    let length = vlen(vsub(seg.end, start))
    return (length: length, cumulative: (0, length), samples: 1)
  }
  let total = 0
  let cumulative = (0,)
  let previous = start
  for i in range(1, samples + 1) {
    let point = point-on-segment(start, seg, i / samples)
    total += vlen(vsub(point, previous))
    cumulative.push(total)
    previous = point
  }
  (length: total, cumulative: cumulative, samples: samples)
}

// Finds the segment parameter whose sampled prefix has the requested length.
#let segment-t-at-length(metrics, distance) = {
  let segment-len = metrics.length
  if segment-len <= 0 { return 0 }
  if metrics.samples == 1 {
    return calc.min(calc.max(distance / segment-len, 0), 1)
  }
  let target = calc.min(calc.max(distance, 0), segment-len)
  // Cumulative distances are monotonic. Binary elimination takes about five
  // probes at the default 24 samples instead of walking up to all of them.
  let low = 1
  let high = metrics.cumulative.len() - 1
  while low < high {
    let middle = calc.floor((low + high) / 2)
    if metrics.cumulative.at(middle) < target {
      low = middle + 1
    } else {
      high = middle
    }
  }
  let before = metrics.cumulative.at(low - 1)
  let after = metrics.cumulative.at(low)
  let step = after - before
  let fraction = if step == 0 { 0 } else { (target - before) / step }
  (low - 1 + fraction) / metrics.samples
}

#let path-metrics(resolved) = {
  let starts = ()
  let metrics = ()
  let total = 0
  let start = resolved.start
  for seg in resolved.segments {
    starts.push(start)
    let current = segment-metrics(start, seg)
    metrics.push(current)
    total += current.length
    start = seg.end
  }
  (starts: starts, metrics: metrics, length: total)
}

// Absolute point at distance fraction `t` (0..1) along the whole path.
#let point-on-path(resolved, t, metrics: auto) = {
  let info = if metrics == auto { path-metrics(resolved) } else { metrics }
  if info.length <= 1e-9 { return resolved.start }
  let target = calc.min(calc.max(t, 0), 1) * info.length
  let walked = 0
  for i in range(resolved.segments.len()) {
    let current = info.metrics.at(i)
    if walked + current.length >= target or i == resolved.segments.len() - 1 {
      let local-t = segment-t-at-length(current, target - walked)
      return point-on-segment(
        info.starts.at(i),
        resolved.segments.at(i),
        local-t,
      )
    }
    walked += current.length
  }
  resolved.segments.last().end
}

// The direction the path leaves its start / arrives at its end, in diagram
// units. Used to attach an edge to a node's boundary along the angle it
// actually approaches from.
#let path-start-direction(resolved) = {
  // A repeated waypoint or stationary control has a zero derivative. Continue
  // to the first point that actually differs so clipping still uses the path's
  // limiting direction instead of an arbitrary zero-vector angle.
  for seg in resolved.segments {
    for target in seg.ctrl + (seg.end,) {
      let direction = vsub(target, resolved.start)
      if direction != (0, 0) { return direction }
    }
  }
  (0, 0)
}

#let path-end-direction(resolved) = {
  let endpoint = resolved.segments.last().end
  let index = resolved.segments.len() - 1
  while index >= 0 {
    let seg = resolved.segments.at(index)
    let control-index = seg.ctrl.len() - 1
    while control-index >= 0 {
      let direction = vsub(endpoint, seg.ctrl.at(control-index))
      if direction != (0, 0) { return direction }
      control-index -= 1
    }
    let source = if index == 0 { resolved.start }
      else { resolved.segments.at(index - 1).end }
    let direction = vsub(endpoint, source)
    if direction != (0, 0) { return direction }
    index -= 1
  }
  (0, 0)
}

// Keeps the part of a resolved path between two exact segment parameters.
// This is the parameter-space counterpart to `trim-resolved`'s distance API:
// outline intersection can locate a boundary directly and should not convert
// a radial distance into an unrelated distance along a curve.
#let trim-resolved-at(
  resolved,
  start-location: (segment: 0, t: 0),
  end-location: auto,
) = {
  let end-location = if end-location == auto {
    (segment: resolved.segments.len() - 1, t: 1)
  } else {
    end-location
  }
  let first = start-location.segment
  let last = end-location.segment
  let start-t = calc.min(calc.max(start-location.t, 0), 1)
  let end-t = calc.min(calc.max(end-location.t, 0), 1)
  // Overlapping endpoint silhouettes can leave no outside portion to draw.
  // Returning the original path is safe because nodes are emitted above it;
  // more importantly, it avoids manufacturing an inverted Bézier.
  if first > last or (first == last and start-t >= end-t) { return resolved }

  let segment-start(index) = if index == 0 {
    resolved.start
  } else {
    resolved.segments.at(index - 1).end
  }
  let first-start = segment-start(first)
  let segments = resolved.segments.slice(first, last + 1)
  let start = first-start
  if first == last {
    // Bound the original segment at the end first, then translate the start's
    // original parameter into that retained prefix.
    let end-split = split-segment(
      first-start,
      resolved.segments.at(first),
      end-t,
    )
    let local-start = if end-t <= 1e-9 { 0 }
      else { calc.min(calc.max(start-t / end-t, 0), 1) }
    let start-split = split-segment(
      first-start,
      end-split.left,
      local-start,
    )
    start = start-split.point
    segments = (start-split.right,)
  } else {
    if start-t > 1e-9 {
      let split = split-segment(
        first-start,
        resolved.segments.at(first),
        start-t,
      )
      start = split.point
      segments.at(0) = split.right
    }
    if end-t < 1 - 1e-9 {
      let split = split-segment(
        segment-start(last),
        resolved.segments.at(last),
        end-t,
      )
      segments.at(segments.len() - 1) = split.left
    }
  }
  resolved + (
    start: start,
    segments: segments,
    straight: segments.all(seg => seg.kind == "line"),
  )
}

// Shortens a resolved path at one or both ends by the given amounts (in
// diagram units), consuming whole short segments and splitting the first/last
// retained segment. Béziers are split with de Casteljau, so trimming preserves
// their kind, control-point count and tangent instead of moving an endpoint
// past a now-stale control point.
#let trim-resolved(resolved, start-amount, end-amount) = {
  if start-amount <= 0 and end-amount <= 0 { return resolved }
  // The overwhelmingly common case has no segments to consume and no curve
  // to subdivide. Keep it exact and allocation-light while applying the same
  // 95% collapse guard as the general path algorithm below.
  if resolved.straight and resolved.segments.len() == 1 {
    let segment = resolved.segments.first()
    let direction = vsub(segment.end, resolved.start)
    let path-len = vlen(direction)
    let sa = calc.max(start-amount, 0)
    let ea = calc.max(end-amount, 0)
    let requested = sa + ea
    let limit = path-len * 0.95
    if requested > 0 and requested >= limit {
      sa *= limit / requested
      ea *= limit / requested
    }
    let unit = vunit(direction)
    let start = vadd(resolved.start, vscale(unit, sa))
    segment.end = vsub(segment.end, vscale(unit, ea))
    return resolved + (
      start: start,
      segments: (segment,),
      straight: true,
    )
  }
  let info = path-metrics(resolved)
  let path-len = info.length
  if path-len <= 1e-9 { return resolved }

  // Never collapse the whole path. Unlike the former endpoint-chord guard,
  // sampled path length remains meaningful for loops and return curves.
  let sa = calc.max(start-amount, 0)
  let ea = calc.max(end-amount, 0)
  let requested = sa + ea
  let limit = path-len * 0.95
  if requested > 0 and requested >= limit {
    sa *= limit / requested
    ea *= limit / requested
  }
  if sa <= 1e-9 and ea <= 1e-9 { return resolved }

  let first = 0
  let last = resolved.segments.len() - 1
  let remaining = sa
  while first < last and (
    info.metrics.at(first).length <= 1e-9
      or remaining >= info.metrics.at(first).length - 1e-9
  ) {
    remaining = calc.max(remaining - info.metrics.at(first).length, 0)
    first += 1
  }
  let start-t = segment-t-at-length(info.metrics.at(first), remaining)

  remaining = ea
  while last > first and (
    info.metrics.at(last).length <= 1e-9
      or remaining >= info.metrics.at(last).length - 1e-9
  ) {
    remaining = calc.max(remaining - info.metrics.at(last).length, 0)
    last -= 1
  }
  let end-t = segment-t-at-length(
    info.metrics.at(last),
    calc.max(info.metrics.at(last).length - remaining, 0),
  )
  trim-resolved-at(
    resolved,
    start-location: (segment: first, t: start-t),
    end-location: (segment: last, t: end-t),
  )
}
