// lunapark.typ — Luna Park / amusement park scene elements
// Ferris wheel, roller coaster, carousel, bumper cars, etc.

#import "@preview/cetz:0.5.2"
#import "theme.typ": scene-theme, _f, _s

/// Draw a Ferris wheel
/// - base (array): (x, y) center of the wheel axle
/// - radius (float): wheel radius
/// - cabins (int): number of cabins
/// - rotation (angle): rotation offset of the wheel
/// - color (color): wheel structure color
/// - cabin-colors (array): colors for cabins (cycles)
#let scene-ferris-wheel(
  base,
  radius: 2.0,
  cabins: 8,
  rotation: 0deg,
  color: auto,
  cabin-colors: auto,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#757575") } else { color }
  let cc = if cabin-colors == auto {
    (rgb("#E53935"), rgb("#1E88E5"), rgb("#43A047"), rgb("#FFB300"), rgb("#8E24AA"), rgb("#F4511E"))
  } else { cabin-colors }
  let cx = base.at(0)
  let cy = base.at(1)
  let r = radius

  // Support structure (A-frame legs)
  line((cx - r * 0.4, cy - r), (cx, cy), stroke: _s(c, bw) + 2pt)
  line((cx + r * 0.4, cy - r), (cx, cy), stroke: _s(c, bw) + 2pt)
  // Cross brace
  line((cx - r * 0.2, cy - r * 0.5), (cx + r * 0.2, cy - r * 0.5), stroke: _s(c, bw) + 1pt)

  // Outer rim
  circle(base, radius: r, fill: none, stroke: _s(c, bw) + 1.5pt)

  // Inner rim
  circle(base, radius: r * 0.15, fill: _f(c, bw), stroke: _s(c, bw) + 1pt)

  // Spokes and cabins
  for i in range(cabins) {
    let angle = rotation + i * (360deg / cabins)
    let spoke-end-x = cx + r * calc.cos(angle)
    let spoke-end-y = cy + r * calc.sin(angle)

    // Spoke
    line(base, (spoke-end-x, spoke-end-y), stroke: _s(c, bw) + 0.8pt)

    // Cabin (small rectangle hanging from rim)
    let cabin-color = cc.at(calc.rem(i, cc.len()))
    let cw = r * 0.12
    let ch = r * 0.1
    // Cabin hangs below the rim point
    let cabin-cx = spoke-end-x
    let cabin-cy = spoke-end-y - ch
    rect(
      (cabin-cx - cw / 2, cabin-cy - ch / 2),
      (cabin-cx + cw / 2, cabin-cy + ch / 2),
      fill: _f(cabin-color, bw), stroke: _s(cabin-color.darken(20%), bw) + 0.5pt,
    )
    // Hanger line
    line((spoke-end-x, spoke-end-y), (cabin-cx, cabin-cy + ch / 2), stroke: _s(c, bw) + 0.4pt)
  }
}

/// Draw a roller coaster track section
/// - points (array): array of (x, y) control points for the track
/// - color (color): track color
/// - rail-width (float): visual width between rails
#let scene-roller-coaster(
  points,
  color: auto,
  rail-width: 0.08,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#D32F2F") } else { color }

  // Draw the main track
  line(..points, stroke: _s(c, bw) + 2pt)

  // Draw support columns from each point to ground
  for pt in points {
    let px = pt.at(0)
    let py = pt.at(1)
    if py > 0 {
      line((px, 0), (px, py), stroke: _s(rgb("#757575"), bw) + 1pt)
    }
  }

  // Cross ties between supports
  for i in range(points.len() - 1) {
    let p1 = points.at(i)
    let p2 = points.at(i + 1)
    let mid-x = (p1.at(0) + p2.at(0)) / 2
    let mid-y = (p1.at(1) + p2.at(1)) / 2
    if mid-y > 0.2 {
      line((mid-x, 0), (mid-x, mid-y - 0.1), stroke: _s(rgb("#757575"), bw) + 0.5pt)
    }
  }
}

/// Draw a roller coaster cart on the track
/// - position (array): (x, y) center of the cart
/// - angle (angle): tilt angle of the cart (matching track slope)
/// - size (float): cart size
/// - color (color): cart color
#let scene-roller-cart(
  position,
  angle: 0deg,
  size: 0.3,
  color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#FFB300") } else { color }
  let px = position.at(0)
  let py = position.at(1)
  let s = size

  // Cart body
  let hw = s * 0.5
  let hh = s * 0.3
  // Simple rectangle (not rotated for simplicity)
  rect(
    (px - hw, py), (px + hw, py + hh),
    fill: _f(c, bw), stroke: _s(c.darken(20%), bw) + 0.8pt,
  )
  // Wheels
  circle((px - hw * 0.5, py - s * 0.05), radius: s * 0.08, fill: _f(rgb("#333"), bw), stroke: none)
  circle((px + hw * 0.5, py - s * 0.05), radius: s * 0.08, fill: _f(rgb("#333"), bw), stroke: none)

  // Passengers (stick figures in cart)
  for dx in (-hw * 0.3, hw * 0.3) {
    circle((px + dx, py + hh + s * 0.12), radius: s * 0.06, fill: _f(rgb("#333"), bw), stroke: none)
    line((px + dx, py + hh + s * 0.06), (px + dx, py + hh * 0.5), stroke: 0.6pt)
  }
}

