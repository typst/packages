// vehicles.typ — scene-balloon, scene-boat, scene-submarine, scene-mine-cart
// + scene-airplane, scene-helicopter, scene-car, scene-cable-car
// + scene-parachute, scene-rocket, scene-drone

#import "@preview/cetz:0.5.2"
#import "theme.typ": scene-theme, _f, _s

/// Draw a hot-air balloon
#let scene-balloon(
  center,
  size: 0.6,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.balloon-envelope } else { bg }
  let s = if line-color == auto { scene-theme.balloon-envelope-stroke } else { line-color }
  let cx = center.at(0)
  let cy = center.at(1)
  let r = size

  // Basket position
  let basket-y = cy - r - 0.3 * r

  // Ropes (behind envelope)
  line((cx - r * 0.22, basket-y + r * 0.2), (cx - r * 0.5, cy - r * 0.8), stroke: _s(scene-theme.rope, bw) + 0.5pt)
  line((cx + r * 0.22, basket-y + r * 0.2), (cx + r * 0.5, cy - r * 0.8), stroke: _s(scene-theme.rope, bw) + 0.5pt)

  // Envelope (main balloon)
  circle(center, radius: r, fill: _f(f, bw), stroke: _s(s, bw) + 1.2pt)

  // Vertical stripes for detail
  for dx in (-r * 0.3, 0, r * 0.3) {
    let stripe-x = cx + dx
    line(
      (stripe-x, cy + r * 0.85),
      (stripe-x + dx * 0.15, cy),
      (stripe-x, cy - r * 0.85),
      stroke: _s(s, bw) + 0.4pt,
    )
  }

  // Basket
  let bw-width = r * 0.35
  let bh = r * 0.2
  rect((cx - bw-width / 2, basket-y), (cx + bw-width / 2, basket-y + bh),
    fill: _f(scene-theme.balloon-basket, bw), stroke: _s(scene-theme.balloon-basket-stroke, bw) + 0.8pt)

}

