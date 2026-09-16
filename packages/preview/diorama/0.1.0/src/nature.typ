// nature.typ — scene-tree, scene-trees, scene-cloud, scene-sun, scene-seaweed,
//               scene-bush, scene-moon, scene-star, scene-rock, scene-flower,
//               scene-rain, scene-snow-particles, scene-lightning

#import "@preview/cetz:0.5.2"
#import "theme.typ": scene-theme, _f, _s

/// Draw a tree (pine/conifer style by default)
/// - base (array): (x, y) base position
/// - height (float): total height of tree
/// - trunk-color (color): trunk color
/// - foliage-color (color): foliage color
/// - variant (string): "pine" (triangle), "oak" (round), "palm", "birch", "dead", "cypress", "willow"
#let scene-tree(
  base,
  height: 0.6,
  trunk-color: auto,
  foliage-color: auto,
  variant: "pine",
  bw: false,
) = {
  import cetz.draw: *

  let tc = if trunk-color == auto { scene-theme.tree-trunk } else { trunk-color }
  let fc = if foliage-color == auto { scene-theme.tree-foliage } else { foliage-color }
  let bx = base.at(0)
  let by = base.at(1)

  if variant == "oak" {
    // Trunk
    line((bx, by), (bx, by + height * 0.5), stroke: _s(tc, bw) + 1.5pt)
    // Round foliage
    circle((bx, by + height * 0.65), radius: height * 0.35, fill: _f(fc, bw), stroke: if bw { black + 0.5pt } else { none })
  } else if variant == "palm" {
    // Curved trunk
    line((bx, by), (bx + height * 0.1, by + height * 0.7), stroke: _s(tc, bw) + 2pt)
    // Palm fronds (simplified as lines)
    let top = (bx + height * 0.1, by + height * 0.7)
    for angle in (-60deg, -30deg, 0deg, 30deg, 60deg) {
      let end-x = top.at(0) + height * 0.4 * calc.cos(angle)
      let end-y = top.at(1) + height * 0.3 * calc.sin(angle)
      line(top, (end-x, end-y), stroke: _s(fc, bw) + 1.5pt)
    }
  } else if variant == "birch" {
    // Thin white trunk
    let birch-trunk = if trunk-color == auto { rgb("#E8E0D0") } else { trunk-color }
    line((bx, by), (bx, by + height * 0.7), stroke: _s(birch-trunk, bw) + 1.2pt)
    // Small dark marks on trunk
    for i in range(3) {
      let mark-y = by + height * (0.15 + i * 0.18)
      line(
        (bx - 0.015, mark-y),
        (bx + 0.015, mark-y),
        stroke: _s(rgb("#555555"), bw) + 0.5pt,
      )
    }
    // Small scattered leaf clusters (circles)
    let leaf-c = if foliage-color == auto { rgb("#7CB342") } else { foliage-color }
    circle((bx - height * 0.12, by + height * 0.65), radius: height * 0.12, fill: _f(leaf-c, bw), stroke: if bw { black + 0.5pt } else { none })
    circle((bx + height * 0.1, by + height * 0.72), radius: height * 0.14, fill: _f(leaf-c, bw), stroke: if bw { black + 0.5pt } else { none })
    circle((bx - height * 0.05, by + height * 0.82), radius: height * 0.13, fill: _f(leaf-c, bw), stroke: if bw { black + 0.5pt } else { none })
    circle((bx + height * 0.15, by + height * 0.58), radius: height * 0.1, fill: _f(leaf-c, bw), stroke: if bw { black + 0.5pt } else { none })
    circle((bx, by + height * 0.9), radius: height * 0.11, fill: _f(leaf-c, bw), stroke: if bw { black + 0.5pt } else { none })
  } else if variant == "dead" {
    // Bare trunk + angled branches, no foliage
    let dead-trunk = if trunk-color == auto { rgb("#5D4037") } else { trunk-color }
    // Main trunk
    line((bx, by), (bx, by + height * 0.75), stroke: _s(dead-trunk, bw) + 1.5pt)
    // Branches going upward at angles
    let trunk-top = (bx, by + height * 0.75)
    // Branch 1 — upper right
    line(
      (bx, by + height * 0.65),
      (bx + height * 0.2, by + height * 0.85),
      stroke: _s(dead-trunk, bw) + 1pt,
    )
    // Branch 2 — upper left
    line(
      (bx, by + height * 0.55),
      (bx - height * 0.18, by + height * 0.78),
      stroke: _s(dead-trunk, bw) + 1pt,
    )
    // Branch 3 — top center-right
    line(
      trunk-top,
      (bx + height * 0.12, by + height * 0.95),
      stroke: _s(dead-trunk, bw) + 1pt,
    )
    // Branch 4 — top center-left
    line(
      trunk-top,
      (bx - height * 0.1, by + height),
      stroke: _s(dead-trunk, bw) + 0.8pt,
    )
  } else if variant == "cypress" {
    // Tall narrow conical shape (Italian cypress)
    // Thin trunk (barely visible behind foliage)
    line((bx, by), (bx, by + height * 0.15), stroke: _s(tc, bw) + 1pt)
    // Elongated narrow triangle for foliage
    let half-w = height * 0.08
    line(
      (bx - half-w, by + height * 0.1),
      (bx, by + height),
      (bx + half-w, by + height * 0.1),
      close: true, fill: _f(fc.darken(15%), bw), stroke: if bw { black + 0.5pt } else { none },
    )
  } else if variant == "willow" {
    // Trunk
    line((bx, by), (bx, by + height * 0.6), stroke: _s(tc, bw) + 1.8pt)
    // Small foliage crown
    let crown-y = by + height * 0.6
    circle((bx, crown-y + height * 0.08), radius: height * 0.12, fill: _f(fc, bw), stroke: if bw { black + 0.5pt } else { none })
    // Drooping branches as downward curves
    let willow-c = if foliage-color == auto { rgb("#558B2F") } else { foliage-color }
    // Several drooping lines from crown downward
    for i in range(7) {
      let angle = -75deg + i * 25deg
      let start-x = bx + height * 0.1 * calc.cos(angle)
      let start-y = crown-y + height * 0.05 + height * 0.08 * calc.sin(angle)
      let droop = height * 0.35
      let spread = height * 0.15 * calc.cos(angle)
      line(
        (start-x, start-y),
        (start-x + spread * 0.5, start-y - droop * 0.4),
        (start-x + spread, start-y - droop),
        stroke: _s(willow-c, bw) + 0.8pt,
      )
    }
  } else {
    // Pine (default): triangle on trunk
    // Trunk
    line((bx, by), (bx, by + height * 0.35), stroke: _s(tc, bw) + 1pt)
    // Triangular foliage
    line(
      (bx - height * 0.18, by + height * 0.25),
      (bx, by + height),
      (bx + height * 0.18, by + height * 0.25),
      close: true, fill: _f(fc, bw), stroke: if bw { black + 0.5pt } else { none },
    )
  }

}

