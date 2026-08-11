// simple-plot - A simple pgfplots-like function plotting library for Typst
// https://github.com/nathan/simple-plot
// License: MIT

#import "@preview/cetz:0.4.2" as cetz

// ============================================================================
// GLOBAL DEFAULTS
// ============================================================================

#let _plot-defaults = state("simple-plot-defaults", (:))

/// Set default values for all subsequent plots.
///
/// Example:
/// ```typst
/// #set-plot-defaults(width: 10, height: 8, show-grid: true)
/// ```
#let set-plot-defaults(..args) = {
  _plot-defaults.update(current => {
    let new = current
    for (key, value) in args.named() {
      new.insert(key, value)
    }
    new
  })
}

/// Reset all defaults to initial values.
#let reset-plot-defaults() = {
  _plot-defaults.update(_ => (:))
}

// ============================================================================
// MARKER DEFINITIONS
// ============================================================================

/// Available marker types for scatter plots and data points.
#let marker-types = (
  "o",        // circle (hollow)
  "*",        // circle (filled)
  "square",   // square (hollow)
  "square*",  // square (filled)
  "triangle", // triangle (hollow)
  "triangle*",// triangle (filled)
  "diamond",  // diamond (hollow)
  "diamond*", // diamond (filled)
  "star",     // star (hollow)
  "star*",    // star (filled)
  "+",        // plus
  "x",        // cross
  "|",        // vertical bar
  "-",        // horizontal bar
  "none",     // no marker
)

// ============================================================================
// DEFAULT STYLES
// ============================================================================

#let default-style = (
  background: (
    fill: none,
    stroke: none,
  ),
  axis: (
    stroke: black + 0.8pt,
    arrow: "stealth",
  ),
  grid: (
    major: (stroke: luma(180) + 0.8pt),
    minor: (stroke: luma(210) + 0.5pt),
  ),
  ticks: (
    length: 0.1,
    stroke: black + 0.6pt,
    label-offset: 0.15,
    label-size: 0.65em,
  ),
  plot: (
    stroke: blue + 1.2pt,
    samples: 100,
  ),
  marker: (
    size: 0.12,
    stroke: black + 0.8pt,
    fill: black,
  ),
  labels: (
    size: 0.8em,
    offset: 0.3,
  ),
  xlabel-style: (
    anchor: "west",
    offset: (0.3, 0),
  ),
  ylabel-style: (
    anchor: "south",
    offset: (0, 0.3),
  ),
)

#let merge-styles(user-style) = {
  let result = default-style
  if user-style != none {
    for (key, value) in user-style {
      if key in result and type(value) == dictionary {
        for (k, v) in value {
          result.at(key).insert(k, v)
        }
      } else {
        result.insert(key, value)
      }
    }
  }
  result
}

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

// Clip a line segment to a rectangle (all 4 edges) using Liang-Barsky
#let clip-segment(p1, p2, xmin, ymin, xmax, ymax) = {
  let (x1, y1) = p1
  let (x2, y2) = p2

  let dx = x2 - x1
  let dy = y2 - y1

  let t0 = 0.0
  let t1 = 1.0

  // Check each edge: left, right, bottom, top
  let edges = (
    (-dx, x1 - xmin),
    (dx, xmax - x1),
    (-dy, y1 - ymin),
    (dy, ymax - y1),
  )

  for (p, q) in edges {
    if p == 0 {
      if q < 0 { return none }
    } else {
      let t = q / p
      if p < 0 {
        t0 = calc.max(t0, t)
      } else {
        t1 = calc.min(t1, t)
      }
      if t0 > t1 { return none }
    }
  }

  let nx1 = x1 + t0 * dx
  let ny1 = y1 + t0 * dy
  let nx2 = x1 + t1 * dx
  let ny2 = y1 + t1 * dy

  ((nx1, ny1), (nx2, ny2))
}

// Convert user-friendly label-side to CeTZ anchor
// "above" means label is above the point, so anchor at "south" (bottom of text)
#let side-to-anchor(side) = {
  if side == none { return none }
  let mapping = (
    "above": "south",
    "below": "north",
    "left": "east",
    "right": "west",
    "above-left": "south-east",
    "above-right": "south-west",
    "below-left": "north-east",
    "below-right": "north-west",
  )
  mapping.at(side, default: side)  // fallback to raw anchor if not in mapping
}

