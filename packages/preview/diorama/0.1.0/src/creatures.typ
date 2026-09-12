// creatures.typ — scene-fish, scene-person
// + scene-bird, scene-dog, scene-butterfly, scene-crab

#import "@preview/cetz:0.5.2"
#import "theme.typ": scene-theme, _f, _s

/// Draw a fish
/// - center (array): (x, y) center position
/// - size (float): body radius
/// - color (color): fish color
/// - direction (float): 1 = facing right, -1 = facing left
#let scene-fish(
  center,
  size: 0.15,
  color: auto,
  direction: 1,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { scene-theme.fish-default } else { color }
  let cx = center.at(0)
  let cy = center.at(1)
  let s = size
  let d = direction

  // Body
  circle(center, radius: s, fill: _f(c, bw), stroke: none)

  // Tail
  line(
    (cx - s * d, cy),
    (cx - s * 2.2 * d, cy + s * 0.9),
    (cx - s * 2.2 * d, cy - s * 0.9),
    close: true, fill: _f(c, bw), stroke: none,
  )

  // Eye
  circle((cx + s * 0.4 * d, cy + s * 0.2), radius: s * 0.15, fill: white, stroke: none)
  circle((cx + s * 0.45 * d, cy + s * 0.22), radius: s * 0.07, fill: black, stroke: none)

}

/// Return anchor positions for a person figure (non-drawing helper).
/// Returns a dictionary with keys: head, eye, shoulder, hip, feet.
/// Each value is an (x, y) tuple.
#let scene-person-anchors(base, height: 0.6) = {
  let h = height
  let bx = base.at(0)
  let by = base.at(1)
  let head-r = h * 0.1
  let head-y = by + h - head-r
  let eye-y = head-y - head-r * 0.3
  let shoulder-y = by + h * 0.65
  let hip-y = by + h * 0.35
  (
    head: (bx, head-y),
    eye: (bx, eye-y),
    shoulder: (bx, shoulder-y),
    hip: (bx, hip-y),
    feet: (bx, by),
  )
}

