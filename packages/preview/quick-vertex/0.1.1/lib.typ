// =============================================================================
//  feasible-region · Linear programming in two variables (feasible regions)
//
//  Covers: bounded and UNBOUNDED regions · unique optimum · multiple optimum
//          (segment or ray) · unbounded objective · empty region ·
//          strict inequalities · any quadrant.
//
//  Self-contained (imports CeTZ, defines its own palette). Public API in
//  English; rendered labels localizable via `lang` ("en" default, "es").
// =============================================================================

#import "@preview/cetz:0.5.2"

#let _blue = rgb("#2e5fa3")

#let _fmt-num(v) = {
  let r = calc.round(v, digits: 2)
  if calc.abs(r) < 1e-9 { r = 0 }
  if calc.round(r) == r { str(calc.round(r)) } else { str(r) }
}

// Builtin `table` aliased so it can be exposed as a parameter name without collision.
#let _table = table

// Rendered strings, keyed by `lang`. Add a language by copying a block and translating.
#let _i18n = (
  en: (
    infeasible: "Infeasible region",
    infeasible-note: " (the constraint system has no common solution).",
    unbounded: "Unbounded region (arrows indicate it continues indefinitely).",
    lines: "Lines:",
    vertex: "Vertex",
    coordinates: "Coordinates",
    vertices: "Vertices:",
    multiple: "Multiple solution:",
    seg-prefix: "on the entire segment",
    ray-prefix: "on the entire ray starting at",
    infinitely: "(infinitely many optima).",
    optimum: "Optimum",
    at: "at",
    no-finite: sense => [No finite #sense: $Z$ #if sense == "max" [increases] else [decreases] without bound over the unbounded region.],
  ),
  es: (
    infeasible: "Región no factible",
    infeasible-note: " (el sistema de restricciones no tiene solución común).",
    unbounded: "Región no acotada (las flechas indican que continúa indefinidamente).",
    lines: "Rectas:",
    vertex: "Vértice",
    coordinates: "Coordenadas",
    vertices: "Vértices:",
    multiple: "Solución múltiple:",
    seg-prefix: "en todo el segmento",
    ray-prefix: "en toda la semirrecta que parte de",
    infinitely: "(infinitos óptimos).",
    optimum: "Óptimo",
    at: "en",
    no-finite: sense => [No existe #(if sense == "max" [máximo] else [mínimo]) finito: $Z$ #if sense == "max" [crece] else [decrece] sin cota sobre la región no acotada.],
  ),
)

/// Feasible region of a two-variable linear program, BOUNDED OR UNBOUNDED.
/// The shading is obtained by clipping the visible frame against each
/// half-plane (Sutherland–Hodgman), so open regions are filled correctly and
/// their free sides are marked with arrows.
///
/// - constraints: array of (a, b, c, op) → a·x + b·y <op> c ; op ∈ "<=",">=","<",">"
///     an optional 5th element sets that line's color: (a, b, c, op, color)
/// - objective: (c1, c2) coefficients of Z = c1·x + c2·y   (or none)
///     an optional 3rd element sets the objective color: (c1, c2, color)
/// - sense: "max" (default) or "min" (optimization sense)
/// - gradient: draw the ∇Z vector at the optimum
/// - table: show the vertex table; if false, a compact vertex legend
/// - first-quadrant: add x ≥ 0, y ≥ 0 (ON by default)
/// - labels: line equations, in the order of `constraints`
/// - lang: "en" (default) or "es" — language of the rendered labels
/// - region-color: fill/hatch/border color of the feasible region
/// - equal-aspect: force both axes to the same units-per-length scale (default
///     true — matches the textbook square-grid convention, and keeps ∇Z
///     visually perpendicular to the level lines). false stretches each axis
///     independently to fill `size` exactly.
///
/// Lines without an explicit color get distinct colors automatically (a curated
/// palette, then generated hues), so they never repeat however many there are.
#let feasible-region(
  constraints,
  objective: none,
  sense: "max",
  gradient: true,
  table: true,
  first-quadrant: true,
  labels: none,
  lang: "en",
  region-color: rgb("#2e5fa3"),
  size: (6, 4.5),
  margin: 1.15,
  equal-aspect: true,
) = {
  let S = _i18n.at(lang, default: _i18n.en)
  let R = constraints
  if first-quadrant {
    R = R + ((1, 0, 0, ">="), (0, 1, 0, ">="))
  }

  // normalized operator: "<" behaves like "<=" for the geometry
  // (the boundary is drawn dashed to signal it is not included)
  let _norm(s) = if s == "<" { "<=" } else if s == ">" { ">=" } else { s }
  let _strict(s) = s == "<" or s == ">"

  let satisfies(p) = {
    let (x, y) = p
    for (a, b, c, s, ..) in R {
      let sn = _norm(s)
      let v = a * x + b * y
      if sn == "<=" and v > c + 1e-6 { return false }
      if sn == ">=" and v < c - 1e-6 { return false }
    }
    true
  }

  let intersect(r1, r2) = {
    let (a1, b1, c1, ..) = r1
    let (a2, b2, c2, ..) = r2
    let det = a1 * b2 - a2 * b1
    if calc.abs(det) < 1e-9 { return none }
    ((c1 * b2 - c2 * b1) / det, (a1 * c2 - a2 * c1) / det)
  }

  // ---- finite vertices (real corners), for labeling and optimizing ----
  let verts = ()
  for i in range(R.len()) {
    for j in range(i + 1, R.len()) {
      let p = intersect(R.at(i), R.at(j))
      if p != none and satisfies(p) {
        let is-dup = verts.any(q => calc.abs(q.at(0) - p.at(0)) < 1e-4 and calc.abs(q.at(1) - p.at(1)) < 1e-4)
        if not is-dup { verts.push(p) }
      }
    }
  }
  if verts.len() >= 1 {
    let cx = verts.map(p => p.at(0)).sum() / verts.len()
    let cy = verts.map(p => p.at(1)).sum() / verts.len()
    verts = verts.sorted(key: p => calc.atan2(p.at(0) - cx, p.at(1) - cy))
  }

  // ---- recession cone: is the region unbounded? ----
  let recession = ()
  let steps = 180
  for k in range(steps) {
    let th = k / steps * 360deg
    let dx = calc.cos(th)
    let dy = calc.sin(th)
    let ok = true
    for (a, b, c, s, ..) in R {
      let sn = _norm(s)
      let ad = a * dx + b * dy
      if sn == "<=" and ad > 1e-9 { ok = false }
      if sn == ">=" and ad < -1e-9 { ok = false }
    }
    if ok { recession.push((dx, dy)) }
  }
  let bounded = recession.len() == 0

  // ---- objective: finite optimum (unique or multiple), or unbounded ----
  let evals = ()
  let opt-idx = none        // "primary" optimal vertex (for the gradient)
  let opt-idxs = ()         // ALL optimal vertices (ties ⇒ multiple solution)
  let obj-unbounded = false
  let opt-multiple = false
  let opt-ray = none        // recession direction with constant Z (infinite optimal edge)
  if objective != none {
    let (oc1, oc2, ..) = objective
    for d in recession {
      let g = oc1 * d.at(0) + oc2 * d.at(1)
      if sense == "max" and g > 1e-7 { obj-unbounded = true }
      if sense == "min" and g < -1e-7 { obj-unbounded = true }
    }
    if verts.len() > 0 {
      evals = verts.map(p => oc1 * p.at(0) + oc2 * p.at(1))
      if not obj-unbounded {
        let best = evals.at(0)
        for z in evals {
          if (sense == "max" and z > best) or (sense == "min" and z < best) { best = z }
        }
        // relative tolerance: every vertex reaching the optimal value
        let tol = 1e-6 * calc.max(1, calc.abs(best))
        for (k, z) in evals.enumerate() {
          if calc.abs(z - best) <= tol { opt-idxs.push(k) }
        }
        opt-idx = opt-idxs.at(0)
        opt-multiple = opt-idxs.len() >= 2

        // Unbounded region: is there a recession direction with constant Z?
        // Then an optimal RAY leaves the optimal vertex.
        if not bounded and opt-idxs.len() >= 1 {
          for d in recession {
            if calc.abs(oc1 * d.at(0) + oc2 * d.at(1)) < 1e-7 {
              opt-ray = d
              opt-multiple = true
            }
          }
        }
      }
    }
  }

  // ---- visible frame: REAL bounding box (allows negative coordinates) ----
  let mrg = if bounded { margin } else { calc.max(margin, 1.6) }
  let xs = verts.map(p => p.at(0))
  let ys = verts.map(p => p.at(1))
  // if there are no vertices, a default frame
  let bx0 = if xs.len() > 0 { calc.min(..xs, 0) } else { 0 }
  let bx1 = if xs.len() > 0 { calc.max(..xs, 0) } else { 3 }
  let by0 = if ys.len() > 0 { calc.min(..ys, 0) } else { 0 }
  let by1 = if ys.len() > 0 { calc.max(..ys, 0) } else { 3 }
  // padding proportional to the size of the vertex cloud.
  // If the region is UNBOUNDED, extend the box along the recession directions,
  // so it is visible where it escapes (the frame used to shrink otherwise).
  if not bounded {
    let span = calc.max(bx1 - bx0, by1 - by0, 3)
    let anchors = if verts.len() > 0 { verts } else { ((0, 0),) }
    for d in recession {
      for A in anchors {
        let px2 = A.at(0) + span * d.at(0)
        let py2 = A.at(1) + span * d.at(1)
        bx0 = calc.min(bx0, px2)
        bx1 = calc.max(bx1, px2)
        by0 = calc.min(by0, py2)
        by1 = calc.max(by1, py2)
      }
    }
  }
  let box-w = calc.max(bx1 - bx0, 1)
  let box-h = calc.max(by1 - by0, 1)
  let pad-x = box-w * (mrg - 1)
  let pad-y = box-h * (mrg - 1)
  // in the first quadrant do NOT add negative padding (keeps the usual look)
  let minx = if first-quadrant { 0 } else { bx0 - pad-x }
  let miny = if first-quadrant { 0 } else { by0 - pad-y }
  let maxx = bx1 + pad-x
  let maxy = by1 + pad-y
  if maxx - minx < 1e-6 { maxx = minx + 1 }
  if maxy - miny < 1e-6 { maxy = miny + 1 }
  // equal-aspect (default): a single units-per-length scale for both axes, so
  // angles on screen match true angles (∇Z ⊥ level lines, etc.). `size` is
  // then an upper bound — the drawn extent (w, h) shrinks in whichever
  // dimension is not the tightest fit, instead of stretching that axis
  // independently. With equal-aspect: false, each axis stretches on its own
  // to fill `size` exactly (angles are then only approximate).
  let (size-w, size-h) = size
  let kx = size-w / (maxx - minx)
  let ky = size-h / (maxy - miny)
  let w = size-w
  let h = size-h
  if equal-aspect {
    let uscale = calc.min(kx, ky)
    kx = uscale
    ky = uscale
    w = (maxx - minx) * uscale
    h = (maxy - miny) * uscale
  }
  let sx = x => (x - minx) * kx
  let sy = y => (y - miny) * ky
  // position of the axes inside the canvas (where x=0 and y=0 fall)
  let axis-y = sx(0)  // vertical axis, at x=0
  let axis-x = sy(0)  // horizontal axis, at y=0

  // ---- clip the frame against each half-plane (Sutherland–Hodgman) ----
  let clip-hp(poly, ine) = {
    let (a, b, c, s, ..) = ine
    let sn = _norm(s)
    let inside = p => {
      let v = a * p.at(0) + b * p.at(1)
      if sn == "<=" { v <= c + 1e-9 } else { v >= c - 1e-9 }
    }
    let inter = (A, B) => {
      let den = a * (B.at(0) - A.at(0)) + b * (B.at(1) - A.at(1))
      let t = if calc.abs(den) < 1e-12 { 0 } else { (c - a * A.at(0) - b * A.at(1)) / den }
      (A.at(0) + t * (B.at(0) - A.at(0)), A.at(1) + t * (B.at(1) - A.at(1)))
    }
    let out = ()
    let n = poly.len()
    if n == 0 { return out }
    for i in range(n) {
      let A = poly.at(i)
      let B = poly.at(calc.rem(i + 1, n))
      let inA = inside(A)
      let inB = inside(B)
      if inA { out.push(A) }
      if inA != inB { out.push(inter(A, B)) }
    }
    out
  }
  let region = ((minx, miny), (maxx, miny), (maxx, maxy), (minx, maxy))
  for ine in R { region = clip-hp(region, ine) }
  // drop consecutive duplicate points (appear when 3+ lines are concurrent)
  let cleaned = ()
  for p in region {
    let dup = cleaned.len() > 0 and (
      calc.abs(cleaned.last().at(0) - p.at(0)) < 1e-7 and calc.abs(cleaned.last().at(1) - p.at(1)) < 1e-7
    )
    if not dup { cleaned.push(p) }
  }
  if cleaned.len() >= 2 {
    let pa = cleaned.first()
    let pz = cleaned.last()
    if calc.abs(pa.at(0) - pz.at(0)) < 1e-7 and calc.abs(pa.at(1) - pz.at(1)) < 1e-7 {
      cleaned = cleaned.slice(0, cleaned.len() - 1)
    }
  }
  let region = cleaned

  // does an edge (in data coords) lie on a real constraint line?
  let edge-on-constraint = (A, B) => {
    for (a, b, c, s, ..) in R {
      if calc.abs(a * A.at(0) + b * A.at(1) - c) < 1e-5 and calc.abs(a * B.at(0) + b * B.at(1) - c) < 1e-5 { return true }
    }
    false
  }

  // default palette for the boundary lines (kept distinct and print-friendly)
  let colors = (
    rgb("#1a9850"), rgb("#a0522d"), rgb("#c85c1a"), rgb("#922B21"), _blue,
    rgb("#c9a227"), rgb("#008080"), rgb("#d6336c"), rgb("#5f7d1f"), rgb("#495057"),
  )
  // color of constraint k: a manual 5th tuple element wins; otherwise the palette;
  // otherwise an evenly-spread generated hue, so colors never repeat, however many
  let line-color-for = (k, con) => if con.len() >= 5 {
    con.at(4)
  } else if k < colors.len() {
    colors.at(k)
  } else {
    color.hsl(calc.rem(k * 137.5, 360) * 1deg, 62%, 45%)
  }
  let circled = ("①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨", "⑩")
  let letters = ("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
  // objective color: a manual 3rd element of `objective` wins; otherwise purple
  let obj-color = if objective != none and objective.len() >= 3 { objective.at(2) } else { rgb("#6a1b9a") }

  let plot = cetz.canvas({
    import cetz.draw: *
    // axes at their real position (they cross inside the frame if there are negatives)
    line((sx(minx) - 0.15, axis-x), (w + 0.4, axis-x), mark: (end: "stealth"), stroke: 0.7pt + luma(40%))
    line((axis-y, sy(miny) - 0.15), (axis-y, h + 0.4), mark: (end: "stealth"), stroke: 0.7pt + luma(40%))
    content((w + 0.55, axis-x), text(9pt)[$x$])
    content((axis-y, h + 0.6), text(9pt)[$y$])
    let nice-step = value => {
      let raw = value / 6
      let exp = calc.floor(calc.log(calc.max(raw, 1e-9), base: 10))
      let base = calc.pow(10, exp)
      let m = raw / base
      let mult = if m <= 1 { 1 } else if m <= 2 { 2 } else if m <= 5 { 5 } else { 10 }
      mult * base
    }
    let fmt = _fmt-num  // same formatting as in the legends (avoids -0)
    // with equal-aspect, both axes share one step (the same grid everywhere);
    // otherwise each axis picks its own "nice" step independently.
    let px = nice-step(if equal-aspect { calc.max(maxx - minx, maxy - miny) } else { maxx - minx })
    // x ticks: cover the WHOLE range [minx, maxx], not just the positive part
    let i0 = calc.ceil(minx / px)
    let i1 = calc.floor(maxx / px)
    for i in range(i0, i1 + 1) {
      let xv = i * px
      if calc.abs(xv) > 1e-9 {
        line((sx(xv), axis-x - 0.08), (sx(xv), axis-x + 0.08), stroke: 0.6pt + luma(40%))
        content((sx(xv), axis-x - 0.32), text(7.5pt, fill: luma(30%))[#fmt(xv)])
      }
    }
    // y ticks
    let py = if equal-aspect { px } else { nice-step(maxy - miny) }
    let j0 = calc.ceil(miny / py)
    let j1 = calc.floor(maxy / py)
    for j in range(j0, j1 + 1) {
      let yv = j * py
      if calc.abs(yv) > 1e-9 {
        line((axis-y - 0.08, sy(yv)), (axis-y + 0.08, sy(yv)), stroke: 0.6pt + luma(40%))
        content((axis-y - 0.36, sy(yv)), text(7.5pt, fill: luma(30%))[#fmt(yv)])
      }
    }

    // ---- fill + hatching of the clipped region ----
    if region.len() >= 3 {
      let polygon = region.map(p => (sx(p.at(0)), sy(p.at(1))))
      line(..polygon, close: true, fill: region-color.transparentize(78%), stroke: none)
      let region-edge = region-color.darken(25%)
      let hatch-gap = 0.42
      let dmin = polygon.map(p => p.at(0) + p.at(1)).reduce((a, b) => calc.min(a, b))
      let dmax = polygon.map(p => p.at(0) + p.at(1)).reduce((a, b) => calc.max(a, b))
      let nsides = polygon.len()
      let d = dmin + hatch-gap
      while d < dmax {
        let hits = ()
        for i in range(nsides) {
          let p1 = polygon.at(i)
          let p2 = polygon.at(calc.rem(i + 1, nsides))
          let f1 = p1.at(0) + p1.at(1) - d
          let f2 = p2.at(0) + p2.at(1) - d
          if f1 * f2 <= 0 and f1 != f2 {
            let t = f1 / (f1 - f2)
            hits.push((p1.at(0) + t * (p2.at(0) - p1.at(0)), p1.at(1) + t * (p2.at(1) - p1.at(1))))
          }
        }
        if hits.len() >= 2 { line(hits.at(0), hits.at(1), stroke: 0.5pt + region-edge) }
        d += hatch-gap
      }
      // border: solid on real sides; "continues" arrow on open frame sides
      let nsides = region.len()
      for i in range(nsides) {
        let Ad = region.at(i)
        let Bd = region.at(calc.rem(i + 1, nsides))
        let A = (sx(Ad.at(0)), sy(Ad.at(1)))
        let B = (sx(Bd.at(0)), sy(Bd.at(1)))
        if edge-on-constraint(Ad, Bd) {
          line(A, B, stroke: 0.9pt + region-edge)
        } else {
          // open side (on the frame): arrows pointing outward
          let mx = (A.at(0) + B.at(0)) / 2
          let my = (A.at(1) + B.at(1)) / 2
          // approximate outward normal: right frame (+x) or top frame (+y)
          let out-dir = if calc.abs(Ad.at(0) - maxx) < 1e-4 and calc.abs(Bd.at(0) - maxx) < 1e-4 {
            (1, 0)
          } else if calc.abs(Ad.at(0) - minx) < 1e-4 and calc.abs(Bd.at(0) - minx) < 1e-4 {
            (-1, 0)
          } else if calc.abs(Ad.at(1) - maxy) < 1e-4 and calc.abs(Bd.at(1) - maxy) < 1e-4 {
            (0, 1)
          } else if calc.abs(Ad.at(1) - miny) < 1e-4 and calc.abs(Bd.at(1) - miny) < 1e-4 {
            (0, -1)
          } else { (0, 0) }
          if out-dir != (0, 0) {
            for f in (0.3, 0.7) {
              let bx = A.at(0) + f * (B.at(0) - A.at(0))
              let by = A.at(1) + f * (B.at(1) - A.at(1))
              line(
                (bx, by),
                (bx + out-dir.at(0) * 0.45, by + out-dir.at(1) * 0.45),
                mark: (end: "stealth", fill: region-edge),
                stroke: 0.8pt + region-edge,
              )
            }
          }
        }
      }
    }

    // ---- boundary lines ----
    for (k, con) in constraints.enumerate() {
      let (a, b, c, s, ..) = con
      let cand = ()
      if calc.abs(b) > 1e-9 { cand.push((minx, (c - a * minx) / b)); cand.push((maxx, (c - a * maxx) / b)) }
      if calc.abs(a) > 1e-9 { cand.push(((c - b * miny) / a, miny)); cand.push(((c - b * maxy) / a, maxy)) }
      let pts = cand.filter(p => p.at(0) >= minx - 1e-6 and p.at(0) <= maxx + 1e-6 and p.at(1) >= miny - 1e-6 and p.at(1) <= maxy + 1e-6)
      let col = line-color-for(k, con)
      if pts.len() >= 2 {
        // dashed boundary if the inequality is strict (does not include the line)
        let stroke-style = if _strict(s) {
          (paint: col, thickness: 1.1pt, dash: "dashed")
        } else {
          (paint: col, thickness: 1.1pt)
        }
        line((sx(pts.at(0).at(0)), sy(pts.at(0).at(1))), (sx(pts.at(1).at(0)), sy(pts.at(1).at(1))), stroke: stroke-style)
        let ext = if pts.at(0).at(1) >= pts.at(1).at(1) { pts.at(0) } else { pts.at(1) }
        content((sx(ext.at(0)) + 0.22, sy(ext.at(1)) + 0.18), text(10pt, weight: "bold", fill: col)[#circled.at(calc.rem(k, circled.len()))])
      }
    }

    // ---- objective level lines ----
    if objective != none and verts.len() > 0 {
      let (oc1, oc2, ..) = objective
      let level-line(kval, style) = {
        let cand = ()
        if calc.abs(oc2) > 1e-9 { cand.push((minx, (kval - oc1 * minx) / oc2)); cand.push((maxx, (kval - oc1 * maxx) / oc2)) }
        if calc.abs(oc1) > 1e-9 { cand.push(((kval - oc2 * miny) / oc1, miny)); cand.push(((kval - oc2 * maxy) / oc1, maxy)) }
        let pts = cand.filter(p => p.at(0) >= minx - 1e-6 and p.at(0) <= maxx + 1e-6 and p.at(1) >= miny - 1e-6 and p.at(1) <= maxy + 1e-6)
        if pts.len() >= 2 { line((sx(pts.at(0).at(0)), sy(pts.at(0).at(1))), (sx(pts.at(1).at(0)), sy(pts.at(1).at(1))), ..style) }
      }
      let zs = verts.map(p => oc1 * p.at(0) + oc2 * p.at(1))
      let zlo = zs.reduce((a, b) => calc.min(a, b))
      let zhi = zs.reduce((a, b) => calc.max(a, b))
      if opt-idx != none {
        for frac in (0.34, 0.67) { level-line(zlo + frac * (zhi - zlo), (stroke: (paint: obj-color.transparentize(60%), thickness: 0.7pt, dash: "dashed"))) }
        level-line(evals.at(opt-idx), (stroke: 1.2pt + obj-color))

        // ---- optimal edge (multiple solution) highlighted ----
        if opt-multiple {
          if opt-idxs.len() >= 2 {
            // segment between the two tied optimal vertices
            let P = verts.at(opt-idxs.at(0))
            let Q = verts.at(opt-idxs.at(opt-idxs.len() - 1))
            line(
              (sx(P.at(0)), sy(P.at(1))),
              (sx(Q.at(0)), sy(Q.at(1))),
              stroke: (paint: obj-color, thickness: 3.4pt, cap: "round"),
            )
          }
          if opt-ray != none {
            // optimal ray: from the optimal vertex along the recession direction
            let P = verts.at(opt-idxs.at(opt-idxs.len() - 1))
            let dx = opt-ray.at(0)
            let dy = opt-ray.at(1)
            // advance until leaving the frame
            let t = 1e9
            if dx > 1e-9 { t = calc.min(t, (maxx - P.at(0)) / dx) }
            if dx < -1e-9 { t = calc.min(t, (minx - P.at(0)) / dx) }
            if dy > 1e-9 { t = calc.min(t, (maxy - P.at(1)) / dy) }
            if dy < -1e-9 { t = calc.min(t, (miny - P.at(1)) / dy) }
            if t < 1e8 {
              let Q = (P.at(0) + t * dx, P.at(1) + t * dy)
              line(
                (sx(P.at(0)), sy(P.at(1))),
                (sx(Q.at(0)), sy(Q.at(1))),
                mark: (end: "stealth", fill: obj-color),
                stroke: (paint: obj-color, thickness: 3.4pt, cap: "round"),
              )
            }
          }
        }

        if gradient {
          let vopt = verts.at(opt-idx)
          // gradient direction on screen: (ky·oc1, kx·oc2) — the "crossed" scale
          // factors are exactly what keeps the arrow perpendicular to the level
          // lines on screen even when kx ≠ ky (equal-aspect: false). Flipped for
          // "min" so it points towards the optimum (∇Z itself always points
          // towards increasing Z, but a "min" optimum lies in the decreasing
          // direction).
          let gsign = if sense == "min" { -1 } else { 1 }
          let gx = gsign * ky * oc1
          let gy = gsign * kx * oc2
          let norm = calc.sqrt(gx * gx + gy * gy)
          if norm > 1e-9 {
            let L = 0.9
            let ox = sx(vopt.at(0))
            let oy = sy(vopt.at(1))
            line((ox, oy), (ox + gx / norm * L, oy + gy / norm * L), mark: (end: "stealth", fill: obj-color), stroke: 1.1pt + obj-color)
            content((ox + gx / norm * (L + 0.35), oy + gy / norm * (L + 0.35)), text(8pt, fill: obj-color, weight: "bold")[$nabla Z$])
          }
        }
      } else if obj-unbounded {
        // unbounded objective: show the family sliding towards infinity
        let span = zhi - zlo
        for frac in (0.0, 0.5, 1.0, 1.6) { level-line(zlo + frac * calc.max(span, 1), (stroke: (paint: obj-color.transparentize(45%), thickness: 0.8pt, dash: "dashed"))) }
      }
    }

    // ---- finite vertices: only those inside the frame ----
    let n-verts = verts.len()
    for (k, p) in verts.enumerate() {
      if p.at(0) >= minx - 1e-6 and p.at(0) <= maxx + 1e-6 and p.at(1) >= miny - 1e-6 and p.at(1) <= maxy + 1e-6 {
        let is-opt = opt-idxs.contains(k)
        // label offset: the exterior bisector at this vertex, so the letter
        // leans away from the polygon instead of a fixed corner offset (which
        // could land the label on top of an edge or another vertex).
        let (lx, ly) = (0.28, 0.28)
        if n-verts >= 3 {
          let prev = verts.at(calc.rem(k - 1 + n-verts, n-verts))
          let next = verts.at(calc.rem(k + 1, n-verts))
          let v1 = (prev.at(0) - p.at(0), prev.at(1) - p.at(1))
          let v2 = (next.at(0) - p.at(0), next.at(1) - p.at(1))
          let len1 = calc.sqrt(v1.at(0) * v1.at(0) + v1.at(1) * v1.at(1))
          let len2 = calc.sqrt(v2.at(0) * v2.at(0) + v2.at(1) * v2.at(1))
          if len1 > 1e-5 and len2 > 1e-5 {
            let out-x = -(v1.at(0) / len1 + v2.at(0) / len2)
            let out-y = -(v1.at(1) / len1 + v2.at(1) / len2)
            let out-len = calc.sqrt(out-x * out-x + out-y * out-y)
            if out-len > 1e-5 {
              let dist = if is-opt { 0.42 } else { 0.35 }
              lx = out-x / out-len * dist
              ly = out-y / out-len * dist
            }
          }
        }
        if is-opt {
          circle((sx(p.at(0)), sy(p.at(1))), radius: 0.18, fill: obj-color.transparentize(65%), stroke: none)
          circle((sx(p.at(0)), sy(p.at(1))), radius: 0.11, fill: obj-color, stroke: 0.8pt + white)
          content((sx(p.at(0)) + lx, sy(p.at(1)) + ly), text(10.5pt, weight: "bold", fill: obj-color)[#letters.at(calc.rem(k, letters.len()))])
        } else {
          circle((sx(p.at(0)), sy(p.at(1))), radius: 0.1, fill: red, stroke: none)
          content((sx(p.at(0)) + lx, sy(p.at(1)) + ly), text(10pt, weight: "bold")[#letters.at(calc.rem(k, letters.len()))])
        }
      }
    }
  })

  // ---- legends ----
  let line-legend = if labels != none {
    constraints.enumerate().map(((k, r)) => {
      let et = if k < labels.len() { labels.at(k) } else { none }
      if et != none { text(fill: line-color-for(k, r))[#circled.at(calc.rem(k, circled.len())) #et] }
    }).filter(x => x != none)
  } else { () }

  align(center, plot)
  v(0.3em)

  if verts.len() == 0 and region.len() < 3 {
    align(center, text(size: 9pt, fill: rgb("#922B21"))[*#S.infeasible*#S.infeasible-note])
    return
  }

  if not bounded {
    align(center, text(size: 8.5pt, style: "italic", fill: luma(35%))[#S.unbounded])
    v(0.2em)
  }
  if line-legend.len() > 0 {
    align(center, text(size: 9pt)[*#S.lines* #line-legend.join(", ")])
    v(0.2em)
  }

  if objective != none and table and verts.len() > 0 {
    let (oc1, oc2, ..) = objective
    let rows = verts.enumerate().map(((k, p)) => {
      let et = letters.at(calc.rem(k, letters.len()))
      let coord = $(#_fmt-num(p.at(0)), #_fmt-num(p.at(1)))$
      let zv = $#_fmt-num(evals.at(k))$
      if opt-idxs.contains(k) {
        (
          _table.cell(fill: obj-color.transparentize(88%), text(fill: obj-color, weight: "bold")[#et]),
          _table.cell(fill: obj-color.transparentize(88%), text(fill: obj-color, weight: "bold")[#coord]),
          _table.cell(fill: obj-color.transparentize(88%), text(fill: obj-color, weight: "bold")[#zv]),
        )
      } else { ([#et], coord, zv) }
    }).flatten()
    align(center, block(_table(
      columns: 3, align: center + horizon, inset: 5pt, stroke: 0.5pt + luma(75%),
      _table.header([*#S.vertex*], [*#S.coordinates*], $bold(Z = #oc1 x + #oc2 y)$),
      ..rows,
    )))
    if opt-idx != none and opt-multiple {
      let zopt = _fmt-num(evals.at(opt-idx))
      if opt-idxs.len() >= 2 and opt-ray == none {
        let P = verts.at(opt-idxs.at(0))
        let Q = verts.at(opt-idxs.at(opt-idxs.len() - 1))
        let eP = letters.at(calc.rem(opt-idxs.at(0), letters.len()))
        let eQ = letters.at(calc.rem(opt-idxs.at(opt-idxs.len() - 1), letters.len()))
        align(center, text(size: 9pt)[
          *#S.multiple* $Z = zopt$ #S.seg-prefix #eP$(#_fmt-num(P.at(0)), #_fmt-num(P.at(1)))$–#eQ$(#_fmt-num(Q.at(0)), #_fmt-num(Q.at(1)))$ #S.infinitely
        ])
      } else {
        let P = verts.at(opt-idxs.at(opt-idxs.len() - 1))
        let eP = letters.at(calc.rem(opt-idxs.at(opt-idxs.len() - 1), letters.len()))
        align(center, text(size: 9pt)[
          *#S.multiple* $Z = zopt$ #S.ray-prefix #eP$(#_fmt-num(P.at(0)), #_fmt-num(P.at(1)))$ #S.infinitely
        ])
      }
    } else if opt-idx != none {
      let vopt = verts.at(opt-idx)
      let et-opt = letters.at(calc.rem(opt-idx, letters.len()))
      align(center, text(size: 9pt)[#S.optimum (#sense): $Z = #_fmt-num(evals.at(opt-idx))$ #S.at #et-opt$(#_fmt-num(vopt.at(0)), #_fmt-num(vopt.at(1)))$])
    } else if obj-unbounded {
      align(center, block(width: 100%, text(size: 9pt, fill: rgb("#922B21"))[#(S.no-finite)(sense)]))
    }
  } else {
    let vertex-legend = verts.enumerate().map(((k, p)) => [#letters.at(calc.rem(k, letters.len()))$(#_fmt-num(p.at(0)), #_fmt-num(p.at(1)))$])
    align(center, text(size: 9pt)[*#S.vertices* #vertex-legend.join(", ")])
  }
}
