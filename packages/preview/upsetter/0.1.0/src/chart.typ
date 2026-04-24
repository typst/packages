#import "deps.typ": *
#import "common.typ": _parse-inter-key

#let _barchart(
  /// -> string
  legend,
  /// -> "h" | "v"
  orientation,
  /// -> array
  data,
  /// -> float | none
  width: none,
  /// -> float | none
  gap: none,
  /// -> float | none
  max-length: none,
  /// -> bool
  show-axes: false,
  /// -> float | auto
  tick-step: auto
) = {
  import cetz.draw: *
  import calc: log, floor, ceil, pow, sqrt

  let max = calc.max(..data, 1)
  let style = (stroke: none, fill: black)

  let tick-step = if tick-step == auto {
    let b = max / pow(10, floor(log(max)))

    let k = if b < 1 {
      0.1
    } else if b < 2.5 {
      0.5
    } else {
      1
    }

    k * pow(10, floor(log(max)))
  } else {
    tick-step
  }

  if max / tick-step > 8 {
    tick-step *= 2
  }

  let n-ticks = ceil(max / tick-step) + 1
  let actual-max = (n-ticks - 1) * tick-step

  // Gap between axis and chart
  let D = -0.05

  // Gap between legend and chart
  // FIXME: should take width of axis tick labels into account when `orientation == "h"`
  let Q = if show-axes and orientation == "v" {
    0.65
  } else if show-axes and orientation == "h" {
    0.75
  } else {
    0.15
  }

  // Conversion factor from the "data" coordinate system to the "plot axes" coordinate system
  let p = max-length / actual-max

  let tick-text = i => text(8pt, $#(i * tick-step)$)

  if orientation == "h" {
    for (i, y) in data.enumerate() {
      let x = (i + 1) * gap + i * width
      rect((x, 0), (x + width, y * p), ..style)
    }

    if show-axes {
      line((D, 0), (D, max-length))

      for i in range(n-ticks) {
        let u = i / (n-ticks - 1) * max-length + 0.01
        
        line((D + 0.05, u), (D - 0.05, u))
        content(anchor: "east", (D - 0.15, u), text(8pt, $#(i * tick-step)$))
      }
    }

    if legend != none {
      content((D - Q, max-length / 2), anchor: "center", angle: 90deg, text(9pt, legend))
    } 
  } else {
    // NOTE: This is rather ugly and can't be unified with the code for the
    // opposite orientation as-is due to the origin of the coordinate system
    // being at the lower left corner rather than the lower right corner.
    for (i, x) in data.rev().enumerate() {
      let y = (i + 1) * gap + i * width
      rect((max-length, y), (max-length - x * p, y + width), ..style)
    }

    if show-axes {
      line((0, D), (max-length, D))

      for i in range(n-ticks) {
        let u = max-length - i / (n-ticks - 1) * max-length - 0.01

        line((u, D + 0.05), (u, D - 0.05))
        content(anchor: "north", (u, D - 0.15), text(8pt, $#(i * tick-step)$))
      }
    }

    if legend != none {
      content((max-length / 2, D - Q), anchor: "center", text(9pt, legend))
    } 
  }
}

#let _interchart(
  /// -> "h" | "v"
  orientation,
  /// -> dictionary
  sets,
  /// -> array
  inter,
  /// -> str
  delim,
  /// -> float | none
  width: none,
   /// -> float | none
  gap-sets: none,
  /// -> float | none
  gap-inter: none
) = {
  import cetz.draw: *

  let n = sets.len()
  let m = inter.len()
  let r = width / 2

  if orientation == "v" {
    inter = inter.rev()
  }

  let coord(x, y) = if orientation == "h" {
    (x, y)
  } else {
    (y, x)
  }

  for (i, s) in inter.enumerate() {
    let inter-dict = _parse-inter-key(s, delim)

    let min = n - 1
    let max = 0

    for (s, j) in sets.pairs() {
      let k = if orientation == "h" {
        n - j - 1
      } else {
        j
      }

      let args = arguments(coord(gap-inter + i * (width + gap-inter) + r, gap-sets + k * (width + gap-sets) + r), radius: 0.8 * r, stroke: none)
      
      if s in inter-dict {
        on-layer(1, circle(..args, fill: black))

        if k < min { min = k }
        if k > max { max = k }
      } else {
        circle(..args, fill: black.lighten(80%))
      }

      if min < max {
        rect(
          coord(
            gap-inter + i * (width + gap-inter) + 0.65 * r,
            gap-sets + min * (width + gap-sets) + 0.65 * r
          ),
          coord(
            gap-inter + i * (width + gap-inter) + 1.35 * r,
            gap-sets + max * (width + gap-sets) + 1.35 * r              
          ),
          stroke: none,
          fill: black
        )
      }
    }
  }
  
  for (s, i) in sets.pairs() {
    if calc.rem-euclid(i, 2) != 0 { continue }

    on-layer(-1, rect(
      coord(0, i * (width + gap-sets) + gap-sets/2),
      coord(gap-inter + m * (width + gap-inter), (i + 1) * (width + gap-sets) + gap-sets/2),
      stroke: none,
      fill: black.lighten(96%)
    ))
  }
}
