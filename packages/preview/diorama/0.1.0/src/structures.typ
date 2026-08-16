// structures.typ — wall, ladder, house, building, box, pole, bridge, tower, lighthouse, flag-pole, shadow
// + fence, stairs, ramp, windmill, crane, kite, antenna, telescope, slide, rope

#import "@preview/cetz:0.5.2"
#import "theme.typ": scene-theme, _f, _s

/// Draw a wall
#let scene-wall(
  base,
  height,
  width: 0.3,
  bg: auto,
  line-color: auto,
  variant: "plain",
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.wall-fill } else { bg }
  let s = if line-color == auto { scene-theme.wall-stroke } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)

  rect((bx, by), (bx + width, by + height), fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt)

  if variant == "brick" {
    let rows = calc.floor(height / 0.15)
    for r in range(rows) {
      let ry = by + r * (height / rows)
      line((bx, ry), (bx + width, ry), stroke: _s(s, bw) + 0.3pt)
      let cols = calc.max(1, calc.floor(width / 0.2))
      let offset = if calc.rem(r, 2) == 0 { 0 } else { width / cols / 2 }
      for c in range(1, cols) {
        let cx = bx + offset + c * (width / cols)
        if cx < bx + width {
          line((cx, ry), (cx, ry + height / rows), stroke: _s(s, bw) + 0.3pt)
        }
      }
    }
  } else if variant == "stone" {
    // Irregular stone pattern: horizontal mortar lines at uneven heights
    // plus some diagonal/vertical joints to suggest individual stones
    let row-count = calc.max(2, calc.floor(height / 0.2))
    // Pseudo-random offsets using a simple pattern
    let offsets = (0.0, 0.12, -0.05, 0.08, -0.1, 0.06, -0.03, 0.1, -0.07, 0.04)
    for r in range(1, row-count) {
      let base-ry = by + r * (height / row-count)
      // Slightly wavy horizontal mortar line (3 segments)
      let off = offsets.at(calc.rem(r, offsets.len())) * 0.15
      let mid1-x = bx + width * 0.33
      let mid2-x = bx + width * 0.66
      line(
        (bx, base-ry + off),
        (mid1-x, base-ry - off * 0.5),
        (mid2-x, base-ry + off * 0.7),
        (bx + width, base-ry - off * 0.3),
        stroke: _s(s, bw) + 0.3pt,
      )
      // Vertical/diagonal joints within each row (2-3 per row)
      let joints = if calc.rem(r, 2) == 0 { 2 } else { 3 }
      for j in range(1, joints + 1) {
        let jx = bx + j * (width / (joints + 1))
        let j-off = offsets.at(calc.rem(r + j, offsets.len())) * 0.08
        let ry-top = base-ry + off * 0.5
        let ry-bot = by + (r - 1) * (height / row-count) + offsets.at(calc.rem(r - 1, offsets.len())) * 0.15 * 0.5
        line(
          (jx + j-off, ry-bot),
          (jx - j-off * 0.5, ry-top),
          stroke: _s(s, bw) + 0.25pt,
        )
      }
    }
  }

}

/// Draw a ladder between two points
#let scene-ladder(
  base,
  top,
  width: 0.1,
  rungs: 5,
  color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { scene-theme.wood } else { color }
  let bx = base.at(0)
  let by = base.at(1)
  let tx = top.at(0)
  let ty = top.at(1)

  let dx = tx - bx
  let dy = ty - by
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return }

  let nx = -dy / len * width / 2
  let ny = dx / len * width / 2

  line((bx + nx, by + ny), (tx + nx, ty + ny), stroke: _s(c, bw) + 1.2pt)
  line((bx - nx, by - ny), (tx - nx, ty - ny), stroke: _s(c, bw) + 1.2pt)

  let rung-pts = ()
  for i in range(1, rungs + 1) {
    let t = i / (rungs + 1)
    let rx = bx + dx * t
    let ry = by + dy * t
    line((rx + nx, ry + ny), (rx - nx, ry - ny), stroke: _s(c, bw) + 0.8pt)
    rung-pts.push((rx, ry))
  }

}

