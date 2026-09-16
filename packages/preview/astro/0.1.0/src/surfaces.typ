#import "@preview/cetz:0.5.0"
#import cetz.draw: *

// ── Utilities ─────────────────────────────────────────────────────────────────

// Draw a horizontal band clipped to a unit circle centered at the origin.
// y1/y2 are the bottom and top of the band in canvas units; values outside
// [-1, 1] are clamped so pole-spanning bands work without degenerate arcs.
#let circle-band(y1, y2, fill: none, stroke: none) = {
  let y_lo = calc.max(-0.9999, y1)
  let y_hi = calc.min(0.9999, y2)
  if y_lo >= y_hi { return }
  let x_lo = calc.sqrt(1 - y_lo * y_lo)
  let x_hi = calc.sqrt(1 - y_hi * y_hi)
  let y_mid = (y_lo + y_hi) / 2
  let x_mid = calc.sqrt(1 - y_mid * y_mid)
  merge-path(close: true, fill: fill, stroke: stroke, {
    line((-x_hi, y_hi), (x_hi, y_hi))
    arc-through((x_hi, y_hi), (x_mid, y_mid), (x_lo, y_lo))
    line((x_lo, y_lo), (-x_lo, y_lo))
    arc-through((-x_lo, y_lo), (-x_mid, y_mid), (-x_hi, y_hi))
  })
}

// ── Colors ────────────────────────────────────────────────────────────────────

#let mercury-crater-edge = rgb(44, 42, 41)
#let mercury-crater = rgb(55, 54, 54)
#let mercury-caloris = rgb(80, 76, 72)
#let venus1 = rgb(100, 100, 85)
#let venus2 = rgb(100, 87, 60)
#let venus3 = rgb(96, 87, 0)
#let uranus-gray = rgb(69, 77, 80)
#let uranus-blue = rgb(69, 93, 90)
#let neptune1 = rgb(27, 51, 71)
#let neptune2 = rgb(25, 41, 88)
#let neptune3 = rgb(53, 85, 95)
#let neptune4 = rgb(12, 56, 100)
#let neptune5 = rgb(42, 35, 80)
#let neptune-white = rgb(94, 100, 100)
#let neptune-dark-spot = rgb(10, 22, 58)
#let pluto1 = rgb(82, 77, 70)
#let pluto2 = rgb(24, 18, 100)
#let pluto-heart = rgb(91, 88, 83)

#let brownish = rgb(70, 58, 42)
#let wheat = rgb(96, 87, 70)
#let yellowish = rgb(100, 100, 88)
#let orangish = rgb(82, 71, 50)
#let pinkish = rgb(100, 85, 73)
#let sienna = rgb(50, 26, 100)
#let greenish = rgb(80, 78, 60)
#let whiteish = rgb(98, 92, 80)

// ── Ring colors ───────────────────────────────────────────────────────────────
#let saturn-ring = rgb("#c8a850")   // warm golden-tan matching Saturn's belt palette
#let uranus-ring = luma(22%)        // very dark — Uranus's rings are nearly opaque charcoal
#let neptune-ring = rgb(28, 32, 52) // dark blue-gray — Neptune's rings are dusty and dim

// ── Surfaces ──────────────────────────────────────────────────────────────────

#let sun-surface() = {
  circle((0, 0), radius: 1, fill: color.mix((yellow, 85%), (red, 15%)), stroke: yellow.lighten(30%) + 2pt)
  // sunspot groups at mid-latitudes (appear in pairs)
  let sp(pos, r) = circle(pos, radius: r, fill: color.mix((orange.darken(50%), 65%), (red.darken(20%), 35%)), stroke: none)
  sp((0.28, 0.33), 0.055)
  sp((0.38, 0.28), 0.035)
  sp((-0.44, -0.22), 0.05)
  sp((-0.52, -0.16), 0.032)
  sp((0.14, -0.4), 0.042)
}

