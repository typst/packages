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
      let nx = int(calc.ceil((xmax - xmin) / minor-x-step)) + 1
      let ny = int(calc.ceil((ymax - ymin) / minor-y-step)) + 1

      for i in range(nx) {
        let x = xmin + i * minor-x-step
        if x <= xmax {
          let cx = (x - xmin) * x-scale
          if grid-label-break and x-break-zones.len() + y-break-zones.len() > 0 {
            draw-vline-with-gaps(cx, grid-y-start, grid-y-end, s.grid.minor.stroke)
          } else {
            line((cx, grid-y-start), (cx, grid-y-end), stroke: s.grid.minor.stroke)
          }
        }
      }
      for i in range(ny) {
        let y = ymin + i * minor-y-step
        if y <= ymax {
          let cy = (y - ymin) * y-scale
          if grid-label-break and x-break-zones.len() + y-break-zones.len() > 0 {
            draw-hline-with-gaps(cy, grid-x-start, grid-x-end, s.grid.minor.stroke)
          } else {
            line((grid-x-start, cy), (grid-x-end, cy), stroke: s.grid.minor.stroke)
          }
        }
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
                  text(size: s.ticks.label-size)[#label], anchor: "north")
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
                  text(size: s.ticks.label-size)[#label], anchor: "east")
        }
      }
    }

    // Origin label
    if show-origin and calc.abs(x-axis-y) < 0.0001 and calc.abs(y-axis-x) < 0.0001 {
      let (ox, oy) = to-canvas(0, 0)
      content((ox - tick-len - 0.05, oy - tick-len - 0.05),
              text(size: s.ticks.label-size)[0], anchor: "north-east")
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
      content((lx + ox, ly + oy), text(size: s.labels.size)[#xlabel], anchor: xlabel-anchor)
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

    // Merge series: array with positional functions
    let all-funcs = if series != none { series + functions.pos() } else { functions.pos() }

    // Plot functions and data (with manual line clipping)
    for func-spec in all-funcs {
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