/// Draw a carousel / merry-go-round
/// - base (array): (x, y) center bottom
/// - radius (float): carousel radius
/// - height (float): pole height
/// - horses (int): number of horses
/// - color (color): canopy color
#let scene-carousel(
  base,
  radius: 1.0,
  height: 1.5,
  horses: 6,
  color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#E91E63") } else { color }
  let bx = base.at(0)
  let by = base.at(1)
  let r = radius
  let h = height

  // Platform (ellipse approximated as flat rect)
  rect((bx - r, by), (bx + r, by + 0.1), fill: _f(rgb("#8D6E63"), bw), stroke: _s(rgb("#5D4037"), bw) + 0.8pt)

  // Center pole
  line((bx, by + 0.1), (bx, by + h), stroke: _s(rgb("#FFD600"), bw) + 2pt)

  // Conical canopy
  line(
    (bx - r * 1.1, by + h * 0.7),
    (bx, by + h),
    (bx + r * 1.1, by + h * 0.7),
    close: false, stroke: _s(c, bw) + 1.5pt,
  )
  // Fill the canopy
  line(
    (bx - r * 1.1, by + h * 0.7),
    (bx, by + h),
    (bx + r * 1.1, by + h * 0.7),
    close: true, fill: _f(c.lighten(30%), bw), stroke: none,
  )

  // Canopy scallops (decorative edge)
  let scallops = 8
  for i in range(scallops + 1) {
    let t = i / scallops
    let sx = bx - r * 1.1 + 2 * r * 1.1 * t
    let sy = by + h * 0.7
    if calc.rem(i, 2) == 0 {
      circle((sx, sy), radius: 0.06, fill: _f(rgb("#FFD600"), bw), stroke: none)
    }
  }

  // Horses on poles (simplified)
  let visible-horses = calc.min(horses, 5)  // only show front-facing ones
  for i in range(visible-horses) {
    let t = (i + 0.5) / visible-horses
    let hx = bx - r * 0.8 + r * 1.6 * t
    let pole-y = by + h * 0.35
    let horse-y = by + 0.2

    // Pole
    line((hx, horse-y), (hx, pole-y), stroke: _s(rgb("#FFD600"), bw) + 0.8pt)

    // Simple horse shape (rectangle body + triangle head)
    let hs = 0.12
    rect((hx - hs, horse-y), (hx + hs, horse-y + hs * 1.3),
      fill: _f(rgb("#F5DEB3"), bw), stroke: _s(rgb("#8D6E63"), bw) + 0.5pt)
    // Head
    line(
      (hx + hs, horse-y + hs * 1.3),
      (hx + hs * 1.5, horse-y + hs * 1.6),
      (hx + hs, horse-y + hs * 0.8),
      close: true, fill: _f(rgb("#F5DEB3"), bw), stroke: _s(rgb("#8D6E63"), bw) + 0.4pt,
    )
    // Legs
    line((hx - hs * 0.5, horse-y), (hx - hs * 0.5, horse-y - hs * 0.5), stroke: _s(rgb("#8D6E63"), bw) + 0.6pt)
    line((hx + hs * 0.5, horse-y), (hx + hs * 0.5, horse-y - hs * 0.5), stroke: _s(rgb("#8D6E63"), bw) + 0.6pt)
  }

  // Decorative lights on edge
  for i in range(6) {
    let t = (i + 0.5) / 6
    let lx = bx - r * 0.9 + r * 1.8 * t
    circle((lx, by + 0.1), radius: 0.03, fill: _f(rgb("#FFD600"), bw), stroke: none)
  }
}

/// Draw a swing ride / chair swing
/// - base (array): (x, y) center base
/// - height (float): total height of the ride
/// - radius (float): swing radius
/// - swings (int): number of swings visible
/// - color (color): structure color
#let scene-swing-ride(
  base,
  height: 2.5,
  radius: 1.5,
  swings: 6,
  color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#FF6F00") } else { color }
  let bx = base.at(0)
  let by = base.at(1)
  let h = height
  let r = radius

  // Central column
  line((bx, by), (bx, by + h), stroke: _s(c, bw) + 2.5pt)

  // Top disc (flat line)
  line((bx - r * 0.3, by + h), (bx + r * 0.3, by + h), stroke: _s(c, bw) + 3pt)

  // Canopy cone
  line(
    (bx - r * 0.5, by + h - 0.1),
    (bx, by + h + 0.2),
    (bx + r * 0.5, by + h - 0.1),
    close: true, fill: _f(c.lighten(30%), bw), stroke: _s(c, bw) + 0.8pt,
  )

  // Swings (chains + seats)
  for i in range(swings) {
    let t = (i + 0.5) / swings
    // Distribute swings across the diameter
    let swing-x = bx - r + 2 * r * t
    // Chain angle (swings fly outward)
    let chain-top-x = bx + (swing-x - bx) * 0.3
    let chain-top-y = by + h

    // Chain
    line((chain-top-x, chain-top-y), (swing-x, by + h * 0.5), stroke: _s(rgb("#757575"), bw) + 0.5pt)

    // Seat
    line(
      (swing-x - 0.06, by + h * 0.5),
      (swing-x + 0.06, by + h * 0.5),
      stroke: _s(rgb("#333"), bw) + 1.5pt,
    )

    // Tiny person
    circle((swing-x, by + h * 0.5 + 0.15), radius: 0.04, fill: _f(rgb("#333"), bw), stroke: none)
    line((swing-x, by + h * 0.5 + 0.11), (swing-x, by + h * 0.5 + 0.02), stroke: 0.5pt)
  }
}