#let mercury-surface() = {
  circle((0, 0), radius: 1, fill: gray, stroke: gray.darken(30%) + 2pt)
  // Caloris Basin — Mercury's dominant impact feature (~1500 km wide)
  circle((-0.25, 0.38), radius: 0.32, fill: mercury-caloris, stroke: mercury-crater-edge + 1pt)
  circle((-0.25, 0.38), radius: 0.22, fill: color.mix((mercury-caloris, 55%), (gray, 45%)), stroke: none)
  // craters distributed across the non-Caloris hemisphere
  let c(pos, r) = circle(pos, radius: r, fill: mercury-crater, stroke: mercury-crater-edge + 0.5pt)
  c((0.5, 0.55), 0.09)
  c((0.22, 0.3), 0.075)
  c((0.6, 0.65), 0.04)
  c((0.75, 0.42), 0.03)
  c((0.17, -0.07), 0.09)
  c((0.02, -0.28), 0.08)
  c((0.33, -0.43), 0.07)
  c((0.63, -0.3), 0.06)
  c((0.02, -0.88), 0.06)
  c((0.85, -0.05), 0.04)
  c((0.61, -0.14), 0.03)
  c((0.15, -0.62), 0.035)
  c((-0.47, -0.41), 0.08)
  c((-0.2, -0.87), 0.07)
  c((-0.78, -0.17), 0.05)
  c((-0.57, -0.66), 0.05)
  c((-0.4, -0.15), 0.04)
  c((-0.65, 0.55), 0.025)
  c((0.02, -0.54), 0.06)
}

#let venus-surface() = {
  circle(
    (0, 0),
    radius: 1,
    fill: gradient.linear(
      (venus1, 0%),
      (venus2, 15%),
      (venus3, 50%),
      (color.mix((venus2, 90%), (black, 10%)), 85%),
      (venus1, 100%),
      angle: 90deg,
    ),
    stroke: brownish.lighten(40%) + 2pt,
  )
  // cloud band stripes — subtle C/Y-shaped atmospheric banding
  let band(y1, y2, c) = circle-band(y1, y2, fill: c)
  band(0.62, 0.73, color.mix((venus3, 35%), (venus2, 65%)).darken(12%))
  band(0.36, 0.50, color.mix((venus3, 50%), (venus2, 50%)).darken(10%))
  band(0.08, 0.20, color.mix((venus2, 60%), (venus3, 40%)).darken(14%))
  band(-0.20, -0.08, color.mix((venus2, 55%), (venus3, 45%)).darken(12%))
  band(-0.50, -0.36, color.mix((venus3, 50%), (venus2, 50%)).darken(10%))
  band(-0.73, -0.62, color.mix((venus3, 35%), (venus2, 65%)).darken(12%))
}

#let earth-surface() = {
  let land = color.mix((green, 70%), (black, 30%))
  let ice = color.mix((white, 88%), (aqua, 12%))
  circle((0, 0), radius: 1, fill: aqua, stroke: neptune3 + 2pt)
  // North America
  circle((-0.52, 0.52), radius: (0.22, 0.17), fill: land, stroke: none)
  circle((-0.44, 0.35), radius: (0.14, 0.13), fill: land, stroke: none)
  circle((-0.36, 0.18), radius: (0.09, 0.11), fill: land, stroke: none)
  // South America
  circle((-0.32, -0.18), radius: (0.11, 0.09), fill: land, stroke: none)
  circle((-0.28, -0.42), radius: (0.09, 0.2), fill: land, stroke: none)
  // Europe
  circle((0.44, 0.54), radius: (0.16, 0.12), fill: land, stroke: none)
  circle((0.5, 0.38), radius: (0.1, 0.08), fill: land, stroke: none)
  // Africa
  circle((0.48, 0.1), radius: (0.14, 0.28), fill: land, stroke: none)
  // Asia
  circle((0.28, 0.66), radius: (0.32, 0.14), fill: land, stroke: none)
  circle((0.58, 0.5), radius: (0.1, 0.12), fill: land, stroke: none)
  // polar ice caps
  circle-band(0.84, 1.0, fill: ice)
  circle-band(-1.0, -0.88, fill: ice)
}

