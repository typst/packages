// ============================================================================
// pythagorean-spiral — The Spiral of Theodorus (the "snail of Pythagoras")
// ============================================================================
// A zero-dependency Typst package that draws the famous spiral of right
// triangles: each triangle adds a leg of length `size` at a right angle to
// the previous hypotenuse, so the n-th triangle has legs sqrt(n)·size and
// size and hypotenuse sqrt(n+1)·size.
//
//   #import "@preview/pythagorean-spiral:0.1.0": *
//
//   #pythagorean-spiral(steps: 17, size: 1cm)
//   #pythagorean-spiral(steps: 30, fill: gradient.linear(red, blue))
//
// Everything is drawn with plain Typst primitives (polygon, line, curve,
// circle, place) — no plugin, no CeTZ dependency.
// ============================================================================

// ---------------------------------------------------------------------------
// Geometry
// ---------------------------------------------------------------------------

/// The vertices P_0 … P_N of the spiral, in math coordinates (y up), in
/// units of the leg length `size`. P_0 = (1, 0); the n-th triangle is
/// (O, P_(n-1), P_n) with |P_n| = sqrt(n+1).
///
/// - steps (int): number of triangles (>= 1)
/// - direction (str): `"ccw"` (counter-clockwise, default) or `"cw"`
/// - start-angle (angle): rotation of the whole spiral
/// -> array of (float, float) pairs
#let spiral-points(steps, direction: "ccw", start-angle: 0deg) = {
  let sign = if direction == "cw" { -1.0 } else { 1.0 }
  let pts = ((1.0, 0.0),)
  let phi = 0deg
  for n in range(1, steps + 1) {
    phi += sign * calc.atan(1.0 / calc.sqrt(n))
    let r = calc.sqrt(n + 1.0)
    pts.push((r * calc.cos(phi), r * calc.sin(phi)))
  }
  let ca = calc.cos(start-angle)
  let sa = calc.sin(start-angle)
  pts.map(p => (
    p.at(0) * ca - p.at(1) * sa,
    p.at(0) * sa + p.at(1) * ca,
  ))
}

/// The accumulated angle of the spiral after `steps` triangles
/// (positive, absolute value). With 17 triangles it already exceeds 2·pi:
/// 364.78° — the spiral famously overshoots a full turn.
/// -> angle
#let spiral-angle(steps) = {
  let phi = 0deg
  for n in range(1, steps + 1) {
    phi += calc.atan(1.0 / calc.sqrt(n))
  }
  phi
}

// ---------------------------------------------------------------------------
// Colour helpers
// ---------------------------------------------------------------------------

/// Fill colour for triangle i (0-based) out of n, given the `fill`
/// specification (none | color | gradient | array of colors).
#let _color-for(i, n, fill) = {
  if fill == none or n == 0 {
    none
  } else if type(fill) == color {
    fill
  } else if type(fill) == gradient {
    gradient.sample(fill, (if n == 1 { 0.0 } else { i / (n - 1) }) * 100%)
  } else if type(fill) == array {
    let m = fill.len()
    if m == 0 {
      none
    } else if m == 1 {
      fill.at(0)
    } else {
      let t = if n == 1 { 0.0 } else { i / (n - 1) }
      let pos = t * (m - 1)
      let k = calc.min(m - 2, calc.floor(pos))
      gradient.sample(
        gradient.linear(fill.at(k), fill.at(k + 1)),
        (pos - k) * 100%,
      )
    }
  } else {
    none
  }
}

// ---------------------------------------------------------------------------
// Rendering
// ---------------------------------------------------------------------------