/// Draw multiple trees at given positions
/// - positions (array): array of (x, height) or (x, y, height) tuples
/// - ..args: forwarded to scene-tree
#let scene-trees(positions, variant: "pine", foliage-color: auto, trunk-color: auto, bw: false) = {
  for pos in positions {
    let base = if pos.len() >= 3 { (pos.at(0), pos.at(1)) } else { (pos.at(0), 0) }
    let h = if pos.len() >= 3 { pos.at(2) } else { pos.at(1) }
    scene-tree(base, height: h, variant: variant, foliage-color: foliage-color, trunk-color: trunk-color, bw: bw)
  }
}

/// Draw a cloud
/// - center (array): (x, y) center position
/// - size (float): overall size factor
/// - bg (color): cloud color
#let scene-cloud(center, size: 0.3, bg: white, bw: false) = {
  import cetz.draw: *

  let cx = center.at(0)
  let cy = center.at(1)
  let s = size

  circle((cx - s * 0.5, cy), radius: s * 0.4, fill: _f(bg, bw), stroke: if bw { black + 0.5pt } else { none })
  circle((cx, cy + s * 0.15), radius: s * 0.55, fill: _f(bg, bw), stroke: if bw { black + 0.5pt } else { none })
  circle((cx + s * 0.5, cy), radius: s * 0.4, fill: _f(bg, bw), stroke: if bw { black + 0.5pt } else { none })

}