/// Draw a person (stick figure or silhouette)
/// - base (array): (x, y) feet position
/// - height (float): total height
/// - color (color): person color
/// - variant (string): "standing", "pointing", "walking", "sitting", "measuring", "waving"
#let scene-person(
  base,
  height: 0.6,
  color: auto,
  variant: "standing",
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { scene-theme.person } else { color }
  let bx = base.at(0)
  let by = base.at(1)
  let h = height

  if variant == "sitting" {
    // Sitting variant: reduced total visual height, legs bent at 90 degrees
    // The person appears shorter because they are seated
    let sit-h = h * 0.7  // visible upper body height

    // Head
    let head-r = h * 0.1
    let head-y = by + sit-h - head-r
    circle((bx, head-y), radius: head-r, fill: _f(c, bw), stroke: none)

    // Body (torso, upright)
    let shoulder-y = by + sit-h * 0.7
    let hip-y = by + sit-h * 0.35
    line((bx, head-y - head-r), (bx, hip-y), stroke: _s(c, bw) + 1.2pt)

    // Arms (resting on lap / slightly forward)
    line((bx, shoulder-y), (bx - h * 0.12, hip-y - h * 0.02), stroke: _s(c, bw) + 0.8pt)
    line((bx, shoulder-y), (bx + h * 0.12, hip-y - h * 0.02), stroke: _s(c, bw) + 0.8pt)

    // Legs bent at 90 degrees (thighs horizontal, shins vertical going down)
    // Thigh extends forward
    let knee-x-l = bx - h * 0.12
    let knee-x-r = bx + h * 0.12
    let knee-y = hip-y
    // Thighs (horizontal)
    line((bx, hip-y), (knee-x-l, knee-y), stroke: _s(c, bw) + 0.8pt)
    line((bx, hip-y), (knee-x-r, knee-y), stroke: _s(c, bw) + 0.8pt)
    // Shins (vertical, going down to feet)
    line((knee-x-l, knee-y), (knee-x-l, by), stroke: _s(c, bw) + 0.8pt)
    line((knee-x-r, knee-y), (knee-x-r, by), stroke: _s(c, bw) + 0.8pt)

  } else if variant == "walking" {
    // Walking: legs apart (stride), arms swinging opposite to legs
    // Head
    let head-r = h * 0.1
    let head-y = by + h - head-r
    circle((bx, head-y), radius: head-r, fill: _f(c, bw), stroke: none)

    // Body
    let shoulder-y = by + h * 0.65
    let hip-y = by + h * 0.35
    line((bx, head-y - head-r), (bx, hip-y), stroke: _s(c, bw) + 1.2pt)

    // Arms (swinging: left forward, right back)
    line((bx, shoulder-y), (bx + h * 0.18, shoulder-y - h * 0.12), stroke: _s(c, bw) + 0.8pt)
    line((bx, shoulder-y), (bx - h * 0.15, shoulder-y + h * 0.08), stroke: _s(c, bw) + 0.8pt)

    // Legs (stride position: one forward, one back)
    line((bx, hip-y), (bx - h * 0.18, by), stroke: _s(c, bw) + 0.8pt)
    line((bx, hip-y), (bx + h * 0.18, by), stroke: _s(c, bw) + 0.8pt)

  } else if variant == "measuring" {
    // Measuring: holding an instrument (like a sextant/theodolite) at eye level
    // Head
    let head-r = h * 0.1
    let head-y = by + h - head-r
    circle((bx, head-y), radius: head-r, fill: _f(c, bw), stroke: none)

    // Body
    let shoulder-y = by + h * 0.65
    let hip-y = by + h * 0.35
    line((bx, head-y - head-r), (bx, hip-y), stroke: _s(c, bw) + 1.2pt)

    // Arms (both reaching forward, holding instrument at eye level)
    let instrument-x = bx + h * 0.22
    let eye-y = head-y - head-r * 0.3
    // Upper arm + forearm
    line((bx, shoulder-y), (instrument-x, eye-y), stroke: _s(c, bw) + 0.8pt)
    // Second arm supporting
    line((bx, shoulder-y), (instrument-x - h * 0.05, eye-y - h * 0.03), stroke: _s(c, bw) + 0.8pt)

    // Instrument (small triangle / rectangle at eye level)
    line(
      (instrument-x, eye-y + h * 0.03),
      (instrument-x + h * 0.08, eye-y),
      (instrument-x, eye-y - h * 0.03),
      close: true, fill: _f(rgb("#455A64"), bw), stroke: _s(rgb("#263238"), bw) + 0.4pt,
    )

    // Legs (standing)
    line((bx, hip-y), (bx - h * 0.12, by), stroke: _s(c, bw) + 0.8pt)
    line((bx, hip-y), (bx + h * 0.12, by), stroke: _s(c, bw) + 0.8pt)

  } else if variant == "waving" {
    // Waving: one arm raised above head
    // Head
    let head-r = h * 0.1
    let head-y = by + h - head-r
    circle((bx, head-y), radius: head-r, fill: _f(c, bw), stroke: none)

    // Body
    let shoulder-y = by + h * 0.65
    let hip-y = by + h * 0.35
    line((bx, head-y - head-r), (bx, hip-y), stroke: _s(c, bw) + 1.2pt)

    // Arms
    // Left arm: normal, slightly away from body
    line((bx, shoulder-y), (bx - h * 0.15, hip-y + h * 0.05), stroke: _s(c, bw) + 0.8pt)
    // Right arm: raised above head, waving
    line((bx, shoulder-y), (bx + h * 0.12, head-y + head-r + h * 0.08), stroke: _s(c, bw) + 0.8pt)
    // Hand / wave motion (small angled segment at tip)
    line(
      (bx + h * 0.12, head-y + head-r + h * 0.08),
      (bx + h * 0.18, head-y + head-r + h * 0.12),
      stroke: _s(c, bw) + 0.8pt,
    )

    // Legs (standing)
    line((bx, hip-y), (bx - h * 0.12, by), stroke: _s(c, bw) + 0.8pt)
    line((bx, hip-y), (bx + h * 0.12, by), stroke: _s(c, bw) + 0.8pt)

  } else if variant == "pointing" {
    // Head
    let head-r = h * 0.1
    let head-y = by + h - head-r
    circle((bx, head-y), radius: head-r, fill: _f(c, bw), stroke: none)

    // Body
    let shoulder-y = by + h * 0.65
    let hip-y = by + h * 0.35
    line((bx, head-y - head-r), (bx, hip-y), stroke: _s(c, bw) + 1.2pt)

    // Left arm down, right arm pointing
    line((bx, shoulder-y), (bx - h * 0.15, hip-y + h * 0.05), stroke: _s(c, bw) + 0.8pt)
    line((bx, shoulder-y), (bx + h * 0.25, shoulder-y + h * 0.05), stroke: _s(c, bw) + 0.8pt)

    // Legs
    line((bx, hip-y), (bx - h * 0.12, by), stroke: _s(c, bw) + 0.8pt)
    line((bx, hip-y), (bx + h * 0.12, by), stroke: _s(c, bw) + 0.8pt)

  } else {
    // Standing (default): arms slightly apart
    // Head
    let head-r = h * 0.1
    let head-y = by + h - head-r
    circle((bx, head-y), radius: head-r, fill: _f(c, bw), stroke: none)

    // Body
    let shoulder-y = by + h * 0.65
    let hip-y = by + h * 0.35
    line((bx, head-y - head-r), (bx, hip-y), stroke: _s(c, bw) + 1.2pt)

    // Arms
    line((bx, shoulder-y), (bx - h * 0.15, hip-y + h * 0.05), stroke: _s(c, bw) + 0.8pt)
    line((bx, shoulder-y), (bx + h * 0.15, hip-y + h * 0.05), stroke: _s(c, bw) + 0.8pt)

    // Legs
    line((bx, hip-y), (bx - h * 0.12, by), stroke: _s(c, bw) + 0.8pt)
    line((bx, hip-y), (bx + h * 0.12, by), stroke: _s(c, bw) + 0.8pt)
  }

}