/// Draw a house
#let scene-house(
  base,
  width: 2,
  wall-height: 1.5,
  roof-height: 0.8,
  bg: auto,
  line-color: auto,
  variant: "simple",
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.wall-fill } else { bg }
  let s = if line-color == auto { scene-theme.wall-stroke } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)
  let w = width
  let wh = wall-height
  let rh = roof-height

  if variant == "modern" {
    // Modern house: flat roof, larger windows, no triangular roof
    // Walls
    rect((bx, by), (bx + w, by + wh), fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt)

    // Flat roof: thick horizontal line on top
    rect((bx - w * 0.03, by + wh), (bx + w + w * 0.03, by + wh + rh * 0.12),
      fill: _f(scene-theme.concrete-stroke, bw), stroke: _s(s, bw) + 0.8pt)

    // Door (wider, taller)
    let dw = w * 0.18
    let dh = wh * 0.5
    let door-x = bx + w * 0.15
    rect((door-x, by), (door-x + dw, by + dh), fill: _f(scene-theme.door, bw), stroke: _s(s, bw) + 0.5pt)

    // Large windows (wider rectangles)
    let win-w = w * 0.22
    let win-h = w * 0.16
    let win-y = by + wh * 0.45
    // Window left-center
    rect((bx + w * 0.45 - win-w / 2, win-y), (bx + w * 0.45 + win-w / 2, win-y + win-h),
      fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.5pt)
    // Window right
    rect((bx + w * 0.78 - win-w / 2, win-y), (bx + w * 0.78 + win-w / 2, win-y + win-h),
      fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.5pt)

  } else if variant == "chalet" {
    // Chalet: wider overhanging roof, balcony
    // Walls
    rect((bx, by), (bx + w, by + wh), fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt)

    // Wide overhanging roof (extends 15% past walls on each side)
    let overhang = w * 0.15
    let roof-top = (bx + w / 2, by + wh + rh)
    line(
      (bx - overhang, by + wh), roof-top, (bx + w + overhang, by + wh),
      close: true, fill: _f(scene-theme.roof, bw), stroke: _s(s, bw) + 0.8pt,
    )

    // Door
    let dw = w * 0.15
    let dh = wh * 0.4
    let door-x = bx + w / 2 - dw / 2
    rect((door-x, by), (door-x + dw, by + dh), fill: _f(scene-theme.door, bw), stroke: _s(s, bw) + 0.5pt)

    // Windows (same as simple)
    let win-size = w * 0.12
    let win-y = by + wh * 0.55
    rect((bx + w * 0.2 - win-size / 2, win-y), (bx + w * 0.2 + win-size / 2, win-y + win-size),
      fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.5pt)
    rect((bx + w * 0.8 - win-size / 2, win-y), (bx + w * 0.8 + win-size / 2, win-y + win-size),
      fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.5pt)

    // Balcony: horizontal rail below roof line with vertical supports
    let balcony-y = by + wh * 0.82
    let balcony-left = bx + w * 0.1
    let balcony-right = bx + w * 0.9
    // Balcony rail
    line((balcony-left, balcony-y), (balcony-right, balcony-y), stroke: _s(scene-theme.wood, bw) + 1pt)
    // Balcony floor
    line((balcony-left, balcony-y - wh * 0.08), (balcony-right, balcony-y - wh * 0.08), stroke: _s(scene-theme.wood, bw) + 0.8pt)
    // Vertical supports
    let support-count = 5
    for i in range(support-count + 1) {
      let sx = balcony-left + i * (balcony-right - balcony-left) / support-count
      line((sx, balcony-y - wh * 0.08), (sx, balcony-y), stroke: _s(scene-theme.wood, bw) + 0.5pt)
    }

  } else {
    // Simple (default)
    rect((bx, by), (bx + w, by + wh), fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt)

    let roof-top = (bx + w / 2, by + wh + rh)
    line(
      (bx - w * 0.05, by + wh), roof-top, (bx + w + w * 0.05, by + wh),
      close: true, fill: _f(scene-theme.roof, bw), stroke: _s(s, bw) + 0.8pt,
    )

    let dw = w * 0.15
    let dh = wh * 0.4
    let door-x = bx + w / 2 - dw / 2
    rect((door-x, by), (door-x + dw, by + dh), fill: _f(scene-theme.door, bw), stroke: _s(s, bw) + 0.5pt)

    let win-size = w * 0.12
    let win-y = by + wh * 0.55
    rect((bx + w * 0.2 - win-size / 2, win-y), (bx + w * 0.2 + win-size / 2, win-y + win-size),
      fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.5pt)
    rect((bx + w * 0.8 - win-size / 2, win-y), (bx + w * 0.8 + win-size / 2, win-y + win-size),
      fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.5pt)
  }

}

/// Draw a building (multi-story)
#let scene-building(
  base,
  width: 1.5,
  floors: 3,
  floor-height: 0.5,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.concrete } else { bg }
  let s = if line-color == auto { scene-theme.concrete-stroke } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)
  let w = width
  let h = floors * floor-height

  rect((bx, by), (bx + w, by + h), fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt)

  let win-size = floor-height * 0.4
  let cols = calc.max(2, calc.floor(w / 0.5))
  for fl in range(floors) {
    let fy = by + fl * floor-height
    if fl > 0 {
      line((bx, fy), (bx + w, fy), stroke: _s(s, bw) + 0.3pt)
    }
    for c in range(cols) {
      let wx = bx + (c + 0.5) * (w / cols) - win-size / 2
      let wy = fy + floor-height * 0.3
      rect((wx, wy), (wx + win-size, wy + win-size), fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.3pt)
    }
  }

  rect((bx - 0.05, by + h), (bx + w + 0.05, by + h + 0.05), fill: _f(s, bw), stroke: none)

}

/// Draw a 3D box (with perspective)
#let scene-box(
  base,
  width: 1,
  height: 0.8,
  depth: 0.3,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.wall-fill } else { bg }
  let s = if line-color == auto { scene-theme.wall-stroke } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)
  let w = width
  let h = height
  let d = depth

  rect((bx, by), (bx + w, by + h), fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt)

  line(
    (bx, by + h), (bx + d, by + h + d),
    (bx + w + d, by + h + d), (bx + w, by + h),
    close: true, fill: _f(f.lighten(15%), bw), stroke: _s(s, bw) + 0.6pt,
  )

  line(
    (bx + w, by), (bx + w + d, by + d),
    (bx + w + d, by + h + d), (bx + w, by + h),
    close: true, fill: _f(f.darken(15%), bw), stroke: _s(s, bw) + 0.6pt,
  )

  let diag = calc.sqrt((w + d) * (w + d) + (h + d) * (h + d))

}

