// ctz-euclide/src/drawing/labels.typ
// Label positioning and drawing functions

#import "@preview/cetz:0.5.2" as cetz
#import "../util.typ"
#import "../draw.typ"
#import "clipping.typ"
#import "state.typ": *

// =============================================================================
// MATH LABEL HELPER
// =============================================================================

/// Greek letter names rendered as symbols in labels ("alpha" → α)
#let _greek-names = (
  "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta",
  "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi", "rho",
  "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega",
  "Gamma", "Delta", "Theta", "Lambda", "Xi", "Pi", "Sigma", "Upsilon",
  "Phi", "Psi", "Omega",
)

/// Convert a point name string to math content.
/// - Greek letter names render as the symbol: "alpha" → α, "omega1" → ω1
/// - Other letters are treated as separate identifiers so multi-character
///   names like "Ma" or "P1" render correctly, and primes ("A'") render
///   as primes.
/// - Names that are not simple identifiers (spaces, punctuation, ...) are
///   returned as plain text instead of panicking inside eval().
#let _math-label(name) = {
  let m = name.match(regex("^([A-Za-z]+)([0-9]*)('*)$"))
  if m == none {
    return name
  }
  let (base, digits, primes) = (m.captures.at(0), m.captures.at(1), m.captures.at(2))
  let expr = if base in _greek-names {
    base
  } else {
    base.clusters().join(" ")
  }
  if digits != "" {
    expr = expr + " " + digits.clusters().join(" ")
  }
  if primes != "" {
    expr = expr + " " + primes
  }
  eval(expr, mode: "math")
}

// =============================================================================
// LABEL POSITIONING HELPERS
// =============================================================================

/// The 8 standard label positions with their angular directions (in degrees)
/// Angle 0 = right, 90 = above, 180 = left, 270 = below
#let _label-positions = (
  (name: "right", angle: 0),
  (name: "above right", angle: 45),
  (name: "above", angle: 90),
  (name: "above left", angle: 135),
  (name: "left", angle: 180),
  (name: "below left", angle: 225),
  (name: "below", angle: 270),
  (name: "below right", angle: 315),
)

/// Normalize angle to [0, 360)
#let _normalize-angle(a) = {
  let result = calc.rem(a, 360)
  if result < 0 { result + 360 } else { result }
}

/// Compute angular distance between two angles (in degrees), result in [0, 180]
#let _angular-distance(a1, a2) = {
  let diff = calc.abs(_normalize-angle(a1) - _normalize-angle(a2))
  if diff > 180 { 360 - diff } else { diff }
}

/// Compute the optimal label position given a list of "avoid" directions (angles in degrees)
/// Returns one of the 8 standard position names
#let compute-auto-label-position(avoid-angles) = {
  if avoid-angles.len() == 0 {
    return "above right"  // Default when nothing to avoid
  }

  // For each candidate position, compute the minimum distance to any avoid angle
  let best-pos = "above right"
  let best-score = -1

  for pos in _label-positions {
    let min-dist = 180  // Start with max possible
    for avoid in avoid-angles {
      let dist = _angular-distance(pos.angle, avoid)
      if dist < min-dist {
        min-dist = dist
      }
    }
    // Higher min-dist is better (farther from all avoid angles)
    if min-dist > best-score {
      best-score = min-dist
      best-pos = pos.name
    }
  }

  best-pos
}

/// Compute the angle (in degrees) from point p1 to point p2
#let _direction-angle(p1, p2) = {
  let dx = p2.at(0) - p1.at(0)
  let dy = p2.at(1) - p1.at(1)
  util.angle-of(dx, dy) / 1deg
}

// =============================================================================
// BASIC LABEL FUNCTIONS
// =============================================================================

/// Label a point with automatic positioning
/// pos can be: "above", "below", "left", "right", "above left", etc.
/// dist is an absolute length (e.g. 5pt) so the gap is canvas-scale independent.
#let label-point(cetz-draw, coord, label, pos: "above", dist: 5pt) = {
  let anchor = draw.ctz-pos-to-anchor(pos)
  cetz-draw.content(coord, label, anchor: anchor, padding: dist)
}