/// Draw a boat
#let scene-boat(
  base,
  size: 0.5,
  bg: auto,
  line-color: auto,
  variant: "rowboat",
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.boat-hull } else { bg }
  let s = if line-color == auto { scene-theme.boat-hull-stroke } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)
  let sz = size

  if variant == "ship" {
    // Ship: larger hull with flat bottom, multiple deck levels, funnel
    // Hull (wider, more rectangular shape)
    line(
      (bx - sz * 0.8, by),
      (bx - sz * 0.65, by + sz * 0.3),
      (bx + sz * 0.65, by + sz * 0.3),
      (bx + sz * 0.8, by + sz * 0.1),
      (bx + sz * 0.75, by),
      close: true, fill: _f(f, bw), stroke: _s(s, bw) + 1pt,
    )

    let deck-y = by + sz * 0.3

    // Lower deck (first level)
    rect(
      (bx - sz * 0.5, deck-y),
      (bx + sz * 0.55, deck-y + sz * 0.18),
      fill: _f(rgb("#ECEFF1"), bw), stroke: _s(s, bw) + 0.6pt,
    )
    // Windows on lower deck
    for i in range(5) {
      let wx = bx - sz * 0.4 + i * sz * 0.2
      circle((wx, deck-y + sz * 0.09), radius: sz * 0.03, fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.3pt)
    }

    // Upper deck (second level, slightly narrower)
    let upper-y = deck-y + sz * 0.18
    rect(
      (bx - sz * 0.35, upper-y),
      (bx + sz * 0.35, upper-y + sz * 0.15),
      fill: _f(white, bw), stroke: _s(s, bw) + 0.6pt,
    )
    // Windows on upper deck
    for i in range(3) {
      let wx = bx - sz * 0.2 + i * sz * 0.2
      circle((wx, upper-y + sz * 0.075), radius: sz * 0.025, fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.3pt)
    }

    // Bridge / wheelhouse
    let bridge-y = upper-y + sz * 0.15
    rect(
      (bx - sz * 0.12, bridge-y),
      (bx + sz * 0.12, bridge-y + sz * 0.12),
      fill: _f(rgb("#ECEFF1"), bw), stroke: _s(s, bw) + 0.5pt,
    )
    // Bridge window
    rect(
      (bx - sz * 0.08, bridge-y + sz * 0.04),
      (bx + sz * 0.08, bridge-y + sz * 0.1),
      fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.3pt,
    )

    // Funnel / smokestack
    let funnel-x = bx + sz * 0.25
    rect(
      (funnel-x - sz * 0.05, upper-y),
      (funnel-x + sz * 0.05, upper-y + sz * 0.22),
      fill: _f(rgb("#D32F2F"), bw), stroke: _s(s, bw) + 0.6pt,
    )
    // Funnel stripe
    rect(
      (funnel-x - sz * 0.05, upper-y + sz * 0.15),
      (funnel-x + sz * 0.05, upper-y + sz * 0.18),
      fill: _f(rgb("#212121"), bw), stroke: none,
    )
    // Smoke puff
    circle((funnel-x, upper-y + sz * 0.28), radius: sz * 0.04, fill: _f(rgb("#9E9E9E").transparentize(40%), bw), stroke: none)
    circle((funnel-x + sz * 0.04, upper-y + sz * 0.33), radius: sz * 0.03, fill: _f(rgb("#BDBDBD").transparentize(50%), bw), stroke: none)

  } else if variant == "motorboat" {
    // Motorboat: low sleek hull, small cabin/windshield, outboard motor
    // Sleek hull (lower profile, more pointed bow)
    line(
      (bx - sz * 0.55, by + sz * 0.05),
      (bx - sz * 0.45, by + sz * 0.2),
      (bx + sz * 0.35, by + sz * 0.2),
      (bx + sz * 0.55, by + sz * 0.12),
      (bx + sz * 0.6, by),
      (bx - sz * 0.5, by),
      close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt,
    )

    let deck-y = by + sz * 0.2

    // Windshield (angled rectangle)
    line(
      (bx - sz * 0.05, deck-y),
      (bx - sz * 0.1, deck-y + sz * 0.18),
      (bx + sz * 0.05, deck-y + sz * 0.18),
      (bx + sz * 0.08, deck-y),
      close: true, fill: _f(scene-theme.window.transparentize(30%), bw), stroke: _s(s, bw) + 0.5pt,
    )

    // Small cabin behind windshield
    rect(
      (bx + sz * 0.08, deck-y),
      (bx + sz * 0.25, deck-y + sz * 0.12),
      fill: _f(rgb("#ECEFF1"), bw), stroke: _s(s, bw) + 0.5pt,
    )

    // Outboard motor at back (stern)
    let motor-x = bx - sz * 0.5
    rect(
      (motor-x - sz * 0.08, by - sz * 0.05),
      (motor-x, by + sz * 0.1),
      fill: _f(rgb("#37474F"), bw), stroke: _s(rgb("#263238"), bw) + 0.6pt,
    )
    // Motor shaft going down
    line((motor-x - sz * 0.04, by - sz * 0.05), (motor-x - sz * 0.04, by - sz * 0.15), stroke: _s(rgb("#37474F"), bw) + 1pt)
    // Propeller
    line((motor-x - sz * 0.1, by - sz * 0.15), (motor-x + sz * 0.02, by - sz * 0.15), stroke: _s(rgb("#546E7A"), bw) + 1pt)

    // Wake line
    line(
      (bx - sz * 0.55, by - sz * 0.02),
      (bx - sz * 0.7, by - sz * 0.05),
      stroke: _s(rgb("#90CAF9"), bw) + 0.5pt,
    )

  } else if variant == "sailboat" {
    // Hull
    line(
      (bx - sz * 0.6, by),
      (bx - sz * 0.45, by + sz * 0.25),
      (bx + sz * 0.45, by + sz * 0.25),
      (bx + sz * 0.6, by),
      close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt,
    )

    let deck-y = by + sz * 0.25

    // Mast
    line((bx, deck-y), (bx, deck-y + sz * 0.9), stroke: _s(s, bw) + 0.8pt)
    // Sail (triangle)
    line(
      (bx, deck-y + sz * 0.85),
      (bx + sz * 0.4, deck-y + sz * 0.3),
      (bx, deck-y + sz * 0.15),
      close: true, fill: _f(white, bw), stroke: _s(rgb("#BDBDBD"), bw) + 0.5pt,
    )
  } else {
    // Rowboat (default)
    // Hull
    line(
      (bx - sz * 0.6, by),
      (bx - sz * 0.45, by + sz * 0.25),
      (bx + sz * 0.45, by + sz * 0.25),
      (bx + sz * 0.6, by),
      close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt,
    )

    let deck-y = by + sz * 0.25

    // Mast with flag
    line((bx, deck-y), (bx, deck-y + sz * 0.5), stroke: _s(s, bw) + 0.8pt)
    line(
      (bx, deck-y + sz * 0.5),
      (bx + sz * 0.15, deck-y + sz * 0.43),
      (bx, deck-y + sz * 0.36),
      close: true, fill: _f(red, bw), stroke: if bw { black + 0.5pt } else { none },
    )
  }
}

/// Draw a submarine
#let scene-submarine(
  center,
  size: 1.0,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.submarine-hull } else { bg }
  let s = if line-color == auto { scene-theme.submarine-hull-stroke } else { line-color }
  let cx = center.at(0)
  let cy = center.at(1)
  let half = size / 2
  let h = size * 0.18

  // Hull (elongated hexagon shape)
  line(
    (cx - half, cy),
    (cx - half * 0.8, cy + h),
    (cx + half * 0.7, cy + h),
    (cx + half, cy),
    (cx + half * 0.7, cy - h),
    (cx - half * 0.8, cy - h),
    close: true, fill: _f(f, bw), stroke: _s(s, bw) + 1pt,
  )

  // Conning tower
  let tw = size * 0.12
  let th = size * 0.2
  rect((cx - tw / 2, cy + h), (cx + tw / 2, cy + h + th),
    fill: _f(rgb("#455A64"), bw), stroke: _s(s, bw) + 0.8pt)

  // Periscope
  line((cx + tw * 0.3, cy + h + th), (cx + tw * 0.3, cy + h + th + size * 0.12), stroke: _s(rgb("#455A64"), bw) + 0.8pt)
  line((cx + tw * 0.3, cy + h + th + size * 0.12), (cx + tw * 0.3 + size * 0.05, cy + h + th + size * 0.12), stroke: _s(rgb("#455A64"), bw) + 0.8pt)

  // Propeller
  line((cx - half, cy + h * 0.6), (cx - half - size * 0.08, cy + h + size * 0.05), stroke: _s(rgb("#546E7A"), bw) + 1pt)
  line((cx - half, cy - h * 0.6), (cx - half - size * 0.08, cy - h - size * 0.05), stroke: _s(rgb("#546E7A"), bw) + 1pt)

  // Bubbles
  circle((cx + size * 0.15, cy + h + th + size * 0.1), radius: 0.04, fill: none, stroke: _s(rgb("#80DEEA"), bw) + 0.6pt)
  circle((cx + size * 0.08, cy + h + th + size * 0.2), radius: 0.06, fill: none, stroke: _s(rgb("#80DEEA"), bw) + 0.6pt)

}