#let format-number(n, precision: 2) = {
  if calc.abs(n - calc.round(n)) < 0.0001 {
    str(int(calc.round(n)))
  } else {
    let rounded = calc.round(n * calc.pow(10, precision)) / calc.pow(10, precision)
    str(rounded)
  }
}

#let generate-ticks(min, max, step: auto, count: auto) = {
  let actual-step = if step != auto {
    step
  } else if count != auto {
    (max - min) / count
  } else {
    let range = max - min
    // Use range/10 as base to ensure ~10 ticks, then round to nice number
    let raw-step = range / 10
    let magnitude = calc.pow(10, calc.floor(calc.log(raw-step, base: 10)))
    let normalized = raw-step / magnitude
    if normalized <= 1.5 { magnitude }
    else if normalized <= 3 { magnitude * 2 }
    else if normalized <= 7 { magnitude * 5 }
    else { magnitude * 10 }
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

// ============================================================================
// MARKER DRAWING
// ============================================================================

#let draw-marker(ctx, pos, marker-type, size, fill-color, stroke-style) = {
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

// ============================================================================
// MAIN PLOT FUNCTION
// ============================================================================

/// Create a 2D plot with axes, grid, and function/data visualization.
///
/// - xmin (auto, float): Minimum x value
/// - xmax (auto, float): Maximum x value
/// - ymin (auto, float): Minimum y value
/// - ymax (auto, float): Maximum y value
/// - width (auto, float): Plot width in cm
/// - height (auto, float): Plot height in cm
/// - scale (auto, float): Scale factor for the entire plot (default: 1)
/// - xlabel (auto, content): X-axis label
/// - ylabel (auto, content): Y-axis label
/// - xlabel-pos (auto, str, array): X label position ("end", "center", or (x,y))
/// - ylabel-pos (auto, str, array): Y label position ("end", "center", or (x,y))
/// - xlabel-anchor (auto, str): X label anchor point
/// - ylabel-anchor (auto, str): Y label anchor point
/// - xlabel-offset (auto, array): X label offset (x, y) in cm
/// - ylabel-offset (auto, array): Y label offset (x, y) in cm
/// - xtick (auto, none, array): X tick positions
/// - ytick (auto, none, array): Y tick positions
/// - xtick-step (auto, float): X tick step
/// - ytick-step (auto, float): Y tick step
/// - xtick-labels (auto, array): Custom X tick labels
/// - ytick-labels (auto, array): Custom Y tick labels
/// - show-grid (auto, bool, str): Grid display ("major", "minor", "both", true, false)
/// - minor-grid-step (auto, int): Minor grid subdivisions per major tick
/// - axis-x-pos (auto, float, str): X-axis y-position ("bottom", "center", or value)
/// - axis-y-pos (auto, float, str): Y-axis x-position ("left", "center", or value)
/// - axis-x-extend (auto, float, array): X-axis extension beyond plot (value or (left, right))
/// - axis-y-extend (auto, float, array): Y-axis extension beyond plot (value or (bottom, top))
/// - show-origin (auto, bool): Show "0" label at origin (default: true)
/// - tick-label-size (auto, length): Font size for tick labels (default: 0.65em)
/// - axis-label-size (auto, length): Font size for axis labels x/y (default: 0.8em)
/// - style (none, dictionary): Style overrides
/// - ..functions: Function/data specifications to plot
#let plot(
  xmin: auto,
  xmax: auto,
  ymin: auto,
  ymax: auto,
  width: auto,
  height: auto,
  scale: auto,
  xlabel: auto,
  ylabel: auto,
  xlabel-pos: auto,
  ylabel-pos: auto,
  xlabel-anchor: auto,
  ylabel-anchor: auto,
  xlabel-offset: auto,
  ylabel-offset: auto,
  xtick: auto,
  ytick: auto,
  xtick-step: auto,
  ytick-step: auto,
  xtick-labels: auto,
  ytick-labels: auto,
  show-grid: auto,
  minor-grid-step: auto,
  axis-x-pos: auto,
  axis-y-pos: auto,
  axis-x-extend: auto,
  axis-y-extend: auto,
  show-origin: auto,
  tick-label-size: auto,
  axis-label-size: auto,
  style: none,
  ..functions,
) = context {
  let defaults = _plot-defaults.get()

  let resolve(val, key, fallback) = {
    if val != auto { val }
    else if key in defaults { defaults.at(key) }
    else { fallback }
  }

  let xmin = resolve(xmin, "xmin", -5)
  let xmax = resolve(xmax, "xmax", 5)
  let ymin = resolve(ymin, "ymin", -5)
  let ymax = resolve(ymax, "ymax", 5)
  let width = resolve(width, "width", 6)
  let height = resolve(height, "height", 6)
  let scale = resolve(scale, "scale", 1)
  let width = width * scale
  let height = height * scale
  let xlabel = resolve(xlabel, "xlabel", none)
  let ylabel = resolve(ylabel, "ylabel", none)
  let xlabel-pos = resolve(xlabel-pos, "xlabel-pos", "end")
  let ylabel-pos = resolve(ylabel-pos, "ylabel-pos", "end")
  let xlabel-anchor = resolve(xlabel-anchor, "xlabel-anchor", "west")
  let ylabel-anchor = resolve(ylabel-anchor, "ylabel-anchor", "south")
  let xlabel-offset = resolve(xlabel-offset, "xlabel-offset", (0.3, 0))
  let ylabel-offset = resolve(ylabel-offset, "ylabel-offset", (0, 0.3))
  let xtick = resolve(xtick, "xtick", auto)
  let ytick = resolve(ytick, "ytick", auto)
  let xtick-step = resolve(xtick-step, "xtick-step", auto)
  let ytick-step = resolve(ytick-step, "ytick-step", auto)
  let xtick-labels = resolve(xtick-labels, "xtick-labels", auto)
  let ytick-labels = resolve(ytick-labels, "ytick-labels", auto)
  let show-grid = resolve(show-grid, "show-grid", false)
  let minor-grid-step = resolve(minor-grid-step, "minor-grid-step", 2)
  let axis-x-pos = resolve(axis-x-pos, "axis-x-pos", 0)
  let axis-y-pos = resolve(axis-y-pos, "axis-y-pos", 0)
  let axis-x-extend = resolve(axis-x-extend, "axis-x-extend", 0)
  let axis-y-extend = resolve(axis-y-extend, "axis-y-extend", 0)
  let show-origin = resolve(show-origin, "show-origin", true)
  let tick-label-size = resolve(tick-label-size, "tick-label-size", auto)
  let axis-label-size = resolve(axis-label-size, "axis-label-size", auto)

  // Normalize extend values to (left/bottom, right/top) tuples
  let x-extend = if type(axis-x-extend) == array { axis-x-extend } else { (axis-x-extend, axis-x-extend) }
  let y-extend = if type(axis-y-extend) == array { axis-y-extend } else { (axis-y-extend, axis-y-extend) }

  let s = merge-styles(style)

  // Override style values with direct parameters if set
  if tick-label-size != auto {
    s.ticks.label-size = tick-label-size
  }
  if axis-label-size != auto {
    s.labels.size = axis-label-size
  }

  let x-scale = width / (xmax - xmin)
  let y-scale = height / (ymax - ymin)

  let to-canvas(x, y) = {
    ((x - xmin) * x-scale, (y - ymin) * y-scale)
  }

  let x-axis-y = if axis-x-pos == "bottom" { ymin }
                 else if axis-x-pos == "center" { 0 }
                 else { calc.max(ymin, calc.min(ymax, axis-x-pos)) }

  let y-axis-x = if axis-y-pos == "left" { xmin }
                 else if axis-y-pos == "center" { 0 }
                 else { calc.max(xmin, calc.min(xmax, axis-y-pos)) }

  let x-ticks = if xtick == none { (ticks: (), step: 1) }
                else if xtick == auto { generate-ticks(xmin, xmax, step: xtick-step) }
                else { (ticks: xtick, step: if xtick.len() > 1 { xtick.at(1) - xtick.at(0) } else { 1 }) }

  let y-ticks = if ytick == none { (ticks: (), step: 1) }
                else if ytick == auto { generate-ticks(ymin, ymax, step: ytick-step) }
                else { (ticks: ytick, step: if ytick.len() > 1 { ytick.at(1) - ytick.at(0) } else { 1 }) }

  cetz.canvas(length: 1cm, {
    import cetz.draw: *

    set-style(
      mark: (fill: black, scale: 1.5),
      stroke: (cap: "round", join: "round"),
      content: (padding: 2pt),
    )

    // Background
    if s.background.fill != none or s.background.stroke != none {
      let (bx1, by1) = to-canvas(xmin, ymin)
      let (bx2, by2) = to-canvas(xmax, ymax)
      rect((bx1, by1), (bx2, by2), fill: s.background.fill, stroke: s.background.stroke)
    }

    // Grid extension bounds (in canvas coordinates)
    let grid-x-start = -x-extend.at(0) * x-scale
    let grid-x-end = width + x-extend.at(1) * x-scale
    let grid-y-start = -y-extend.at(0) * y-scale
    let grid-y-end = height + y-extend.at(1) * y-scale

    // Minor grid
    if show-grid == "minor" or show-grid == "both" or show-grid == true {
      let minor-x-step = x-ticks.step / minor-grid-step
      let minor-y-step = y-ticks.step / minor-grid-step
      let nx = int(calc.ceil((xmax - xmin) / minor-x-step)) + 1
      let ny = int(calc.ceil((ymax - ymin) / minor-y-step)) + 1

      for i in range(nx) {
        let x = xmin + i * minor-x-step
        if x <= xmax {
          let cx = (x - xmin) * x-scale
          line((cx, grid-y-start), (cx, grid-y-end), stroke: s.grid.minor.stroke)
        }
      }
      for i in range(ny) {
        let y = ymin + i * minor-y-step
        if y <= ymax {
          let cy = (y - ymin) * y-scale
          line((grid-x-start, cy), (grid-x-end, cy), stroke: s.grid.minor.stroke)
        }
      }
    }

    // Major grid
    if show-grid == "major" or show-grid == "both" or show-grid == true {
      for x in x-ticks.ticks {
        let cx = (x - xmin) * x-scale
        line((cx, grid-y-start), (cx, grid-y-end), stroke: s.grid.major.stroke)
      }
      for y in y-ticks.ticks {
        let cy = (y - ymin) * y-scale
        line((grid-x-start, cy), (grid-x-end, cy), stroke: s.grid.major.stroke)
      }
    }

    // Axes (with optional extension beyond plot area)
    let (x1, y-ax) = to-canvas(xmin, x-axis-y)
    let (x2, _) = to-canvas(xmax, x-axis-y)
    let x1-ext = x1 - x-extend.at(0) * x-scale
    let x2-ext = x2 + x-extend.at(1) * x-scale
    line((x1-ext, y-ax), (x2-ext, y-ax), stroke: s.axis.stroke, mark: (end: s.axis.arrow))

    let (x-ax, y1) = to-canvas(y-axis-x, ymin)
    let (_, y2) = to-canvas(y-axis-x, ymax)
    let y1-ext = y1 - y-extend.at(0) * y-scale
    let y2-ext = y2 + y-extend.at(1) * y-scale
    line((x-ax, y1-ext), (x-ax, y2-ext), stroke: s.axis.stroke, mark: (end: s.axis.arrow))

    // Ticks and labels
    let tick-len = s.ticks.length

    for (i, x) in x-ticks.ticks.enumerate() {
      let (cx, cy) = to-canvas(x, x-axis-y)
      line((cx, cy - tick-len), (cx, cy + tick-len), stroke: s.ticks.stroke)
      let label = if xtick-labels == auto { format-number(x) }
                  else if xtick-labels != none and i < xtick-labels.len() { xtick-labels.at(i) }
                  else { "" }
      if label != "" and label != "0" {
        content((cx, cy - tick-len - s.ticks.label-offset),
                text(size: s.ticks.label-size)[#label], anchor: "north")
      }
    }

    for (i, y) in y-ticks.ticks.enumerate() {
      let (cx, cy) = to-canvas(y-axis-x, y)
      line((cx - tick-len, cy), (cx + tick-len, cy), stroke: s.ticks.stroke)
      let label = if ytick-labels == auto { format-number(y) }
                  else if ytick-labels != none and i < ytick-labels.len() { ytick-labels.at(i) }
                  else { "" }
      if label != "" and label != "0" {
        content((cx - tick-len - s.ticks.label-offset, cy),
                text(size: s.ticks.label-size)[#label], anchor: "east")
      }
    }

    // Origin label
    if show-origin and calc.abs(x-axis-y) < 0.0001 and calc.abs(y-axis-x) < 0.0001 {
      let (ox, oy) = to-canvas(0, 0)
      content((ox - tick-len - 0.05, oy - tick-len - 0.05),
              text(size: s.ticks.label-size)[0], anchor: "north-east")
    }

    // Axis labels
    if xlabel != none {
      let (lx, ly) = if xlabel-pos == "end" { to-canvas(xmax, x-axis-y) }
                     else if xlabel-pos == "center" { to-canvas((xmin + xmax) / 2, x-axis-y) }
                     else if type(xlabel-pos) == array { to-canvas(xlabel-pos.at(0), xlabel-pos.at(1)) }
                     else { to-canvas(xmax, x-axis-y) }
      let (ox, oy) = xlabel-offset
      content((lx + ox, ly + oy), text(size: s.labels.size)[#xlabel], anchor: xlabel-anchor)
    }

    if ylabel != none {
      let (lx, ly) = if ylabel-pos == "end" { to-canvas(y-axis-x, ymax) }
                     else if ylabel-pos == "center" { to-canvas(y-axis-x, (ymin + ymax) / 2) }
                     else if type(ylabel-pos) == array { to-canvas(ylabel-pos.at(0), ylabel-pos.at(1)) }
                     else { to-canvas(y-axis-x, ymax) }
      let (ox, oy) = ylabel-offset
      content((lx + ox, ly + oy), text(size: s.labels.size)[#ylabel], anchor: ylabel-anchor)
    }

    // Extended bounds for clipping area
    let x-clip-min = xmin - x-extend.at(0)
    let x-clip-max = xmax + x-extend.at(1)
    let y-clip-min = ymin - y-extend.at(0)
    let y-clip-max = ymax + y-extend.at(1)

    // Sampling bounds (extend further so lines reach clip edges)
    let sample-margin = calc.max(xmax - xmin, ymax - ymin) * 0.5
    let x-plot-min = x-clip-min - sample-margin
    let x-plot-max = x-clip-max + sample-margin
    let y-plot-min = y-clip-min - sample-margin
    let y-plot-max = y-clip-max + sample-margin

    // Clip bounds in canvas coordinates
    let clip-x1 = grid-x-start
    let clip-y1 = grid-y-start
    let clip-x2 = grid-x-end
    let clip-y2 = grid-y-end

    // Plot functions and data (with manual line clipping)
    for func-spec in functions.pos() {
      let fn = func-spec.at("fn", default: none)
      let data-points = func-spec.at("points", default: none)
      let stroke-style = func-spec.at("stroke", default: s.plot.stroke)
      let mark-type = func-spec.at("mark", default: "none")
      let mark-size = func-spec.at("mark-size", default: s.marker.size)
      let mark-fill = func-spec.at("mark-fill", default: s.marker.fill)
      let mark-stroke = func-spec.at("mark-stroke", default: s.marker.stroke)
      let mark-interval = func-spec.at("mark-interval", default: 1)
      let label = func-spec.at("label", default: none)
      let points-to-draw = ()

      if fn != none {
        let domain-min = func-spec.at("domain", default: (x-plot-min, x-plot-max)).at(0)
        let domain-max = func-spec.at("domain", default: (x-plot-min, x-plot-max)).at(1)
        let samples = func-spec.at("samples", default: s.plot.samples)
        let step = (domain-max - domain-min) / samples

        // Collect all valid points first
        let all-points = ()
        for i in range(samples + 1) {
          let x = domain-min + i * step
          let y = fn(x)
          if y != none and not (y).is-nan() {
            let (cx, cy) = to-canvas(x, y)
            all-points.push((cx, cy, i))
            // Check if point is inside clip area for markers
            if cx >= clip-x1 and cx <= clip-x2 and cy >= clip-y1 and cy <= clip-y2 {
              points-to-draw.push((cx, cy, i))
            }
          } else {
            all-points.push(none)  // Mark break in function
          }
        }

        // Draw clipped line segments between consecutive valid points
        for j in range(all-points.len() - 1) {
          let pt1 = all-points.at(j)
          let pt2 = all-points.at(j + 1)
          if pt1 != none and pt2 != none {
            let (x1, y1, _) = pt1
            let (x2, y2, _) = pt2
            let clipped = clip-segment((x1, y1), (x2, y2), clip-x1, clip-y1, clip-x2, clip-y2)
            if clipped != none {
              let (p1, p2) = clipped
              line(p1, p2, stroke: stroke-style)
            }
          }
        }

        if label != none {
          let label-pos = func-spec.at("label-pos", default: 0.8)
          let label-side = func-spec.at("label-side", default: none)
          let label-anchor = if label-side != none { side-to-anchor(label-side) } else { func-spec.at("label-anchor", default: "south-west") }
          // Use visible area for label positioning, not extended sampling domain
          let lx = x-clip-min + (x-clip-max - x-clip-min) * label-pos
          let ly = fn(lx)
          if ly != none and not (ly).is-nan() and ly >= y-clip-min and ly <= y-clip-max {
            let (cx, cy) = to-canvas(lx, ly)
            content((cx, cy), label, anchor: label-anchor)
          }
        }

      } else if data-points != none {
        let connect = func-spec.at("connect", default: true)
        let canvas-points = ()
        for (i, pt) in data-points.enumerate() {
          let (x, y) = pt
          if x >= x-clip-min and x <= x-clip-max and y >= y-clip-min and y <= y-clip-max {
            let (cx, cy) = to-canvas(x, y)
            canvas-points.push((cx, cy))
            points-to-draw.push((cx, cy, i))
          }
        }
        if connect and canvas-points.len() > 1 {
          line(..canvas-points, stroke: stroke-style)
        }
        if label != none and canvas-points.len() > 0 {
          let label-pos = func-spec.at("label-pos", default: 0.8)
          let label-side = func-spec.at("label-side", default: none)
          let label-anchor = if label-side != none { side-to-anchor(label-side) } else { func-spec.at("label-anchor", default: "south-west") }
          let idx = calc.min(int(canvas-points.len() * label-pos), canvas-points.len() - 1)
          let (cx, cy) = canvas-points.at(idx)
          content((cx, cy), label, anchor: label-anchor)
        }
      }

      if mark-type != "none" and points-to-draw.len() > 0 {
        for (cx, cy, i) in points-to-draw {
          if calc.rem(i, mark-interval) == 0 {
            draw-marker(none, (cx, cy), mark-type, mark-size, mark-fill, mark-stroke)
          }
        }
      }
    }
  })
}

// ============================================================================
// CONVENIENCE FUNCTIONS
// ============================================================================

/// Quick single function plot with auto-scaling.
#let plot-fn(
  fn,
  domain: (-5, 5),
  ymin: auto,
  ymax: auto,
  stroke: blue + 1.2pt,
  ..args
) = {
  let samples = args.named().at("samples", default: 100)
  let (y-min, y-max) = if ymin == auto or ymax == auto {
    let ys = ()
    let step = (domain.at(1) - domain.at(0)) / samples
    for i in range(samples + 1) {
      let x = domain.at(0) + i * step
      let y = fn(x)
      if y != none and not (y).is-nan() { ys.push(y) }
    }
    let min-y = calc.min(..ys)
    let max-y = calc.max(..ys)
    let padding = (max-y - min-y) * 0.1
    (min-y - padding, max-y + padding)
  } else { (ymin, ymax) }

  plot(
    xmin: domain.at(0), xmax: domain.at(1),
    ymin: if ymin == auto { y-min } else { ymin },
    ymax: if ymax == auto { y-max } else { ymax },
    ..args,
    (fn: fn, stroke: stroke, domain: domain),
  )
}

/// Create a scatter plot specification.
#let scatter(
  points,
  mark: "*",
  mark-size: 0.12,
  mark-fill: blue,
  mark-stroke: blue + 0.8pt,
  connect: false,
  stroke: none,
  label: none,
  label-pos: 0.8,
  label-anchor: "south-west",
) = (
  points: points, mark: mark, mark-size: mark-size,
  mark-fill: mark-fill, mark-stroke: mark-stroke,
  connect: connect, stroke: stroke, label: label,
  label-pos: label-pos, label-anchor: label-anchor,
)

/// Create a line plot with markers specification.
#let line-plot(
  points,
  stroke: blue + 1.2pt,
  mark: "o",
  mark-size: 0.1,
  mark-fill: white,
  mark-stroke: blue + 0.8pt,
  label: none,
  label-pos: 0.8,
  label-anchor: "south-west",
) = (
  points: points, stroke: stroke, mark: mark,
  mark-size: mark-size, mark-fill: mark-fill,
  mark-stroke: mark-stroke, connect: true,
  label: label, label-pos: label-pos, label-anchor: label-anchor,
)

/// Create a function plot specification with markers.
#let func-plot(
  fn,
  domain: auto,
  stroke: blue + 1.2pt,
  samples: 100,
  mark: "none",
  mark-size: 0.1,
  mark-fill: blue,
  mark-stroke: blue + 0.8pt,
  mark-interval: 10,
  label: none,
  label-pos: 0.8,
  label-anchor: "south-west",
) = {
  let spec = (
    fn: fn, stroke: stroke, samples: samples,
    mark: mark, mark-size: mark-size, mark-fill: mark-fill,
    mark-stroke: mark-stroke, mark-interval: mark-interval,
    label: label, label-pos: label-pos, label-anchor: label-anchor,
  )
  if domain != auto { spec.insert("domain", domain) }
  spec
}