/// Label multiple points with their names
#let label-points(cetz-draw, pt-func, ..args, pos: "above", dist: 5pt) = {
  let names = args.pos()
  let positions = args.named()

  for name in names {
    let p = positions.at(name, default: pos)
    label-point(cetz-draw, pt-func(name), [$#_math-label(name)$], pos: p, dist: dist)
  }
}


// =============================================================================
// COLLISION-AVOIDING PLACEMENT ENGINE (pure functions, no canvas context)
// =============================================================================
// Places a label as close as possible to the preferred anchor without
// overlapping drawn segments, circles, point markers, or other labels.
// Bounded and deterministic: 8 anchors x `rings` distances x shrink scales,
// first collision-free candidate wins; otherwise the least-bad full-size
// candidate is used.

/// Collision rectangle of a label drawn with
/// `content(coord, body, anchor: ctz-pos-to-anchor(pos), padding: pad)`.
/// - pos: ctz position name ("above", "below left", ...)
/// - coord: the content coordinate (x, y)
/// - w, h: measured content size in canvas units
/// - pad: padding in canvas units (applied on all four sides by cetz)
/// Returns (xmin, ymin, xmax, ymax).
#let anchor-candidate-rect(pos, coord, w, h, pad) = {
  let W = w + 2 * pad
  let H = h + 2 * pad
  let x = coord.at(0)
  let y = coord.at(1)
  if pos == "above" { (x - W / 2, y, x + W / 2, y + H) }
  else if pos == "below" { (x - W / 2, y - H, x + W / 2, y) }
  else if pos == "right" { (x, y - H / 2, x + W, y + H / 2) }
  else if pos == "left" { (x - W, y - H / 2, x, y + H / 2) }
  else if pos == "above right" { (x, y, x + W, y + H) }
  else if pos == "above left" { (x - W, y, x, y + H) }
  else if pos == "below right" { (x, y - H, x + W, y) }
  else if pos == "below left" { (x - W, y - H, x, y) }
  else { (x - W / 2, y - H / 2, x + W / 2, y + H / 2) }  // center/unknown
}

/// Ordered list of (pos:, ring:, cost:) candidates, closest to the preferred
/// anchor first: cost = anchor-change cost + ring, with a deterministic
/// tie-break (counter-clockwise neighbor first).
///
/// The anchor-change cost is deliberately NON-monotonic in the angle:
///   same anchor 0 < 45° lean 2.2 < 180° opposite 2.6 < 90° 4.4 < 135° 6.6
/// Staying on the requested side (pushed slightly farther out) is cheap;
/// the OPPOSITE side is next-best because it keeps the label centered on
/// the same axis (above <-> below, left <-> right) — a crowded row then
/// alternates its labels above/below, which reads far calmer than piling
/// them up in staggered rows on one side. Perpendicular and diagonal flips
/// read as chaos and come last.
#let _anchor-change-cost = (0, 2.2, 4.4, 6.6, 2.6)
#let _candidate-list(preferred, rings) = {
  let pref = _label-positions.find(p => p.name == preferred)
  if pref == none { pref = (name: preferred, angle: 45) }
  let items = ()
  for (i, p) in _label-positions.enumerate() {
    let ang-steps = _angular-distance(p.angle, pref.angle) / 45
    // ccw neighbor (positive delta < 180) before cw on equal angular distance
    let delta = _normalize-angle(p.angle - pref.angle)
    let tie = if delta <= 180 { 0 } else { 1 }
    for ring in range(rings) {
      let cost = _anchor-change-cost.at(int(ang-steps)) + ring
      items.push((
        key: cost * 1000 + tie * 100 + i,
        pos: p.name,
        angle: p.angle,
        ring: ring,
        cost: cost,
      ))
    }
  }
  // FLOAT candidates: the label CENTER placed at a fine direction around the
  // point (16 directions, 22.5° apart), anchor "center". The 8-anchor grid
  // cannot center a label inside a TILTED wedge (e.g. between two medians
  // crossing at a centroid); these can nestle into any opening. They cost
  // more than staying near the requested anchor but less than far rings and
  // big anchor flips, so they kick in exactly when the grid fails nearby.
  for k in range(16) {
    let ang = k * 22.5
    let ang-dist = _angular-distance(ang, pref.angle)
    for ring in range(rings) {
      let cost = 3.4 + 1.1 * ang-dist / 45 + ring
      items.push((
        key: cost * 1000 + 50 + k,
        pos: "center",
        angle: ang,
        ring: ring,
        cost: cost,
      ))
    }
  }
  items.sorted(key: it => it.key).map(it => (pos: it.pos, angle: it.angle, ring: it.ring, cost: it.cost))
}