/// Draw a mine cart
#let scene-mine-cart(
  base,
  size: 0.4,
  bg: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.wood } else { bg }
  let bx = base.at(0)
  let by = base.at(1)
  let s = size

  // Cart body (trapezoid)
  line(
    (bx - s * 0.5, by),
    (bx - s * 0.38, by + s * 0.5),
    (bx + s * 0.38, by + s * 0.5),
    (bx + s * 0.5, by),
    close: true, fill: _f(rgb("#5D4037"), bw), stroke: _s(rgb("#3E2723"), bw) + 0.8pt,
  )

  // Wheels
  circle((bx - s * 0.28, by - s * 0.08), radius: s * 0.1, fill: _f(rgb("#37474F"), bw), stroke: _s(rgb("#263238"), bw) + 0.5pt)
  circle((bx + s * 0.28, by - s * 0.08), radius: s * 0.1, fill: _f(rgb("#37474F"), bw), stroke: _s(rgb("#263238"), bw) + 0.5pt)

  // Rocks in cart
  circle((bx - s * 0.12, by + s * 0.38), radius: s * 0.08, fill: _f(rgb("#9E9E9E"), bw), stroke: if bw { black + 0.5pt } else { none })
  circle((bx + s * 0.1, by + s * 0.42), radius: s * 0.06, fill: _f(rgb("#757575"), bw), stroke: if bw { black + 0.5pt } else { none })
  circle((bx + s * 0.2, by + s * 0.35), radius: s * 0.07, fill: _f(rgb("#BDBDBD"), bw), stroke: if bw { black + 0.5pt } else { none })

}

// ============================================================
// NEW VEHICLES BELOW
// ============================================================

/// Draw a side-view airplane
/// - center (array): (x, y) center of the fuselage
/// - size (float): overall scale
/// - bg (color): fuselage color
/// - line-color (color): stroke color
/// - direction (int): 1 = facing right, -1 = facing left
#let scene-airplane(
  center,
  size: 1.0,
  bg: auto,
  line-color: auto,
  direction: 1,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#ECEFF1") } else { bg }
  let s = if line-color == auto { rgb("#546E7A") } else { line-color }
  let cx = center.at(0)
  let cy = center.at(1)
  let sz = size
  let d = if direction < 0 { -1 } else { 1 }

  // Fuselage (elongated body)
  line(
    (cx + sz * 0.6 * d, cy),           // nose tip
    (cx + sz * 0.5 * d, cy + sz * 0.06),
    (cx - sz * 0.1 * d, cy + sz * 0.08),
    (cx - sz * 0.5 * d, cy + sz * 0.06),
    (cx - sz * 0.55 * d, cy),          // tail
    (cx - sz * 0.5 * d, cy - sz * 0.06),
    (cx - sz * 0.1 * d, cy - sz * 0.08),
    (cx + sz * 0.5 * d, cy - sz * 0.06),
    close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt,
  )

  // Wing (main wing from center, angled slightly back)
  line(
    (cx + sz * 0.05 * d, cy - sz * 0.06),
    (cx - sz * 0.1 * d, cy - sz * 0.35),
    (cx - sz * 0.2 * d, cy - sz * 0.35),
    (cx - sz * 0.08 * d, cy - sz * 0.06),
    close: true, fill: _f(f.darken(10%), bw), stroke: _s(s, bw) + 0.6pt,
  )
  // Upper wing hint (above fuselage for perspective)
  line(
    (cx + sz * 0.05 * d, cy + sz * 0.06),
    (cx - sz * 0.1 * d, cy + sz * 0.3),
    (cx - sz * 0.2 * d, cy + sz * 0.3),
    (cx - sz * 0.08 * d, cy + sz * 0.06),
    close: true, fill: _f(f.darken(5%), bw), stroke: _s(s, bw) + 0.6pt,
  )

  // Tail fin (vertical stabilizer)
  line(
    (cx - sz * 0.45 * d, cy + sz * 0.06),
    (cx - sz * 0.52 * d, cy + sz * 0.22),
    (cx - sz * 0.55 * d, cy + sz * 0.22),
    (cx - sz * 0.55 * d, cy + sz * 0.06),
    close: true, fill: _f(f.darken(15%), bw), stroke: _s(s, bw) + 0.6pt,
  )

  // Horizontal tailplane
  line(
    (cx - sz * 0.45 * d, cy - sz * 0.02),
    (cx - sz * 0.55 * d, cy - sz * 0.12),
    (cx - sz * 0.6 * d, cy - sz * 0.12),
    (cx - sz * 0.55 * d, cy - sz * 0.02),
    close: true, fill: _f(f.darken(10%), bw), stroke: _s(s, bw) + 0.5pt,
  )

  // Cockpit window
  line(
    (cx + sz * 0.42 * d, cy + sz * 0.02),
    (cx + sz * 0.35 * d, cy + sz * 0.06),
    (cx + sz * 0.28 * d, cy + sz * 0.06),
    (cx + sz * 0.32 * d, cy + sz * 0.02),
    close: true, fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.4pt,
  )

  // Passenger windows (row of small circles)
  for i in range(4) {
    let wx = cx + (sz * 0.2 - i * sz * 0.12) * d
    circle((wx, cy + sz * 0.03), radius: sz * 0.02, fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.3pt)
  }

  // Engine (under wing)
  let eng-x = cx - sz * 0.05 * d
  let eng-y = cy - sz * 0.15
  rect(
    (eng-x - sz * 0.04 * d, eng-y - sz * 0.025),
    (eng-x + sz * 0.04 * d, eng-y + sz * 0.025),
    fill: _f(rgb("#78909C"), bw), stroke: _s(s, bw) + 0.4pt,
  )
}