/// Draw a sun with rays
/// - center (array): (x, y) center
/// - radius (float): sun disk radius
/// - bg (color): sun color
/// - ray-count (int): number of rays
/// - ray-length (float): length of rays beyond radius
#let scene-sun(
  center,
  radius: 0.4,
  bg: auto,
  ray-count: 8,
  ray-length: 0.2,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#FFD600") } else { bg }
  let cx = center.at(0)
  let cy = center.at(1)

  circle(center, radius: radius, fill: _f(f, bw), stroke: _s(rgb("#FFC107"), bw) + 1pt)

  for i in range(ray-count) {
    let angle = i * (360deg / ray-count)
    let r1 = radius + 0.05
    let r2 = radius + ray-length
    line(
      (cx + r1 * calc.cos(angle), cy + r1 * calc.sin(angle)),
      (cx + r2 * calc.cos(angle), cy + r2 * calc.sin(angle)),
      stroke: _s(f, bw) + 1.5pt,
    )
  }

}

/// Draw seaweed strands
/// - base (array): (x, y) base position on the sea floor
/// - height (float): approximate height
/// - color (color): seaweed color
/// - strands (int): number of strands
#let scene-seaweed(
  base,
  height: 0.5,
  color: auto,
  strands: 1,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#2E7D32") } else { color }
  let bx = base.at(0)
  let by = base.at(1)

  for i in range(strands) {
    let offset = (i - (strands - 1) / 2) * 0.08
    let x = bx + offset
    // Wavy line upward
    line(
      (x, by),
      (x + 0.05, by + height * 0.3),
      (x - 0.03, by + height * 0.6),
      (x + 0.04, by + height * 0.85),
      (x, by + height),
      stroke: _s(c, bw) + 1.2pt,
    )
  }

}

// ============================================================
// New figures
// ============================================================

/// Draw a bush / shrub (cluster of overlapping circles near ground)
/// - base (array): (x, y) base position (bottom-center)
/// - width (float): approximate width
/// - height (float): approximate height
/// - bg (color): bush color (darker green by default)
#let scene-bush(
  base,
  width: 0.4,
  height: 0.3,
  bg: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#1B5E20") } else { bg }
  let bx = base.at(0)
  let by = base.at(1)

  // Cluster of 4 overlapping circles
  let r = height * 0.45
  circle((bx - width * 0.25, by + r * 0.7), radius: r, fill: _f(f, bw), stroke: if bw { black + 0.5pt } else { none })
  circle((bx + width * 0.25, by + r * 0.7), radius: r, fill: _f(f, bw), stroke: if bw { black + 0.5pt } else { none })
  circle((bx, by + r * 0.9), radius: r * 1.1, fill: _f(f.lighten(8%), bw), stroke: if bw { black + 0.5pt } else { none })
  circle((bx + width * 0.1, by + r * 0.5), radius: r * 0.7, fill: _f(f.darken(5%), bw), stroke: if bw { black + 0.5pt } else { none })

}

/// Draw a moon
/// - center (array): (x, y) center position
/// - radius (float): moon radius
/// - phase (string): "crescent", "full", "half"
/// - bg (color): moon color
#let scene-moon(
  center,
  radius: 0.4,
  phase: "crescent",
  bg: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#FFF9C4") } else { bg }
  let cx = center.at(0)
  let cy = center.at(1)
  let r = radius

  if phase == "full" {
    circle(center, radius: r, fill: _f(f, bw), stroke: _s(rgb("#FDD835"), bw) + 0.5pt)
  } else if phase == "half" {
    // Left half-circle: draw full circle then cover right half with background
    // We use an arc-like approach with a filled polygon
    let n = 24
    let pts = ()
    // Left semicircle from 90deg to 270deg (the lit part)
    for i in range(n + 1) {
      let angle = 90deg + i * (180deg / n)
      pts.push((cx + r * calc.cos(angle), cy + r * calc.sin(angle)))
    }
    line(..pts, close: true, fill: _f(f, bw), stroke: _s(rgb("#FDD835"), bw) + 0.5pt)
  } else {
    // Crescent: full moon circle, then a slightly offset circle to "cut out"
    // Draw the main moon disk
    circle(center, radius: r, fill: _f(f, bw), stroke: none)
    // Overlap with a dark circle shifted to the right to create crescent
    // We approximate by drawing the crescent as a filled shape
    // using two arcs: outer (full moon) and inner (cutout)
    let n = 32
    let cutout-offset = r * 0.55
    let cutout-r = r * 0.9

    // Build crescent polygon: outer arc (full circle, left side) + inner arc (cutout, reversed)
    let pts = ()
    // Outer arc from -90deg to +90deg (left-facing crescent)
    for i in range(n + 1) {
      let angle = -90deg + i * (180deg / n)
      pts.push((cx + r * calc.cos(angle), cy + r * calc.sin(angle)))
    }
    // Inner arc from +90deg back to -90deg (the cutout)
    for i in range(n + 1) {
      let angle = 90deg - i * (180deg / n)
      pts.push((cx + cutout-offset + cutout-r * calc.cos(angle), cy + cutout-r * calc.sin(angle)))
    }
    // Draw the crescent shape on top
    line(..pts, close: true, fill: _f(f, bw), stroke: _s(rgb("#FDD835"), bw) + 0.5pt)
  }

}