/// Overlap area of two rects (0 if disjoint)
#let _rect-overlap-area(a, b) = {
  let w = calc.min(a.at(2), b.at(2)) - calc.max(a.at(0), b.at(0))
  let h = calc.min(a.at(3), b.at(3)) - calc.max(a.at(1), b.at(1))
  if w > 0 and h > 0 { w * h } else { 0 }
}

/// Distance from a point to a rect (0 if the point is inside)
#let _rect-point-dist(rect, p) = {
  let dx = calc.max(rect.at(0) - p.at(0), 0, p.at(0) - rect.at(2))
  let dy = calc.max(rect.at(1) - p.at(1), 0, p.at(1) - rect.at(3))
  calc.sqrt(dx * dx + dy * dy)
}

/// Maximum distance from a point to the rect (farthest corner)
#let _rect-point-max-dist(rect, p) = {
  let ds = (
    (rect.at(0), rect.at(1)), (rect.at(2), rect.at(1)),
    (rect.at(0), rect.at(3)), (rect.at(2), rect.at(3)),
  ).map(c => {
    let dx = c.at(0) - p.at(0)
    let dy = c.at(1) - p.at(1)
    calc.sqrt(dx * dx + dy * dy)
  })
  calc.max(..ds)
}

/// Radial penetration depth of a rect into the circle RING
/// [radius - half-thick, radius + half-thick]. A rect fully inside (or fully
/// outside) the circle does not touch the stroke and scores 0 — labels inside
/// a large circle are fine.
#let _rect-circle-ring-depth(rect, center, radius, half-thick) = {
  let dmin = _rect-point-dist(rect, center)
  let dmax = _rect-point-max-dist(rect, center)
  calc.max(0, calc.min(radius + half-thick, dmax) - calc.max(radius - half-thick, dmin))
}

/// Length of the part of segment p1-p2 that lies inside the rect (0 if none)
#let _segment-rect-chord(rect, p1, p2) = {
  let res = clipping.clip-line-to-rect(
    p1.at(0), p1.at(1), p2.at(0), p2.at(1),
    rect.at(0), rect.at(1), rect.at(2), rect.at(3),
  )
  if res == none { return 0 }
  let ((x0, y0), (x1, y1)) = res
  calc.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0))
}

/// SOFT collision score: thin drawn geometry (segments, circle strokes)
/// crossing the given rect. A small soft score on a padded rect means a
/// hairline runs through the label's PADDING, not through its text.
#let _soft-score(rect, obstacles, weights, margin: 0) = {
  // Deflate slightly so obstacles exactly on the rect boundary do not count.
  let e = 1e-6
  let r = (rect.at(0) + e, rect.at(1) + e, rect.at(2) - e, rect.at(3) - e)
  let score = 0.0
  let w-seg = weights.at("segment", default: 1)
  for seg in obstacles.at("segments", default: ()) {
    score += w-seg * _segment-rect-chord(r, seg.at(0), seg.at(1))
  }
  let w-circ = weights.at("circle", default: 1)
  for c in obstacles.at("circles", default: ()) {
    score += w-circ * _rect-circle-ring-depth(r, c.center, c.radius, margin + 0.02)
  }
  score
}

/// HARD collision score: overlaps that are never acceptable — point markers
/// (tested against point-rect) and other labels' tight rects (tested against
/// label-rect).
#let _hard-score(point-rect, label-rect, obstacles, weights, margin: 0) = {
  let score = 0.0
  let w-pt = weights.at("point", default: 2)
  for p in obstacles.at("points", default: ()) {
    let depth = calc.max(0, p.at(2) + margin - _rect-point-dist(point-rect, p))
    score += w-pt * depth
  }
  let w-lab = weights.at("label", default: 4)
  for lr in obstacles.at("labels", default: ()) {
    score += w-lab * _rect-overlap-area(label-rect, lr)
  }
  score
}