/// Draw a side-view helicopter
/// - center (array): (x, y) center of the body
/// - size (float): overall scale
/// - bg (color): body color
/// - line-color (color): stroke color
#let scene-helicopter(
  center,
  size: 0.8,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#1565C0") } else { bg }
  let s = if line-color == auto { rgb("#0D47A1") } else { line-color }
  let cx = center.at(0)
  let cy = center.at(1)
  let sz = size

  // Main body (rounded shape)
  line(
    (cx + sz * 0.3, cy + sz * 0.05),   // nose
    (cx + sz * 0.25, cy + sz * 0.15),
    (cx - sz * 0.1, cy + sz * 0.18),
    (cx - sz * 0.2, cy + sz * 0.15),
    (cx - sz * 0.25, cy + sz * 0.08),   // back top
    (cx - sz * 0.25, cy - sz * 0.08),   // back bottom
    (cx - sz * 0.2, cy - sz * 0.15),
    (cx - sz * 0.05, cy - sz * 0.18),
    (cx + sz * 0.2, cy - sz * 0.15),
    (cx + sz * 0.3, cy - sz * 0.05),    // nose bottom
    close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt,
  )

  // Cockpit window (large front window)
  line(
    (cx + sz * 0.28, cy + sz * 0.03),
    (cx + sz * 0.2, cy + sz * 0.13),
    (cx + sz * 0.05, cy + sz * 0.15),
    (cx + sz * 0.05, cy + sz * 0.02),
    close: true, fill: _f(scene-theme.window.transparentize(20%), bw), stroke: _s(s, bw) + 0.5pt,
  )

  // Tail boom (extending backward)
  line(
    (cx - sz * 0.25, cy + sz * 0.05),
    (cx - sz * 0.6, cy + sz * 0.06),
    (cx - sz * 0.6, cy - sz * 0.02),
    (cx - sz * 0.25, cy - sz * 0.05),
    close: true, fill: _f(f.darken(10%), bw), stroke: _s(s, bw) + 0.6pt,
  )

  // Tail fin (vertical)
  line(
    (cx - sz * 0.58, cy + sz * 0.06),
    (cx - sz * 0.62, cy + sz * 0.18),
    (cx - sz * 0.65, cy + sz * 0.18),
    (cx - sz * 0.62, cy + sz * 0.06),
    close: true, fill: _f(f.darken(15%), bw), stroke: _s(s, bw) + 0.5pt,
  )

  // Tail rotor (small circle at end of tail)
  circle((cx - sz * 0.63, cy + sz * 0.12), radius: sz * 0.04, fill: none, stroke: _s(s, bw) + 0.6pt)
  // Tail rotor blades
  line((cx - sz * 0.63, cy + sz * 0.08), (cx - sz * 0.63, cy + sz * 0.16), stroke: _s(rgb("#455A64"), bw) + 0.8pt)

  // Landing skids
  let skid-y = cy - sz * 0.22
  // Left strut
  line((cx - sz * 0.1, cy - sz * 0.15), (cx - sz * 0.12, skid-y), stroke: _s(s, bw) + 0.8pt)
  // Right strut
  line((cx + sz * 0.15, cy - sz * 0.15), (cx + sz * 0.13, skid-y), stroke: _s(s, bw) + 0.8pt)
  // Skid bar
  line((cx - sz * 0.2, skid-y), (cx + sz * 0.25, skid-y), stroke: _s(rgb("#37474F"), bw) + 1.2pt)

  // Main rotor mast
  line((cx, cy + sz * 0.18), (cx, cy + sz * 0.28), stroke: _s(s, bw) + 1pt)
  // Main rotor hub
  circle((cx, cy + sz * 0.28), radius: sz * 0.02, fill: _f(rgb("#37474F"), bw), stroke: if bw { black + 0.5pt } else { none })
  // Main rotor blades
  line((cx - sz * 0.5, cy + sz * 0.29), (cx + sz * 0.5, cy + sz * 0.27), stroke: _s(rgb("#455A64"), bw) + 1.2pt)
  // Second blade (slightly offset angle)
  line((cx - sz * 0.15, cy + sz * 0.31), (cx + sz * 0.35, cy + sz * 0.25), stroke: _s(rgb("#455A64"), bw) + 0.8pt)
}

