// backgrounds.typ — scene-sky, scene-ground, scene-water-gradient

#import "@preview/cetz:0.5.2"
#import "theme.typ": scene-theme, _f, _s

/// Draw a sky rectangle
#let scene-sky(left, right, top, bottom: 0, bg: auto, bw: false) = {
  import cetz.draw: *
  let c = if bg == auto { scene-theme.sky } else { bg }
  rect((left, bottom), (right, top), fill: _f(c, bw), stroke: none)
}

/// Draw a ground rectangle
#let scene-ground(left, right, y: 0, depth: 1, bg: auto, line-color: auto, bw: false) = {
  import cetz.draw: *
  let f = if bg == auto { scene-theme.ground } else { bg }
  let s = if line-color == auto { scene-theme.ground-stroke } else { line-color }
  rect((left, y - depth), (right, y), fill: _f(f, bw), stroke: none)
  line((left, y), (right, y), stroke: _s(s, bw) + 2pt)
}

/// Draw a water gradient (multiple horizontal layers)
#let scene-water-gradient(left, right, top: 0, bottom, layers: 3, surface-stroke: auto, bw: false) = {
  import cetz.draw: *
  let colors = (_f(scene-theme.water-light, bw), _f(scene-theme.water-mid, bw), _f(scene-theme.water-deep, bw))
  let total = top - bottom
  for i in range(layers) {
    let y-top = top - (total / layers) * i
    let y-bot = top - (total / layers) * (i + 1)
    let c = colors.at(calc.min(i, colors.len() - 1))
    rect((left, y-bot), (right, y-top), fill: c, stroke: none)
  }
  let ss = if surface-stroke == auto { rgb("#1565C0") } else { surface-stroke }
  line((left, top), (right, top), stroke: _s(ss, bw) + 2pt)
}

/// Draw a night sky with scattered stars
/// - left (float): left x bound
/// - right (float): right x bound
/// - top (float): top y bound
/// - bottom (float): bottom y bound
/// - bg (color): sky color (default: dark navy)
/// - stars (int): number of stars to scatter
#let scene-night-sky(left, right, top, bottom: 0, bg: auto, stars: 20, bw: false) = {
  import cetz.draw: *
  let c = if bg == auto { rgb("#0d1b2a") } else { bg }
  rect((left, bottom), (right, top), fill: _f(c, bw), stroke: none)

  let width = right - left
  let height = top - bottom
  for i in range(stars) {
    // Deterministic pseudo-random placement using trig
    let sx = calc.sin(i * 137.5deg)
    let cx = calc.cos(i * 97.3deg)
    // Map to 0..1 range: sin/cos produce -1..1, so (v + 1) / 2 maps to 0..1
    let fx = (sx + 1) / 2
    let fy = (cx + 1) / 2
    let px = left + fx * width
    let py = bottom + fy * height
    // Vary radius between 0.02 and 0.04 based on index
    let r = 0.02 + 0.02 * (calc.sin(i * 53.7deg) + 1) / 2
    circle((px, py), radius: r, fill: if bw { black } else { white }, stroke: if bw { black + 0.5pt } else { none })
  }
}

/// Draw an underground / cave background
/// - left (float): left x bound
/// - right (float): right x bound
/// - top (float): top y bound
/// - bottom (float): bottom y bound
/// - bg (color): fill color (default: dark brown)
/// - line-color (color): top edge stroke color
#let scene-underground(left, right, top, bottom, bg: auto, line-color: auto, bw: false) = {
  import cetz.draw: *
  let f = if bg == auto { rgb("#3E2723") } else { bg }
  let s = if line-color == auto { rgb("#5D4037") } else { line-color }
  rect((left, bottom), (right, top), fill: _f(f, bw), stroke: none)
  line((left, top), (right, top), stroke: _s(s, bw) + 2pt)

  // Scattered small grey rocks embedded in the underground
  let width = right - left
  let height = top - bottom
  let rock-count = 8
  for i in range(rock-count) {
    let sx = calc.sin(i * 113.2deg)
    let cx = calc.cos(i * 79.8deg)
    let fx = (sx + 1) / 2
    let fy = (cx + 1) / 2
    let px = left + fx * width
    let py = bottom + fy * height
    let r = 0.04 + 0.03 * (calc.sin(i * 61.4deg) + 1) / 2
    circle((px, py), radius: r, fill: _f(rgb("#9E9E9E"), bw), stroke: if bw { black + 0.5pt } else { none })
  }
}
