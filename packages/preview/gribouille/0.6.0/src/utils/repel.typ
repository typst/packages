// Force-based label repulsion used when a text/label/typst geom sets
// `repel: true`. Pure function: takes anchors and measured label boxes
// (canvas-cm) plus tuning parameters, returns one `(dx, dy)` offset per
// row that pushes labels apart while keeping them tethered to their
// anchor by a spring pull.
//
// Determinism matters so Typst's incremental compile does not jitter
// labels across runs.

#import "segment-route.typ": aabb-from-centre, aabb-overlap, segment-crosses
#import "errors.typ": fail

#let _norm-2d(dx, dy) = {
  let len = calc.sqrt(dx * dx + dy * dy)
  if len < 1e-9 { return (0.0, 0.0, 0.0) }
  (dx / len, dy / len, len)
}

// Spread each anchor by a deterministic, fixed-magnitude vector. Using
// the golden angle (~137.5 deg) per index plus a seed-dependent rotation
// guarantees that two coincident anchors start at distinct positions
// regardless of `seed`, so the repulsion forces have a non-zero direction
// to act on from the first iteration.
#let DEG-RAD = calc.pi / 180

#let _init-centres(anchors, seed, jitter) = {
  let out = ()
  for i in range(anchors.len()) {
    let theta = (i * 137.508 + seed * 73.0) * DEG-RAD
    let dx = jitter * calc.cos(theta)
    let dy = jitter * calc.sin(theta)
    let (ax, ay) = anchors.at(i)
    out.push((ax + dx, ay + dy))
  }
  out
}

// One simulation step. `half` carries `(hw, hh)` per row, derived once
// from immutable label sizes plus `box-padding`. Returns the new
// centres array and the cumulative squared displacement so the caller
// can detect convergence.
#let _step(centres, anchors, half, params) = {
  let n = centres.len()
  let forces = range(n).map(_ => (0.0, 0.0))
  let boxes = range(n).map(i => {
    let (cx, cy) = centres.at(i)
    let (hw, hh) = half.at(i)
    (x-lo: cx - hw, y-lo: cy - hh, x-hi: cx + hw, y-hi: cy + hh)
  })

  for i in range(n) {
    let (cx, cy) = centres.at(i)
    let (ax, ay) = anchors.at(i)
    let fx = (ax - cx) * params.force-pull
    let fy = (ay - cy) * params.force-pull

    for j in range(n) {
      if j == i { continue }
      let ov = aabb-overlap(boxes.at(i), boxes.at(j))
      if ov == none { continue }
      let (jx, jy) = centres.at(j)
      let (ux, uy, len) = _norm-2d(cx - jx, cy - jy)
      if len == 0 { continue }
      let push = calc.max(ov.at(0), ov.at(1)) * params.force-push
      fx += ux * push
      fy += uy * push
    }

    let (hw, hh) = half.at(i)
    let limit = params.point-padding + calc.max(hw, hh)
    for j in range(n) {
      let (px, py) = anchors.at(j)
      let (ux, uy, len) = _norm-2d(cx - px, cy - py)
      if len == 0 or len >= limit { continue }
      let push = (limit - len) * params.force-push
      fx += ux * push
      fy += uy * push
    }
    forces.at(i) = (fx, fy)
  }

  // Segment-crossing penalty: if the connector from anchor_i to centre_i
  // passes through label_j's padded box, push label_j off the segment so
  // the non-crossing invariant emerges from layout rather than being
  // patched up at draw time.
  for i in range(n) {
    let (six, siy) = anchors.at(i)
    let (eix, eiy) = centres.at(i)
    let (ux, uy, len) = _norm-2d(eix - six, eiy - siy)
    if len == 0 { continue }
    let perp-x = -uy
    let perp-y = ux
    for j in range(n) {
      if j == i { continue }
      if not segment-crosses(anchors.at(i), centres.at(i), boxes.at(j)) {
        continue
      }
      let (jx, jy) = centres.at(j)
      let side = (jx - six) * perp-x + (jy - siy) * perp-y
      let sign = if side >= 0 { 1 } else { -1 }
      let push = params.force-segment
      let (fx2, fy2) = forces.at(j)
      forces.at(j) = (fx2 + sign * perp-x * push, fy2 + sign * perp-y * push)
    }
  }

  let step-cap = params.step-cap
  let total-sq = 0.0
  let new-centres = ()
  for i in range(n) {
    let (cx, cy) = centres.at(i)
    let (fx, fy) = forces.at(i)
    let mag = calc.sqrt(fx * fx + fy * fy)
    let (sx, sy) = if mag <= step-cap or mag < 1e-9 { (fx, fy) } else {
      (fx / mag * step-cap, fy / mag * step-cap)
    }
    new-centres.push((cx + sx, cy + sy))
    total-sq += sx * sx + sy * sy
  }
  (centres: new-centres, total-sq: total-sq)
}

// Internal stability knobs not exposed to users: changing them re-tunes
// the whole force balance and the public defaults are calibrated to it.
#let _default-params = (
  box-padding: 0.1,
  point-padding: 0.05,
  max-iter: 100,
  force-pull: 0.1,
  force-push: 0.2,
  force-segment: 0.3,
  seed: 0,
  step-cap: 0.4,
  jitter: 0.02,
  epsilon: 1e-3,
)

#let merge-params(overrides) = {
  let out = _default-params
  for (k, v) in overrides.pairs() {
    if k not in _default-params {
      fail("repel", "unknown parameter '" + k + "'")
    }
    if v != none { out.insert(k, v) }
  }
  out
}

// Run the repulsion loop and return per-row `(dx, dy)` offsets relative
// to each anchor.
#let repel(anchors, sizes, params: (:)) = {
  let p = merge-params(params)
  let n = anchors.len()
  let half = sizes.map(s => (
    s.w / 2 + p.box-padding,
    s.h / 2 + p.box-padding,
  ))
  let centres = _init-centres(anchors, p.seed, p.jitter)
  // Per-label convergence threshold so the early exit fires once every
  // label is moving below ~3% of `step-cap` per iteration.
  let eps-sq = p.epsilon * p.epsilon * n
  for _ in range(p.max-iter) {
    let next = _step(centres, anchors, half, p)
    centres = next.centres
    if next.total-sq < eps-sq { break }
  }
  let out = ()
  for i in range(n) {
    out.push((
      centres.at(i).at(0) - anchors.at(i).at(0),
      centres.at(i).at(1) - anchors.at(i).at(1),
    ))
  }
  out
}