/// Draw a side-view car
/// - base (array): (x, y) bottom center where wheels sit
/// - size (float): overall scale
/// - bg (color): body color
/// - line-color (color): stroke color
/// - variant (string): "sedan" or "truck"
#let scene-car(
  base,
  size: 0.5,
  bg: auto,
  line-color: auto,
  variant: "sedan",
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#D32F2F") } else { bg }
  let s = if line-color == auto { rgb("#B71C1C") } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)
  let sz = size

  // Wheel radius
  let wr = sz * 0.1

  if variant == "truck" {
    // Pickup truck
    // Lower body (chassis)
    line(
      (bx - sz * 0.5, by + wr),
      (bx - sz * 0.5, by + sz * 0.3),
      (bx + sz * 0.5, by + sz * 0.3),
      (bx + sz * 0.5, by + wr),
      close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt,
    )

    // Cabin (front half, taller)
    line(
      (bx + sz * 0.1, by + sz * 0.3),
      (bx + sz * 0.08, by + sz * 0.55),
      (bx + sz * 0.4, by + sz * 0.55),
      (bx + sz * 0.45, by + sz * 0.3),
      close: true, fill: _f(f.darken(5%), bw), stroke: _s(s, bw) + 0.8pt,
    )

    // Cabin window
    line(
      (bx + sz * 0.14, by + sz * 0.33),
      (bx + sz * 0.12, by + sz * 0.5),
      (bx + sz * 0.36, by + sz * 0.5),
      (bx + sz * 0.38, by + sz * 0.33),
      close: true, fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.4pt,
    )

    // Truck bed (back, open top)
    rect(
      (bx - sz * 0.48, by + sz * 0.3),
      (bx + sz * 0.08, by + sz * 0.42),
      fill: _f(f.darken(15%), bw), stroke: _s(s, bw) + 0.6pt,
    )

    // Headlight
    rect(
      (bx + sz * 0.46, by + sz * 0.2),
      (bx + sz * 0.5, by + sz * 0.26),
      fill: _f(rgb("#FFEE58"), bw), stroke: _s(s, bw) + 0.3pt,
    )

    // Taillight
    rect(
      (bx - sz * 0.5, by + sz * 0.2),
      (bx - sz * 0.47, by + sz * 0.26),
      fill: _f(rgb("#E53935"), bw), stroke: _s(s, bw) + 0.3pt,
    )

  } else {
    // Sedan (default)
    // Lower body
    line(
      (bx - sz * 0.45, by + wr),
      (bx - sz * 0.45, by + sz * 0.25),
      (bx + sz * 0.45, by + sz * 0.25),
      (bx + sz * 0.5, by + sz * 0.18),
      (bx + sz * 0.5, by + wr),
      close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt,
    )

    // Upper body / cabin (roofline)
    line(
      (bx - sz * 0.25, by + sz * 0.25),
      (bx - sz * 0.2, by + sz * 0.48),
      (bx + sz * 0.15, by + sz * 0.48),
      (bx + sz * 0.3, by + sz * 0.25),
      close: true, fill: _f(f.darken(5%), bw), stroke: _s(s, bw) + 0.8pt,
    )

    // Windshield (front window)
    line(
      (bx + sz * 0.14, by + sz * 0.27),
      (bx + sz * 0.12, by + sz * 0.44),
      (bx + sz * 0.26, by + sz * 0.27),
      close: true, fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.4pt,
    )

    // Rear window
    line(
      (bx - sz * 0.22, by + sz * 0.27),
      (bx - sz * 0.18, by + sz * 0.44),
      (bx - sz * 0.06, by + sz * 0.27),
      close: true, fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.4pt,
    )

    // Headlight
    rect(
      (bx + sz * 0.44, by + sz * 0.18),
      (bx + sz * 0.5, by + sz * 0.23),
      fill: _f(rgb("#FFEE58"), bw), stroke: _s(s, bw) + 0.3pt,
    )

    // Taillight
    rect(
      (bx - sz * 0.45, by + sz * 0.18),
      (bx - sz * 0.42, by + sz * 0.23),
      fill: _f(rgb("#E53935"), bw), stroke: _s(s, bw) + 0.3pt,
    )
  }

  // Wheels (common for both variants)
  let front-wheel-x = bx + sz * 0.28
  let rear-wheel-x = bx - sz * 0.28
  // Rear wheel
  circle((rear-wheel-x, by + wr), radius: wr, fill: _f(rgb("#212121"), bw), stroke: _s(rgb("#111111"), bw) + 0.5pt)
  circle((rear-wheel-x, by + wr), radius: wr * 0.45, fill: _f(rgb("#9E9E9E"), bw), stroke: if bw { black + 0.5pt } else { none })
  // Front wheel
  circle((front-wheel-x, by + wr), radius: wr, fill: _f(rgb("#212121"), bw), stroke: _s(rgb("#111111"), bw) + 0.5pt)
  circle((front-wheel-x, by + wr), radius: wr * 0.45, fill: _f(rgb("#9E9E9E"), bw), stroke: if bw { black + 0.5pt } else { none })
}