// ============================================================
// NEW CREATURES BELOW
// ============================================================

/// Draw a bird
/// - center (array): (x, y) center position
/// - size (float): overall scale
/// - bg (color): bird color
/// - variant (string): "flying" (M-shape arcs) or "perched" (small body on a branch)
#let scene-bird(
  center,
  size: 0.1,
  bg: auto,
  variant: "flying",
  bw: false,
) = {
  import cetz.draw: *

  let c = if bg == auto { rgb("#212121") } else { bg }
  let cx = center.at(0)
  let cy = center.at(1)
  let s = size

  if variant == "perched" {
    // Body (small oval shape)
    circle((cx, cy), radius: s * 0.7, fill: _f(c, bw), stroke: none)
    // Head (smaller circle, overlapping body)
    circle((cx + s * 0.55, cy + s * 0.35), radius: s * 0.4, fill: _f(c, bw), stroke: none)
    // Beak
    line(
      (cx + s * 0.85, cy + s * 0.4),
      (cx + s * 1.15, cy + s * 0.3),
      (cx + s * 0.85, cy + s * 0.25),
      close: true, fill: _f(rgb("#FF8F00"), bw), stroke: none,
    )
    // Eye
    circle((cx + s * 0.7, cy + s * 0.45), radius: s * 0.08, fill: white, stroke: none)
    circle((cx + s * 0.72, cy + s * 0.46), radius: s * 0.04, fill: black, stroke: none)
    // Tail feathers
    line(
      (cx - s * 0.6, cy + s * 0.1),
      (cx - s * 1.1, cy + s * 0.3),
      stroke: _s(c, bw) + 0.8pt,
    )
    line(
      (cx - s * 0.6, cy),
      (cx - s * 1.0, cy + s * 0.05),
      stroke: _s(c, bw) + 0.8pt,
    )
    // Legs
    line((cx - s * 0.15, cy - s * 0.7), (cx - s * 0.15, cy - s * 1.1), stroke: _s(c, bw) + 0.5pt)
    line((cx + s * 0.15, cy - s * 0.7), (cx + s * 0.15, cy - s * 1.1), stroke: _s(c, bw) + 0.5pt)
    // Feet (small horizontal lines)
    line((cx - s * 0.3, cy - s * 1.1), (cx, cy - s * 1.1), stroke: _s(c, bw) + 0.5pt)
    line((cx, cy - s * 1.1), (cx + s * 0.3, cy - s * 1.1), stroke: _s(c, bw) + 0.5pt)
  } else {
    // Flying (default): simplified M-shape / two arc-like wing strokes
    // Left wing (arc upward)
    line(
      (cx, cy),
      (cx - s * 0.6, cy + s * 0.8),
      (cx - s * 1.2, cy + s * 0.3),
      stroke: _s(c, bw) + 1pt,
    )
    // Right wing (arc upward)
    line(
      (cx, cy),
      (cx + s * 0.6, cy + s * 0.8),
      (cx + s * 1.2, cy + s * 0.3),
      stroke: _s(c, bw) + 1pt,
    )
    // Small body dot at center
    circle(center, radius: s * 0.15, fill: _f(c, bw), stroke: none)
  }
}