/// Draw a ticket booth / entrance gate
/// - base (array): (x, y) base position
/// - width (float): booth width
/// - height (float): booth height
/// - color (color): booth color
#let scene-ticket-booth(
  base,
  width: 1.0,
  height: 1.5,
  color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#F44336") } else { color }
  let bx = base.at(0)
  let by = base.at(1)
  let w = width
  let h = height

  // Booth body
  rect((bx, by), (bx + w, by + h), fill: _f(c, bw), stroke: _s(c.darken(20%), bw) + 0.8pt)

  // Window
  let win-w = w * 0.5
  let win-h = h * 0.25
  let win-x = bx + w / 2 - win-w / 2
  let win-y = by + h * 0.5
  rect((win-x, win-y), (win-x + win-w, win-y + win-h), fill: _f(rgb("#BBDEFB"), bw), stroke: _s(c.darken(20%), bw) + 0.5pt)

  // Striped awning
  let aw-h = h * 0.15
  for i in range(5) {
    let t = i / 5
    let stripe-x = bx + w * t
    let stripe-w = w / 5
    let stripe-color = if calc.rem(i, 2) == 0 { c } else { white }
    rect((stripe-x, by + h), (stripe-x + stripe-w, by + h + aw-h), fill: _f(stripe-color, bw), stroke: none)
  }
  rect((bx, by + h), (bx + w, by + h + aw-h), fill: none, stroke: _s(c.darken(20%), bw) + 0.5pt)

  // "TICKETS" sign
  content((bx + w / 2, by + h + aw-h + 0.15), text(size: 6pt, weight: "bold", fill: c, [TICKETS]))
}

/// Draw a balloon (decorative, like party balloon on a string)
/// - base (array): (x, y) where the string is held
/// - height (float): string length
/// - color (color): balloon color
#let scene-party-balloon(
  base,
  height: 0.8,
  color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#E91E63") } else { color }
  let bx = base.at(0)
  let by = base.at(1)
  let h = height

  // String (slightly wavy)
  line(
    (bx, by),
    (bx + 0.03, by + h * 0.3),
    (bx - 0.02, by + h * 0.6),
    (bx, by + h * 0.85),
    stroke: _s(rgb("#555"), bw) + 0.4pt,
  )

  // Balloon (oval)
  let br = h * 0.15
  circle((bx, by + h), radius: br, fill: _f(c, bw), stroke: _s(c.darken(15%), bw) + 0.6pt)
  // Shine
  circle((bx - br * 0.3, by + h + br * 0.25), radius: br * 0.15, fill: _f(white.transparentize(50%), bw), stroke: none)
  // Knot
  line((bx, by + h - br), (bx, by + h - br - 0.03), stroke: _s(c.darken(20%), bw) + 0.6pt)
}

/// Draw festive bunting / pennant flags
/// - left (array): (x, y) left attachment
/// - right (array): (x, y) right attachment
/// - flags (int): number of flags
/// - colors (array): flag colors (cycles)
/// - sag (float): how much the bunting sags in the middle
#let scene-bunting(
  left,
  right,
  flags: 8,
  colors: auto,
  sag: 0.3,
  bw: false,
) = {
  import cetz.draw: *

  let cc = if colors == auto {
    (rgb("#E53935"), rgb("#FFB300"), rgb("#43A047"), rgb("#1E88E5"), rgb("#8E24AA"))
  } else { colors }

  let lx = left.at(0)
  let ly = left.at(1)
  let rx = right.at(0)
  let ry = right.at(1)

  // Catenary-like string
  let pts = ()
  let n = flags * 2
  for i in range(n + 1) {
    let t = i / n
    let x = lx + (rx - lx) * t
    let y = ly + (ry - ly) * t - sag * calc.sin(t * 180deg)
    pts.push((x, y))
  }
  line(..pts, stroke: _s(rgb("#555"), bw) + 0.4pt)

  // Flags hanging from string
  for i in range(flags) {
    let t = (i + 0.5) / flags
    let fx = lx + (rx - lx) * t
    let fy = ly + (ry - ly) * t - sag * calc.sin(t * 180deg)
    let flag-c = cc.at(calc.rem(i, cc.len()))
    let fh = 0.12

    // Triangle pennant
    line(
      (fx - 0.04, fy),
      (fx, fy - fh),
      (fx + 0.04, fy),
      close: true, fill: _f(flag-c, bw), stroke: none,
    )
  }
}
