// simple-plot - A simple pgfplots-like function plotting library for Typst
// https://github.com/nathan/simple-plot
// License: MIT

#import "@preview/cetz:0.5.2" as cetz

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
    arrow: (symbol: "stealth", fill: black, scale: 0.55),
  ),
  grid: (
    // Elegant thin grid lines inspired by tkz-fct
    major: (stroke: luma(200) + 0.5pt),
    minor: (stroke: luma(230) + 0.3pt),
  ),
  ticks: (
    length: 0.1,
    stroke: black + 0.6pt,
    label-offset: 0.15,
    label-size: 10pt,
    label-fill: black,
  ),
  origin: (
    label-offset: (-0.11, -0.11),
    label-anchor: "north-east",
    leader: true,
    leader-stroke: black + 0.6pt,
    leader-gap: 0.025,
    leader-end-gap: 0.025,
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
    size: 10pt,
    fill: black,
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

#let merge-styles(..styles) = {
  let result = default-style
  for user-style in styles.pos() {
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

// Clip a line segment to an ellipse (cx, cy, rx, ry) using parametric quadratic solve
#let clip-segment-ellipse(p1, p2, cx, cy, rx, ry) = {
  let (x1, y1) = p1
  let (x2, y2) = p2
  let dx = x2 - x1
  let dy = y2 - y1

  let is-inside(x, y) = {
    let ex = (x - cx) / rx
    let ey = (y - cy) / ry
    ex * ex + ey * ey <= 1.0001
  }

  let i1 = is-inside(x1, y1)
  let i2 = is-inside(x2, y2)
  if i1 and i2 { return (p1, p2) }

  let A = (dx / rx) * (dx / rx) + (dy / ry) * (dy / ry)
  if A < 1e-10 { return none }

  let ax = x1 - cx
  let ay = y1 - cy
  let B = 2.0 * (ax * dx / (rx * rx) + ay * dy / (ry * ry))
  let C = (ax / rx) * (ax / rx) + (ay / ry) * (ay / ry) - 1.0

  let disc = B * B - 4.0 * A * C
  if disc < 0 { return none }

  let sd = calc.sqrt(disc)
  let ta = (-B - sd) / (2.0 * A)
  let tb = (-B + sd) / (2.0 * A)
  let te = calc.min(ta, tb)
  let tx = calc.max(ta, tb)

  let t0 = if i1 { 0.0 } else { calc.max(0.0, te) }
  let t1 = if i2 { 1.0 } else { calc.min(1.0, tx) }

  if t0 >= t1 or t1 < 0.0 or t0 > 1.0 { return none }
  (
    (x1 + t0 * dx, y1 + t0 * dy),
    (x1 + t1 * dx, y1 + t1 * dy),
  )
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

// Generate ticks with step=1 by default, starting on integers
#let generate-ticks(min, max, step: auto, count: auto) = {
  let actual-step = if step != auto {
    step
  } else if count != auto {
    (max - min) / count
  } else {
    // Default to step=1 for clean integer ticks
    1
  }

  let ticks = ()
  // Start at the first integer >= min (aligned to step)
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
/// - xtick-step (auto, float): X tick step (default: 1)
/// - ytick-step (auto, float): Y tick step (default: 1)
/// - xtick-labels (auto, none, array): Custom X tick labels (none = no labels)
/// - ytick-labels (auto, none, array): Custom Y tick labels (none = no labels)
/// - xtick-label-step (auto, int): Show X tick label every N ticks (e.g., 5 = labels at 0,5,10...)
/// - ytick-label-step (auto, int): Show Y tick label every N ticks (e.g., 5 = labels at 0,5,10...)
/// - show-grid (auto, bool, str): Grid display ("major", "minor", "both", true, false)
/// - minor-grid-step (auto, int): Minor grid subdivisions per major tick (default: 5)
/// - grid-label-break (auto, bool): Break grid lines around tick labels (default: true)
/// - unit-label-only (auto, bool): Show only "1" label on axes (not -1), useful for minimal style (default: false)
/// - axis-x-pos (auto, float, str): X-axis y-position ("bottom", "center", or value)
/// - axis-y-pos (auto, float, str): Y-axis x-position ("left", "center", or value)
/// - axis-x-extend (auto, float, array): X-axis extension beyond plot (value or (left, right))
/// - axis-y-extend (auto, float, array): Y-axis extension beyond plot (value or (bottom, top))
/// - show-origin (auto, bool): Show "0" label at origin (default: true)
/// - origin-label-offset (auto, array): Origin label offset from (0,0) in cm (default: (-0.11, -0.11))
/// - origin-label-anchor (auto, str): Origin label anchor (default: "north-east")
/// - origin-leader (auto, bool): Draw a subtle leader from origin label toward (0,0) (default: true)
/// - origin-leader-stroke (auto, stroke): Origin leader stroke (default: black + 0.6pt)
/// - origin-leader-gap (auto, float): Gap from origin before leader starts, in cm (default: 0.025)
/// - origin-leader-end-gap (auto, float): Gap before the label anchor, in cm (default: 0.025)
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
  xtick-label-step: auto,
  ytick-label-step: auto,
  show-grid: auto,
  minor-grid-step: auto,
  grid-label-break: auto,
  unit-label-only: auto,
  axis-x-pos: auto,
  axis-y-pos: auto,
  axis-x-extend: auto,
  axis-y-extend: auto,
  show-origin: auto,
  origin-label-offset: auto,
  origin-label-anchor: auto,
  origin-leader: auto,
  origin-leader-stroke: auto,
  origin-leader-gap: auto,
  origin-leader-end-gap: auto,
  tick-label-size: auto,
  axis-label-size: auto,
  style: none,
  series: none,
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
  let xlabel = resolve(xlabel, "xlabel", $x$)
  let ylabel = resolve(ylabel, "ylabel", $y$)
  let xlabel-pos = resolve(xlabel-pos, "xlabel-pos", "end")
  let ylabel-pos = resolve(ylabel-pos, "ylabel-pos", "end")
  let xlabel-anchor = resolve(xlabel-anchor, "xlabel-anchor", "north")
  let ylabel-anchor = resolve(ylabel-anchor, "ylabel-anchor", "east")
  let xlabel-offset = resolve(xlabel-offset, "xlabel-offset", (0.0, -0.05))
  let ylabel-offset = resolve(ylabel-offset, "ylabel-offset", (-0.05, 0.0))
  let xtick = resolve(xtick, "xtick", auto)
  let ytick = resolve(ytick, "ytick", auto)
  let xtick-step = resolve(xtick-step, "xtick-step", auto)
  let ytick-step = resolve(ytick-step, "ytick-step", auto)
  let xtick-labels = resolve(xtick-labels, "xtick-labels", auto)
  let ytick-labels = resolve(ytick-labels, "ytick-labels", auto)
  let xtick-label-step = resolve(xtick-label-step, "xtick-label-step", 1)
  let ytick-label-step = resolve(ytick-label-step, "ytick-label-step", 1)
  let show-grid = resolve(show-grid, "show-grid", false)
  let minor-grid-step = resolve(minor-grid-step, "minor-grid-step", 5)
  let grid-label-break = resolve(grid-label-break, "grid-label-break", true)
  let unit-label-only = resolve(unit-label-only, "unit-label-only", false)
  let axis-x-pos = resolve(axis-x-pos, "axis-x-pos", 0)
  let axis-y-pos = resolve(axis-y-pos, "axis-y-pos", 0)
  let axis-x-extend = resolve(axis-x-extend, "axis-x-extend", (0, 0.5))
  let axis-y-extend = resolve(axis-y-extend, "axis-y-extend", (0, 0.5))
  let show-origin = resolve(show-origin, "show-origin", true)
  let origin-label-offset = resolve(origin-label-offset, "origin-label-offset", auto)
  let origin-label-anchor = resolve(origin-label-anchor, "origin-label-anchor", auto)
  let origin-leader = resolve(origin-leader, "origin-leader", auto)
  let origin-leader-stroke = resolve(origin-leader-stroke, "origin-leader-stroke", auto)
  let origin-leader-gap = resolve(origin-leader-gap, "origin-leader-gap", auto)
  let origin-leader-end-gap = resolve(origin-leader-end-gap, "origin-leader-end-gap", auto)
  let tick-label-size = resolve(tick-label-size, "tick-label-size", auto)
  let axis-label-size = resolve(axis-label-size, "axis-label-size", auto)

  // Normalize extend values to (left/bottom, right/top) tuples
  let x-extend = if type(axis-x-extend) == array { axis-x-extend } else { (axis-x-extend, axis-x-extend) }
  let y-extend = if type(axis-y-extend) == array { axis-y-extend } else { (axis-y-extend, axis-y-extend) }

  let s = merge-styles(defaults.at("style", default: none), style)

  // Override style values with direct parameters if set
  if tick-label-size != auto {
    s.ticks.label-size = tick-label-size
  }
  if axis-label-size != auto {
    s.labels.size = axis-label-size
  }
  if origin-label-offset != auto {
    s.origin.label-offset = origin-label-offset
  }
  if origin-label-anchor != auto {
    s.origin.label-anchor = origin-label-anchor
  }
  if origin-leader != auto {
    s.origin.leader = origin-leader
  }
  if origin-leader-stroke != auto {
    s.origin.leader-stroke = origin-leader-stroke
  }
  if origin-leader-gap != auto {
    s.origin.leader-gap = origin-leader-gap
  }
  if origin-leader-end-gap != auto {
    s.origin.leader-end-gap = origin-leader-end-gap
  }

  // Scale factors in CeTZ canvas units
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
    // Save Typst's native `line` before cetz shadows it — needed for pattern() fills
    let native-line = line
    import cetz.draw: *

    // ── Hatch pattern builder ────────────────────────────────────────────────
    // Returns a Typst fill paint: a solid color or a repeating pattern.
    // style: none | "ne" | "nw" | "h" | "v" | "cross" | "grid"
    // spacing: absolute length (e.g. 5pt)
    // stroke-style: a Typst stroke value
    let make-hatch-pattern(style, spacing, stroke-style) = {
      if style == none { return none }
      let s = spacing
      if style == "ne" {
        tiling(size: (s, s))[
          #place(native-line(start: (0pt, s), end: (s, 0pt), stroke: stroke-style))
        ]
      } else if style == "nw" {
        tiling(size: (s, s))[
          #place(native-line(start: (0pt, 0pt), end: (s, s), stroke: stroke-style))
        ]
      } else if style == "h" {
        tiling(size: (s, s))[
          #place(native-line(start: (0pt, s / 2), end: (s, s / 2), stroke: stroke-style))
        ]
      } else if style == "v" {
        tiling(size: (s, s))[
          #place(native-line(start: (s / 2, 0pt), end: (s / 2, s), stroke: stroke-style))
        ]
      } else if style == "cross" {
        tiling(size: (s, s))[
          #place(native-line(start: (0pt, s), end: (s, 0pt), stroke: stroke-style))
          #place(native-line(start: (0pt, 0pt), end: (s, s), stroke: stroke-style))
        ]
      } else if style == "grid" {
        tiling(size: (s, s))[
          #place(native-line(start: (0pt, s / 2), end: (s, s / 2), stroke: stroke-style))
          #place(native-line(start: (s / 2, 0pt), end: (s / 2, s), stroke: stroke-style))
        ]
      }
    }

    set-style(
      mark: (fill: black),
      stroke: (cap: "round", join: "round"),
      content: (padding: 2pt),
    )

    // Background
    if s.background.fill != none or s.background.stroke != none {
      let (bx1, by1) = to-canvas(xmin, ymin)
      let (bx2, by2) = to-canvas(xmax, ymax)
      rect((bx1, by1), (bx2, by2), fill: s.background.fill, stroke: s.background.stroke)
    }

    // Grid bounds - grid stays within the main plot area (no extension)
    // Only the axes extend beyond the grid
    let grid-x-start = 0
    let grid-x-end = width
    let grid-y-start = 0
    let grid-y-end = height

    // Tick and label dimensions (already unitless floats)
    let tick-len = s.ticks.length
    let label-offset = s.ticks.label-offset

    // Helper: check if a tick value should have a label displayed
    let x-has-label(x) = {
      if xtick-labels == none { return false }
      if calc.abs(x) < 0.0001 { return false }  // 0 handled separately
      let label-interval = x-ticks.step * xtick-label-step
      let at-interval = calc.abs(calc.rem(x, label-interval)) < 0.0001 or calc.abs(calc.rem(x, label-interval) - label-interval) < 0.0001
      if unit-label-only and calc.abs(x - 1) > 0.0001 { return false }
      at-interval
    }

    let y-has-label(y) = {
      if ytick-labels == none { return false }
      if calc.abs(y) < 0.0001 { return false }  // 0 handled separately
      let label-interval = y-ticks.step * ytick-label-step
      let at-interval = calc.abs(calc.rem(y, label-interval)) < 0.0001 or calc.abs(calc.rem(y, label-interval) - label-interval) < 0.0001
      if unit-label-only and calc.abs(y - 1) > 0.0001 { return false }
      at-interval
    }

    // Pre-compute label exclusion zones for gap-based grid-label-break
    // Instead of drawing full grid lines and overlaying white rectangles,
    // we draw grid lines with gaps where labels are placed.
    // This works on any background color.
    let x-break-zones = ()  // Each: (x-left, x-right, gap-y-bottom, gap-y-top)
    let y-break-zones = ()  // Each: (y-bottom, y-top, gap-x-left, gap-x-right)

    if grid-label-break and (show-grid == "major" or show-grid == "both" or show-grid == true) {
      let y-ax-canvas = (x-axis-y - ymin) * y-scale
      let x-ax-canvas = (y-axis-x - xmin) * x-scale

      let scale-factor = 1.0
      let pad-x = 0.07 * scale-factor
      let pad-y = 0.05 * scale-factor
      let char-width = 0.17 * scale-factor
      let char-height = 0.25 * scale-factor
      let minus-width = 0.10 * scale-factor

      let calc-text-width(val) = {
        let label-text = format-number(val)
        if val < 0 {
          minus-width + (label-text.len() - 1) * char-width
        } else {
          label-text.len() * char-width
        }
      }

      // X-axis tick labels (below axis, anchor "north")
      for x in x-ticks.ticks {
        if x-has-label(x) and calc.abs(x - xmax) > 0.0001 {
          let cx = (x - xmin) * x-scale
          let text-width = calc-text-width(x)
          let anchor-x = cx
          let anchor-y = y-ax-canvas - tick-len - label-offset

          x-break-zones.push((
            anchor-x - text-width / 2 - pad-x,
            anchor-x + text-width / 2 + pad-x,
            anchor-y - char-height - pad-y,
            anchor-y + pad-y,
          ))
        }
      }

      // Y-axis tick labels (left of axis, anchor "east")
      for y in y-ticks.ticks {
        if y-has-label(y) and calc.abs(y - ymax) > 0.0001 {
          let cy = (y - ymin) * y-scale
          let text-width = calc-text-width(y)
          let anchor-x = x-ax-canvas - tick-len - label-offset
          let anchor-y = cy

          y-break-zones.push((
            anchor-y - char-height / 2 - pad-y,
            anchor-y + char-height / 2 + pad-y,
            anchor-x - text-width - pad-x,
            anchor-x + pad-x,
          ))
        }
      }

      // Origin label zone (anchor "north-east", text extends down and left)
      if show-origin and calc.abs(x-axis-y) < 0.0001 and calc.abs(y-axis-x) < 0.0001 {
        let (ox, oy) = to-canvas(0, 0)
        let anchor-x = ox - tick-len - 0.05
        let anchor-y = oy - tick-len - 0.05
        let text-width = char-width  // Single "0"

        // Origin label can intersect both vertical and horizontal grid lines
        x-break-zones.push((
          anchor-x - text-width - pad-x,
          anchor-x + pad-x,
          anchor-y - char-height - pad-y,
          anchor-y + pad-y,
        ))
        y-break-zones.push((
          anchor-y - char-height - pad-y,
          anchor-y + pad-y,
          anchor-x - text-width - pad-x,
          anchor-x + pad-x,
        ))
      }
    }

    // Helper: draw a vertical line with gaps for break zones
    let draw-vline-with-gaps(cx, y-start, y-end, stroke-style) = {
      // Collect gap y-ranges that intersect this vertical line's x position
      let gaps = ()
      for zone in x-break-zones {
        let (x-left, x-right, gap-y-bottom, gap-y-top) = zone
        if cx >= x-left and cx <= x-right {
          gaps.push((gap-y-bottom, gap-y-top))
        }
      }

      if gaps.len() == 0 {
        line((cx, y-start), (cx, y-end), stroke: stroke-style)
      } else {
        // Sort gaps by bottom y
        let sorted-gaps = gaps.sorted(key: g => g.at(0))
        let current-y = y-start
        for (gap-bottom, gap-top) in sorted-gaps {
          let seg-end = calc.max(current-y, calc.min(gap-bottom, y-end))
          if seg-end > current-y + 0.001 {
            line((cx, current-y), (cx, seg-end), stroke: stroke-style)
          }
          current-y = calc.max(current-y, gap-top)
        }
        if current-y < y-end - 0.001 {
          line((cx, current-y), (cx, y-end), stroke: stroke-style)
        }
      }
    }

    // Helper: draw a horizontal line with gaps for break zones
    let draw-hline-with-gaps(cy, x-start, x-end, stroke-style) = {
      // Collect gap x-ranges that intersect this horizontal line's y position
      let gaps = ()
      for zone in y-break-zones {
        let (y-bottom, y-top, gap-x-left, gap-x-right) = zone
        if cy >= y-bottom and cy <= y-top {
          gaps.push((gap-x-left, gap-x-right))
        }
      }

      if gaps.len() == 0 {
        line((x-start, cy), (x-end, cy), stroke: stroke-style)
      } else {
        // Sort gaps by left x
        let sorted-gaps = gaps.sorted(key: g => g.at(0))
        let current-x = x-start
        for (gap-left, gap-right) in sorted-gaps {
          let seg-end = calc.max(current-x, calc.min(gap-left, x-end))
          if seg-end > current-x + 0.001 {
            line((current-x, cy), (seg-end, cy), stroke: stroke-style)
          }
          current-x = calc.max(current-x, gap-right)
        }
        if current-x < x-end - 0.001 {
          line((current-x, cy), (x-end, cy), stroke: stroke-style)
        }
      }
    }

    // Minor grid
    if show-grid == "minor" or show-grid == "both" or show-grid == true {
      let minor-x-step = x-ticks.step / minor-grid-step
      let minor-y-step = y-ticks.step / minor-grid-step
      let is-major-x(x) = {
        for major-x in x-ticks.ticks {
          if calc.abs(x - major-x) < 0.0001 { return true }
        }
        false
      }
      let is-major-y(y) = {
        for major-y in y-ticks.ticks {
          if calc.abs(y - major-y) < 0.0001 { return true }
        }
        false
      }

      let x = calc.ceil(xmin / minor-x-step) * minor-x-step
      while x <= xmax + 0.0001 {
        if not is-major-x(x) {
          let cx = (x - xmin) * x-scale
          if grid-label-break and x-break-zones.len() + y-break-zones.len() > 0 {
            draw-vline-with-gaps(cx, grid-y-start, grid-y-end, s.grid.minor.stroke)
          } else {
            line((cx, grid-y-start), (cx, grid-y-end), stroke: s.grid.minor.stroke)
          }
        }
        x = x + minor-x-step
      }

      let y = calc.ceil(ymin / minor-y-step) * minor-y-step
      while y <= ymax + 0.0001 {
        if not is-major-y(y) {
          let cy = (y - ymin) * y-scale
          if grid-label-break and x-break-zones.len() + y-break-zones.len() > 0 {
            draw-hline-with-gaps(cy, grid-x-start, grid-x-end, s.grid.minor.stroke)
          } else {
            line((grid-x-start, cy), (grid-x-end, cy), stroke: s.grid.minor.stroke)
          }
        }
        y = y + minor-y-step
      }
    }

    // Major grid
    if show-grid == "major" or show-grid == "both" or show-grid == true {
      for x in x-ticks.ticks {
        let cx = (x - xmin) * x-scale
        if grid-label-break and x-break-zones.len() + y-break-zones.len() > 0 {
          draw-vline-with-gaps(cx, grid-y-start, grid-y-end, s.grid.major.stroke)
        } else {
          line((cx, grid-y-start), (cx, grid-y-end), stroke: s.grid.major.stroke)
        }
      }
      for y in y-ticks.ticks {
        let cy = (y - ymin) * y-scale
        if grid-label-break and x-break-zones.len() + y-break-zones.len() > 0 {
          draw-hline-with-gaps(cy, grid-x-start, grid-x-end, s.grid.major.stroke)
        } else {
          line((grid-x-start, cy), (grid-x-end, cy), stroke: s.grid.major.stroke)
        }
      }
    }

    // Axes, ticks, and axis labels are drawn after plot series so curves cannot cover labels.
    let draw-axes-ticks-labels() = {
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

      // Ticks and labels (tick-len already defined above)
      for (i, x) in x-ticks.ticks.enumerate() {
        // Skip tick at xmax (where arrow is)
        if calc.abs(x - xmax) < 0.0001 { continue }
        let (cx, cy) = to-canvas(x, x-axis-y)
        line((cx, cy - tick-len), (cx, cy + tick-len), stroke: s.ticks.stroke)
        // Only show label if x is a multiple of (tick-step * label-step)
        let label-interval = x-ticks.step * xtick-label-step
        let show-this-label = calc.abs(calc.rem(x, label-interval)) < 0.0001 or calc.abs(calc.rem(x, label-interval) - label-interval) < 0.0001
        // If unit-label-only, only show label for x = 1 (not -1 or other values)
        if unit-label-only and calc.abs(x - 1) > 0.0001 {
          show-this-label = false
        }
        // Avoid duplicate "0" when explicit origin label is enabled.
        if show-origin and calc.abs(x-axis-y) < 0.0001 and calc.abs(y-axis-x) < 0.0001 and calc.abs(x) < 0.0001 {
          show-this-label = false
        }
        if show-this-label and xtick-labels != none {
          let label = if xtick-labels == auto { format-number(x) }
                      else if i < xtick-labels.len() { xtick-labels.at(i) }
                      else { "" }
          let render-label = if type(label) == content { true }
                             else { label != "" and label != "0" }
          if render-label {
            content((cx, cy - tick-len - label-offset),
                    text(size: s.ticks.label-size, fill: s.ticks.label-fill)[#label], anchor: "north")
          }
        }
      }

      for (i, y) in y-ticks.ticks.enumerate() {
        // Skip tick at ymax (where arrow is)
        if calc.abs(y - ymax) < 0.0001 { continue }
        let (cx, cy) = to-canvas(y-axis-x, y)
        line((cx - tick-len, cy), (cx + tick-len, cy), stroke: s.ticks.stroke)
        // Only show label if y is a multiple of (tick-step * label-step)
        let label-interval = y-ticks.step * ytick-label-step
        let show-this-label = calc.abs(calc.rem(y, label-interval)) < 0.0001 or calc.abs(calc.rem(y, label-interval) - label-interval) < 0.0001
        // If unit-label-only, only show label for y = 1 (not -1 or other values)
        if unit-label-only and calc.abs(y - 1) > 0.0001 {
          show-this-label = false
        }
        // Avoid duplicate "0" when explicit origin label is enabled.
        if show-origin and calc.abs(x-axis-y) < 0.0001 and calc.abs(y-axis-x) < 0.0001 and calc.abs(y) < 0.0001 {
          show-this-label = false
        }
        if show-this-label and ytick-labels != none {
          let label = if ytick-labels == auto { format-number(y) }
                      else if i < ytick-labels.len() { ytick-labels.at(i) }
                      else { "" }
          let render-label = if type(label) == content { true }
                             else { label != "" and label != "0" }
          if render-label {
            content((cx - tick-len - label-offset, cy),
                    text(size: s.ticks.label-size, fill: s.ticks.label-fill)[#label], anchor: "east")
          }
        }
      }

      // Origin label
      if show-origin and calc.abs(x-axis-y) < 0.0001 and calc.abs(y-axis-x) < 0.0001 {
        let (ox, oy) = to-canvas(0, 0)
        let (dx, dy) = s.origin.label-offset
        let label-pos = (ox + dx, oy + dy)
        if s.origin.leader {
          let dist = calc.sqrt(dx * dx + dy * dy)
          if dist > s.origin.leader-gap + s.origin.leader-end-gap {
            let ux = dx / dist
            let uy = dy / dist
            line(
              (ox + ux * s.origin.leader-gap, oy + uy * s.origin.leader-gap),
              (ox + ux * (dist - s.origin.leader-end-gap), oy + uy * (dist - s.origin.leader-end-gap)),
              stroke: s.origin.leader-stroke,
            )
          }
        }
        content(label-pos, text(size: s.ticks.label-size, fill: s.ticks.label-fill)[0], anchor: s.origin.label-anchor)
      }

      // Axis labels - positioned at the extended arrow tips
      if xlabel != none {
        let (lx, ly) = if xlabel-pos == "end" {
          // Position just before the extended arrow tip so labels stay inside tight panels.
          let (base-x, base-y) = to-canvas(xmax, x-axis-y)
          (base-x + x-extend.at(1) * x-scale - 0.18, base-y)
        } else if xlabel-pos == "center" { to-canvas((xmin + xmax) / 2, x-axis-y) }
          else if type(xlabel-pos) == array { to-canvas(xlabel-pos.at(0), xlabel-pos.at(1)) }
          else { to-canvas(xmax, x-axis-y) }
        let (ox, oy) = xlabel-offset
        content((lx + ox, ly + oy), text(size: s.labels.size, fill: s.labels.fill)[#xlabel], anchor: xlabel-anchor)
      }

      if ylabel != none {
        let (lx, ly) = if ylabel-pos == "end" {
          // Position just below the extended arrow tip so labels stay inside tight panels.
          let (base-x, base-y) = to-canvas(y-axis-x, ymax)
          (base-x, base-y + y-extend.at(1) * y-scale - 0.18)
        } else if ylabel-pos == "center" { to-canvas(y-axis-x, (ymin + ymax) / 2) }
          else if type(ylabel-pos) == array { to-canvas(ylabel-pos.at(0), ylabel-pos.at(1)) }
          else { to-canvas(y-axis-x, ymax) }
        let (ox, oy) = ylabel-offset
        content((lx + ox, ly + oy), text(size: s.labels.size, fill: s.labels.fill)[#ylabel], anchor: ylabel-anchor)
      }
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

    // Merge series: array with positional functions
    let all-funcs = if series != none { series + functions.pos() } else { functions.pos() }

    // Separate zoom inset specs — rendered after axes
    let is-zoom-spec(f) = type(f) == dictionary and "zoom-region" in f
    let zoom-specs = all-funcs.filter(is-zoom-spec)
    let all-funcs = all-funcs.filter(f => not is-zoom-spec(f))

    // Plot functions and data (with manual line clipping)
    for func-spec in all-funcs {
      let func-spec = if type(func-spec) == function { (fn: func-spec) } else { func-spec }
      let fn = func-spec.at("fn", default: none)
      let data-points = func-spec.at("points", default: func-spec.at("data", default: none))
      let stroke-style = func-spec.at("stroke", default: s.plot.stroke)
      let mark-type = func-spec.at("mark", default: "none")
      let mark-size = func-spec.at("mark-size", default: s.marker.size)
      let mark-fill = func-spec.at("mark-fill", default: s.marker.fill)
      let mark-stroke = func-spec.at("mark-stroke", default: s.marker.stroke)
      let mark-interval = func-spec.at("mark-interval", default: 1)
      let label = func-spec.at("label", default: none)
      let points-to-draw = ()

      if fn != none {
        let domain = func-spec.at("domain", default: none)
        let domain-min = if domain == none { x-plot-min } else { domain.at(0) }
        let domain-max = if domain == none { x-plot-max } else { domain.at(1) }
        let samples = func-spec.at("samples", default: s.plot.samples)
        let step = (domain-max - domain-min) / samples

        // Collect all valid points first
        let all-points = ()
        for i in range(samples + 1) {
          let x = domain-min + i * step
          let y = fn(x)
          if y != none and not float(y).is-nan() {
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
          let label-pos = func-spec.at("label-pos", default: 1.0)
          let label-side = func-spec.at("label-side", default: none)
          // Clip label position to the data range (xmin/xmax).
          // Do NOT clip to x-clip-max — that includes axis arrow overshoot and places labels outside the canvas.
          // "south-west" text extends right into the axis extension zone, which is natural for end-of-curve labels.
          let label-domain-min = if domain == none { xmin } else { calc.max(float(domain-min), xmin) }
          let label-domain-max = if domain == none { xmax } else { calc.min(float(domain-max), xmax) }
          let label-anchor = if label-side != none {
            side-to-anchor(label-side)
          } else {
            func-spec.at("label-anchor", default: "south-west")
          }
          let lx = label-domain-min + (label-domain-max - label-domain-min) * label-pos
          let ly = fn(lx)
          if ly != none and not float(ly).is-nan() and ly >= y-clip-min and ly <= y-clip-max {
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

      // ── Fill below a single function to a baseline ─────────────────────
      // Keys: fill:fn, baseline:float, domain:(a,b), color:color,
      //       hatch:style, hatch-spacing:length, hatch-stroke:stroke, samples:int
      } else if "fill" in func-spec {
        let fill-fn      = func-spec.at("fill")
        let baseline     = func-spec.at("baseline", default: 0.0)
        let domain       = func-spec.at("domain", default: (xmin, xmax))
        let samples      = func-spec.at("samples", default: 80)
        let fill-color   = func-spec.at("color", default: luma(220))
        let hatch-style  = func-spec.at("hatch", default: none)
        let hatch-sp     = func-spec.at("hatch-spacing", default: 5pt)
        let hatch-stroke = func-spec.at("hatch-stroke", default: luma(80) + 0.5pt)

        let (d1, d2) = domain
        let step = (d2 - d1) / samples
        let top-pts = ()
        let bot-pts = ()

        for i in range(samples + 1) {
          let x = d1 + i * step
          let y = fill-fn(x)
          if y != none and not float(y).is-nan() {
            let (cx, cy-top) = to-canvas(x, float(y))
            let (_, cy-bot) = to-canvas(x, float(baseline))
            top-pts.push((cx, cy-top))
            bot-pts.push((cx, cy-bot))
          }
        }

        let all-pts = top-pts + bot-pts.rev()
        if all-pts.len() > 2 {
          let paint = if hatch-style != none {
            make-hatch-pattern(hatch-style, hatch-sp, hatch-stroke)
          } else { fill-color }
          line(..all-pts, close: true, fill: paint, stroke: none)
        }

      // ── Fill between two functions ───────────────────────────────────────
      // Keys: fill-between:(fn1, fn2), domain:(a,b), color:color,
      //       hatch:style, hatch-spacing:length, hatch-stroke:stroke, samples:int
      // Alias: fill-fn1: fn1 (legacy key, fn2 via fill-fn2:)
      } else if "fill-between" in func-spec or "fill-fn1" in func-spec {
        let (fn1, fn2) = if "fill-between" in func-spec {
          func-spec.at("fill-between")
        } else {
          (func-spec.at("fill-fn1"), func-spec.at("fill-fn2", default: x => 0.0))
        }
        let domain       = func-spec.at("domain", default: (xmin, xmax))
        let samples      = func-spec.at("samples", default: 80)
        let fill-color   = func-spec.at("color",
                             default: func-spec.at("fill", default: luma(220)))
        let hatch-style  = func-spec.at("hatch", default: none)
        let hatch-sp     = func-spec.at("hatch-spacing", default: 5pt)
        let hatch-stroke = func-spec.at("hatch-stroke", default: luma(80) + 0.5pt)

        let (d1, d2) = domain
        let step = (d2 - d1) / samples
        let fwd-pts = ()
        let bwd-pts = ()

        for i in range(samples + 1) {
          let x = d1 + i * step
          let y1 = fn1(x)
          let y2 = fn2(x)
          if (y1 != none and not float(y1).is-nan()
              and y2 != none and not float(y2).is-nan()) {
            let (cx, cy-top) = to-canvas(x, calc.max(float(y1), float(y2)))
            let (_, cy-bot)  = to-canvas(x, calc.min(float(y1), float(y2)))
            fwd-pts.push((cx, cy-top))
            bwd-pts.push((cx, cy-bot))
          }
        }

        let all-pts = fwd-pts + bwd-pts.rev()
        if all-pts.len() > 2 {
          let paint = if hatch-style != none {
            make-hatch-pattern(hatch-style, hatch-sp, hatch-stroke)
          } else { fill-color }
          line(..all-pts, close: true, fill: paint, stroke: none)
        }

      // ── Text annotation at data coordinates ─────────────────────────────
      // Keys: annotation:content, pos:(x,y), anchor:string, size:length
      } else if "annotation" in func-spec {
        let ann-text   = func-spec.at("annotation")
        let ann-pos    = func-spec.at("pos")
        let ann-anchor = func-spec.at("anchor", default: "center")
        let ann-size   = func-spec.at("size", default: 10pt)
        let (ax, ay)   = ann-pos
        let (cx, cy)   = to-canvas(ax, ay)
        content((cx, cy), text(ann-text, size: ann-size), anchor: ann-anchor)

      // ── Riemann sum rectangles ───────────────────────────────────────────
      // Keys: riemann:fn, domain:(a,b), n:int, method:"left"|"right"|"mid",
      //       baseline:float, color:color, stroke:stroke,
      //       hatch:style, hatch-spacing:length, hatch-stroke:stroke
      } else if "riemann" in func-spec {
        let r-fn        = func-spec.at("riemann")
        let r-domain    = func-spec.at("domain", default: (xmin, xmax))
        let r-n         = func-spec.at("n", default: 4)
        let r-method    = func-spec.at("method", default: "right")
        let r-base      = func-spec.at("baseline", default: 0.0)
        let fill-color  = func-spec.at("color", default: luma(220))
        let rect-stroke = func-spec.at("stroke", default: luma(80) + 0.6pt)
        let hatch-style = func-spec.at("hatch", default: none)
        let hatch-sp    = func-spec.at("hatch-spacing", default: 5pt)
        let hatch-stk   = func-spec.at("hatch-stroke", default: luma(80) + 0.5pt)

        let r-samples      = func-spec.at("samples", default: 20)
        let r-show-points  = func-spec.at("show-points", default: false)
        let r-point-color  = func-spec.at("point-color", default: rgb("#c94a00"))
        let r-point-size   = func-spec.at("point-size", default: 0.07)
        let r-point-label  = func-spec.at("point-label", default: none)
        let r-point-lpos   = func-spec.at("point-label-pos", default: auto)
        let r-show-dx      = func-spec.at("show-dx", default: false)
        let r-dx-rect      = func-spec.at("dx-rect", default: auto)
        let r-dx-label     = func-spec.at("dx-label", default: $Delta x$)
        let r-show-xi        = func-spec.at("show-xi", default: false)
        let r-xi-labels      = func-spec.at("xi-labels", default: auto)
        let r-xi-show-values = func-spec.at("xi-show-values", default: false)

        let (d1, d2) = r-domain
        let w = (d2 - d1) / r-n

        // Collect canvas evaluation points for dots/arrows (left/right/mid only)
        let eval-pts = ()

        for i in range(r-n) {
          let xl = d1 + i * w
          let xr = d1 + (i + 1) * w
          let y = if r-method == "lower" or r-method == "upper" {
            let sub-ys = ()
            for j in range(r-samples + 1) {
              let x = xl + j * (xr - xl) / r-samples
              let v = r-fn(x)
              if v != none and not float(v).is-nan() { sub-ys.push(float(v)) }
            }
            if sub-ys.len() == 0 { none }
            else if r-method == "lower" { calc.min(..sub-ys) }
            else { calc.max(..sub-ys) }
          } else {
            let xeval = if r-method == "left"  { xl }
                        else if r-method == "right" { xr }
                        else { (xl + xr) / 2.0 }
            let ev = r-fn(xeval)
            if ev != none and not float(ev).is-nan() {
              eval-pts.push(to-canvas(xeval, float(ev)))
            }
            ev
          }
          if y != none and not float(y).is-nan() {
            let yv = float(y)
            let (cxl, cybot) = to-canvas(xl, r-base)
            let (cxr, cytop) = to-canvas(xr, yv)
            let paint = if hatch-style != none {
              make-hatch-pattern(hatch-style, hatch-sp, hatch-stk)
            } else { fill-color }
            rect((cxl, cybot), (cxr, cytop), fill: paint, stroke: rect-stroke)
          }
        }

        // ── Δx bracket ──────────────────────────────────────────────────────
        let dx-di = if r-dx-rect == auto { calc.floor(r-n / 2) } else { r-dx-rect }
        if r-show-dx {
          let xl = d1 + dx-di * w
          let xr = d1 + (dx-di + 1) * w
          let (cxl, cy-base) = to-canvas(xl, r-base)
          let (cxr, _)       = to-canvas(xr, r-base)
          let tick-drop = 0.10
          let arrow-y   = cy-base - 0.18
          line((cxl, cy-base - 0.02), (cxl, cy-base - tick-drop), stroke: black + 0.5pt)
          line((cxr, cy-base - 0.02), (cxr, cy-base - tick-drop), stroke: black + 0.5pt)
          line((cxl, arrow-y), (cxr, arrow-y),
               mark: (start: (symbol: "stealth", fill: black, scale: 0.35),
                      end:   (symbol: "stealth", fill: black, scale: 0.35)),
               stroke: black + 0.5pt)
          content(((cxl + cxr) / 2, arrow-y - 0.06), r-dx-label, anchor: "north")
        }

        // ── x_i labels ──────────────────────────────────────────────────────
        if r-show-xi {
          for i in range(r-n + 1) {
            // Skip the two indices that straddle the Δx bracket to avoid overlap
            if r-show-dx and (i == dx-di or i == dx-di + 1) { continue }
            let x = d1 + i * w
            let (cx, cy) = to-canvas(x, r-base)
            let xi-lbl = if r-xi-labels != auto and i < r-xi-labels.len() {
              r-xi-labels.at(i)
            } else {
              math.attach($x$, b: [#i])
            }
            let lbl = if r-xi-show-values {
              // Stack: numeric value on top, xi subscript below
              let sz = s.ticks.label-size
              stack(dir: ttb, spacing: 1pt,
                text(size: sz)[$#format-number(x)$],
                text(size: sz)[#xi-lbl],
              )
            } else {
              xi-lbl
            }
            // Always shift right when xi label lands on the y-axis to avoid overlap
            let x-shift = if calc.abs(x - y-axis-x) < 0.001 { 0.35 } else { 0.0 }
            content((cx + x-shift, cy - 0.20), lbl, anchor: "north")
          }
        }

        // ── Endpoint dots + label with arrows ───────────────────────────────
        if r-show-points and eval-pts.len() > 0 {
          let lbl-text = if r-point-label == auto {
            if r-method == "left"  { [Left endpoints] }
            else if r-method == "right" { [Right endpoints] }
            else if r-method == "mid"   { [Midpoints] }
            else { none }
          } else { r-point-label }

          if lbl-text != none {
            let (lx, ly) = if r-point-lpos == auto {
              // Place inside the canvas: upper-left for right method, upper-right for left/mid
              let frac = if r-method == "right" { 0.25 } else { 0.75 }
              let lx-data = d1 + frac * (d2 - d1)
              let ly-data = ymax - 0.12 * (ymax - ymin)
              to-canvas(lx-data, ly-data)
            } else {
              to-canvas(r-point-lpos.at(0), r-point-lpos.at(1))
            }
            // Arrows first so dots render on top
            for (px, py) in eval-pts {
              line((lx, ly), (px, py),
                   mark: (end: (symbol: "stealth", fill: black, scale: 0.35)),
                   stroke: black + 0.5pt)
            }
            content((lx, ly), lbl-text, anchor: "center")
          }
          // Dots on top
          for (px, py) in eval-pts {
            circle((px, py), radius: r-point-size, fill: r-point-color, stroke: none)
          }
        }

      // ── Vertical reference line ──────────────────────────────────────────
      // Keys: vline:x, ymin:float, ymax:float, stroke:stroke
      } else if "vline" in func-spec {
        let x0    = func-spec.at("vline")
        let vy1   = func-spec.at("ymin", default: ymin)
        let vy2   = func-spec.at("ymax", default: ymax)
        let (cx, cy1) = to-canvas(x0, vy1)
        let (_, cy2)  = to-canvas(x0, vy2)
        line((cx, cy1), (cx, cy2), stroke: stroke-style)

      // ── Horizontal reference line ────────────────────────────────────────
      // Keys: hline:y, xmin:float, xmax:float, stroke:stroke
      } else if "hline" in func-spec {
        let y0    = func-spec.at("hline")
        let hx1   = func-spec.at("xmin", default: xmin)
        let hx2   = func-spec.at("xmax", default: xmax)
        let (cx1, cy) = to-canvas(hx1, y0)
        let (cx2, _)  = to-canvas(hx2, y0)
        line((cx1, cy), (cx2, cy), stroke: stroke-style)

      // ── Parametric curve (fn-x(t), fn-y(t)) ─────────────────────────────
      // Keys: parametric:(fn-x, fn-y), domain:(t1,t2), samples:int, stroke:stroke
      } else if "parametric" in func-spec {
        let (par-x, par-y) = func-spec.at("parametric")
        let par-domain = func-spec.at("domain", default: (0.0, 1.0))
        let par-samples = func-spec.at("samples", default: 100)
        let (t1, t2) = par-domain
        let step = (t2 - t1) / par-samples
        let all-par-pts = ()
        for i in range(par-samples + 1) {
          let t = t1 + i * step
          let px = par-x(t)
          let py = par-y(t)
          if px != none and py != none and not float(px).is-nan() and not float(py).is-nan() {
            all-par-pts.push(to-canvas(float(px), float(py)))
          } else {
            all-par-pts.push(none)
          }
        }
        for j in range(all-par-pts.len() - 1) {
          let pt1 = all-par-pts.at(j)
          let pt2 = all-par-pts.at(j + 1)
          if pt1 != none and pt2 != none {
            let clipped = clip-segment(pt1, pt2, clip-x1, clip-y1, clip-x2, clip-y2)
            if clipped != none {
              let (p1, p2) = clipped
              line(p1, p2, stroke: stroke-style)
            }
          }
        }

      // ── Fill area enclosed by parametric closed curve ────────────────────
      // Keys: fill-closed:(fn-x, fn-y), domain:(t1,t2), color:color,
      //       hatch:style, hatch-spacing:length, hatch-stroke:stroke, samples:int
      } else if "fill-closed" in func-spec {
        let (par-x, par-y) = func-spec.at("fill-closed")
        let par-domain = func-spec.at("domain", default: (0.0, 1.0))
        let par-samples = func-spec.at("samples", default: 80)
        let fill-color   = func-spec.at("color", default: luma(220))
        let hatch-style  = func-spec.at("hatch", default: none)
        let hatch-sp     = func-spec.at("hatch-spacing", default: 5pt)
        let hatch-stroke = func-spec.at("hatch-stroke", default: luma(80) + 0.5pt)
        let (t1, t2) = par-domain
        let step = (t2 - t1) / par-samples
        let par-pts = ()
        for i in range(par-samples + 1) {
          let t = t1 + i * step
          let px = par-x(t)
          let py = par-y(t)
          if px != none and py != none and not float(px).is-nan() and not float(py).is-nan() {
            par-pts.push(to-canvas(float(px), float(py)))
          }
        }
        if par-pts.len() > 2 {
          let paint = if hatch-style != none {
            make-hatch-pattern(hatch-style, hatch-sp, hatch-stroke)
          } else { fill-color }
          line(..par-pts, close: true, fill: paint, stroke: none)
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

    // Keep axes and tick labels above curves, markers, and filled regions.
    draw-axes-ticks-labels()

    // ── Zoom / Spy Insets ─────────────────────────────────────────────────
    for zs in zoom-specs {
      // Resolve zoom region: explicit corners or center+size-cm (square on canvas)
      let (zx1, zy1, zx2, zy2) = if "zoom-center" in zs and "zoom-size-cm" in zs {
        let (zcx, zcy) = zs.at("zoom-center")
        let sz = zs.at("zoom-size-cm")
        let hx = sz / (2 * x-scale)
        let hy = sz / (2 * y-scale)
        (zcx - hx, zcy - hy, zcx + hx, zcy + hy)
      } else {
        let r = zs.at("zoom-region")
        (r.at(0), r.at(1), r.at(2), r.at(3))
      }

      // Resolve inset size: explicit, magnification-based, or default
      let z-mag  = zs.at("magnification", default: none)
      let zoom-w = if "zoom-width" in zs   { zs.at("zoom-width") }
                   else if z-mag != none   { (zx2 - zx1) * x-scale * z-mag }
                   else                    { 3.5 }
      let zoom-h = if "zoom-height" in zs  { zs.at("zoom-height") }
                   else if z-mag != none   { (zy2 - zy1) * y-scale * z-mag }
                   else                    { 3.5 }

      let lens-shape  = zs.at("lens-shape", default: "rect")
      let do-connect  = zs.at("connect", default: true)
      let accent-col  = zs.at("accent", default: rgb("#4a90d9"))
      let reg-fill    = zs.at("region-fill", default: none)
      let reg-stk     = zs.at("region-stroke", default: accent-col + 0.9pt)
      let box-fill-v  = zs.at("box-fill", default: white)
      let box-stk     = zs.at("box-stroke", default: accent-col + 1pt)
      let conn-stk    = zs.at("connector-stroke", default: (paint: luma(140), thickness: 0.5pt, dash: "dashed"))
      let conn-fill   = zs.at("connector-fill", default: none)
      // Shadow: on by default only for rect with a solid background fill
      let shadow-default = lens-shape != "circle" and box-fill-v != none
      let do-shadow   = zs.at("shadow", default: shadow-default)
      // Grid inside inset: only useful when background is opaque
      let do-igrid    = zs.at("show-inset-grid", default: box-fill-v != none)
      let do-mag      = zs.at("show-magnification", default: false)
      let z-label     = zs.at("label", default: none)

      // Canvas coords of the zoom region bounding box
      let (crx1, cry1) = to-canvas(zx1, zy1)
      let (crx2, cry2) = to-canvas(zx2, zy2)
      let lens-cx = (crx1 + crx2) / 2
      let lens-cy = (cry1 + cry2) / 2
      let lens-rx = (crx2 - crx1) / 2
      let lens-ry = (cry2 - cry1) / 2

      // Canvas center of the inset box
      let (cix, ciy) = {
        let at-val = zs.at("at", default: auto)
        let margin-x = zoom-w / 2 + 0.2
        let margin-y = zoom-h / 2 + 0.2
        if at-val == auto {
          // Smart default: opposite quadrant from zoom center
          let nc-x = ((zx1 + zx2) / 2 - xmin) / (xmax - xmin)
          let nc-y = ((zy1 + zy2) / 2 - ymin) / (ymax - ymin)
          let tx = if nc-x > 0.5 { 0.25 } else { 0.75 }
          let ty = if nc-y > 0.5 { 0.25 } else { 0.75 }
          (width * tx, height * ty)
        } else if type(at-val) == str {
          // Named placement keywords: keep inset inside the canvas with margin
          if at-val == "top-right"    { (width  - margin-x, height - margin-y) }
          else if at-val == "top-left"     { (margin-x,          height - margin-y) }
          else if at-val == "bottom-right" { (width  - margin-x, margin-y) }
          else if at-val == "bottom-left"  { (margin-x,          margin-y) }
          else if at-val == "top"          { (width / 2,          height - margin-y) }
          else if at-val == "bottom"       { (width / 2,          margin-y) }
          else if at-val == "left"         { (margin-x,           height / 2) }
          else if at-val == "right"        { (width - margin-x,   height / 2) }
          else { (width * 0.75, height * 0.75) }
        } else {
          to-canvas(at-val.at(0), at-val.at(1))
        }
      }

      let bx1 = cix - zoom-w / 2
      let by1 = ciy - zoom-h / 2
      let bx2 = cix + zoom-w / 2
      let by2 = ciy + zoom-h / 2

      // Pick two non-crossing connector corner pairs
      let ddx = cix - lens-cx
      let ddy = ciy - lens-cy

      let (cf1, cf2, ct1, ct2) = if calc.abs(ddx) >= calc.abs(ddy) {
        if ddx > 0 { ((crx2, cry1), (crx2, cry2), (bx1, by1), (bx1, by2)) }
        else       { ((crx1, cry1), (crx1, cry2), (bx2, by1), (bx2, by2)) }
      } else {
        if ddy > 0 { ((crx1, cry2), (crx2, cry2), (bx1, by1), (bx2, by1)) }
        else       { ((crx1, cry1), (crx2, cry1), (bx1, by2), (bx2, by2)) }
      }

      // Connector lines
      if do-connect {
        if conn-fill != none {
          line(cf1, ct1, ct2, cf2, close: true, fill: conn-fill, stroke: none)
        }
        line(cf1, ct1, stroke: conn-stk)
        line(cf2, ct2, stroke: conn-stk)
      }

      // Drop shadow (shape-aware)
      if do-shadow {
        let sh = 0.07
        if lens-shape == "circle" {
          let ic-x = (bx1 + bx2) / 2 + sh
          let ic-y = (by1 + by2) / 2 - sh
          let sh-pts = range(65).map(i => {
            let t = i * 360deg / 64
            (ic-x + zoom-w / 2 * calc.cos(t), ic-y + zoom-h / 2 * calc.sin(t))
          })
          line(..sh-pts, close: true, fill: luma(185), stroke: none)
        } else {
          rect((bx1 + sh, by1 - sh), (bx2 + sh, by2 - sh), fill: luma(185), stroke: none)
        }
      }

      // Inset background (circle: filled ellipse; rect: filled rectangle)
      if box-fill-v != none {
        if lens-shape == "circle" {
          let ic-x = (bx1 + bx2) / 2
          let ic-y = (by1 + by2) / 2
          let bg-pts = range(65).map(i => {
            let t = i * 360deg / 64
            (ic-x + zoom-w / 2 * calc.cos(t), ic-y + zoom-h / 2 * calc.sin(t))
          })
          line(..bg-pts, close: true, fill: box-fill-v, stroke: none)
        } else {
          rect((bx1, by1), (bx2, by2), fill: box-fill-v, stroke: none)
        }
      }

      // Subtle grid inside inset aligned to main plot tick spacing
      let ic-cx = (bx1 + bx2) / 2
      let ic-cy = (by1 + by2) / 2
      let ic-rx = zoom-w / 2
      let ic-ry = zoom-h / 2

      if do-igrid {
        let g-stk = luma(210) + 0.4pt
        let gx = calc.ceil(zx1 / x-ticks.step) * x-ticks.step
        while gx <= zx2 + 0.0001 {
          let cx-g = bx1 + (gx - zx1) * zoom-w / (zx2 - zx1)
          if cx-g >= bx1 - 0.001 and cx-g <= bx2 + 0.001 {
            if lens-shape == "circle" {
              let cl = clip-segment-ellipse((cx-g, by1), (cx-g, by2), ic-cx, ic-cy, ic-rx, ic-ry)
              if cl != none { let (p1, p2) = cl; line(p1, p2, stroke: g-stk) }
            } else {
              line((cx-g, by1), (cx-g, by2), stroke: g-stk)
            }
          }
          gx = gx + x-ticks.step
        }
        let gy = calc.ceil(zy1 / y-ticks.step) * y-ticks.step
        while gy <= zy2 + 0.0001 {
          let cy-g = by1 + (gy - zy1) * zoom-h / (zy2 - zy1)
          if cy-g >= by1 - 0.001 and cy-g <= by2 + 0.001 {
            if lens-shape == "circle" {
              let cl = clip-segment-ellipse((bx1, cy-g), (bx2, cy-g), ic-cx, ic-cy, ic-rx, ic-ry)
              if cl != none { let (p1, p2) = cl; line(p1, p2, stroke: g-stk) }
            } else {
              line((bx1, cy-g), (bx2, cy-g), stroke: g-stk)
            }
          }
          gy = gy + y-ticks.step
        }
      }

      // Re-render plot series inside the inset (clipped to circle or rect)
      let z-x-sc = zoom-w / (zx2 - zx1)
      let z-y-sc = zoom-h / (zy2 - zy1)
      let to-zoom(x, y) = (bx1 + (x - zx1) * z-x-sc, by1 + (y - zy1) * z-y-sc)

      for fs in all-funcs {
        let fs = if type(fs) == function { (fn: fs) } else { fs }
        let fs-stk = fs.at("stroke", default: s.plot.stroke)

        if "fn" in fs {
          let fn-z   = fs.at("fn")
          let z-samp = fs.at("samples", default: s.plot.samples)
          let fs-dom = fs.at("domain", default: none)
          let d1-z   = if fs-dom != none { calc.max(float(fs-dom.at(0)), zx1) } else { zx1 }
          let d2-z   = if fs-dom != none { calc.min(float(fs-dom.at(1)), zx2) } else { zx2 }
          if d1-z < d2-z {
            let stp-z = (d2-z - d1-z) / z-samp
            let z-pts = ()
            for i in range(z-samp + 1) {
              let xv = d1-z + i * stp-z
              let yv = fn-z(xv)
              if yv != none and not float(yv).is-nan() {
                z-pts.push(to-zoom(xv, float(yv)))
              } else {
                z-pts.push(none)
              }
            }
            for j in range(z-pts.len() - 1) {
              let p1 = z-pts.at(j)
              let p2 = z-pts.at(j + 1)
              if p1 != none and p2 != none {
                let cl = if lens-shape == "circle" {
                  clip-segment-ellipse(p1, p2, ic-cx, ic-cy, ic-rx, ic-ry)
                } else {
                  clip-segment(p1, p2, bx1, by1, bx2, by2)
                }
                if cl != none {
                  let (cp1, cp2) = cl
                  line(cp1, cp2, stroke: fs-stk)
                }
              }
            }
          }

        } else if "points" in fs {
          let pts-z    = fs.at("points")
          let conn-z   = fs.at("connect", default: true)
          let canvas-z = ()
          for pt in pts-z {
            let (xv, yv) = pt
            let in-zx = xv >= zx1 - 0.0001 and xv <= zx2 + 0.0001
            let in-zy = yv >= zy1 - 0.0001 and yv <= zy2 + 0.0001
            if in-zx and in-zy {
              canvas-z.push(to-zoom(xv, yv))
            }
          }
          if conn-z and canvas-z.len() > 1 {
            line(..canvas-z, stroke: fs-stk)
          }
          let mk-z = fs.at("mark", default: "none")
          if mk-z != "none" {
            for pt-z in canvas-z {
              draw-marker(none, pt-z, mk-z,
                fs.at("mark-size",   default: s.marker.size),
                fs.at("mark-fill",   default: s.marker.fill),
                fs.at("mark-stroke", default: s.marker.stroke))
            }
          }
        }
      }

      // Draw axis lines inside the inset if they pass through the zoom region
      let draw-inset-line(p1, p2) = {
        let cl = if lens-shape == "circle" {
          clip-segment-ellipse(p1, p2, ic-cx, ic-cy, ic-rx, ic-ry)
        } else {
          clip-segment(p1, p2, bx1, by1, bx2, by2)
        }
        if cl != none { let (cp1, cp2) = cl; line(cp1, cp2, stroke: s.axis.stroke) }
      }
      // X-axis
      if x-axis-y >= zy1 - 0.0001 and x-axis-y <= zy2 + 0.0001 {
        let (_, y-ax-z) = to-zoom(zx1, x-axis-y)
        draw-inset-line((bx1, y-ax-z), (bx2, y-ax-z))
      }
      // Y-axis
      if y-axis-x >= zx1 - 0.0001 and y-axis-x <= zx2 + 0.0001 {
        let (x-ax-z, _) = to-zoom(y-axis-x, zy1)
        draw-inset-line((x-ax-z, by1), (x-ax-z, by2))
      }

      // Spy glass shape on the main plot (drawn on top of all content)
      if lens-shape == "circle" {
        let n-c = 64
        let circ-pts = range(n-c + 1).map(i => {
          let t = i * 360deg / n-c
          (lens-cx + lens-rx * calc.cos(t), lens-cy + lens-ry * calc.sin(t))
        })
        line(..circ-pts, close: true, stroke: reg-stk, fill: reg-fill)
      } else {
        rect((crx1, cry1), (crx2, cry2), stroke: reg-stk, fill: reg-fill)
      }

      // Inset border
      if lens-shape == "circle" {
        let ic-x = (bx1 + bx2) / 2
        let ic-y = (by1 + by2) / 2
        let n-c = 64
        let circ-pts = range(n-c + 1).map(i => {
          let t = i * 360deg / n-c
          (ic-x + zoom-w / 2 * calc.cos(t), ic-y + zoom-h / 2 * calc.sin(t))
        })
        line(..circ-pts, close: true, fill: none, stroke: box-stk)
      } else {
        rect((bx1, by1), (bx2, by2), fill: none, stroke: box-stk)
      }

      // Optional label / magnification factor
      let eff-lbl = if z-label != none {
        z-label
      } else if do-mag {
        let mag-v = calc.round(z-x-sc / x-scale * 10) / 10
        text(size: 7pt, fill: accent-col)[×#mag-v]
      } else { none }
      if eff-lbl != none {
        content((bx1 + 0.12, by2 - 0.06), eff-lbl, anchor: "north-west")
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
      if y != none and not float(y).is-nan() { ys.push(y) }
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

/// Plot a rational-style function with defaults suited to school exercises.
///
/// This is a thin convenience wrapper around `plot` that sets a centered
/// grid, axis labels, and a single function series. Use `..args` to override
/// any plot option or add extra series such as asymptotes and points.
#let plot-rational(
  fn,
  xmin: -6,
  xmax: 6,
  ymin: -8,
  ymax: 8,
  stroke: blue + 1.2pt,
  domain: auto,
  samples: 200,
  vertical-asymptotes: (),
  asymptote-stroke: stroke(paint: luma(80), thickness: 0.6pt, dash: "dashed"),
  asymptote-gap: 0.05,
  width: auto,
  height: auto,
  ..args
) = {
  let plot-args = args.named()
  let specs = args.pos()
  let fn-domain = if domain == auto { (xmin, xmax) } else { domain }
  let split-points = vertical-asymptotes
    .filter(x => fn-domain.at(0) < x and x < fn-domain.at(1))
    .sorted()
  let fn-specs = ()
  let left-bound = fn-domain.at(0)
  for x0 in split-points {
    let right-bound = x0 - asymptote-gap
    if left-bound < right-bound {
      fn-specs.push((fn: fn, domain: (left-bound, right-bound), samples: samples, stroke: stroke))
    }
    left-bound = x0 + asymptote-gap
    specs.push((vline: x0, stroke: asymptote-stroke))
  }
  if left-bound < fn-domain.at(1) {
    fn-specs.push((fn: fn, domain: (left-bound, fn-domain.at(1)), samples: samples, stroke: stroke))
  }
  for (key, value) in (
    "show-grid": "major",
    "axis-x-pos": "center",
    "axis-y-pos": "center",
    "show-origin": false,
    "xlabel": $x$,
    "ylabel": $y$,
  ) {
    if key not in plot-args {
      plot-args.insert(key, value)
    }
  }
  plot(
    xmin: xmin,
    xmax: xmax,
    ymin: ymin,
    ymax: ymax,
    width: width,
    height: height,
    ..plot-args,
    ..fn-specs,
    ..specs,
  )
}

/// Schematic plot showing the local behavior of a function near x = `a`.
///
/// `left` and `right` each accept `"+oo"`, `"-oo"`, a finite number, or
/// `none`. Use `val` for a filled dot at the defined value `f(a)`.
#let limit-schema(
  a: 0,
  left: none,
  right: none,
  val: none,
  a-label: auto,
  show-limit: false,
  L-label: auto,
  width: 3.8,
  height: 2.8,
) = {
  let xr    = 1.2
  let gap   = 0.13
  let C     = 0.9
  let slope = 0.5

  let lbl   = if a-label == auto { [#a] } else { a-label }
  let L-lbl = if L-label == auto { $L$ } else { L-label }
  let items = ()

  let limit-y = if type(show-limit) in (int, float) {
    float(show-limit)
  } else if show-limit == true {
    if type(left) in (int, float) and type(right) in (int, float) and float(left) == float(right) {
      float(left)
    } else if type(left) in (int, float) and right == none {
      float(left)
    } else if type(right) in (int, float) and left == none {
      float(right)
    } else {
      none
    }
  } else {
    none
  }

  let has-inf = left in ("+oo", "-oo") or right in ("+oo", "-oo")
  if has-inf {
    items.push((vline: a, stroke: stroke(paint: luma(80), thickness: 0.5pt, dash: "dashed")))
  }

  let finite-vals = ()
  if type(left)  in (int, float) { finite-vals.push(float(left))  }
  if type(right) in (int, float) { finite-vals.push(float(right)) }
  if val != none                 { finite-vals.push(float(val))   }
  if limit-y != none             { finite-vals.push(limit-y)      }

  let (ymin-plot, ymax-plot, xaxis-y) = if has-inf {
    (-5.5, 5.5, 0.0)
  } else if finite-vals.len() > 0 {
    let vmin = calc.min(..finite-vals)
    let vmax = calc.max(..finite-vals)
    let ctr  = (vmin + vmax) / 2.0
    let half = calc.max(2.5, (vmax - vmin) / 2.0 + 1.5)
    let lo   = ctr - half
    let hi   = ctr + half
    let xax  = if lo <= 0.0 and 0.0 <= hi { 0.0 } else { lo - 0.5 }
    (lo, hi, xax)
  } else {
    (-5.5, 5.5, 0.0)
  }

  if limit-y != none {
    items.push((hline: limit-y, stroke: stroke(paint: luma(60), thickness: 0.5pt, dash: "dashed")))
    items.push((annotation: L-lbl, pos: (a - 1.35, limit-y), anchor: "east", size: 8pt))
  }

  if left == "+oo" {
    items.push((fn: x => C / (a - x), domain: (a - xr, a - gap), stroke: blue + 1.2pt, samples: 60))
    items.push((annotation: $+oo$, pos: (a - 0.52, ymax-plot - 0.9), anchor: "center", size: 8pt))
  } else if left == "-oo" {
    items.push((fn: x => -C / (a - x), domain: (a - xr, a - gap), stroke: blue + 1.2pt, samples: 60))
    items.push((annotation: $-oo$, pos: (a - 0.52, ymin-plot + 0.9), anchor: "center", size: 8pt))
  } else if type(left) in (int, float) {
    let L = float(left)
    items.push((fn: x => L + slope * (x - a), domain: (a - xr, a - gap), stroke: blue + 1.2pt, samples: 2))
    items.push((points: ((a, L),), mark: "o", mark-fill: white, mark-stroke: blue, mark-size: 0.16, stroke: none))
  }

  if right == "+oo" {
    items.push((fn: x => C / (x - a), domain: (a + gap, a + xr), stroke: blue + 1.2pt, samples: 60))
    items.push((annotation: $+oo$, pos: (a + 0.52, ymax-plot - 0.9), anchor: "center", size: 8pt))
  } else if right == "-oo" {
    items.push((fn: x => -C / (x - a), domain: (a + gap, a + xr), stroke: blue + 1.2pt, samples: 60))
    items.push((annotation: $-oo$, pos: (a + 0.52, ymin-plot + 0.9), anchor: "center", size: 8pt))
  } else if type(right) in (int, float) {
    let R = float(right)
    items.push((fn: x => R + slope * (x - a), domain: (a + gap, a + xr), stroke: blue + 1.2pt, samples: 2))
    items.push((points: ((a, R),), mark: "o", mark-fill: white, mark-stroke: blue, mark-size: 0.16, stroke: none))
  }

  if val != none {
    items.push((points: ((a, float(val)),), mark: "*", mark-fill: blue, mark-stroke: blue, mark-size: 0.16, stroke: none))
  }

  align(center)[
    #plot(
      xmin: a - 1.35, xmax: a + 1.35,
      ymin: ymin-plot, ymax: ymax-plot,
      width: width, height: height,
      axis-x-pos: xaxis-y,
      ylabel: none,
      xtick: (a,),
      xtick-labels: (lbl,),
      ytick: (),
      show-grid: false,
      show-origin: false,
      show-y-axis: false,
      ..items,
    )
  ]
}

/// Backwards-compatible French alias for `limit-schema`.
#let schema-lim = limit-schema

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

/// Create a data-point series specification.
///
/// This is an alias for `scatter` with the same options. Use `connect: true`
/// to join the points with line segments.
#let data(
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
) = scatter(
  points,
  mark: mark,
  mark-size: mark-size,
  mark-fill: mark-fill,
  mark-stroke: mark-stroke,
  connect: connect,
  stroke: stroke,
  label: label,
  label-pos: label-pos,
  label-anchor: label-anchor,
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

/// Build a fill-below-curve series spec.
///
/// Fills the region between `fn` and `baseline` (default 0) over `domain`.
///
/// Example:
/// ```typst
/// #plot(...,
///   fill-area(x => calc.sin(x), domain: (0, calc.pi), color: blue.lighten(70%)),
///   (fn: x => calc.sin(x), stroke: blue + 1.2pt),
/// )
/// ```
#let fill-area(
  fn,
  domain: auto,
  baseline: 0.0,
  color: luma(220),
  hatch: none,
  hatch-spacing: 5pt,
  hatch-stroke: luma(80) + 0.5pt,
  samples: 80,
) = {
  let spec = (
    fill: fn, baseline: baseline, color: color,
    hatch: hatch, hatch-spacing: hatch-spacing, hatch-stroke: hatch-stroke,
    samples: samples,
  )
  if domain != auto { spec.insert("domain", domain) }
  spec
}

/// Build a fill-between-curves series spec.
///
/// Fills the region between `fn1` and `fn2` over `domain`.
/// The filled shape always encloses both curves (uses max/min at each sample).
///
/// Hatch styles: `"ne"` (/), `"nw"` (\), `"h"`, `"v"`, `"cross"`, `"grid"`.
///
/// Example:
/// ```typst
/// #plot(...,
///   area-between(x => calc.exp(x), x => x + 1, domain: (0, 1),
///                color: green.lighten(60%)),
/// )
/// ```
#let area-between(
  fn1,
  fn2,
  domain: auto,
  color: luma(220),
  hatch: none,
  hatch-spacing: 5pt,
  hatch-stroke: luma(80) + 0.5pt,
  samples: 80,
) = {
  let spec = (
    fill-between: (fn1, fn2), color: color,
    hatch: hatch, hatch-spacing: hatch-spacing, hatch-stroke: hatch-stroke,
    samples: samples,
  )
  if domain != auto { spec.insert("domain", domain) }
  spec
}

/// Place a text annotation at a data-coordinate position.
///
/// Example:
/// ```typst
/// #plot(...,
///   note([AV : $x = 0$], pos: (0.4, -2.5), anchor: "west"),
/// )
/// ```
#let note(
  body,
  pos,
  anchor: "center",
  size: 9pt,
) = (annotation: body, pos: pos, anchor: anchor, size: size)

/// Vertical reference line at x = `x0`.
///
/// Example:
/// ```typst
/// (vline: 1.0, stroke: (dash: "dashed") + luma(100) + 0.6pt)
/// ```
#let vline(x0, stroke: luma(100) + 0.6pt, ymin: auto, ymax: auto) = {
  let spec = (vline: x0, stroke: stroke)
  if ymin != auto { spec.insert("ymin", ymin) }
  if ymax != auto { spec.insert("ymax", ymax) }
  spec
}

/// Horizontal reference line at y = `y0`.
///
/// Example:
/// ```typst
/// (hline: 0.0, stroke: (dash: "dashed") + luma(100) + 0.6pt)
/// ```
#let hline(y0, stroke: luma(100) + 0.6pt, xmin: auto, xmax: auto) = {
  let spec = (hline: y0, stroke: stroke)
  if xmin != auto { spec.insert("xmin", xmin) }
  if xmax != auto { spec.insert("xmax", xmax) }
  spec
}

/// Add a spy/zoom inset: a magnified sub-view of a region of the main plot.
///
/// Specify the spy glass via `region` (explicit data-coord corners) OR via
/// `center` + `size` (square on the canvas in cm, independent of axis aspect ratio).
///
/// - region: `(x1, y1, x2, y2)` in data coords — explicit spy glass corners
/// - center: `(cx, cy)` in data coords — spy glass center (use with `size`)
/// - size: spy glass size in cm (canvas units) — ensures a square spy glass
/// - at: `(x, y)` data coords of inset center (`auto` = smart placement in opposite quadrant)
/// - width: inset box width in cm (`auto` = from magnification or 3.5)
/// - height: inset box height in cm (`auto` = from magnification or 3.5)
/// - magnification: zoom factor — inset size = spy glass canvas size × factor
/// - lens-shape: `"rect"` (default) or `"circle"`
/// - connect: draw connector lines between spy glass and inset (default true)
/// - accent: accent color for borders and region fill tint
/// - region-fill: fill tint inside spy glass (default: light accent)
/// - region-stroke: border stroke of the spy glass
/// - box-stroke: border stroke of the inset box
/// - box-fill: background fill of the inset (default white)
/// - connector-stroke: stroke for connector lines (default: dashed gray)
/// - connector-fill: fill for the trapezoid between connector lines (default none)
/// - shadow: drop shadow behind the inset (default true)
/// - show-inset-grid: subtle grid inside inset aligned to main ticks (default true)
/// - show-magnification: show ×N label in inset corner (default false)
/// - label: custom label inside inset (overrides auto ×N; `none` = hide)
///
/// Example — square spy glass, 4× magnification:
/// ```typst
/// #plot(xmin: -5, xmax: 5, ymin: -2, ymax: 2,
///   (fn: x => calc.sin(x), stroke: blue + 1.2pt),
///   zoom(center: (0, 0), size: 0.8, magnification: 4, at: (3, 1.5)),
/// )
/// ```
#let zoom(
  region: auto,
  center: auto,
  size: auto,
  at: auto,
  width: auto,
  height: auto,
  magnification: auto,
  lens-shape: "rect",
  connect: true,
  accent: rgb("#4a90d9"),
  region-fill: auto,
  region-stroke: auto,
  box-stroke: auto,
  box-fill: white,
  connector-stroke: auto,
  connector-fill: none,
  shadow: auto,
  show-inset-grid: true,
  show-magnification: false,
  label: none,
) = {
  assert(region != auto or (center != auto and size != auto),
    message: "zoom() requires either 'region: (x1,y1,x2,y2)' or both 'center' and 'size'")
  // Store region placeholder (rendering overrides it when zoom-center+zoom-size-cm are present)
  let eff-region = if region != auto {
    region
  } else {
    let (cx, cy) = center
    (cx, cy, cx, cy)  // placeholder — overridden in rendering by center+size-cm logic
  }
  let spec = (
    zoom-region: eff-region,
    at: at,
    lens-shape: lens-shape,
    connect: connect,
    accent: accent,
    connector-fill: connector-fill,
    show-inset-grid: show-inset-grid,
    show-magnification: show-magnification,
    label: label,
  )
  if center != auto           { spec.insert("zoom-center", center) }
  if size != auto             { spec.insert("zoom-size-cm", size) }
  if width != auto            { spec.insert("zoom-width", width) }
  if height != auto           { spec.insert("zoom-height", height) }
  if magnification != auto    { spec.insert("magnification", magnification) }
  if region-fill != auto      { spec.insert("region-fill", region-fill) }
  if region-stroke != auto    { spec.insert("region-stroke", region-stroke) }
  if box-stroke != auto       { spec.insert("box-stroke", box-stroke) }
  if box-fill != none         { spec.insert("box-fill", box-fill) }
  if connector-stroke != auto { spec.insert("connector-stroke", connector-stroke) }
  if shadow != auto           { spec.insert("shadow", shadow) }
  spec
}

/// Draw Riemann sum rectangles for `fn` over `domain` with `n` subdivisions.
///
/// - method: `"left"`, `"right"`, `"mid"`, `"lower"` (true infimum), `"upper"` (true supremum)
/// - samples: sample points per subinterval for `"lower"`/`"upper"` (default 20)
/// - show-points: draw a dot at each evaluation point (left/right/mid only)
/// - point-color: fill color of the dots (default dark orange)
/// - point-size: radius of dots in cm (default 0.07)
/// - point-label: content label with arrows to dots; `auto` = method-based text, `none` = no label
/// - point-label-pos: (x,y) in data coords for the label; `auto` = upper-right of dots
/// - show-dx: draw a Δx dimension bracket under one rectangle
/// - dx-rect: index of rectangle to annotate (0-based); `auto` = middle rectangle
/// - dx-label: content for the bracket label (default $Delta x$)
/// - show-xi: draw x₀, x₁, … labels at subdivision points below the axis
/// - xi-labels: array of content overrides; `auto` = generate x_i subscripts
/// - xi-show-values: if true, stack the numeric x value above each xi label
/// - Hatch styles: `"ne"`, `"nw"`, `"h"`, `"v"`, `"cross"`, `"grid"`
#let riemann-sum(
  fn,
  domain: auto,
  n: 4,
  method: "right",
  baseline: 0.0,
  color: luma(220),
  stroke: luma(80) + 0.6pt,
  hatch: none,
  hatch-spacing: 5pt,
  hatch-stroke: luma(80) + 0.5pt,
  samples: 20,
  show-points: false,
  point-color: rgb("#c94a00"),
  point-size: 0.07,
  point-label: auto,
  point-label-pos: auto,
  show-dx: false,
  dx-rect: auto,
  dx-label: $Delta x$,
  show-xi: false,
  xi-labels: auto,
  xi-show-values: false,
) = {
  let spec = (
    riemann: fn, n: n, method: method, baseline: baseline,
    color: color, stroke: stroke,
    hatch: hatch, hatch-spacing: hatch-spacing, hatch-stroke: hatch-stroke,
    samples: samples,
    show-points: show-points, point-color: point-color, point-size: point-size,
    point-label: point-label, point-label-pos: point-label-pos,
    show-dx: show-dx, dx-rect: dx-rect, dx-label: dx-label,
    show-xi: show-xi, xi-labels: xi-labels, xi-show-values: xi-show-values,
  )
  if domain != auto { spec.insert("domain", domain) }
  spec
}

/// Parametric curve specification: plot the curve (fn-x(t), fn-y(t)) for t in domain.
///
/// Example (unit circle):
/// ```typst
/// #plot(xmin: -1.5, xmax: 1.5, ymin: -1.5, ymax: 1.5,
///   parametric(t => calc.cos(t), t => calc.sin(t), domain: (0, 2*calc.pi)),
/// )
/// ```
#let parametric(
  fn-x,
  fn-y,
  domain: (0.0, 1.0),
  stroke: blue + 1.2pt,
  samples: 100,
) = (parametric: (fn-x, fn-y), domain: domain, stroke: stroke, samples: samples)

/// Fill area enclosed by a parametric closed curve (fn-x(t), fn-y(t)).
///
/// The curve should be closed: (fn-x(t1), fn-y(t1)) ≈ (fn-x(t2), fn-y(t2)).
///
/// Example (filled unit circle):
/// ```typst
/// #plot(xmin: -1.5, xmax: 1.5, ymin: -1.5, ymax: 1.5,
///   fill-closed(t => calc.cos(t), t => calc.sin(t), domain: (0, 2*calc.pi),
///               color: blue.lighten(70%)),
/// )
/// ```
#let fill-closed(
  fn-x,
  fn-y,
  domain: (0.0, 1.0),
  color: luma(220),
  hatch: none,
  hatch-spacing: 5pt,
  hatch-stroke: luma(80) + 0.5pt,
  samples: 80,
) = (
  fill-closed: (fn-x, fn-y), domain: domain, color: color,
  hatch: hatch, hatch-spacing: hatch-spacing, hatch-stroke: hatch-stroke,
  samples: samples,
)

// ============================================================================
// SOLID OF REVOLUTION ILLUSTRATION
// ============================================================================

/// Draw a 3D-style solid of revolution illustration.
///
/// Rotates the region between y = fn(x) and y = axis-y from x=a to x=b.
/// Renders a perspective view with profile curves, end caps, and disk cross-sections.
///
/// - fn: profile function y = f(x) > 0
/// - domain: (a, b) — interval of revolution
/// - axis-y: y-value of the horizontal axis of revolution (default: 0, the x-axis)
/// - n-disks: number of intermediate circular cross-sections to show
/// - width, height: canvas size in cm
/// - samples: number of points to sample the profile
/// - show-axis: draw x-axis through center
/// - show-y-axis: draw a coordinate y-axis
/// - show-labels: show a, b, f labels
/// - profile-stroke: stroke for the top profile curve
/// - disk-color: fill color for the solid body
/// - label-a, label-b, label-f: content for axis position labels and function label
///
/// Example:
/// ```typst
/// #volume-of-revolution(x => calc.sqrt(x + 1), domain: (0, 3), n-disks: 4)
/// ```
#let volume-of-revolution(
  fn,
  domain: (0.0, 4.0),
  n-disks: 4,
  width: 5.0,
  height: 3.5,
  samples: 60,
  show-axis: true,
  show-y-axis: false,
  y-axis-x: auto,
  y-axis-offset: 0.45,
  y-axis-extend: (0.35, 0.45),
  axis-y: 0.0,
  axis-slope: 0.0,   // slope m: revolution axis is y = m*x + axis-y
  show-yaxis: false,
  show-radius-marker: false,
  yaxis-x: auto,
  show-labels: true,
  show-back: true,
  profile-stroke: blue + 1.5pt,
  disk-color: luma(218),
  disk-stroke: luma(90) + 0.6pt,
  axis-stroke: black + 0.7pt,
  label-a: $a$,
  label-b: $b$,
  label-f: $f$,
  label-y: $y$,
) = {
  let (a, b) = domain
  let m   = float(axis-slope)
  let b0  = float(axis-y)      // y-intercept of axis: y = m*x + b0
  let dsq = 1.0 + m * m        // denominator 1 + m²

  // Perpendicular distance from (px, py) to the axis line y = m*px + b0.
  let perp-r(px, py) = calc.abs(py - m * px - b0) / calc.sqrt(dsq)

  // X-coordinate of the foot of the perpendicular from (px, py) onto the axis.
  let foot-x(px, py) = (px + m * (py - b0)) / dsq

  // Sample curve to find foot-x range and maximum radius.
  let n-s = samples
  let step = (b - a) / n-s
  let foot-xs = ()
  let radii   = ()
  for i in range(n-s + 1) {
    let x = a + i * step
    let y = fn(x)
    if y != none and not float(y).is-nan() {
      let fy = float(y)
      let r = perp-r(x, fy)
      if r > 0.0 {
        foot-xs.push(foot-x(x, fy))
        radii.push(r)
      }
    }
  }
  let fx-min = if foot-xs.len() > 0 { calc.min(..foot-xs) } else { float(a) }
  let fx-max = if foot-xs.len() > 0 { calc.max(..foot-xs) } else { float(b) }
  let r-max  = if radii.len()   > 0 { calc.max(..radii)   } else { 1.0 }

  let x-sc = width / (fx-max - fx-min)
  let y-sc = (height / 2.0) / r-max
  let ell-r = 0.30

  // Canvas coordinate helpers — both take the original (x, y) point.
  let cx(px, py) = (foot-x(px, float(py)) - fx-min) * x-sc
  let cr(px, py) = perp-r(px, float(py)) * y-sc

  let safe-cr(raw, px) = {
    if raw == none { 0.0 }
    else {
      let v = float(raw)
      if v.is-nan() { 0.0 } else { perp-r(px, v) * y-sc }
    }
  }

  cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let axis-cy = 0.0
    let disk-steps = 36
    let dashed-stroke = (paint: luma(160), thickness: 0.45pt, dash: "dashed")
    let draw-coordinate-y-axis = show-y-axis or show-yaxis
    let draw-radius-marker = show-radius-marker

    let ellipse-half(ex, radius, side) = {
      let pts = ()
      let er = radius * ell-r
      for j in range(disk-steps + 1) {
        let t = j / disk-steps
        let angle = if side == "front" {
          -90deg + t * 180deg
        } else if side == "back" {
          90deg + t * 180deg
        } else if side == "upper" {
          0deg + t * 180deg
        } else if side == "upper-front" {
          0deg + t * 90deg
        } else if side == "upper-back" {
          90deg + t * 90deg
        } else {
          180deg + t * 180deg
        }
        pts.push((
          ex + er * calc.cos(angle),
          axis-cy + radius * calc.sin(angle),
        ))
      }
      pts
    }

    let ellipse-full(ex, radius) = {
      let pts = ()
      let er = radius * ell-r
      for j in range(disk-steps + 1) {
        let t = j / disk-steps
        let angle = -90deg + t * 360deg
        pts.push((
          ex + er * calc.cos(angle),
          axis-cy + radius * calc.sin(angle),
        ))
      }
      pts
    }

    // Collect profile points.
    let top-pts = ()
    let bot-pts = ()
    for i in range(n-s + 1) {
      let x = a + i * step
      let y = fn(x)
      if y != none and not float(y).is-nan() {
        let fy = float(y)
        let r = cr(x, fy)
        if r > 0.0 {
          top-pts.push((cx(x, fy), axis-cy + r))
          bot-pts.push((cx(x, fy), axis-cy - r))
        }
      }
    }

    // Right cap at x=b, drawn first so the closing disk sits behind the body.
    let yb = fn(b)
    if yb != none {
      let fyb = float(yb)
      let ex = cx(b, fyb)
      let radius = safe-cr(yb, b)
      if radius > 0.02 {
        if show-back {
          line(..ellipse-full(ex, radius), close: true, fill: disk-color, stroke: none)
          line(..ellipse-half(ex, radius, "back"), stroke: (paint: luma(140), thickness: 0.4pt, dash: "dashed"))
        } else {
          line(..ellipse-half(ex, radius, "upper"), close: true, fill: disk-color, stroke: none)
          line(..ellipse-half(ex, radius, "upper-back"), stroke: dashed-stroke)
        }
      }
    }

    // Filled solid body
    if top-pts.len() > 0 {
      if show-back {
        line(..(top-pts + bot-pts.rev()), close: true, fill: disk-color, stroke: none)
      } else {
        let x-left  = top-pts.first().at(0)
        let x-right = top-pts.last().at(0)
        line(..(top-pts + ((x-right, axis-cy), (x-left, axis-cy))), close: true,
             fill: disk-color, stroke: none)
      }
    }

    // Intermediate disk cross-sections
    for i in range(1, n-disks + 1) {
      let xd = a + i * (b - a) / (n-disks + 1)
      let yd = fn(xd)
      if yd != none and not float(yd).is-nan() {
        let fyd = float(yd)
        let ex = cx(xd, fyd)
        let radius = cr(xd, fyd)
        if radius > 0.02 {
          if show-back {
            line(..ellipse-half(ex, radius, "back"), stroke: dashed-stroke)
            line(..ellipse-half(ex, radius, "front"), stroke: disk-stroke)
          } else {
            line(..ellipse-half(ex, radius, "upper-back"), stroke: dashed-stroke)
            line(..ellipse-half(ex, radius, "upper-front"), stroke: disk-stroke)
          }
        }
      }
    }

    // Bottom profile (dashed)
    if show-back and bot-pts.len() > 1 {
      line(..bot-pts, stroke: dashed-stroke)
    }

    // Left cap at x=a
    let ya = fn(a)
    if ya != none {
      let fya = float(ya)
      let ex = cx(a, fya)
      let radius = safe-cr(ya, a)
      if radius > 0.02 {
        if show-back {
          line(..ellipse-full(ex, radius), close: true, fill: disk-color, stroke: none)
          line(..ellipse-half(ex, radius, "back"), stroke: (paint: luma(170), thickness: 0.4pt, dash: "dashed"))
          line(..ellipse-half(ex, radius, "front"), stroke: (paint: luma(100), thickness: 0.5pt))
        } else {
          line(..ellipse-half(ex, radius, "upper"), close: true, fill: disk-color, stroke: none)
          line(..ellipse-half(ex, radius, "upper-back"), stroke: dashed-stroke)
          line(..ellipse-half(ex, radius, "upper-front"), stroke: (paint: luma(100), thickness: 0.5pt))
        }
      }
    }

    // Top profile
    if top-pts.len() > 1 {
      line(..top-pts, stroke: profile-stroke)
    }

    let coord-y-axis-x = if draw-coordinate-y-axis {
      if y-axis-x == auto {
        -float(y-axis-offset)
      } else {
        let xv = y-axis-x
        let yv-raw = fn(xv)
        if yv-raw != none { cx(xv, float(yv-raw)) } else { 0.0 }
      }
    } else { none }

    // Coordinate y-axis (optional)
    if draw-coordinate-y-axis {
      let (ext-bot, ext-top) = if type(y-axis-extend) == array { y-axis-extend } else { (y-axis-extend, y-axis-extend) }
      let y-bottom = -height / 2.0 - ext-bot
      let y-top = height / 2.0 + ext-top
      line((coord-y-axis-x, y-bottom), (coord-y-axis-x, axis-cy + y-top), stroke: axis-stroke,
           mark: (end: (symbol: "stealth", fill: black, scale: 0.55)))
      content((coord-y-axis-x - 0.05, axis-cy + y-top), label-y, anchor: "east")
    }

    // Radius marker (optional)
    if draw-radius-marker {
      let xv = if yaxis-x == auto { a } else { yaxis-x }
      let yv-raw = fn(xv)
      let yv = safe-cr(yv-raw, xv)
      if yv > 0.05 {
        let yax-x = if yv-raw != none { cx(xv, float(yv-raw)) } else { 0.0 }
        line((yax-x, axis-cy), (yax-x, axis-cy + yv + 0.35), stroke: axis-stroke,
             mark: (end: (symbol: "stealth", fill: black, scale: 0.55)))
        content((yax-x - 0.05, axis-cy + yv + 0.35), label-y, anchor: "east")
      }
    }

    // Revolution axis arrow
    if show-axis {
      let axis-start-x = if coord-y-axis-x != none { coord-y-axis-x } else { -0.25 }
      line((axis-start-x, axis-cy), (width + 0.4, axis-cy), stroke: axis-stroke,
           mark: (end: (symbol: "stealth", fill: black, scale: 0.55)))
      content((width + 0.45, axis-cy - 0.03), $x$, anchor: "north-west")
    }

    // Tick marks and labels at domain endpoints
    if show-labels {
      let tick = 0.15
      // Canvas positions of the domain endpoints' foot projections
      let cx-a = if ya != none { cx(a, float(ya)) } else { 0.0 }
      let cx-b = if yb != none { cx(b, float(yb)) } else { width }
      line((cx-a, axis-cy + tick), (cx-a, axis-cy - tick), stroke: axis-stroke)
      line((cx-b, axis-cy + tick), (cx-b, axis-cy - tick), stroke: axis-stroke)
      content((cx-a, axis-cy - (tick + 0.08)), label-a, anchor: "north")
      content((cx-b, axis-cy - (tick + 0.08)), label-b, anchor: "north")
      let lx = a + (b - a) * 0.18
      let ly = fn(lx)
      if ly != none {
        let fly = float(ly)
        content((cx(lx, fly), axis-cy + safe-cr(ly, lx) + 0.22), label-f, anchor: "south")
      }
    }
  })
}

#let solid-of-revolution = volume-of-revolution