/// Draw a cable car / gondola on a cable
/// - top-left (array): (x, y) left cable anchor point
/// - top-right (array): (x, y) right cable anchor point
/// - position (float): 0-1, where the cabin sits on the cable
/// - cabin-size (float): size of the cabin
/// - cable-color (color): color of the cable line
/// - cabin-color (color): color of the cabin
#let scene-cable-car(
  top-left,
  top-right,
  position: 0.5,
  cabin-size: 0.4,
  cable-color: auto,
  cabin-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let cc = if cable-color == auto { rgb("#37474F") } else { cable-color }
  let fc = if cabin-color == auto { rgb("#F44336") } else { cabin-color }
  let lx = top-left.at(0)
  let ly = top-left.at(1)
  let rx = top-right.at(0)
  let ry = top-right.at(1)
  let t = position
  let sz = cabin-size

  // Cable line (slight sag)
  let sag = 0.15 * calc.abs(rx - lx)
  let n = 20
  let pts = ()
  for i in range(n + 1) {
    let p = i / n
    let px = lx + (rx - lx) * p
    let py = ly + (ry - ly) * p - sag * calc.sin(p * 180deg)
    pts.push((px, py))
  }
  line(..pts, stroke: _s(cc, bw) + 1.5pt)

  // Cable anchor points (small circles)
  circle(top-left, radius: 0.04, fill: _f(cc, bw), stroke: if bw { black + 0.5pt } else { none })
  circle(top-right, radius: 0.04, fill: _f(cc, bw), stroke: if bw { black + 0.5pt } else { none })

  // Cabin position on cable
  let cab-x = lx + (rx - lx) * t
  let cab-y = ly + (ry - ly) * t - sag * calc.sin(t * 180deg)

  // Hanger / grip mechanism
  let grip-y = cab-y
  let cabin-top-y = grip-y - sz * 0.15
  rect(
    (cab-x - sz * 0.06, grip-y - sz * 0.05),
    (cab-x + sz * 0.06, grip-y + sz * 0.05),
    fill: _f(rgb("#455A64"), bw), stroke: _s(cc, bw) + 0.5pt,
  )

  // Vertical hanger bar
  line((cab-x, cabin-top-y), (cab-x, grip-y - sz * 0.05), stroke: _s(cc, bw) + 1pt)

  // Cabin body
  let cw = sz * 0.5
  let ch = sz * 0.55
  let cabin-bottom = cabin-top-y - ch
  rect(
    (cab-x - cw / 2, cabin-bottom),
    (cab-x + cw / 2, cabin-top-y),
    fill: _f(fc, bw), stroke: _s(fc.darken(20%), bw) + 0.8pt,
  )

  // Cabin windows
  let win-y-top = cabin-top-y - ch * 0.15
  let win-y-bot = cabin-top-y - ch * 0.6
  rect(
    (cab-x - cw / 2 + sz * 0.04, win-y-bot),
    (cab-x + cw / 2 - sz * 0.04, win-y-top),
    fill: _f(scene-theme.window, bw), stroke: _s(fc.darken(20%), bw) + 0.4pt,
  )

  // Cabin roof (slightly wider)
  rect(
    (cab-x - cw / 2 - sz * 0.03, cabin-top-y),
    (cab-x + cw / 2 + sz * 0.03, cabin-top-y + sz * 0.06),
    fill: _f(fc.darken(25%), bw), stroke: none,
  )

  // Cabin floor (slightly wider)
  rect(
    (cab-x - cw / 2 - sz * 0.02, cabin-bottom - sz * 0.04),
    (cab-x + cw / 2 + sz * 0.02, cabin-bottom),
    fill: _f(fc.darken(30%), bw), stroke: none,
  )
}