/// Draw a side-view dog
/// - base (array): (x, y) feet position (bottom center)
/// - size (float): overall scale
/// - bg (color): dog body color
/// - direction (int): 1 = facing right, -1 = facing left
#let scene-dog(
  base,
  size: 0.3,
  bg: auto,
  direction: 1,
  bw: false,
) = {
  import cetz.draw: *

  let c = if bg == auto { rgb("#8D6E63") } else { bg }
  let bx = base.at(0)
  let by = base.at(1)
  let s = size
  let d = if direction < 0 { -1 } else { 1 }

  // Body (rectangle)
  let body-bottom = by + s * 0.35
  let body-top = by + s * 0.7
  let body-left = bx - s * 0.4 * d
  let body-right = bx + s * 0.4 * d
  // Use line to draw body so direction works naturally
  line(
    (bx - s * 0.4, body-bottom),
    (bx - s * 0.4, body-top),
    (bx + s * 0.4, body-top),
    (bx + s * 0.4, body-bottom),
    close: true, fill: _f(c, bw), stroke: _s(c.darken(15%), bw) + 0.5pt,
  )

  // Head (circle, positioned at front)
  let head-x = bx + s * 0.45 * d
  let head-y = by + s * 0.75
  let head-r = s * 0.2
  circle((head-x, head-y), radius: head-r, fill: _f(c, bw), stroke: _s(c.darken(15%), bw) + 0.5pt)

  // Snout / muzzle (small bump forward)
  circle((head-x + s * 0.18 * d, head-y - s * 0.02), radius: head-r * 0.5, fill: _f(c.lighten(10%), bw), stroke: none)
  // Nose
  circle((head-x + s * 0.25 * d, head-y), radius: s * 0.03, fill: _f(rgb("#212121"), bw), stroke: none)

  // Eye
  circle((head-x + s * 0.08 * d, head-y + s * 0.07), radius: s * 0.035, fill: white, stroke: none)
  circle((head-x + s * 0.09 * d, head-y + s * 0.075), radius: s * 0.018, fill: black, stroke: none)

  // Ear (triangle, flopping down from top of head)
  line(
    (head-x - s * 0.05 * d, head-y + head-r * 0.8),
    (head-x + s * 0.05 * d, head-y + head-r),
    (head-x + s * 0.12 * d, head-y + head-r * 0.3),
    close: true, fill: _f(c.darken(20%), bw), stroke: none,
  )

  // Legs (4 stick legs)
  // Front legs
  line((bx + s * 0.25, body-bottom), (bx + s * 0.25, by), stroke: _s(c.darken(10%), bw) + 0.8pt)
  line((bx + s * 0.15, body-bottom), (bx + s * 0.15, by), stroke: _s(c.darken(10%), bw) + 0.8pt)
  // Back legs
  line((bx - s * 0.25, body-bottom), (bx - s * 0.25, by), stroke: _s(c.darken(10%), bw) + 0.8pt)
  line((bx - s * 0.15, body-bottom), (bx - s * 0.15, by), stroke: _s(c.darken(10%), bw) + 0.8pt)

  // Paws (small circles at foot position)
  circle((bx + s * 0.25, by), radius: s * 0.03, fill: _f(c.darken(10%), bw), stroke: none)
  circle((bx + s * 0.15, by), radius: s * 0.03, fill: _f(c.darken(10%), bw), stroke: none)
  circle((bx - s * 0.25, by), radius: s * 0.03, fill: _f(c.darken(10%), bw), stroke: none)
  circle((bx - s * 0.15, by), radius: s * 0.03, fill: _f(c.darken(10%), bw), stroke: none)

  // Tail (curved line from back of body, going up)
  let tail-base-x = bx - s * 0.4 * d
  line(
    (tail-base-x, body-top - s * 0.05),
    (tail-base-x - s * 0.15 * d, body-top + s * 0.15),
    (tail-base-x - s * 0.1 * d, body-top + s * 0.3),
    stroke: _s(c.darken(10%), bw) + 1pt,
  )
}

