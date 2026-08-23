#import "@preview/cetz:0.5.0"
#import cetz.draw: *
#import "surfaces.typ": *
#import "rings.typ": *

#let add-surface(name, color: blue) = {
  let f = surfaces.at(name, default: none)
  if f != none { f() } else { generic-surface(color: color) }
}

#let add-label(position, radius, name) = {
  if name != "" {
    content(
      (position.at(0), position.at(1) - radius - 0.3),
      align(center, text(name, fill: white, size: 7pt)),
      anchor: "north",
    )
  }
}

// ── Phase stubs ───────────────────────────────────────────────────────────────

#let add-surface-phase(phase) = {
  let shadow = black.transparentize(40%)
  let r2 = calc.sqrt(2)

  // Four canonical shapes, all with shadow on the left, rotated into position.
  let _draw(type, rot) = {
    group({
      rotate(rot)
      if type == "new" {
        circle((0, 0), radius: 1, fill: shadow, stroke: none)
      } else if type == "half" {
        arc((0, 1), start: 90deg, stop: 270deg, radius: 1, mode: "CLOSE", fill: shadow, stroke: none)
      } else if type == "crescent" {
        // Left semicircle + right-curving terminator (center (-1,0), radius √2)
        merge-path(close: true, fill: shadow, stroke: none, {
          arc((0, 1), start: 90deg, stop: 270deg, radius: 1)
          arc((0, -1), start: -45deg, stop: 45deg, radius: r2)
        })
      } else if type == "gibbous" {
        // Left semicircle + left-curving terminator CW (center (1,0), radius √2)
        merge-path(close: true, fill: shadow, stroke: none, {
          arc((0, 1), start: 90deg, stop: 270deg, radius: 1)
          arc((0, -1), start: 225deg, stop: 135deg, radius: r2)
        })
      }
    })
  }

  let phases = (
    "new": ("new", 0deg),
    "first half": ("half", 0deg),
    "last half": ("half", 180deg),
    "first crescent": ("crescent", 0deg),
    "last crescent": ("crescent", 180deg),
    "waxing gibbous": ("gibbous", 0deg),
    "waning gibbous": ("gibbous", 180deg),
    "top half": ("half", 90deg),
    "bottom half": ("half", -90deg),
  )

  let config = phases.at(phase, default: none)
  if config != none { _draw(config.at(0), config.at(1)) }
  // "full": no shadow
}

#let add-ring-phase(phase) = {
  let shadow = black.transparentize(40%)
  // semi-axes of the outer and inner ring ellipses — must match rings.typ
  let ro = (2.3, 0.23)
  let ri = (1.3, 0.13)

  // Point on an ellipse at angle a
  let ep(r, a) = (r.at(0) * calc.cos(a), r.at(1) * calc.sin(a))

  // Terminator x on the ring plane for crescent/gibbous phases (|x| = √2 − 1)
  let x_t = calc.sqrt(2) - 1

  // Angles on the LOWER half (180°–360°) of each ellipse where x = ±x_t.
  // Lower-half angle = 360° − arccos(x/r_x)  (calc.acos returns angle type)
  let outer_pos = 360deg - calc.acos(x_t / ro.at(0)) // ≈ 284° (x = +x_t)
  let outer_neg = 360deg - calc.acos(-x_t / ro.at(0)) // ≈ 256° (x = -x_t)
  let inner_pos = 360deg - calc.acos(x_t / ri.at(0)) // ≈ 289° (x = +x_t)
  let inner_neg = 360deg - calc.acos(-x_t / ri.at(0)) // ≈ 251° (x = -x_t)

  // Draw shadow annular sector on front ring from angle a to b (both in [180°, 360°], a < b).
  // When b = 360°, normalise inner arc start to 0° to keep the CW sweep unambiguous.
  let sector(a, b) = {
    let p_o_a = ep(ro, a)
    let p_i_a = ep(ri, a)
    let p_o_b = ep(ro, b)
    let p_i_b = ep(ri, b)
    let (b_s, a_s) = if b >= 360deg { (0deg, a - 360deg) } else { (b, a) }
    merge-path(close: true, fill: shadow, stroke: none, {
      arc(p_o_a, start: a, stop: b, radius: ro) // outer CCW
      line(p_o_b, p_i_b)
      arc(p_i_b, start: b_s, stop: a_s, radius: ri) // inner CW
      line(p_i_a, p_o_a)
    })
  }

  let angles = (
    "new": (180deg, 360deg),
    "first half": (180deg, 270deg),
    "last half": (270deg, 360deg),
    "first crescent": (180deg, outer_pos),
    "last crescent": (outer_neg, 360deg),
    "waxing gibbous": (180deg, outer_neg),
    "waning gibbous": (outer_pos, 360deg),
    // "full" and "top half" absent → no shadow
  )

  let ab = angles.at(phase, default: none)
  if ab != none { sector(ab.at(0), ab.at(1)) }
}


// ── Main planet function ──────────────────────────────────────────────────────

#let planet(
  center: (0, 0),
  radius: 1,
  surface: none,
  tilt: 0, // axial tilt in degrees
  phase: "full",
  rings: false, // full Saturn-style ring system
  ring: none, // single thin ring at given semi-major axis
  ring-color: luma(22%), // color for thin ring (Uranus/Neptune style)
  color: blue,
  name: "",
) = {
  group({
    translate(center)
    scale(radius)

    // Back halves of rings (drawn first, appear behind the planet)
    if rings {
      group({
        rotate(tilt * 1deg)
        add-rings-back()
      })
    }
    if ring != none {
      group({
        rotate(tilt * 1deg)
        add-thin-ring-back(ring, color: ring-color)
      })
    }

    // Planet surface
    group({
      rotate(tilt * 1deg)
      add-surface(surface, color: color)
    })
    add-surface-phase(phase)

    // Front halves of rings (drawn last, appear in front of the planet)
    if rings {
      group({
        rotate(tilt * 1deg)
        add-rings-front()
        add-ring-phase(phase)
      })
    }
    if ring != none {
      group({
        rotate(tilt * 1deg)
        add-thin-ring-front(ring, color: ring-color)
      })
    }
  })
  add-label(center, radius, name)
}