/// Draw a parachute with person dangling below
/// - center (array): (x, y) center of the canopy
/// - size (float): overall scale
/// - bg (color): canopy color
/// - person-color (color): color of the stick figure
#let scene-parachute(
  center,
  size: 0.6,
  bg: auto,
  person-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#FF7043") } else { bg }
  let pc = if person-color == auto { scene-theme.person } else { person-color }
  let cx = center.at(0)
  let cy = center.at(1)
  let sz = size

  // Canopy (dome / half-circle, approximated with polygon points)
  let canopy-pts = ()
  let n = 12
  for i in range(n + 1) {
    let angle = 180deg * i / n
    let px = cx + sz * 0.5 * calc.cos(angle)
    let py = cy + sz * 0.35 * calc.sin(angle)
    canopy-pts.push((px, py))
  }
  line(..canopy-pts, close: true, fill: _f(f, bw), stroke: _s(f.darken(15%), bw) + 0.8pt)

  // Canopy stripes (radial lines for detail)
  for i in range(1, n) {
    if calc.rem(i, 2) == 0 {
      let angle = 180deg * i / n
      let px = cx + sz * 0.5 * calc.cos(angle)
      let py = cy + sz * 0.35 * calc.sin(angle)
      line((cx, cy + sz * 0.1), (px, py), stroke: _s(f.darken(20%), bw) + 0.3pt)
    }
  }

  // Canopy vent (small circle at top)
  circle((cx, cy + sz * 0.33), radius: sz * 0.04, fill: _f(f.darken(10%), bw), stroke: if bw { black + 0.5pt } else { none })

  // Strings from canopy edge to person
  let person-y = cy - sz * 0.7
  // Left string
  line((cx - sz * 0.5, cy), (cx, person-y + sz * 0.15), stroke: _s(scene-theme.rope, bw) + 0.4pt)
  // Right string
  line((cx + sz * 0.5, cy), (cx, person-y + sz * 0.15), stroke: _s(scene-theme.rope, bw) + 0.4pt)
  // Middle strings
  line((cx - sz * 0.3, cy + sz * 0.2), (cx, person-y + sz * 0.15), stroke: _s(scene-theme.rope, bw) + 0.3pt)
  line((cx + sz * 0.3, cy + sz * 0.2), (cx, person-y + sz * 0.15), stroke: _s(scene-theme.rope, bw) + 0.3pt)

  // Stick figure hanging below
  let ph = sz * 0.35  // person height
  let pbx = cx
  let pby = person-y

  // Head
  circle((pbx, pby + ph), radius: ph * 0.12, fill: _f(pc, bw), stroke: if bw { black + 0.5pt } else { none })
  // Body
  line((pbx, pby + ph - ph * 0.12), (pbx, pby + ph * 0.35), stroke: _s(pc, bw) + 1pt)
  // Arms (reaching up to hold strings)
  line((pbx, pby + ph * 0.7), (pbx - sz * 0.08, pby + ph + sz * 0.05), stroke: _s(pc, bw) + 0.7pt)
  line((pbx, pby + ph * 0.7), (pbx + sz * 0.08, pby + ph + sz * 0.05), stroke: _s(pc, bw) + 0.7pt)
  // Legs (dangling)
  line((pbx, pby + ph * 0.35), (pbx - ph * 0.1, pby), stroke: _s(pc, bw) + 0.7pt)
  line((pbx, pby + ph * 0.35), (pbx + ph * 0.1, pby), stroke: _s(pc, bw) + 0.7pt)
}

/// Draw a rocket
/// - base (array): (x, y) bottom center of the rocket
/// - height (float): total height
/// - bg (color): body color
/// - line-color (color): stroke color
/// - flames (bool): whether to draw exhaust flames
#let scene-rocket(
  base,
  height: 1.0,
  bg: auto,
  line-color: auto,
  flames: true,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#ECEFF1") } else { bg }
  let s = if line-color == auto { rgb("#546E7A") } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)
  let h = height
  let bw-width = h * 0.12  // body half-width

  // Nose cone (pointed top)
  line(
    (bx, by + h),                    // tip
    (bx - bw-width, by + h * 0.75),        // left shoulder
    (bx + bw-width, by + h * 0.75),        // right shoulder
    close: true, fill: _f(rgb("#E53935"), bw), stroke: _s(s, bw) + 0.8pt,
  )

  // Cylindrical body (rectangle)
  rect(
    (bx - bw-width, by + h * 0.2),
    (bx + bw-width, by + h * 0.75),
    fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt,
  )

  // Body stripe / band
  rect(
    (bx - bw-width, by + h * 0.45),
    (bx + bw-width, by + h * 0.52),
    fill: _f(rgb("#1565C0"), bw), stroke: none,
  )

  // Porthole window
  circle((bx, by + h * 0.6), radius: bw-width * 0.4, fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.5pt)
  // Inner window shine
  circle((bx - bw-width * 0.1, by + h * 0.61), radius: bw-width * 0.12, fill: _f(white.transparentize(50%), bw), stroke: none)

  // Fins (left and right)
  // Left fin
  line(
    (bx - bw-width, by + h * 0.2),
    (bx - bw-width * 2.2, by),
    (bx - bw-width * 2.2, by + h * 0.05),
    (bx - bw-width, by + h * 0.3),
    close: true, fill: _f(rgb("#E53935"), bw), stroke: _s(s, bw) + 0.6pt,
  )
  // Right fin
  line(
    (bx + bw-width, by + h * 0.2),
    (bx + bw-width * 2.2, by),
    (bx + bw-width * 2.2, by + h * 0.05),
    (bx + bw-width, by + h * 0.3),
    close: true, fill: _f(rgb("#E53935"), bw), stroke: _s(s, bw) + 0.6pt,
  )

  // Nozzle
  line(
    (bx - bw-width * 0.7, by + h * 0.2),
    (bx - bw-width * 0.9, by),
    (bx + bw-width * 0.9, by),
    (bx + bw-width * 0.7, by + h * 0.2),
    close: true, fill: _f(rgb("#455A64"), bw), stroke: _s(s, bw) + 0.5pt,
  )

  // Exhaust flames
  if flames {
    // Outer flame (orange)
    line(
      (bx - bw-width * 0.6, by),
      (bx, by - h * 0.25),
      (bx + bw-width * 0.6, by),
      close: true, fill: _f(rgb("#FF9800"), bw), stroke: if bw { black + 0.5pt } else { none },
    )
    // Inner flame (yellow)
    line(
      (bx - bw-width * 0.35, by),
      (bx, by - h * 0.18),
      (bx + bw-width * 0.35, by),
      close: true, fill: _f(rgb("#FFEE58"), bw), stroke: if bw { black + 0.5pt } else { none },
    )
    // Core flame (white-hot)
    line(
      (bx - bw-width * 0.15, by),
      (bx, by - h * 0.1),
      (bx + bw-width * 0.15, by),
      close: true, fill: _f(white, bw), stroke: if bw { black + 0.5pt } else { none },
    )
  }
}