/// Draw a butterfly
/// - center (array): (x, y) center of the body
/// - size (float): overall scale
/// - color (color): wing color
#let scene-butterfly(
  center,
  size: 0.15,
  color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#CE93D8") } else { color }
  let cx = center.at(0)
  let cy = center.at(1)
  let s = size

  // Body (thin vertical line)
  line((cx, cy - s * 0.6), (cx, cy + s * 0.6), stroke: _s(rgb("#333333"), bw) + 0.8pt)

  // Head (small circle at top)
  circle((cx, cy + s * 0.7), radius: s * 0.12, fill: _f(rgb("#333333"), bw), stroke: none)

  // Antennae
  line((cx, cy + s * 0.7), (cx - s * 0.3, cy + s * 1.1), stroke: _s(rgb("#333333"), bw) + 0.4pt)
  line((cx, cy + s * 0.7), (cx + s * 0.3, cy + s * 1.1), stroke: _s(rgb("#333333"), bw) + 0.4pt)
  // Antenna tips
  circle((cx - s * 0.3, cy + s * 1.1), radius: s * 0.05, fill: _f(rgb("#333333"), bw), stroke: none)
  circle((cx + s * 0.3, cy + s * 1.1), radius: s * 0.05, fill: _f(rgb("#333333"), bw), stroke: none)

  // Upper wings (larger, elliptical shape approximated with polygon)
  // Left upper wing
  let lu-pts = ()
  for i in range(9) {
    let angle = 90deg + i * (180deg / 8)
    let px = cx - s * 0.7 * calc.cos(angle) - s * 0.5
    let py = cy + s * 0.5 * calc.sin(angle) + s * 0.15
    lu-pts.push((px, py))
  }
  line(..lu-pts, close: true, fill: _f(c, bw), stroke: _s(c.darken(20%), bw) + 0.4pt)

  // Right upper wing
  let ru-pts = ()
  for i in range(9) {
    let angle = -90deg + i * (180deg / 8)
    let px = cx + s * 0.7 * calc.cos(angle) + s * 0.5
    let py = cy + s * 0.5 * calc.sin(angle) + s * 0.15
    ru-pts.push((px, py))
  }
  line(..ru-pts, close: true, fill: _f(c, bw), stroke: _s(c.darken(20%), bw) + 0.4pt)

  // Lower wings (smaller)
  // Left lower wing
  let ll-pts = ()
  for i in range(9) {
    let angle = 90deg + i * (180deg / 8)
    let px = cx - s * 0.5 * calc.cos(angle) - s * 0.35
    let py = cy + s * 0.35 * calc.sin(angle) - s * 0.25
    ll-pts.push((px, py))
  }
  line(..ll-pts, close: true, fill: _f(c.lighten(15%), bw), stroke: _s(c.darken(15%), bw) + 0.3pt)

  // Right lower wing
  let rl-pts = ()
  for i in range(9) {
    let angle = -90deg + i * (180deg / 8)
    let px = cx + s * 0.5 * calc.cos(angle) + s * 0.35
    let py = cy + s * 0.35 * calc.sin(angle) - s * 0.25
    rl-pts.push((px, py))
  }
  line(..rl-pts, close: true, fill: _f(c.lighten(15%), bw), stroke: _s(c.darken(15%), bw) + 0.3pt)

  // Wing spots (decorative)
  circle((cx - s * 0.55, cy + s * 0.2), radius: s * 0.12, fill: _f(c.darken(30%), bw), stroke: none)
  circle((cx + s * 0.55, cy + s * 0.2), radius: s * 0.12, fill: _f(c.darken(30%), bw), stroke: none)
}