/// Draw a star shape
/// - center (array): (x, y) center position
/// - size (float): outer radius of the star
/// - points (int): number of star points (default 5)
/// - bg (color): star color
#let scene-star(
  center,
  size: 0.15,
  points: 5,
  bg: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#FFD600") } else { bg }
  let cx = center.at(0)
  let cy = center.at(1)
  let outer = size
  let inner = size * 0.4

  // Build star polygon: alternate outer and inner vertices
  let pts = ()
  for i in range(points * 2) {
    let angle = 90deg + i * (360deg / (points * 2))
    let r = if calc.rem(i, 2) == 0 { outer } else { inner }
    pts.push((cx + r * calc.cos(angle), cy + r * calc.sin(angle)))
  }
  line(..pts, close: true, fill: _f(f, bw), stroke: if bw { black + 0.5pt } else { none })

}

/// Draw a rock / boulder
/// - base (array): (x, y) base position (bottom-center)
/// - width (float): approximate width
/// - height (float): approximate height
/// - bg (color): rock fill color
/// - line-color (color): rock outline color
/// - variant (string): "round", "angular", "flat"
#let scene-rock(
  base,
  width: 0.3,
  height: 0.2,
  bg: auto,
  line-color: auto,
  variant: "round",
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.rock } else { bg }
  let s = if line-color == auto { scene-theme.mountain-stroke } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)
  let hw = width / 2
  let h = height

  if variant == "angular" {
    // Jagged polygonal rock
    line(
      (bx - hw, by),
      (bx - hw * 0.85, by + h * 0.6),
      (bx - hw * 0.3, by + h),
      (bx + hw * 0.2, by + h * 0.85),
      (bx + hw * 0.7, by + h * 0.95),
      (bx + hw, by + h * 0.5),
      (bx + hw * 0.8, by),
      close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.6pt,
    )
  } else if variant == "flat" {
    // Flat slab — wide and short
    line(
      (bx - hw, by),
      (bx - hw * 0.9, by + h * 0.4),
      (bx - hw * 0.5, by + h),
      (bx + hw * 0.5, by + h),
      (bx + hw * 0.9, by + h * 0.4),
      (bx + hw, by),
      close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.6pt,
    )
  } else {
    // Round (default): smooth rounded boulder (approximated by a polygon)
    let n = 12
    let pts = ()
    for i in range(n) {
      let angle = i * (180deg / (n - 1))
      let rx = hw * calc.cos(angle)
      // Scale vertical so bottom is flat-ish and top is round
      let ry = h * calc.sin(angle)
      pts.push((bx - rx, by + ry))
    }
    line(..pts, close: true, fill: _f(f, bw), stroke: _s(s, bw) + 0.6pt)
  }

}