/// Draw a drone / quadcopter (side view)
/// - center (array): (x, y) center of the body
/// - size (float): overall scale
/// - bg (color): body color
#let scene-drone(
  center,
  size: 0.5,
  bg: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#37474F") } else { bg }
  let cx = center.at(0)
  let cy = center.at(1)
  let sz = size

  // Central body (rectangular box)
  rect(
    (cx - sz * 0.15, cy - sz * 0.08),
    (cx + sz * 0.15, cy + sz * 0.08),
    fill: _f(f, bw), stroke: _s(f.darken(20%), bw) + 0.8pt,
  )

  // Camera / sensor (small circle underneath)
  circle((cx, cy - sz * 0.12), radius: sz * 0.04, fill: _f(rgb("#212121"), bw), stroke: _s(rgb("#111"), bw) + 0.4pt)

  // LED indicator
  circle((cx, cy + sz * 0.06), radius: sz * 0.015, fill: _f(rgb("#4CAF50"), bw), stroke: if bw { black + 0.5pt } else { none })

  // Arms extending out (4 arms for quadcopter, shown as side view so 2 pairs)
  // Front-left arm
  line((cx - sz * 0.15, cy + sz * 0.04), (cx - sz * 0.45, cy + sz * 0.12), stroke: _s(f, bw) + 1.2pt)
  // Front-right arm
  line((cx + sz * 0.15, cy + sz * 0.04), (cx + sz * 0.45, cy + sz * 0.12), stroke: _s(f, bw) + 1.2pt)
  // Back-left arm (slightly lower for perspective)
  line((cx - sz * 0.12, cy - sz * 0.02), (cx - sz * 0.38, cy + sz * 0.04), stroke: _s(f.lighten(20%), bw) + 0.8pt)
  // Back-right arm
  line((cx + sz * 0.12, cy - sz * 0.02), (cx + sz * 0.38, cy + sz * 0.04), stroke: _s(f.lighten(20%), bw) + 0.8pt)

  // Propeller circles at arm tips (front, larger)
  circle((cx - sz * 0.45, cy + sz * 0.12), radius: sz * 0.08, fill: none, stroke: _s(rgb("#90A4AE"), bw) + 0.6pt)
  circle((cx + sz * 0.45, cy + sz * 0.12), radius: sz * 0.08, fill: none, stroke: _s(rgb("#90A4AE"), bw) + 0.6pt)
  // Propeller circles (back, slightly smaller for perspective)
  circle((cx - sz * 0.38, cy + sz * 0.04), radius: sz * 0.065, fill: none, stroke: _s(rgb("#90A4AE"), bw) + 0.5pt)
  circle((cx + sz * 0.38, cy + sz * 0.04), radius: sz * 0.065, fill: none, stroke: _s(rgb("#90A4AE"), bw) + 0.5pt)

  // Motor hubs (small filled circles at arm ends)
  circle((cx - sz * 0.45, cy + sz * 0.12), radius: sz * 0.025, fill: _f(f, bw), stroke: if bw { black + 0.5pt } else { none })
  circle((cx + sz * 0.45, cy + sz * 0.12), radius: sz * 0.025, fill: _f(f, bw), stroke: if bw { black + 0.5pt } else { none })
  circle((cx - sz * 0.38, cy + sz * 0.04), radius: sz * 0.02, fill: _f(f.lighten(15%), bw), stroke: if bw { black + 0.5pt } else { none })
  circle((cx + sz * 0.38, cy + sz * 0.04), radius: sz * 0.02, fill: _f(f.lighten(15%), bw), stroke: if bw { black + 0.5pt } else { none })

  // Landing legs (small stubs underneath body)
  line((cx - sz * 0.1, cy - sz * 0.08), (cx - sz * 0.12, cy - sz * 0.16), stroke: _s(f, bw) + 0.8pt)
  line((cx + sz * 0.1, cy - sz * 0.08), (cx + sz * 0.12, cy - sz * 0.16), stroke: _s(f, bw) + 0.8pt)
  // Landing feet
  line((cx - sz * 0.16, cy - sz * 0.16), (cx - sz * 0.08, cy - sz * 0.16), stroke: _s(f, bw) + 0.8pt)
  line((cx + sz * 0.08, cy - sz * 0.16), (cx + sz * 0.16, cy - sz * 0.16), stroke: _s(f, bw) + 0.8pt)
}