/// Collision score of a candidate label rect. 0 = collision-free.
/// - rect: PADDED label rect, tested against geometry (segments, circles,
///   points) — the padding enforces visible air between text and geometry.
/// - label-rect: TIGHT (near-text) rect, tested against other labels' tight
///   rects. Two neighboring labels may share padding space without being
///   considered colliding — texts just must not touch. Defaults to rect.
/// - point-rect: rect tested against point markers. Markers are small, so a
///   label may let its padding overlap a neighboring marker as long as the
///   text keeps clear — testing the fully padded rect makes labels flee
///   points they do not even touch. Defaults to rect.
/// obstacles: (segments: ((p1, p2), ...), circles: ((center:, radius:), ...),
///             points: ((x, y, r), ...), labels: (tight-rect, ...))
/// margin: clearance added around points and circle strokes (canvas units)
#let score-label-rect(rect, obstacles, weights, margin: 0, label-rect: auto, point-rect: auto) = {
  let e = 1e-6
  let r = (rect.at(0) + e, rect.at(1) + e, rect.at(2) - e, rect.at(3) - e)
  let lr0 = if label-rect == auto { rect } else { label-rect }
  let pr0 = if point-rect == auto { r } else { point-rect }
  let soft = _soft-score(rect, obstacles, weights, margin: margin)
  let hard = _hard-score(pr0, lr0, obstacles, weights, margin: margin)
  soft + hard
}