#let moon-surface() = {
  circle((0, 0), radius: 1, fill: luma(77%), stroke: luma(60%) + 2pt)
  // maria — dark basalt plains on the near side
  let m(pos, r) = circle(pos, radius: r, fill: luma(52%), stroke: none)
  m((-0.4, 0.32), 0.36)   // Oceanus Procellarum (largest dark plain)
  m((-0.05, 0.54), 0.26)  // Mare Imbrium
  m((0.22, 0.44), 0.16)   // Mare Serenitatis
  m((0.26, 0.22), 0.17)   // Mare Tranquillitatis
  m((0.62, 0.54), 0.1)    // Mare Crisium
  m((0.1, -0.08), 0.19)   // Mare Nubium / Mare Cognitum
  m((-0.18, -0.22), 0.14) // Mare Humorum
  // prominent craters
  let c(pos, r) = circle(pos, radius: r, fill: luma(83%), stroke: luma(62%) + 0.5pt)
  c((0.48, -0.22), 0.12)  // Tycho
  c((-0.38, -0.56), 0.1)  // Clavius
  c((0.1, -0.48), 0.07)   // Maginus
  c((0.68, -0.18), 0.05)
  c((-0.62, -0.3), 0.04)
  c((-0.08, 0.76), 0.04)
  c((0.42, 0.74), 0.03)
  c((-0.7, 0.5), 0.03)
  c((0.8, 0.28), 0.025)
}

#let mars-surface() = {
  let rust = color.mix((red, 50%), (brownish, 50%))
  circle((0, 0), radius: 1, fill: rust, stroke: color.mix((red, 60%), (black, 40%)) + 2pt)
  // Hellas Planitia — large southern impact basin (lighter dusty floor)
  circle((0.38, -0.54), radius: (0.28, 0.2), fill: color.mix((rust, 30%), (pinkish, 70%)), stroke: none)
  // Tharsis volcanic plateau (slightly warmer/lighter)
  circle((-0.28, 0.12), radius: (0.34, 0.3), fill: color.mix((rust, 55%), (orange.lighten(15%), 45%)), stroke: none)
  // Valles Marineris — equatorial canyon system running east–west
  circle((0.1, 0.04), radius: (0.42, 0.032), fill: color.mix((rust, 30%), (brownish, 70%)), stroke: none)
  // polar ice caps
  circle-band(0.83, 1.0, fill: white.darken(5%))
  circle-band(-1.0, -0.86, fill: white.darken(8%))
}

#let jupiter-surface() = {
  let b(p) = color.mix((brownish, p), (white, 100% - p))
  let zone = color.mix((wheat, 55%), (white, 45%))
  let belt = color.mix((brownish, 78%), (sienna, 22%))
  circle((0, 0), radius: 1, fill: zone, stroke: b(60%) + 2pt)
  // belts and zones from north pole to south pole
  circle-band(0.70, 1.0, fill: b(68%))          // North Polar Region
  circle-band(0.56, 0.68, fill: b(42%))          // North Temperate Zone
  circle-band(0.46, 0.56, fill: b(62%))          // North Temperate Belt
  circle-band(0.10, 0.46, fill: belt)            // North Equatorial Belt
  circle-band(-0.04, 0.10, fill: zone)           // Equatorial Zone
  circle-band(-0.40, -0.04, fill: belt)          // South Equatorial Belt (contains GRS)
  circle-band(-0.52, -0.40, fill: b(42%))        // South Tropical Zone
  circle-band(-0.62, -0.52, fill: b(62%))        // South Temperate Belt
  circle-band(-1.0, -0.70, fill: b(68%))         // South Polar Region
  // Great Red Spot — oval storm in South Equatorial Belt
  circle((-0.36, -0.22), radius: (0.21, 0.14), fill: color.mix((red, 45%), (brownish, 55%)), stroke: none)
  circle((-0.36, -0.22), radius: (0.14, 0.09), fill: color.mix((red, 38%), (orangish, 62%)), stroke: none)
}

