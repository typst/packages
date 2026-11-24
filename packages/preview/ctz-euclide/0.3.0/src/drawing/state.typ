// ctz-euclide/src/drawing/state.typ
// Shared drawing-state registry keys and the state-preserving draw helper.

#import "@preview/cetz:0.5.2" as cetz

/// Registry of drawn line segments: list of (p1, p2) pairs (canvas units)
#let _drawn-lines-key = "ctz-drawn-lines"
/// Registry of drawn circles: list of (center: (x, y), radius: r)
#let _drawn-circles-key = "ctz-drawn-circles"
/// Registry of drawn point markers: list of (x, y, radius)
#let _drawn-points-key = "ctz-drawn-points"
/// Registry of placed label rectangles: list of (xmin, ymin, xmax, ymax)
#let _placed-labels-key = "ctz-placed-labels"

/// Like cetz's get-ctx, but PERSISTS shared-state mutations.
///
/// A plain `get-ctx(ctx => ...)` callback receives a copy of the context:
/// mutations to ctx.shared-state made inside it are silently discarded
/// (Typst value semantics). This helper is a custom canvas element whose
/// callback must return `(ctx, elements)`; the returned ctx — including any
/// shared-state changes — is threaded to all subsequent draw elements, and
/// `elements` (an array of cetz elements, or none) is drawn.
#let draw-with-state(callback) = {
  (
    ctx => {
      let (new-ctx, body) = callback(ctx)
      if body == none or body == () {
        return (ctx: new-ctx)
      }
      let res = cetz.process.many(new-ctx, body)
      (ctx: res.ctx, drawables: res.drawables)
    },
  )
}

/// Record a drawn circle in the shared-state registry (label avoidance);
/// returns the updated ctx
#let _record-circle(ctx, center, radius) = {
  let circles = ctx.shared-state.at(_drawn-circles-key, default: ())
  circles.push((center: center, radius: radius))
  ctx.shared-state.insert(_drawn-circles-key, circles)
  ctx
}

/// Record an arc as sampled segments in the drawn-lines registry (label
/// avoidance); angles are Typst angles. Returns the updated ctx.
#let _record-arc-segments(ctx, center, radius, start, stop, steps: 16) = {
  let drawn = ctx.shared-state.at(_drawn-lines-key, default: ())
  let prev = none
  for i in range(steps + 1) {
    let a = start + (stop - start) * i / steps
    let p = (center.at(0) + radius * calc.cos(a), center.at(1) + radius * calc.sin(a))
    if prev != none {
      drawn.push((prev, p))
    }
    prev = p
  }
  ctx.shared-state.insert(_drawn-lines-key, drawn)
  ctx
}

/// Record a straight segment in the drawn-lines registry; returns updated ctx
#let _record-segment(ctx, p1, p2) = {
  let drawn = ctx.shared-state.at(_drawn-lines-key, default: ())
  drawn.push((p1, p2))
  ctx.shared-state.insert(_drawn-lines-key, drawn)
  ctx
}

/// Record a placed label rectangle (xmin, ymin, xmax, ymax) in the
/// shared-state registry; returns the updated ctx
#let _record-label-rect(ctx, rect) = {
  let placed = ctx.shared-state.at(_placed-labels-key, default: ())
  placed.push(rect)
  ctx.shared-state.insert(_placed-labels-key, placed)
  ctx
}