/// Find the best label placement.
/// - preferred: preferred ctz position name
/// - base-coord: label base coordinate (point position + user offset).
///   Also the label's OWN point for the association rule (see below).
/// - sizes: ((scale: 1.0, w:, h:), ...) pre-measured content sizes in canvas
///   units, full size first, then optional shrink scales
/// - obstacles: see score-label-rect
/// - cfg: (pad:, label-pad:, ring-step:, rings:, weights:, margin:,
///   assoc-factor:) — canvas units. `pad` is the drawn content padding
///   (clearance against geometry); `label-pad` is the much smaller clearance
///   between two labels (their texts may come close, geometry may not).
/// Returns (pos:, coord:, scale:, rect:, score:, cost:) — cost is the
/// displacement cost of the chosen candidate (0 = exactly where asked),
/// used by the caller to judge how "calm" a whole figure's layout is.
///
/// Search order (both are user requirements):
/// - STRICT size phases: every full-size candidate (all anchors × all rings,
///   ordered by closeness to the preferred anchor) is tried before ANY
///   shrunk candidate — shrinking the font is a last resort.
/// - A candidate is ACCEPTED when its text (plus margin) is clear of all
///   geometry and it overlaps no label or marker; thin geometry may run
///   through its PADDING (graze). Close-but-grazed beats far-but-sterile.
/// - ASSOCIATION RULE (hard): the label center must be closer to its OWN
///   point than to any other point (assoc-factor, default 1.0: strictly
///   closer; raise it to demand a clear margin),
///   otherwise it visually attaches to the neighbor. Violating candidates
///   are rejected outright, from the search AND the fallback.
/// If no candidate is collision-free at any size, the least-bad
/// association-valid candidate is returned (score > 0). Candidates of all
/// sizes compete for least-bad: at a hub point (e.g. a centroid where three
/// medians cross) a small label that barely grazes a line beats a full-size
/// one sitting on it. Ties prefer the larger size (full size is tried first).
#let find-label-placement(preferred, base-coord, sizes, obstacles, cfg) = {
  let candidates = _candidate-list(preferred, cfg.rings)

  let label-pad = cfg.at("label-pad", default: cfg.pad)
  let assoc-factor = cfg.at("assoc-factor", default: 1.0)

  let assoc-ok(rect) = {
    let cx = (rect.at(0) + rect.at(2)) / 2
    let cy = (rect.at(1) + rect.at(3)) / 2
    let d-own = calc.sqrt(
      (cx - base-coord.at(0)) * (cx - base-coord.at(0)) +
      (cy - base-coord.at(1)) * (cy - base-coord.at(1)),
    )
    for p in obstacles.at("points", default: ()) {
      let d-other = calc.sqrt(
        (cx - p.at(0)) * (cx - p.at(0)) + (cy - p.at(1)) * (cy - p.at(1)),
      )
      if d-other <= assoc-factor * d-own + 1e-9 { return false }
    }
    true
  }

  let margin = cfg.at("margin", default: 0)
  let best = none
  // Size-major: exhaust all positions at each scale before shrinking.
  for (si, size) in sizes.enumerate() {
    for cand in candidates {
      let a = cand.angle * 1deg
      // Anchor candidates sit ON the point (pushed out by ring); float
      // ("center") candidates place the label CENTER at the distance that
      // leaves exactly the padding between text edge and point: pad + the
      // box's support extent in that direction (not the worst-case half
      // diagonal, which over-reserves in off-corner directions).
      let d0 = if cand.pos == "center" {
        let ext = calc.abs(calc.cos(a)) * size.w / 2 + calc.abs(calc.sin(a)) * size.h / 2
        cfg.pad + ext
      } else { 0 }
      let dist = d0 + cand.ring * cfg.ring-step
      let coord = (
        base-coord.at(0) + dist * calc.cos(a),
        base-coord.at(1) + dist * calc.sin(a),
      )
      let rect = anchor-candidate-rect(cand.pos, coord, size.w, size.h, cfg.pad)
      if not assoc-ok(rect) { continue }

      // Tight rect (near the text) for label-vs-label tests: sits at the
      // same drawn position, inset from the padded rect by (pad - label-pad).
      let inset = cfg.pad - label-pad
      let tight = (rect.at(0) + inset, rect.at(1) + inset, rect.at(2) - inset, rect.at(3) - inset)
      // Geometry clearance scales with the label size: a shrunk label only
      // needs proportionally less air around its (smaller) text, otherwise
      // the fixed padding dominates single-letter labels and shrinking buys
      // no room at all.
      let g-inset = cfg.pad * (1 - size.scale)
      let geom = (rect.at(0) + g-inset, rect.at(1) + g-inset, rect.at(2) - g-inset, rect.at(3) - g-inset)
      // Point markers are small: half the padding is enough clearance, the
      // full padded rect would make labels dodge markers they don't touch.
      let p-inset = calc.max(g-inset, cfg.pad * 0.5)
      let pt-rect = (rect.at(0) + p-inset, rect.at(1) + p-inset, rect.at(2) - p-inset, rect.at(3) - p-inset)

      let hard = _hard-score(pt-rect, tight, obstacles, cfg.weights, margin: margin)
      let soft = _soft-score(geom, obstacles, cfg.weights, margin: margin)
      // Reported cost feeds the caller's group-tidiness metric: a float at
      // ring 0 sits snugly NEXT TO its point — visually calm despite its
      // high search cost, so report it by how far out it actually is.
      let vis-cost = if cand.pos == "center" { 1.0 + cand.ring } else { cand.cost }
      if hard == 0 {
        if soft == 0 {
          return (pos: cand.pos, coord: coord, scale: size.scale, rect: tight, score: 0.0, cost: vis-cost)
        }
        // GRAZE acceptance: at a hub point (medians, bisectors... crossing
        // at the labeled point) every nearby candidate has some hairline
        // through its padding, and insisting on a perfectly clear rect
        // exiles the label far from its point. A close label whose TEXT
        // (plus margin) is clear of all geometry reads better than a far
        // clean one, so accept it — the line only crosses the padding.
        let tr = (tight.at(0) - margin, tight.at(1) - margin, tight.at(2) + margin, tight.at(3) + margin)
        if _soft-score(tr, obstacles, cfg.weights) == 0 {
          return (pos: cand.pos, coord: coord, scale: size.scale, rect: tight,
            score: 0.0, cost: vis-cost, graze: soft)
        }
      }
      // least-bad fallback: all sizes compete; strict < keeps ties at the
      // larger size / earlier candidate
      let score = hard + soft
      if best == none or score < best.score {
        best = (pos: cand.pos, coord: coord, scale: size.scale, rect: tight, score: score, cost: vis-cost)
      }
    }
  }
  if best != none { return best }

  // Degenerate: another point lies (essentially) on top of the labeled one,
  // so NO candidate can satisfy the association rule. Keep the position the
  // user asked for — it is the closest to the own point by construction.
  let size = sizes.first()
  let rect = anchor-candidate-rect(preferred, base-coord, size.w, size.h, label-pad)
  let score = score-label-rect(rect, obstacles, cfg.weights, margin: cfg.at("margin", default: 0))
  (pos: preferred, coord: base-coord, scale: size.scale, rect: rect, score: calc.max(score, 1e-9), cost: 0.0)
}