/// Draw a pole/mast/post
#let scene-pole(
  base,
  height,
  color: auto,
  thickness: 2,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { scene-theme.metal } else { color }
  let bx = base.at(0)
  let by = base.at(1)

  line((bx, by), (bx, by + height), stroke: _s(c, bw) + thickness * 1pt)

}

/// Draw a bridge
#let scene-bridge(
  left,
  right,
  height: 0.3,
  bg: auto,
  line-color: auto,
  variant: "beam",
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.concrete } else { bg }
  let s = if line-color == auto { scene-theme.concrete-stroke } else { line-color }
  let lx = left.at(0)
  let ly = left.at(1)
  let rx = right.at(0)
  let ry = right.at(1)

  if variant == "arch" {
    rect((lx, ly), (rx, ly + height), fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt)
    let mid-x = (lx + rx) / 2
    let span = rx - lx
    let n = 16
    let pts = ()
    for i in range(n + 1) {
      let t = i / n
      let ax = lx + span * t
      let ay = ly - 0.3 * span * calc.sin(t * 180deg)
      pts.push((ax, ay))
    }
    line(..pts, stroke: _s(s, bw) + 1.5pt)
  } else if variant == "suspension" {
    // Suspension bridge: deck, two towers, main cable, hanger cables
    let span = rx - lx

    // Deck
    rect((lx, ly), (rx, ly + height), fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt)

    // Tower dimensions
    let tower-w = span * 0.03
    let tower-h = span * 0.35

    // Left tower at 1/4 span
    let lt-x = lx + span * 0.25
    rect(
      (lt-x - tower-w / 2, ly),
      (lt-x + tower-w / 2, ly + height + tower-h),
      fill: _f(f.darken(15%), bw), stroke: _s(s, bw) + 0.8pt,
    )

    // Right tower at 3/4 span
    let rt-x = lx + span * 0.75
    rect(
      (rt-x - tower-w / 2, ly),
      (rt-x + tower-w / 2, ly + height + tower-h),
      fill: _f(f.darken(15%), bw), stroke: _s(s, bw) + 0.8pt,
    )

    // Main cable (catenary from left end through towers, sag in middle, to right end)
    // Cable goes: left deck-top -> left tower top -> sags to middle -> right tower top -> right deck-top
    let cable-top-y = ly + height + tower-h
    let cable-sag = tower-h * 0.6

    // Left approach: deck to left tower top
    let approach-pts = 6
    for i in range(approach-pts) {
      let t0 = i / approach-pts
      let t1 = (i + 1) / approach-pts
      let x0 = lx + (lt-x - lx) * t0
      let x1 = lx + (lt-x - lx) * t1
      let y0 = ly + height + (cable-top-y - ly - height) * t0 * t0
      let y1 = ly + height + (cable-top-y - ly - height) * t1 * t1
      line((x0, y0), (x1, y1), stroke: _s(s, bw) + 1.2pt)
    }

    // Main span: left tower top -> sag -> right tower top (parabolic)
    let cable-n = 20
    let prev-x = lt-x
    let prev-y = cable-top-y
    for i in range(1, cable-n + 1) {
      let t = i / cable-n
      let cx = lt-x + (rt-x - lt-x) * t
      // Parabolic sag: y = top - sag * 4*t*(1-t)
      let cy = cable-top-y - cable-sag * 4 * t * (1 - t)
      line((prev-x, prev-y), (cx, cy), stroke: _s(s, bw) + 1.2pt)
      prev-x = cx
      prev-y = cy
    }

    // Right approach: right tower top to right deck end
    for i in range(approach-pts) {
      let t0 = i / approach-pts
      let t1 = (i + 1) / approach-pts
      let x0 = rt-x + (rx - rt-x) * t0
      let x1 = rt-x + (rx - rt-x) * t1
      // Descending curve (mirror of left approach)
      let y0 = cable-top-y - (cable-top-y - ly - height) * t0 * t0
      let y1 = cable-top-y - (cable-top-y - ly - height) * t1 * t1
      line((x0, y0), (x1, y1), stroke: _s(s, bw) + 1.2pt)
    }

    // Hanger cables (vertical lines from main cable down to deck)
    let hanger-count = calc.max(4, calc.floor(span / 0.3))
    for i in range(1, hanger-count) {
      let t-global = i / hanger-count
      let hx = lx + span * t-global
      // Only draw hangers between the towers
      if hx > lt-x + tower-w and hx < rt-x - tower-w {
        // Find cable y at this x using parabolic formula for main span
        let t-span = (hx - lt-x) / (rt-x - lt-x)
        let cable-y = cable-top-y - cable-sag * 4 * t-span * (1 - t-span)
        line((hx, ly + height), (hx, cable-y), stroke: _s(s, bw) + 0.4pt)
      }
    }
  } else {
    rect((lx, ly), (rx, ly + height), fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt)
    rect((lx, ly - 0.4), (lx + 0.1, ly), fill: _f(f.darken(10%), bw), stroke: _s(s, bw) + 0.5pt)
    rect((rx - 0.1, ly - 0.4), (rx, ly), fill: _f(f.darken(10%), bw), stroke: _s(s, bw) + 0.5pt)
  }

}