/// Draw a simple flower (stem + petals + center)
/// - base (array): (x, y) base position (ground level)
/// - height (float): total height of flower
/// - color (color): petal color
/// - petals (int): number of petals
#let scene-flower(
  base,
  height: 0.3,
  color: auto,
  petals: 5,
  bw: false,
) = {
  import cetz.draw: *

  let petal-c = if color == auto { rgb("#E91E63") } else { color }
  let stem-c = rgb("#388E3C")
  let center-c = rgb("#FDD835")
  let bx = base.at(0)
  let by = base.at(1)

  // Stem
  line((bx, by), (bx, by + height * 0.75), stroke: _s(stem-c, bw) + 1pt)

  // Flower head center
  let head-y = by + height * 0.8
  let petal-r = height * 0.12
  let center-r = height * 0.07

  // Petals (small circles arranged around center)
  for i in range(petals) {
    let angle = i * (360deg / petals) + 90deg
    let px = bx + petal-r * 0.9 * calc.cos(angle)
    let py = head-y + petal-r * 0.9 * calc.sin(angle)
    circle((px, py), radius: petal-r, fill: _f(petal-c, bw), stroke: if bw { black + 0.5pt } else { none })
  }

  // Center dot
  circle((bx, head-y), radius: center-r, fill: _f(center-c, bw), stroke: if bw { black + 0.5pt } else { none })

}

/// Draw rain effect (many small diagonal lines)
/// Uses deterministic positions based on index (no randomness).
/// - left (float): left x boundary
/// - right (float): right x boundary
/// - top (float): top y boundary
/// - bottom (float): bottom y boundary
/// - density (int): number of rain drops
/// - color (color): rain color
#let scene-rain(
  left,
  right,
  top,
  bottom,
  density: 20,
  color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#64B5F6") } else { color }
  let w = right - left
  let h = top - bottom
  let drop-len = h * 0.04

  for i in range(density) {
    // Deterministic pseudo-random placement using sin/cos of index
    let t = i / density
    let px = left + w * calc.abs(calc.sin(i * 2.3 + 0.7))
    let py = bottom + h * calc.abs(calc.cos(i * 1.7 + 0.3))
    // Slight diagonal: drops fall down and slightly right
    line(
      (px, py),
      (px + drop-len * 0.3, py - drop-len),
      stroke: _s(c, bw) + 0.6pt,
    )
  }

}

/// Draw snow particles (small dots scattered in a region)
/// Uses deterministic positions based on index.
/// - left (float): left x boundary
/// - right (float): right x boundary
/// - top (float): top y boundary
/// - bottom (float): bottom y boundary
/// - density (int): number of snowflakes
/// - color (color): snowflake color
#let scene-snow-particles(
  left,
  right,
  top,
  bottom,
  density: 15,
  color: white,
  bw: false,
) = {
  import cetz.draw: *

  let w = right - left
  let h = top - bottom

  for i in range(density) {
    // Deterministic placement using sin-based distribution
    let px = left + w * calc.abs(calc.sin(i * 3.1 + 1.2))
    let py = bottom + h * calc.abs(calc.cos(i * 2.7 + 0.5))
    let r = 0.015 + 0.01 * calc.abs(calc.sin(i * 5.3))
    circle((px, py), radius: r, fill: _f(color, bw), stroke: if bw { black + 0.5pt } else { none })
  }

}

/// Draw a lightning bolt (zigzag line between two points)
/// Uses deterministic calc.sin-based wobble for the offsets.
/// - start (array): (x, y) start point (usually top)
/// - end (array): (x, y) end point (usually bottom)
/// - segments (int): number of zigzag segments
/// - color (color): lightning color
/// - thickness (float): stroke thickness in pt
#let scene-lightning(
  start,
  end,
  segments: 5,
  color: auto,
  thickness: 1.5,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#FFEB3B") } else { color }
  let sx = start.at(0)
  let sy = start.at(1)
  let ex = end.at(0)
  let ey = end.at(1)
  let dx = ex - sx
  let dy = ey - sy
  let length = calc.sqrt(dx * dx + dy * dy)
  if length == 0 { return }

  // Perpendicular direction for offsets
  let perp-x = -dy / length
  let perp-y = dx / length

  // Maximum lateral wobble proportional to length
  let wobble = length * 0.12

  let pts = (start,)
  for i in range(1, segments) {
    let t = i / segments
    // Base point along the line
    let mx = sx + dx * t
    let my = sy + dy * t
    // Deterministic lateral offset using sin
    let offset = wobble * calc.sin(i * 2.8 + 1.3)
    pts.push((mx + perp-x * offset, my + perp-y * offset))
  }
  pts.push(end)

  line(..pts, stroke: _s(c, bw) + thickness * 1pt)

  // Faint glow line (slightly wider, more transparent)
  line(..pts, stroke: _s(c.lighten(50%), bw) + (thickness * 2) * 1pt)

}
