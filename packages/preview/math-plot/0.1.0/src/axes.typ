// Tick generation and marker drawing.

#import "@preview/cetz:0.5.2" as cetz

#let nice-step(needed) = {
  let k = calc.floor(calc.log(calc.max(needed, 1e-9), base: 10))
  let result = 10 * calc.pow(10.0, k)
  for mult in (1, 2, 5) {
    let step = mult * calc.pow(10.0, k)
    if step >= needed - 1e-9 { result = step; break }
  }
  result
}

#let generate-ticks(min, max, step: auto, scale: none, min-spacing: 0.4) = {
  let actual-step = if step != auto {
    step
  } else if scale != none {
    calc.max(1, nice-step(min-spacing / scale))
  } else {
    1
  }

  let ticks = ()
  let start = calc.ceil(min / actual-step) * actual-step
  let pos = start
  while pos <= max + 0.0001 {
    ticks.push(pos)
    pos += actual-step
  }
  (ticks: ticks, step: actual-step)
}

#let draw-marker(pos, marker-type, size, fill-color, stroke-style) = {
  import cetz.draw: *

  let (cx, cy) = pos
  let s = size
  let half = s / 2

  if marker-type == "o" {
    circle((cx, cy), radius: half, stroke: stroke-style, fill: none)
  } else if marker-type == "*" {
    circle((cx, cy), radius: half, stroke: stroke-style, fill: fill-color)
  } else if marker-type == "square" {
    rect((cx - half, cy - half), (cx + half, cy + half), stroke: stroke-style, fill: none)
  } else if marker-type == "square*" {
    rect((cx - half, cy - half), (cx + half, cy + half), stroke: stroke-style, fill: fill-color)
  } else if marker-type == "triangle" {
    let h = s * 0.866
    line((cx, cy + h/2), (cx - half, cy - h/2), (cx + half, cy - h/2),
      close: true, stroke: stroke-style, fill: none)
  } else if marker-type == "triangle*" {
    let h = s * 0.866
    line((cx, cy + h/2), (cx - half, cy - h/2), (cx + half, cy - h/2),
      close: true, stroke: stroke-style, fill: fill-color)
  } else if marker-type == "diamond" {
    line((cx, cy + half), (cx - half, cy), (cx, cy - half), (cx + half, cy),
      close: true, stroke: stroke-style, fill: none)
  } else if marker-type == "diamond*" {
    line((cx, cy + half), (cx - half, cy), (cx, cy - half), (cx + half, cy),
      close: true, stroke: stroke-style, fill: fill-color)
  } else if marker-type == "star" or marker-type == "star*" {
    let outer = half
    let inner = half * 0.4
    let points = ()
    for i in range(10) {
      let angle = calc.pi / 2 + i * calc.pi / 5
      let r = if calc.rem(i, 2) == 0 { outer } else { inner }
      points.push((cx + r * calc.cos(angle), cy + r * calc.sin(angle)))
    }
    line(..points, close: true, stroke: stroke-style,
      fill: if marker-type == "star*" { fill-color } else { none })
  } else if marker-type == "+" {
    line((cx - half, cy), (cx + half, cy), stroke: stroke-style)
    line((cx, cy - half), (cx, cy + half), stroke: stroke-style)
  } else if marker-type == "x" {
    line((cx - half, cy - half), (cx + half, cy + half), stroke: stroke-style)
    line((cx - half, cy + half), (cx + half, cy - half), stroke: stroke-style)
  } else if marker-type == "|" {
    line((cx, cy - half), (cx, cy + half), stroke: stroke-style)
  } else if marker-type == "-" {
    line((cx - half, cy), (cx + half, cy), stroke: stroke-style)
  }
}