/// Draw a tower
#let scene-tower(
  base,
  width: 0.8,
  height: 3,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.concrete } else { bg }
  let s = if line-color == auto { scene-theme.concrete-stroke } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)
  let hw = width / 2

  line(
    (bx - hw, by), (bx - hw * 0.85, by + height),
    (bx + hw * 0.85, by + height), (bx + hw, by),
    close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt,
  )

  let deck-y = by + height
  rect((bx - hw * 1.1, deck-y), (bx + hw * 1.1, deck-y + 0.15), fill: _f(f.darken(10%), bw), stroke: _s(s, bw) + 0.5pt)

  let win-s = width * 0.12
  for fy in range(2, calc.floor(height / 0.6)) {
    let wy = by + fy * 0.6
    rect((bx - win-s / 2, wy), (bx + win-s / 2, wy + win-s), fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.3pt)
  }

}

/// Draw a lighthouse
#let scene-lighthouse(
  base,
  height: 2.5,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { white } else { bg }
  let s = if line-color == auto { scene-theme.concrete-stroke } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)
  let base-w = height * 0.15
  let tw = height * 0.1

  line(
    (bx - base-w, by), (bx - tw, by + height * 0.85),
    (bx + tw, by + height * 0.85), (bx + base-w, by),
    close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt,
  )

  let stripes = 3
  for i in range(stripes) {
    let t1 = (i * 2 + 1) / (stripes * 2 + 1)
    let t2 = (i * 2 + 2) / (stripes * 2 + 1)
    let y1 = by + height * 0.85 * t1
    let y2 = by + height * 0.85 * t2
    let w1 = base-w + (tw - base-w) * t1
    let w2 = base-w + (tw - base-w) * t2
    line(
      (bx - w1, y1), (bx - w2, y2), (bx + w2, y2), (bx + w1, y1),
      close: true, fill: _f(red, bw), stroke: none,
    )
  }

  let lr-y = by + height * 0.85
  let lr-h = height * 0.12
  rect((bx - tw * 1.3, lr-y), (bx + tw * 1.3, lr-y + lr-h),
    fill: _f(rgb("#FFD600"), bw), stroke: _s(s, bw) + 0.5pt)

  let top-pt = (bx, by + height)
  line(
    (bx - tw * 1.3, lr-y + lr-h), top-pt, (bx + tw * 1.3, lr-y + lr-h),
    close: true, fill: _f(s, bw), stroke: _s(s, bw) + 0.5pt,
  )

}

/// Draw a flag pole with flag
#let scene-flag-pole(
  base,
  height,
  flag-color: red,
  bw: false,
) = {
  import cetz.draw: *

  let bx = base.at(0)
  let by = base.at(1)

  line((bx, by), (bx, by + height), stroke: _s(scene-theme.metal, bw) + 1.5pt)

  let fw = height * 0.18
  let fh = height * 0.12
  line(
    (bx, by + height), (bx + fw, by + height - fh * 0.3), (bx, by + height - fh),
    close: true, fill: _f(flag-color, bw), stroke: none,
  )

  circle((bx, by + height), radius: 0.03, fill: _f(scene-theme.metal, bw), stroke: none)

}

/// Draw a shadow projection
#let scene-shadow(
  object-top,
  light-angle,
  ground-y: 0,
  object-base: auto,
  color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#00000040") } else { color }
  let tx = object-top.at(0)
  let ty = object-top.at(1)
  let h = ty - ground-y

  if h <= 0 { return }

  let shadow-length = h / calc.tan(light-angle)
  let tip = (tx + shadow-length, ground-y)

  let base-x = if object-base == auto { tx } else { object-base.at(0) }

  line((base-x, ground-y), tip, stroke: _s(c, bw) + 1.5pt)

}

// ============================================================
// NEW FIGURES
// ============================================================

/// Draw a picket fence
/// - left (array): (x, y) left end of fence
/// - right (array): (x, y) right end of fence (only x used; y from left)
/// - y (float): ground y-level (used if left/right are just x values)
/// - height (float): fence height
/// - spacing (float): space between pickets
/// - bg (color): picket fill color
/// - line-color (color): stroke color
#let scene-fence(
  left,
  right,
  y: 0,
  height: 0.5,
  spacing: 0.3,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { white } else { bg }
  let s = if line-color == auto { scene-theme.wood } else { line-color }
  let lx = left.at(0)
  let ly = left.at(1)
  let rx = right.at(0)
  let span = rx - lx
  if span <= 0 { return }

  let picket-w = spacing * 0.3
  let picket-count = calc.max(2, calc.floor(span / spacing) + 1)
  let actual-spacing = span / (picket-count - 1)

  // Two horizontal rails
  let rail1-y = ly + height * 0.3
  let rail2-y = ly + height * 0.7
  line((lx, rail1-y), (rx, rail1-y), stroke: _s(s, bw) + 1pt)
  line((lx, rail2-y), (rx, rail2-y), stroke: _s(s, bw) + 1pt)

  // Vertical pickets with pointed tops
  for i in range(picket-count) {
    let px = lx + i * actual-spacing
    let half-w = picket-w / 2
    // Picket body (rectangle) + pointed top (triangle)
    let picket-top = ly + height * 0.9
    let point-top = ly + height
    rect(
      (px - half-w, ly),
      (px + half-w, picket-top),
      fill: _f(f, bw), stroke: _s(s, bw) + 0.5pt,
    )
    // Pointed cap
    line(
      (px - half-w, picket-top),
      (px, point-top),
      (px + half-w, picket-top),
      close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.5pt,
    )
  }

}

