/// Pure Typst 2D facial landmark geometry calculations and report table helper.
/// Coordinates follow top-down image space (`x` right, `y` down).

#let phi = 1.618033988749895

/// Computes the medial-to-lateral canthal tilt angle in degrees.
/// Positive degrees indicate an upward lateral tilt in top-down image space.
#let canthal-tilt-deg(medial, lateral) = {
  let dx = calc.abs(lateral.x - medial.x)
  assert(dx > 1e-12, message: "medial and lateral x coordinates must differ")
  let dy-up = medial.y - lateral.y
  calc.atan2(dx, dy-up) / 1deg
}

/// Computes normalized vertical facial thirds and an L1 balance score in [0, 1].
#let compute-facial-thirds(trichion-y, glabella-y, subnasale-y, menton-y) = {
  assert(
    trichion-y < glabella-y and glabella-y < subnasale-y and subnasale-y < menton-y,
    message: "y coordinates must strictly increase from trichion to menton",
  )
  let total = menton-y - trichion-y
  let upper = (glabella-y - trichion-y) / total
  let middle = (subnasale-y - glabella-y) / total
  let lower = (menton-y - subnasale-y) / total
  let target = 1.0 / 3.0
  let l1 = calc.abs(upper - target) + calc.abs(middle - target) + calc.abs(lower - target)
  let score = calc.max(0.0, calc.min(1.0, 1.0 - (l1 / (4.0 / 3.0))))
  (
    upper: upper,
    middle: middle,
    lower: lower,
    balance-score: score,
  )
}

/// Computes face height-to-width ratio and its signed deviation from `phi`.
#let golden-ratio-delta(face-height, face-width) = {
  assert(face-height > 0 and face-width > 0, message: "dimensions must be positive")
  let ratio = face-height / face-width
  (
    ratio: ratio,
    delta: ratio - phi,
  )
}

/// Computes a normalized bilateral mirror symmetry score in [0, 1].
#let bilateral-symmetry(pairs, midline-x, face-width) = {
  assert(pairs.len() > 0, message: "pairs must be non-empty")
  assert(face-width > 0, message: "face-width must be positive")
  let sum-err = 0.0
  for p in pairs {
    let mirrored-lx = 2.0 * midline-x - p.left.x
    let dx = mirrored-lx - p.right.x
    let dy = p.left.y - p.right.y
    sum-err += calc.sqrt(dx * dx + dy * dy)
  }
  let mean-err = sum-err / pairs.len()
  calc.max(0.0, calc.min(1.0, 1.0 - (mean-err / face-width)))
}

/// Formats a decimal number to `digits` places.
#let _fmt(val, digits: 2) = str(calc.round(val, digits: digits))

/// Renders a clean summary table for computed facial proportion metrics.
#let proportion-summary-table(
  canthal-tilt: none,
  thirds: none,
  golden: none,
  symmetry: none,
) = {
  let rows = ()
  if canthal-tilt != none {
    rows.push(([Canthal Tilt], [#_fmt(canthal-tilt, digits: 2)°]))
  }
  if thirds != none {
    rows.push((
      [Facial Thirds (U / M / L)],
      [#_fmt(thirds.upper * 100, digits: 1)% / #_fmt(thirds.middle * 100, digits: 1)% / #_fmt(thirds.lower * 100, digits: 1)%],
    ))
    rows.push(([Thirds Balance Score], [#_fmt(thirds.balance-score * 100, digits: 1)%]))
  }
  if golden != none {
    let sign = if golden.delta >= 0 { "+" } else { "" }
    rows.push((
      [Height / Width Ratio],
      [#_fmt(golden.ratio, digits: 4) (#sign#_fmt(golden.delta, digits: 4) vs #sym.phi)],
    ))
  }
  if symmetry != none {
    rows.push(([Bilateral Symmetry], [#_fmt(symmetry * 100, digits: 1)%]))
  }
  table(
    columns: (auto, auto),
    inset: 6pt,
    align: (left, right),
    stroke: (x: none, y: 0.5pt + luma(200)),
    [*Metric*], [*Value*],
    ..rows.flatten(),
  )
}
