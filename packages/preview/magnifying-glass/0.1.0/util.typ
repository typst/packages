// SPDX-FileCopyrightText: Copyright (C) 2025 Andrew Voynov
//
// SPDX-License-Identifier: AGPL-3.0-only

#import calc: sqrt, pow

/// Convert value to unit of measurement, if necessary.
#let apply-unit(value, unit: 1cm) = {
  if type(value) not in (relative, ratio, length) { value *= unit }
  value.to-absolute()
}

/// Convert (x, y) to (width: x * scale, height: y * scale).
#let wh(coords, scale: 100%) = {
  let scaled-coords = coords.map(v => v * scale)
  ("width", "height").zip(scaled-coords).map(((k, v)) => ((k): v)).join()
}

/// Convert (x, y) to (dx: x, dy: -y). If inverse == true, swap the signs.
#let dxy(coords, inverse: false) = {
  let mods = if inverse { (-1, 1) } else { (1, -1) }
  let norm-xy = coords.zip(mods).map(v => v.fold(1, (acc, v) => acc * v))
  ("dx", "dy").zip(norm-xy).map(((k, v)) => ((k): v)).join()
}

// Normalize a 2D vector
#let normalize(dx, dy) = {
  let len = calc.sqrt(dx.pt() * dx.pt() + dy.pt() * dy.pt())
  (dx / len, dy / len)
}

#let sign(value) = if value > 0pt { 1 } else if value < 0pt { -1 } else { 0 }

// Calculate point on rectangle perimeter along line between two centers.
#let boundary-point(x, y, w, h, vx, vy) = {
  let cx = x + w / 2
  let cy = y + h / 2

  // Handle horizontal or vertical lines.
  if vx == 0pt {
    return (cx, cy + (h / 2) * sign(vy))
  } else if vy == 0pt {
    return (cx + (w / 2) * sign(vx), cy)
  }

  let x-scale = (w / 2) / calc.abs(vx)
  let y-scale = (h / 2) / calc.abs(vy)
  let scale = calc.min(x-scale, y-scale)
  (cx + vx * scale, cy + vy * scale)
}

#let line-coords-between-circles((x1, y1), r1, (x2, y2), r2) = {
  let dx = x2 - x1
  let dy = y2 - y1
  let distance = sqrt(pow(dx.pt(), 2) + pow(dy.pt(), 2))
  if distance == 0pt { return ((x1, y1), (x1, y1)) }
  let nx = dx.pt() / distance
  let ny = dy.pt() / distance
  let p1 = (x1 + nx * r1, y1 + ny * r1)
  let p2 = (x2 - nx * r2, y2 - ny * r2)
  (p1, p2)
}

#let line-coords-between-rects((x1, y1), (w1, h1), (x2, y2), (w2, h2)) = {
  let (cx1, cy1) = (x1 + w1 / 2, y1 + h1 / 2)
  let (cx2, cy2) = (x2 + w2 / 2, y2 + h2 / 2)
  // Normalized direction vector from rectangle 1 to rectangle 2.
  let (vx, vy) = (cx2 - cx1, cy2 - cy1)
  let length = sqrt(pow(vx.pt(), 2) + pow(vy.pt(), 2))
  let (vx, vy) = (vx / length, vy / length)
  let p1 = boundary-point(x1, y1, w1, h1, vx, vy)
  let p2 = boundary-point(x2, y2, w2, h2, -vx, -vy)
  (p1, p2)
}

#let circles-overlapping((x1, y1), radius1, (x2, y2), radius2) = {
  let distance-sq = pow((x2 - x1).pt(), 2) + pow((y2 - y1).pt(), 2)
  distance-sq <= pow((radius1 + radius2).pt(), 2)
}

#let rects-overlapping((x1, y1), (w1, h1), (x2, y2), (w2, h2)) = {
  not (x1 + w1 < x2 or x2 + w2 < x1 or y1 + h1 < y2 or y2 + h2 < y1)
}