/// Draw a staircase profile (side view)
/// - base (array): (x, y) bottom-left of stairs
/// - height (float): total height of staircase
/// - width (float): total horizontal width
/// - steps (int): number of steps
/// - bg (color): step fill color
/// - line-color (color): stroke color
#let scene-stairs(
  base,
  height,
  width: 1.0,
  steps: 6,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.concrete } else { bg }
  let s = if line-color == auto { scene-theme.concrete-stroke } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)
  let step-w = width / steps
  let step-h = height / steps

  // Draw each step as an L-shape (horizontal tread + vertical riser)
  for i in range(steps) {
    let sx = bx + i * step-w
    let sy = by + i * step-h
    // Each step is a filled rectangle from (sx, by) to (sx + step-w, sy + step-h)
    // But for a proper staircase profile, draw the step surface
    rect(
      (sx, sy),
      (sx + step-w, sy + step-h),
      fill: _f(f, bw), stroke: _s(s, bw) + 0.6pt,
    )
  }

  // Outer profile outline: stepped silhouette
  let pts = ()
  pts.push((bx, by))
  for i in range(steps) {
    let sx = bx + i * step-w
    let sy = by + (i + 1) * step-h
    pts.push((sx, sy))
    pts.push((sx + step-w, sy))
  }
  pts.push((bx + width, by))
  line(..pts, close: true, stroke: _s(s, bw) + 0.8pt, fill: none)

}

/// Draw an inclined ramp/slope between base point and top point
/// - base (array): (x, y) bottom of ramp
/// - top (array): (x, y) top of ramp
/// - width (float): thickness of the ramp slab
/// - bg (color): ramp fill color
/// - line-color (color): stroke color
#let scene-ramp(
  base,
  top,
  width: 0.15,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.concrete } else { bg }
  let s = if line-color == auto { scene-theme.concrete-stroke } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)
  let tx = top.at(0)
  let ty = top.at(1)

  let dx = tx - bx
  let dy = ty - by
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return }

  // Normal vector (perpendicular to ramp direction, pointing "up")
  let nx = -dy / len * width / 2
  let ny = dx / len * width / 2

  // Parallelogram: 4 corners
  line(
    (bx + nx, by + ny),
    (tx + nx, ty + ny),
    (tx - nx, ty - ny),
    (bx - nx, by - ny),
    close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt,
  )

}

/// Draw a windmill / wind turbine
/// - base (array): (x, y) base of tower
/// - height (float): tower height
/// - blade-length (float): blade length
/// - blades (int): number of blades
/// - rotation (angle): rotation offset of blades
/// - bg (color): tower fill color
/// - line-color (color): stroke color
#let scene-windmill(
  base,
  height: 2.0,
  blade-length: 0.8,
  blades: 4,
  rotation: 0deg,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { white } else { bg }
  let s = if line-color == auto { scene-theme.metal } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)

  // Tapered tower
  let base-half-w = height * 0.04
  let top-half-w = height * 0.02
  line(
    (bx - base-half-w, by),
    (bx - top-half-w, by + height),
    (bx + top-half-w, by + height),
    (bx + base-half-w, by),
    close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt,
  )

  // Hub at top
  let hub-x = bx
  let hub-y = by + height
  let hub-r = blade-length * 0.08
  circle((hub-x, hub-y), radius: hub-r, fill: _f(s, bw), stroke: _s(s, bw) + 0.6pt)

  // Blades radiating from hub
  let blade-w = blade-length * 0.06
  for i in range(blades) {
    let angle = rotation + i * (360deg / blades)
    let tip-x = hub-x + blade-length * calc.cos(angle)
    let tip-y = hub-y + blade-length * calc.sin(angle)
    // Blade as a thin elongated shape (line with some width)
    // Use perpendicular offset for blade width
    let perp-x = -calc.sin(angle) * blade-w
    let perp-y = calc.cos(angle) * blade-w
    line(
      (hub-x + perp-x, hub-y + perp-y),
      (tip-x + perp-x * 0.3, tip-y + perp-y * 0.3),
      (tip-x - perp-x * 0.3, tip-y - perp-y * 0.3),
      (hub-x - perp-x, hub-y - perp-y),
      close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.5pt,
    )
  }

}