#let saturn-surface() = {
  let base = rgb("#f0e8c0") // pale cream zones
  let belt = rgb("#c0983c") // warm tan belts
  let pole = rgb("#a07c28") // darker polar caps

  circle((0, 0), radius: 1, fill: base, stroke: rgb("#c8a850") + 2pt)
  circle-band(0.78, 1.0, fill: pole)
  circle-band(-1.0, -0.78, fill: pole)
  circle-band(0.56, 0.63, fill: belt)
  circle-band(0.28, 0.37, fill: belt)
  circle-band(0.02, 0.13, fill: belt)
  circle-band(-0.14, -0.04, fill: belt)
  circle-band(-0.38, -0.29, fill: belt)
  circle-band(-0.63, -0.56, fill: belt)
}

#let uranus-surface() = {
  circle((0, 0), radius: 1, fill: uranus-blue, stroke: uranus-gray + 2pt)
  // faint polar collar — slightly brighter near the poles
  let collar = color.mix((uranus-blue, 30%), (white, 70%))
  circle-band(0.72, 1.0, fill: collar)
  circle-band(-1.0, -0.72, fill: collar)
  // very subtle equatorial darkening band
  circle-band(-0.12, 0.12, fill: color.mix((uranus-blue, 80%), (uranus-gray, 20%)))
}

#let neptune-surface() = {
  circle(
    (0, 0),
    radius: 1,
    fill: gradient.linear(
      (color.mix((neptune1, 90%), (black, 10%)), 0%),
      (neptune2, 17.5%),
      (neptune-white, 20%),
      (neptune2, 22.5%),
      (neptune3, 60%),
      (neptune4, 80%),
      (neptune5, 100%),
      angle: 90deg,
    ),
    stroke: blue.lighten(40%) + 2pt,
  )
  // Great Dark Spot — large oval storm in southern hemisphere
  circle((0.15, -0.22), radius: (0.22, 0.14), fill: neptune-dark-spot, stroke: none)
  circle((0.15, -0.22), radius: (0.16, 0.09), fill: color.mix((neptune-dark-spot, 70%), (neptune2, 30%)), stroke: none)
  // Scooter — bright cirrus-like cloud feature
  circle((-0.3, -0.08), radius: (0.09, 0.04), fill: neptune-white, stroke: none)
}

#let pluto-surface() = {
  circle(
    (0, 0),
    radius: 1,
    fill: gradient.linear(
      (pluto1, 0%),
      (pluto2, 20%),
      (pluto2, 35%),
      (pluto1, 60%),
      (pluto1, 100%),
      angle: 90deg,
    ),
    stroke: pluto2.lighten(30%) + 2pt,
  )
  // Tombaugh Regio — heart-shaped nitrogen ice plains (two lobes)
  circle((-0.02, -0.32), radius: (0.2, 0.22), fill: pluto-heart, stroke: none)  // Sputnik Planitia (left lobe)
  circle((0.2, -0.26), radius: (0.15, 0.17), fill: pluto-heart, stroke: none)   // eastern lobe
  // dark equatorial terrain (Cthulhu Macula)
  circle((-0.45, 0.1), radius: (0.32, 0.12), fill: color.mix((pluto2, 60%), (black, 40%)), stroke: none)
}

#let generic-surface(color: blue) = {
  circle((0, 0), radius: 1, fill: color, stroke: color.lighten(50%) + 2pt)
}

#let surfaces = (
  "sun": sun-surface,
  "mercury": mercury-surface,
  "venus": venus-surface,
  "earth": earth-surface,
  "moon": moon-surface,
  "mars": mars-surface,
  "jupiter": jupiter-surface,
  "saturn": saturn-surface,
  "uranus": uranus-surface,
  "neptune": neptune-surface,
  "pluto": pluto-surface,
)