/// Draw a crab
/// - base (array): (x, y) bottom center position
/// - size (float): overall scale
/// - color (color): crab body color
#let scene-crab(
  base,
  size: 0.2,
  color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#E53935") } else { color }
  let bx = base.at(0)
  let by = base.at(1)
  let s = size

  // Body center (slightly above base)
  let body-y = by + s * 0.5

  // Body (oval shape approximated with a wider circle)
  // Horizontal oval using polygon points
  let body-pts = ()
  for i in range(13) {
    let angle = i * (360deg / 12)
    let px = bx + s * 0.6 * calc.cos(angle)
    let py = body-y + s * 0.35 * calc.sin(angle)
    body-pts.push((px, py))
  }
  line(..body-pts, close: true, fill: _f(c, bw), stroke: _s(c.darken(20%), bw) + 0.6pt)

  // Eyes (on stalks)
  // Left eye stalk
  line((bx - s * 0.2, body-y + s * 0.3), (bx - s * 0.3, body-y + s * 0.55), stroke: _s(c.darken(10%), bw) + 0.6pt)
  circle((bx - s * 0.3, body-y + s * 0.55), radius: s * 0.07, fill: white, stroke: _s(c.darken(20%), bw) + 0.3pt)
  circle((bx - s * 0.3, body-y + s * 0.56), radius: s * 0.035, fill: black, stroke: none)
  // Right eye stalk
  line((bx + s * 0.2, body-y + s * 0.3), (bx + s * 0.3, body-y + s * 0.55), stroke: _s(c.darken(10%), bw) + 0.6pt)
  circle((bx + s * 0.3, body-y + s * 0.55), radius: s * 0.07, fill: white, stroke: _s(c.darken(20%), bw) + 0.3pt)
  circle((bx + s * 0.3, body-y + s * 0.56), radius: s * 0.035, fill: black, stroke: none)

  // Claws (left and right)
  // Left claw arm
  line((bx - s * 0.55, body-y + s * 0.1), (bx - s * 0.85, body-y + s * 0.35), stroke: _s(c.darken(10%), bw) + 1pt)
  // Left claw pincers (V shape)
  line((bx - s * 0.85, body-y + s * 0.35), (bx - s * 1.05, body-y + s * 0.55), stroke: _s(c.darken(10%), bw) + 0.8pt)
  line((bx - s * 0.85, body-y + s * 0.35), (bx - s * 1.1, body-y + s * 0.3), stroke: _s(c.darken(10%), bw) + 0.8pt)

  // Right claw arm
  line((bx + s * 0.55, body-y + s * 0.1), (bx + s * 0.85, body-y + s * 0.35), stroke: _s(c.darken(10%), bw) + 1pt)
  // Right claw pincers
  line((bx + s * 0.85, body-y + s * 0.35), (bx + s * 1.05, body-y + s * 0.55), stroke: _s(c.darken(10%), bw) + 0.8pt)
  line((bx + s * 0.85, body-y + s * 0.35), (bx + s * 1.1, body-y + s * 0.3), stroke: _s(c.darken(10%), bw) + 0.8pt)

  // Legs (3 on each side, going outward and down)
  // Left legs
  line((bx - s * 0.5, body-y + s * 0.05), (bx - s * 0.8, by + s * 0.1), stroke: _s(c.darken(10%), bw) + 0.7pt)
  line((bx - s * 0.55, body-y - s * 0.1), (bx - s * 0.85, by), stroke: _s(c.darken(10%), bw) + 0.7pt)
  line((bx - s * 0.5, body-y - s * 0.2), (bx - s * 0.75, by - s * 0.05), stroke: _s(c.darken(10%), bw) + 0.7pt)

  // Right legs
  line((bx + s * 0.5, body-y + s * 0.05), (bx + s * 0.8, by + s * 0.1), stroke: _s(c.darken(10%), bw) + 0.7pt)
  line((bx + s * 0.55, body-y - s * 0.1), (bx + s * 0.85, by), stroke: _s(c.darken(10%), bw) + 0.7pt)
  line((bx + s * 0.5, body-y - s * 0.2), (bx + s * 0.75, by - s * 0.05), stroke: _s(c.darken(10%), bw) + 0.7pt)
}