/// Draw a construction crane (tower crane)
/// - base (array): (x, y) base of crane
/// - height (float): tower height
/// - arm-length (float): jib arm length (extends right)
/// - bg (color): structure fill color
/// - line-color (color): stroke color
#let scene-crane(
  base,
  height: 3.0,
  arm-length: 2.5,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#FFD600") } else { bg }
  let s = if line-color == auto { scene-theme.metal } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)
  let tw = height * 0.06  // tower half-width

  // Tower (vertical rectangle)
  rect((bx - tw, by), (bx + tw, by + height), fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt)

  // Lattice pattern inside tower (X-shaped cross braces)
  let sections = calc.max(3, calc.floor(height / 0.4))
  let section-h = height / sections
  for i in range(sections) {
    let sy = by + i * section-h
    // X brace
    line((bx - tw, sy), (bx + tw, sy + section-h), stroke: _s(s, bw) + 0.3pt)
    line((bx + tw, sy), (bx - tw, sy + section-h), stroke: _s(s, bw) + 0.3pt)
  }

  // Operator cab (small box at top of tower)
  let cab-w = tw * 1.8
  let cab-h = height * 0.05
  rect(
    (bx - cab-w / 2, by + height),
    (bx + cab-w / 2, by + height + cab-h),
    fill: _f(f.darken(10%), bw), stroke: _s(s, bw) + 0.5pt,
  )
  // Cab window
  rect(
    (bx - cab-w * 0.3, by + height + cab-h * 0.2),
    (bx + cab-w * 0.3, by + height + cab-h * 0.8),
    fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.3pt,
  )

  // Jib arm (horizontal, extending right from top)
  let arm-y = by + height + cab-h
  let arm-h = tw * 0.6
  rect(
    (bx - tw, arm-y),
    (bx + arm-length, arm-y + arm-h),
    fill: _f(f, bw), stroke: _s(s, bw) + 0.6pt,
  )

  // Jib lattice
  let jib-sections = calc.max(4, calc.floor(arm-length / 0.3))
  let jib-section-w = (arm-length + tw) / jib-sections
  for i in range(jib-sections) {
    let jx = bx - tw + i * jib-section-w
    line((jx, arm-y), (jx + jib-section-w, arm-y + arm-h), stroke: _s(s, bw) + 0.2pt)
    line((jx + jib-section-w, arm-y), (jx, arm-y + arm-h), stroke: _s(s, bw) + 0.2pt)
  }

  // Counter-jib (shorter arm extending left)
  let counter-len = arm-length * 0.35
  rect(
    (bx - tw - counter-len, arm-y),
    (bx - tw, arm-y + arm-h),
    fill: _f(f, bw), stroke: _s(s, bw) + 0.6pt,
  )
  // Counterweight block at end
  let cw-size = arm-h * 2
  rect(
    (bx - tw - counter-len - cw-size * 0.3, arm-y - cw-size * 0.5),
    (bx - tw - counter-len + cw-size * 0.3, arm-y + arm-h),
    fill: _f(s, bw), stroke: _s(s, bw) + 0.5pt,
  )

  // Support cables from tower peak to jib tip and counter-jib
  let peak-y = arm-y + arm-h + height * 0.08
  // Tower peak mast
  line((bx, arm-y + arm-h), (bx, peak-y), stroke: _s(s, bw) + 1pt)
  // Cable to jib tip
  line((bx, peak-y), (bx + arm-length, arm-y + arm-h), stroke: _s(s, bw) + 0.5pt)
  // Cable to counter-jib end
  line((bx, peak-y), (bx - tw - counter-len, arm-y + arm-h), stroke: _s(s, bw) + 0.5pt)

  // Hanging cable from jib tip with hook
  let hook-y = arm-y - height * 0.25
  line((bx + arm-length, arm-y), (bx + arm-length, hook-y), stroke: _s(s, bw) + 0.6pt)
  // Hook (small arc)
  line(
    (bx + arm-length, hook-y),
    (bx + arm-length + 0.06, hook-y - 0.04),
    (bx + arm-length + 0.04, hook-y - 0.08),
    (bx + arm-length - 0.02, hook-y - 0.06),
    stroke: _s(s, bw) + 1pt,
  )

}

/// Draw a kite on a string
/// - base (array): (x, y) where the string is held
/// - height (float): how high the kite flies above the base
/// - kite-size (float): size of the kite diamond
/// - color (color): kite color
#let scene-kite(
  base,
  height: 2.0,
  kite-size: 0.4,
  color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#E53935") } else { color }
  let bx = base.at(0)
  let by = base.at(1)

  // Kite position (slightly to the right and above)
  let kx = bx + height * 0.3
  let ky = by + height

  // String: slightly curved line from hand to kite
  let mid1-x = bx + height * 0.08
  let mid1-y = by + height * 0.35
  let mid2-x = bx + height * 0.2
  let mid2-y = by + height * 0.7
  line(
    (bx, by), (mid1-x, mid1-y), (mid2-x, mid2-y), (kx, ky - kite-size * 0.6),
    stroke: _s(rgb("#555555"), bw) + 0.5pt,
  )

  // Kite diamond (rhombus shape) - wider than tall
  let kw = kite-size * 0.5  // half-width
  let kh-top = kite-size * 0.4  // top half height
  let kh-bot = kite-size * 0.6  // bottom half height
  line(
    (kx, ky + kh-top),     // top
    (kx + kw, ky),          // right
    (kx, ky - kh-bot),      // bottom
    (kx - kw, ky),          // left
    close: true, fill: _f(c, bw), stroke: _s(c.darken(20%), bw) + 0.6pt,
  )
  // Cross struts on kite
  line((kx, ky + kh-top), (kx, ky - kh-bot), stroke: _s(c.darken(30%), bw) + 0.4pt)
  line((kx - kw, ky), (kx + kw, ky), stroke: _s(c.darken(30%), bw) + 0.4pt)

  // Tail: zigzag line hanging below the kite with small bows
  let tail-x = kx
  let tail-y = ky - kh-bot
  let zig-amp = kite-size * 0.15
  let zig-step = kite-size * 0.2
  let tail-colors = (c, c.lighten(30%), c.darken(10%), c.lighten(20%))
  for i in range(4) {
    let ty1 = tail-y - i * zig-step
    let ty2 = tail-y - (i + 1) * zig-step
    let dir = if calc.rem(i, 2) == 0 { 1 } else { -1 }
    let mid-tx = tail-x + zig-amp * dir
    let mid-ty = (ty1 + ty2) / 2
    line((tail-x, ty1), (mid-tx, mid-ty), (tail-x, ty2), stroke: _s(tail-colors.at(i), bw) + 0.8pt)
    // Small bow/triangle at each zigzag peak
    let bow-size = kite-size * 0.05
    line(
      (mid-tx - bow-size, mid-ty + bow-size),
      (mid-tx, mid-ty - bow-size),
      (mid-tx + bow-size, mid-ty + bow-size),
      close: true, fill: _f(tail-colors.at(i), bw), stroke: none,
    )
  }

}