/// Draws the Spiral of Theodorus (Pythagorean snail).
///
/// ```example
/// #pythagorean-spiral(steps: 17, size: 1cm)
/// ```
///
/// - steps (int): number of triangles (>= 1, cap 5000)
/// - size (length): length of the starting leg
/// - fill (none, color, gradient, array): fill of the triangles.
///   A `gradient` is sampled along the spiral; an array of colors is
///   interpolated along the spiral.
/// - stroke (none, color, stroke): outline style. A bare color uses
///   `stroke-width` as thickness.
/// - stroke-width (length): outline thickness when `stroke` is a color
/// - direction (str): `"ccw"` (counter-clockwise) or `"cw"`
/// - start-angle (angle): rotation of the whole spiral
/// - mode (str): `"triangles"` (default, outlines), `"spiral"` (only the
///   outer staircase), `"rays"` (only the segments from the centre)
/// - show-hypotenuses (bool): draw the inner rays O -> P_n
/// - right-angle-marks (bool): draw small square marks at the right angles
/// - right-angle-size (length): side of the right-angle marks
/// - center-dot (bool): draw a dot at the centre O
/// - center-dot-radius (length), center-dot-fill (color): dot style
/// - labels (none, str): `"vertices"` labels P_0…P_N, `"indices"` numbers
///   the triangles
/// - label-size (length), label-offset (length): label style
/// - length-labels (none, str, function): `"values"` (decimal
///   approximation of `a·√n`, e.g. "1.414 cm"), `"formulas"` (the exact
///   value `√n` in units of `a`, simplified for perfect squares:
///   `√1` → `1`, `√4` → `2`, ...), or a function `(k, len) => content`
///   where `k` is the step number (1 = starting leg) and `len = √k`, so the
///   exact length is `size·len = size·√k`
/// - length-size (length): font size of the length labels
/// - length-offset (length): perpendicular distance of the ray labels from
///   their ray (0 = labels sit on the segment)
/// - length-pos (number): position of the ray label ALONG its ray: 0 = at
///   the centre O, 1 = at the outer endpoint P_n. Values > 0.5 push the
///   label toward the outer end (away from the crowded centre), which
///   keeps adjacent labels well separated
/// - length-label-background (none, color): background behind the labels
///   (labels are rotated parallel to their ray and centred on it).
///   Defaults to `white` so labels stay readable over the strokes even
///   when the triangles are not filled; pass `none` to remove it.
/// - label-new-legs (bool): also label the new perpendicular legs
///   P_(k-1) -> P_k of every triangle — each has the exact length `a`
///   (the starting leg length), shown as "1" in `"formulas"` mode
/// - new-leg-offset (length): perpendicular distance of the new-leg labels
///   from their segment, pushed to the OUTSIDE of the spiral so they never
///   cover the drawing inside (0 puts them on the segment)
/// - padding (length): space around the drawing
/// - background (none, color): canvas background
/// -> content
#let pythagorean-spiral(
  steps: 12,
  size: 1cm,
  fill: none,
  stroke: black,
  stroke-width: 1pt,
  direction: "ccw",
  start-angle: 0deg,
  mode: "triangles",
  show-hypotenuses: true,
  right-angle-marks: false,
  right-angle-size: 3mm,
  center-dot: true,
  center-dot-radius: 1.2mm,
  center-dot-fill: black,
  labels: none,
  label-size: 8pt,
  label-offset: 4mm,
  length-labels: none,
  length-size: 7pt,
  length-offset: 0mm,
  length-pos: 0.72,
  length-label-background: white,
  label-new-legs: false,
  new-leg-offset: 2.5mm,
  padding: 7mm,
  background: none,
) = {
  assert(steps >= 1 and steps <= 5000,
    message: "pythagorean-spiral: `steps` must be between 1 and 5000, got " + repr(steps))
  assert(mode in ("triangles", "spiral", "rays"),
    message: "pythagorean-spiral: `mode` must be \"triangles\", \"spiral\" or \"rays\", got " + repr(mode))
  assert(direction in ("ccw", "cw"),
    message: "pythagorean-spiral: `direction` must be \"ccw\" or \"cw\", got " + repr(direction))
  assert(labels in (none, "vertices", "indices"),
    message: "pythagorean-spiral: `labels` must be none, \"vertices\" or \"indices\", got " + repr(labels))
  assert(length-labels in (none, "values", "formulas") or type(length-labels) == function,
    message: "pythagorean-spiral: `length-labels` must be none, \"values\", \"formulas\" or a function, got " + repr(length-labels))
  assert(type(label-new-legs) == bool,
    message: "pythagorean-spiral: `label-new-legs` must be a boolean, got " + repr(label-new-legs))
  assert(type(length-pos) in (int, float) and length-pos > 0 and length-pos < 1,
    message: "pythagorean-spiral: `length-pos` must be strictly between 0 and 1, got " + repr(length-pos))

  // resolve the outline style
  let st = if stroke == none {
    none
  } else if type(stroke) == color {
    (paint: stroke, thickness: stroke-width)
  } else {
    stroke
  }

  let pts = spiral-points(steps, direction: direction, start-angle: start-angle)
  let rmax = calc.sqrt(steps + 1.0) * size
  let half = rmax + padding
  let w = half * 2
  let h = half * 2
  let cx = half
  let cy = half

  // math coords (units of size, y up) -> screen lengths (y down)
  let scr(p) = (cx + p.at(0) * size, cy - p.at(1) * size)

  let parts = ()

  // background
  if background != none {
    parts.push(place(top + left, rect(width: w, height: h, fill: background)))
  }

  // triangle fills
  if mode == "triangles" and fill != none {
    for i in range(1, steps + 1) {
      let col = _color-for(i - 1, steps, fill)
      if col != none {
        parts.push(place(top + left, polygon(
          fill: col,
          stroke: none,
          (cx, cy),
          scr(pts.at(i - 1)),
          scr(pts.at(i)),
        )))
      }
    }
  }

  // outlines
  if st != none {
    if mode == "triangles" {
      // starting leg O -> P_0
      parts.push(place(top + left, line(
        start: (cx, cy), end: scr(pts.at(0)), stroke: st)))
      // outer staircase P_(n-1) -> P_n
      for i in range(1, steps + 1) {
        parts.push(place(top + left, line(
          start: scr(pts.at(i - 1)), end: scr(pts.at(i)), stroke: st)))
      }
      // inner hypotenuses O -> P_n
      if show-hypotenuses {
        for i in range(1, steps + 1) {
          parts.push(place(top + left, line(
            start: (cx, cy), end: scr(pts.at(i)), stroke: st)))
        }
      }
    } else if mode == "spiral" {
      let segs = ()
      for i in range(0, steps + 1) {
        let p = scr(pts.at(i))
        if i == 0 {
          segs.push(curve.move(p))
        } else {
          segs.push(curve.line(p))
        }
      }
      parts.push(place(top + left, curve(stroke: st, ..segs)))
    } else { // "rays"
      for i in range(0, steps + 1) {
        parts.push(place(top + left, line(
          start: (cx, cy), end: scr(pts.at(i)), stroke: st)))
      }
    }
  }

  // right-angle marks at P_(n-1), n = 1..steps
  if right-angle-marks and mode == "triangles" and st != none {
    let r = right-angle-size / size
    for i in range(1, steps + 1) {
      let q = pts.at(i - 1)
      let v1 = (-q.at(0), -q.at(1)) // towards O
      let v2 = (
        pts.at(i).at(0) - q.at(0),
        pts.at(i).at(1) - q.at(1),
      )
      let l1 = calc.sqrt(v1.at(0) * v1.at(0) + v1.at(1) * v1.at(1))
      let l2 = calc.sqrt(v2.at(0) * v2.at(0) + v2.at(1) * v2.at(1))
      if l1 > 0 and l2 > 0 {
        let u1 = (v1.at(0) / l1 * r, v1.at(1) / l1 * r)
        let u2 = (v2.at(0) / l2 * r, v2.at(1) / l2 * r)
        let p1 = scr((q.at(0) + u1.at(0), q.at(1) + u1.at(1)))
        let p2 = scr((q.at(0) + u2.at(0), q.at(1) + u2.at(1)))
        let p3 = scr((
          q.at(0) + u1.at(0) + u2.at(0),
          q.at(1) + u1.at(1) + u2.at(1),
        ))
        parts.push(place(top + left, line(start: p1, end: p3, stroke: st)))
        parts.push(place(top + left, line(start: p2, end: p3, stroke: st)))
      }
    }
  }

  // Length labels: the exact length of each ray is a·sqrt(k), where a is
  // the starting leg length and k is the step number (k = 1 is the starting
  // leg O -> P_0, length a = a·sqrt(1); the ray O -> P_(k-1) that closes
  // the k-th triangle has length a·sqrt(k)).
  if length-labels != none and mode == "triangles" {
    let fmt(k, len) = {
      if type(length-labels) == function {
        length-labels(k, len)
      } else if length-labels == "values" {
        // decimal approximation of a·sqrt(k), 3 decimals
        let v = calc.round((len * size) / 1cm * 1000) / 1000
        [#v "cm"]
      } else { // "formulas": the exact value a·sqrt(k), in units of a
        let r = calc.round(calc.sqrt(k))
        if calc.abs(calc.sqrt(k) - r) < 1e-9 {
          // perfect square: sqrt(1) = 1, sqrt(4) = 2, ...
          str(int(r))
        } else {
          math.sqrt(str(k))
        }
      }
    }
    let off = length-offset / size
    let norm = if direction == "cw" { 90deg } else { -90deg }
    for k in range(1, steps + 2) {
      let n = k - 1
      let p = pts.at(n)
      let phi = calc.atan2(p.at(0), p.at(1))  // Typst: atan2(x, y)
      // rotate the label so it is parallel to the ray, but never upside
      // down (keep the baseline angle in [-90°, 90°])
      let rot = -phi
      if rot > 90deg {
        rot -= 180deg
      } else if rot < -90deg {
        rot += 180deg
      }
      let nx = calc.cos(phi + norm)
      let ny = calc.sin(phi + norm)
      // place the label ALONG the ray, toward the outer endpoint P_n
      // (length-pos > 0.5 pushes it away from the crowded centre)
      let mid = (
        p.at(0) * length-pos + nx * off,
        p.at(1) * length-pos + ny * off,
      )
      let s = scr(mid)
      let lbl = fmt(k, calc.sqrt(k))
      if length-label-background != none {
        parts.push(place(center + horizon,
          dx: s.at(0) - half, dy: s.at(1) - half,
          rotate(rot,
            rect(fill: length-label-background,
              inset: (x: 1.5pt, y: 0.5pt),
              radius: 1pt,
              text(size: length-size, lbl)))))
      } else {
        parts.push(place(center + horizon,
          dx: s.at(0) - half, dy: s.at(1) - half,
          rotate(rot, text(size: length-size, lbl))))
      }
    }
    // Optionally label the new perpendicular legs P_(k-1) -> P_k. Each of
    // them has the exact length a (the starting leg length), i.e. a·sqrt(1).
    if label-new-legs {
      let noff = new-leg-offset / size
      for k in range(1, steps + 1) {
        let p0 = pts.at(k - 1)
        let p1 = pts.at(k)
        let phi = calc.atan2(p1.at(0) - p0.at(0), p1.at(1) - p0.at(1))
        let rot = -phi
        if rot > 90deg {
          rot -= 180deg
        } else if rot < -90deg {
          rot += 180deg
        }
        // outward normal: the side of the segment that faces AWAY from O,
        // so the label never covers the inside of the spiral
        let mx = (p0.at(0) + p1.at(0)) / 2
        let my = (p0.at(1) + p1.at(1)) / 2
        let n0 = (-calc.sin(phi), calc.cos(phi))
        let (nx, ny) = if n0.at(0) * mx + n0.at(1) * my >= 0 {
          n0
        } else {
          (-n0.at(0), -n0.at(1))
        }
        let mid = (mx + nx * noff, my + ny * noff)
        let s = scr(mid)
        let lbl = if type(length-labels) == function {
          length-labels(k, 1.0)
        } else if length-labels == "values" {
          let v = calc.round(size / 1cm * 1000) / 1000
          [#v "cm"]
        } else { // "formulas"
          [1]
        }
        if length-label-background != none {
          parts.push(place(center + horizon,
            dx: s.at(0) - half, dy: s.at(1) - half,
            rotate(rot,
              rect(fill: length-label-background,
                inset: (x: 1.5pt, y: 0.5pt),
                radius: 1pt,
                text(size: length-size, lbl)))))
        } else {
          parts.push(place(center + horizon,
            dx: s.at(0) - half, dy: s.at(1) - half,
            rotate(rot, text(size: length-size, lbl))))
        }
      }
    }
  }

  // centre dot
  if center-dot {
    parts.push(place(center + horizon, circle(
      radius: center-dot-radius, fill: center-dot-fill, stroke: none)))
  }

  // labels
  if labels == "vertices" {
    for i in range(0, steps + 1) {
      let p = pts.at(i)
      let len = calc.sqrt(p.at(0) * p.at(0) + p.at(1) * p.at(1))
      let off = if len > 0 {
        (p.at(0) / len, p.at(1) / len)
      } else {
        (1.0, 0.0)
      }
      let s = scr(p)
      parts.push(place(center + horizon,
        dx: s.at(0) + off.at(0) * label-offset - half,
        dy: s.at(1) - off.at(1) * label-offset - half,
        text(size: label-size)[P#sub[#i]]))
    }
  } else if labels == "indices" {
    for i in range(1, steps + 1) {
      let g = (
        (pts.at(i - 1).at(0) + pts.at(i).at(0)) / 3,
        (pts.at(i - 1).at(1) + pts.at(i).at(1)) / 3,
      )
      let s = scr(g)
      parts.push(place(center + horizon,
        dx: s.at(0) - half, dy: s.at(1) - half,
        text(size: label-size)[#i]))
    }
  }

  box(width: w, height: h, parts.join())
}