/// Draw a radio antenna / transmission tower
/// - base (array): (x, y) base of tower
/// - height (float): tower height
/// - guy-wires (bool): whether to draw diagonal guy-wires
/// - line-color (color): stroke color
#let scene-antenna(
  base,
  height: 2.0,
  guy-wires: true,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let s = if line-color == auto { scene-theme.metal } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)
  let hw = height * 0.04  // half-width of the lattice tower

  // Main vertical lines (two sides of the lattice)
  line((bx - hw, by), (bx - hw, by + height), stroke: _s(s, bw) + 1pt)
  line((bx + hw, by), (bx + hw, by + height), stroke: _s(s, bw) + 1pt)

  // X-pattern cross braces
  let sections = calc.max(4, calc.floor(height / 0.25))
  let section-h = height / sections
  for i in range(sections) {
    let sy = by + i * section-h
    line((bx - hw, sy), (bx + hw, sy + section-h), stroke: _s(s, bw) + 0.4pt)
    line((bx + hw, sy), (bx - hw, sy + section-h), stroke: _s(s, bw) + 0.4pt)
    // Horizontal brace at each section boundary
    line((bx - hw, sy), (bx + hw, sy), stroke: _s(s, bw) + 0.3pt)
  }
  // Top horizontal
  line((bx - hw, by + height), (bx + hw, by + height), stroke: _s(s, bw) + 0.3pt)

  // Small antenna spike at top
  let spike-h = height * 0.08
  line((bx, by + height), (bx, by + height + spike-h), stroke: _s(s, bw) + 1.2pt)
  circle((bx, by + height + spike-h), radius: hw * 0.4, fill: _f(red, bw), stroke: none)

  // Small crossbars near top (antenna elements)
  let bar-w = hw * 3
  line((bx - bar-w, by + height * 0.92), (bx + bar-w, by + height * 0.92), stroke: _s(s, bw) + 0.6pt)
  line((bx - bar-w * 0.7, by + height * 0.85), (bx + bar-w * 0.7, by + height * 0.85), stroke: _s(s, bw) + 0.5pt)

  // Guy-wires (dashed diagonal lines from top to ground on both sides)
  if guy-wires {
    let wire-ground-spread = height * 0.5
    // Left guy-wire
    let left-pts = ()
    let right-pts = ()
    let wire-n = 8
    for i in range(wire-n + 1) {
      let t = i / wire-n
      left-pts.push((bx - hw - wire-ground-spread * (1 - t), by + height * t))
      right-pts.push((bx + hw + wire-ground-spread * (1 - t), by + height * t))
    }
    // Draw as dashed: alternate short segments
    for i in range(wire-n) {
      if calc.rem(i, 2) == 0 {
        line(left-pts.at(i), left-pts.at(i + 1), stroke: _s(s, bw) + 0.4pt)
        line(right-pts.at(i), right-pts.at(i + 1), stroke: _s(s, bw) + 0.4pt)
      }
    }
  }

}

/// Draw a telescope on a tripod
/// - base (array): (x, y) base center (where tripod touches ground)
/// - height (float): tripod height (to pivot point)
/// - angle (angle): tube angle above horizontal
/// - bg (color): tube fill color
/// - line-color (color): stroke color
#let scene-telescope(
  base,
  height: 0.8,
  angle: 30deg,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.concrete } else { bg }
  let s = if line-color == auto { rgb("#333333") } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)

  // Pivot point (where tube attaches, top of tripod)
  let pivot-x = bx
  let pivot-y = by + height

  // Tripod: 3 legs converging at pivot
  // Center leg (straight up, slightly back)
  line((bx, by), (pivot-x, pivot-y), stroke: _s(s, bw) + 1.2pt)
  // Left leg
  line((bx - height * 0.35, by), (pivot-x, pivot-y), stroke: _s(s, bw) + 1.2pt)
  // Right leg
  line((bx + height * 0.35, by), (pivot-x, pivot-y), stroke: _s(s, bw) + 1.2pt)

  // Telescope tube (elongated rectangle angled upward)
  let tube-len = height * 0.9
  let tube-w = height * 0.08  // half-width of tube

  // Direction of tube
  let dir-x = calc.cos(angle)
  let dir-y = calc.sin(angle)
  // Perpendicular (for tube width)
  let perp-x = -dir-y * tube-w
  let perp-y = dir-x * tube-w

  // Tube extends mostly forward and a bit behind the pivot
  let front-x = pivot-x + tube-len * 0.7 * dir-x
  let front-y = pivot-y + tube-len * 0.7 * dir-y
  let back-x = pivot-x - tube-len * 0.3 * dir-x
  let back-y = pivot-y - tube-len * 0.3 * dir-y

  // Draw tube as parallelogram
  line(
    (back-x + perp-x, back-y + perp-y),
    (front-x + perp-x, front-y + perp-y),
    (front-x - perp-x, front-y - perp-y),
    (back-x - perp-x, back-y - perp-y),
    close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt,
  )

  // Lens cap (circle at front end)
  let lens-r = tube-w * 1.3
  circle((front-x, front-y), radius: lens-r, fill: _f(scene-theme.window, bw), stroke: _s(s, bw) + 0.5pt)

  // Eyepiece (small rectangle at back end)
  let ep-x = back-x - dir-x * tube-w * 0.5
  let ep-y = back-y - dir-y * tube-w * 0.5
  circle((ep-x, ep-y), radius: tube-w * 0.6, fill: _f(s, bw), stroke: none)

  // Pivot joint
  circle((pivot-x, pivot-y), radius: tube-w * 0.5, fill: _f(s, bw), stroke: none)

}

/// Draw a playground slide
/// - base (array): (x, y) bottom-left (where the slide touches ground)
/// - height (float): height of the slide top
/// - length (float): horizontal length of the slide
/// - bg (color): slide surface color
/// - line-color (color): stroke color
#let scene-slide(
  base,
  height: 2.0,
  length: 3.0,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#42A5F5") } else { bg }
  let s = if line-color == auto { scene-theme.metal } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)

  // The slide: ladder on the left, sliding surface going down to the right
  // Top platform position
  let top-x = bx
  let top-y = by + height

  // Landing position (bottom of slide surface)
  let land-x = bx + length
  let land-y = by

  // Vertical ladder on the left side
  let ladder-w = length * 0.05
  // Left rail
  line((top-x - ladder-w, by), (top-x - ladder-w, top-y), stroke: _s(s, bw) + 1.2pt)
  // Right rail
  line((top-x + ladder-w, by), (top-x + ladder-w, top-y), stroke: _s(s, bw) + 1.2pt)
  // Rungs
  let rung-count = calc.max(3, calc.floor(height / 0.3))
  for i in range(1, rung-count + 1) {
    let ry = by + i * (height / (rung-count + 1))
    line((top-x - ladder-w, ry), (top-x + ladder-w, ry), stroke: _s(s, bw) + 0.8pt)
  }

  // Top platform
  let platform-len = length * 0.1
  rect(
    (top-x - ladder-w, top-y),
    (top-x + platform-len, top-y + height * 0.03),
    fill: _f(s, bw), stroke: _s(s, bw) + 0.6pt,
  )

  // Sliding surface: curved path from platform to ground
  // Approximate with a smooth curve (quadratic-ish via multiple segments)
  let slide-n = 16
  let slide-pts-left = ()
  let slide-pts-right = ()
  let slide-thickness = height * 0.03
  for i in range(slide-n + 1) {
    let t = i / slide-n
    // x goes from top platform to landing
    let sx = top-x + platform-len + (land-x - top-x - platform-len) * t
    // y: smooth curve from top to bottom (ease-out shape)
    let sy = top-y + (land-y - top-y) * (t * t)
    slide-pts-left.push((sx, sy))
    slide-pts-right.push((sx, sy - slide-thickness))
  }

  // Draw slide surface as filled shape
  let all-pts = slide-pts-left
  // Add reversed right side
  let ri = slide-n
  while ri >= 0 {
    all-pts.push(slide-pts-right.at(ri))
    ri = ri - 1
  }
  line(..all-pts, close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.8pt)

  // Side rails (slightly above slide surface)
  let rail-h = height * 0.06
  for i in range(slide-n) {
    let t0 = i / slide-n
    let t1 = (i + 1) / slide-n
    let sx0 = top-x + platform-len + (land-x - top-x - platform-len) * t0
    let sy0 = top-y + (land-y - top-y) * (t0 * t0)
    let sx1 = top-x + platform-len + (land-x - top-x - platform-len) * t1
    let sy1 = top-y + (land-y - top-y) * (t1 * t1)
    // Only draw rails for the top portion (first 70%) where they're needed
    if t0 < 0.7 {
      line((sx0, sy0 + rail-h), (sx1, sy1 + rail-h), stroke: _s(s, bw) + 0.6pt)
    }
  }

  // Support leg under the slide (right side, at roughly mid-point)
  let support-t = 0.5
  let support-x = top-x + platform-len + (land-x - top-x - platform-len) * support-t
  let support-y = top-y + (land-y - top-y) * (support-t * support-t)
  line((support-x, by), (support-x, support-y), stroke: _s(s, bw) + 1pt)

}

/// Draw a hanging rope/cable between two points with catenary sag
/// - p1 (array): (x, y) first attachment point
/// - p2 (array): (x, y) second attachment point
/// - sag (float): how much the rope sags below the straight line
/// - color (color): rope color
/// - thickness (float): rope thickness in pt
#let scene-rope(
  p1,
  p2,
  sag: 0.3,
  color: auto,
  thickness: 1.0,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { scene-theme.rope } else { color }
  let x1 = p1.at(0)
  let y1 = p1.at(1)
  let x2 = p2.at(0)
  let y2 = p2.at(1)

  // Approximate catenary with sine-based curve
  let n = 20
  let pts = ()
  for i in range(n + 1) {
    let t = i / n
    let px = x1 + (x2 - x1) * t
    let py = y1 + (y2 - y1) * t - sag * calc.sin(t * 180deg)
    pts.push((px, py))
  }
  line(..pts, stroke: _s(c, bw) + thickness * 1pt)

}
