// simple-plot - A simple pgfplots-like function plotting library for Typst
// https://github.com/nathan/simple-plot
// License: MIT

#import "@preview/cetz:0.5.2" as cetz

// ============================================================================
// GLOBAL DEFAULTS
// ============================================================================

#let _plot-defaults = state("simple-plot-defaults", (:))

// Every named parameter of plot() that set-plot-defaults may override,
// plus "style". Keep in sync with the plot() signature.
#let _plot-default-keys = (
  "xmin", "xmax", "ymin", "ymax", "width", "height", "scale",
  "xlabel", "ylabel", "xlabel-pos", "ylabel-pos",
  "xlabel-anchor", "ylabel-anchor", "xlabel-offset", "ylabel-offset",
  "xtick", "ytick", "xtick-step", "ytick-step",
  "xtick-labels", "ytick-labels", "xtick-label-step", "ytick-label-step",
  "show-grid", "minor-grid-step", "grid-label-break", "unit-label-only",
  "axis-x-pos", "axis-y-pos", "axis-x-extend", "axis-y-extend",
  "show-origin", "origin-label-offset", "origin-label-anchor",
  "origin-leader", "origin-leader-stroke", "origin-leader-gap",
  "origin-leader-end-gap",
  "tick-label-size", "axis-label-size", "font",
  "show-end-ticks", "min-tick-spacing", "hide-crossed-tick-labels",
  "style",
)

/// Set default values for all subsequent plots.
///
/// Example:
/// ```typst
/// #set-plot-defaults(width: 10, height: 8, show-grid: true)
/// ```
#let set-plot-defaults(..args) = {
  for key in args.named().keys() {
    assert(key in _plot-default-keys,
      message: "set-plot-defaults: unknown plot option: " + key)
  }
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
    // Painted behind tick labels so a curve crossing the label band stays
    // behind clean digits (labels are drawn after the plot series).
    label-bg: white,
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
    // Same background trick as tick labels: keeps the x/y axis names legible
    // when a curve passes under them.
    bg: white,
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

// Canvas dimensions (width, height, ...) accept plain numbers (interpreted
// as cm, the historical behavior) or absolute lengths (2cm, 30mm, 12pt, ...).
// Returns a float in cm.
#let to-cm(v) = if type(v) == length { v.cm() } else { v }

// Resolve a function passed either positionally or as the named `fn:`
// argument (helpers accept both, matching the `(fn: ..., ...)` series dicts).
#let _resolve-fn(name, args, fn) = {
  assert(args.named().len() == 0,
    message: name + ": unknown named arguments: " + args.named().keys().join(", "))
  if fn != none {
    assert(args.pos().len() == 0,
      message: name + ": pass the function either positionally or as fn:, not both")
    fn
  } else {
    assert(args.pos().len() == 1,
      message: name + ": expected one function (positional or fn:)")
    args.pos().first()
  }
}

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

// Smallest "nice" step (1, 2 or 5 times a power of ten) >= needed
#let nice-step(needed) = {
  let k = calc.floor(calc.log(calc.max(needed, 1e-9), base: 10))
  let result = 10 * calc.pow(10.0, k)
  for mult in (1, 2, 5) {
    let step = mult * calc.pow(10.0, k)
    if step >= needed - 1e-9 { result = step; break }
  }
  result
}

// Generate ticks starting on integers. With step auto, defaults to 1 but
// widens to the next nice step (2, 5, 10, ...) when the canvas scale would
// place ticks closer than min-spacing (cm) apart — keeps labels readable on
// large ranges (e.g. y from -80 to 30 on a 5 cm axis).
#let generate-ticks(min, max, step: auto, scale: none, min-spacing: 0.4) = {
  let actual-step = if step != auto {
    step
  } else if scale != none {
    calc.max(1, nice-step(min-spacing / scale))
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

// Riemann rectangle geometry: for each of the `n` subintervals of (d1, d2),
// the bounds, the evaluation point (none for lower/upper methods) and the
// rectangle height (none where fn is undefined). Shared by the main renderer
// and the zoom-inset re-render.
#let riemann-heights(fn, d1, d2, n, method, samples) = {
  let w = (d2 - d1) / n
  let out = ()
  for i in range(n) {
    let xl = d1 + i * w
    let xr = d1 + (i + 1) * w
    let (xeval, y) = if method == "lower" or method == "upper" {
      let sub-ys = ()
      for j in range(samples + 1) {
        let x = xl + j * (xr - xl) / samples
        let v = fn(x)
        if v != none and not float(v).is-nan() { sub-ys.push(float(v)) }
      }
      if sub-ys.len() == 0 { (none, none) }
      else if method == "lower" { (none, calc.min(..sub-ys)) }
      else { (none, calc.max(..sub-ys)) }
    } else {
      let xe = if method == "left" { xl }
               else if method == "right" { xr }
               else { (xl + xr) / 2.0 }
      let ev = fn(xe)
      if ev == none or float(ev).is-nan() { (xe, none) } else { (xe, float(ev)) }
    }
    out.push((xl: xl, xr: xr, xeval: xeval, y: y))
  }
  out
}

// Clip a Riemann rectangle (data coordinates, y-lo <= y-hi) to the plot
// window. Returns none when nothing is visible, otherwise the clipped bounds
// plus which of the four edges survived. An edge that was clipped away lies
// outside the window and must not be stroked — stroking it would draw a false
// boundary (e.g. a flat top at ymax pretending to be the rectangle's height).
#let riemann-clip-rect(xl, xr, y-lo, y-hi, xmin, xmax, ymin, ymax) = {
  let eps = 1e-9
  if xr <= xmin + eps or xl >= xmax - eps { return none }
  if y-hi <= ymin + eps or y-lo >= ymax - eps { return none }
  (
    xl: calc.max(xl, xmin), xr: calc.min(xr, xmax),
    y-lo: calc.max(y-lo, ymin), y-hi: calc.min(y-hi, ymax),
    left: xl >= xmin - eps,
    right: xr <= xmax + eps,
    bottom: y-lo >= ymin - eps,
    top: y-hi <= ymax + eps,
  )
}

// ============================================================================
// MARKER DRAWING
// ============================================================================

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

// ============================================================================
// MAIN PLOT FUNCTION
// ============================================================================

/// Create a 2D plot with axes, grid, and function/data visualization.
///
/// - xmin (auto, float): Minimum x value
/// - xmax (auto, float): Maximum x value
/// - ymin (auto, float): Minimum y value
/// - ymax (auto, float): Maximum y value
/// - width (auto, float, length): Plot width — a length (2cm, 30mm, ...) or a number in cm
/// - height (auto, float, length): Plot height — a length (2cm, 30mm, ...) or a number in cm
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
/// - axis-x-pos (auto, none, float, str): X-axis y-position ("bottom", "center", or value; none = hide the axis)
/// - axis-y-pos (auto, none, float, str): Y-axis x-position ("left", "center", or value; none = hide the axis)
/// - axis-x-extend (auto, length, float, array): X-axis extension beyond the plot,
///   value or (left, right) — lengths are absolute (scale-independent), bare
///   numbers are data units (legacy). Default: (0pt, 0.3cm)
/// - axis-y-extend (auto, length, float, array): Y-axis extension beyond the plot,
///   value or (bottom, top) — same conventions as axis-x-extend
/// - show-origin (auto, bool): Show "0" label at origin (default: true)
/// - origin-label-offset (auto, array): Origin label offset from (0,0) in cm (default: (-0.11, -0.11))
/// - origin-label-anchor (auto, str): Origin label anchor (default: "north-east")
/// - origin-leader (auto, bool): Draw a subtle leader from origin label toward (0,0) (default: true)
/// - origin-leader-stroke (auto, stroke): Origin leader stroke (default: black + 0.6pt)
/// - origin-leader-gap (auto, float): Gap from origin before leader starts, in cm (default: 0.025)
/// - origin-leader-end-gap (auto, float): Gap before the label anchor, in cm (default: 0.025)
/// - tick-label-size (auto, length): Font size for tick labels (default: 0.65em)
/// - axis-label-size (auto, length): Font size for axis labels x/y (default: 0.8em)
/// - font (auto, str, array): Font applied to every text the plot generates
///   (tick labels, axis labels, origin, annotations). Default: document font.
/// - show-end-ticks (auto, bool): When the max value lands on a tick, keep that
///   tick/label (e.g. xmax = 5 shows "5") and push the axis slightly past it so
///   the arrow clears the label (default: true)
/// - min-tick-spacing (auto, float): Minimum spacing between auto ticks in cm before
///   the step widens to the next nice value (default: 0.4)
/// - hide-crossed-tick-labels (auto, bool): Hide tick labels crossed by a plotted
///   curve (default: true)
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
  font: auto,
  show-end-ticks: auto,
  min-tick-spacing: auto,
  hide-crossed-tick-labels: auto,
  style: none,
  series: none,
  ..functions,
) = context {
  // Named arguments not in the signature would silently land in the
  // `..functions` sink — catch typos (e.g. `xtick-lables`) instead.
  assert(functions.named().len() == 0,
    message: "plot: unknown named arguments: " + functions.named().keys().join(", "))

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
  let width = to-cm(resolve(width, "width", 6))
  let height = to-cm(resolve(height, "height", 6))
  let scale = resolve(scale, "scale", 1)
  let width = width * scale
  let height = height * scale
  let xlabel = resolve(xlabel, "xlabel", $x$)
  let ylabel = resolve(ylabel, "ylabel", $y$)
  let xlabel-pos = resolve(xlabel-pos, "xlabel-pos", "end")
  let ylabel-pos = resolve(ylabel-pos, "ylabel-pos", "end")
  let xlabel-anchor = resolve(xlabel-anchor, "xlabel-anchor", auto)
  let ylabel-anchor = resolve(ylabel-anchor, "ylabel-anchor", auto)
  let xlabel-offset = resolve(xlabel-offset, "xlabel-offset", (-0.05, 0.08))
  let ylabel-offset = resolve(ylabel-offset, "ylabel-offset", (0.08, -0.05))
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
  let axis-x-extend = resolve(axis-x-extend, "axis-x-extend", (0pt, 0.3cm))
  let axis-y-extend = resolve(axis-y-extend, "axis-y-extend", (0pt, 0.3cm))
  let show-origin = resolve(show-origin, "show-origin", true)
  let origin-label-offset = resolve(origin-label-offset, "origin-label-offset", auto)
  let origin-label-anchor = resolve(origin-label-anchor, "origin-label-anchor", auto)
  let origin-leader = resolve(origin-leader, "origin-leader", auto)
  let origin-leader-stroke = resolve(origin-leader-stroke, "origin-leader-stroke", auto)
  let origin-leader-gap = resolve(origin-leader-gap, "origin-leader-gap", auto)
  let origin-leader-end-gap = resolve(origin-leader-end-gap, "origin-leader-end-gap", auto)
  let tick-label-size = resolve(tick-label-size, "tick-label-size", auto)
  let axis-label-size = resolve(axis-label-size, "axis-label-size", auto)
  let font = resolve(font, "font", auto)
  let show-end-ticks = resolve(show-end-ticks, "show-end-ticks", true)
  let min-tick-spacing = resolve(min-tick-spacing, "min-tick-spacing", 0.4)
  let hide-crossed-tick-labels = resolve(hide-crossed-tick-labels, "hide-crossed-tick-labels", true)

  // Apply a single font to every piece of text the plot generates
  // (tick labels, axis labels, origin label, annotations, ...).
  let apply-font(body) = if font == auto { body } else { text(font: font, body) }

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

  // Axis extensions normalized to canvas cm. A length (3mm, 0.4cm) is
  // absolute and scale-independent; a bare number keeps the historical
  // meaning of data units (multiplied by the axis scale) — that meaning
  // breaks down on small data ranges, hence the length-based default.
  let ext-to-cm(v, scale) = if type(v) == length { v.cm() } else { v * scale }
  let x-extend = (ext-to-cm(x-extend.at(0), x-scale), ext-to-cm(x-extend.at(1), x-scale))
  let y-extend = (ext-to-cm(y-extend.at(0), y-scale), ext-to-cm(y-extend.at(1), y-scale))

  let to-canvas(x, y) = {
    ((x - xmin) * x-scale, (y - ymin) * y-scale)
  }

  // `none` hides the axis entirely (line, arrow, ticks, labels).
  let draw-x-axis = axis-x-pos != none
  let draw-y-axis = axis-y-pos != none
  let x-axis-y = if axis-x-pos == none or axis-x-pos == "bottom" { ymin }
                 else if axis-x-pos == "center" { 0 }
                 else { calc.max(ymin, calc.min(ymax, axis-x-pos)) }

  let y-axis-x = if axis-y-pos == none or axis-y-pos == "left" { xmin }
                 else if axis-y-pos == "center" { 0 }
                 else { calc.max(xmin, calc.min(xmax, axis-y-pos)) }

  // A hidden axis carries no name label and no origin "0".
  let xlabel = if draw-x-axis { xlabel } else { none }
  let ylabel = if draw-y-axis { ylabel } else { none }
  let show-origin = show-origin and draw-x-axis and draw-y-axis

  let x-ticks = if xtick == none { (ticks: (), step: 1) }
                else if xtick == auto { generate-ticks(xmin, xmax, step: xtick-step, scale: x-scale, min-spacing: min-tick-spacing) }
                else { (ticks: xtick, step: if xtick.len() > 1 { xtick.at(1) - xtick.at(0) } else { 1 }) }

  let y-ticks = if ytick == none { (ticks: (), step: 1) }
                else if ytick == auto { generate-ticks(ymin, ymax, step: ytick-step, scale: y-scale, min-spacing: min-tick-spacing) }
                else { (ticks: ytick, step: if ytick.len() > 1 { ytick.at(1) - ytick.at(0) } else { 1 }) }

  // When the max value lands exactly on a tick, keep that tick/label instead of
  // hiding it under the axis arrow, and make sure the axis is pushed a little
  // past it (e.g. xmax = 5 → axis to 5.2) so the arrow clears the label.
  let end-tick-overshoot = 0.12  // cm
  let xmax-on-tick = show-end-ticks and x-ticks.ticks.any(t => calc.abs(t - xmax) < 0.0001)
  let ymax-on-tick = show-end-ticks and y-ticks.ticks.any(t => calc.abs(t - ymax) < 0.0001)
  if xmax-on-tick { x-extend.at(1) = calc.max(x-extend.at(1), end-tick-overshoot) }
  if ymax-on-tick { y-extend.at(1) = calc.max(y-extend.at(1), end-tick-overshoot) }

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
      let seg(from, to) = place(native-line(start: from, end: to, stroke: stroke-style))
      // Every line is extended half a tile past the boundary, and diagonals
      // are repeated at the opposite corners: a thick stroke's band around a
      // corner-to-corner line spills into the neighboring tiles, and the tile
      // clip would otherwise punch holes into it at the corners.
      let ne-lines = (
        seg((-0.5 * s, 1.5 * s), (1.5 * s, -0.5 * s)),
        seg((-0.5 * s, 0.5 * s), (0.5 * s, -0.5 * s)),
        seg((0.5 * s, 1.5 * s), (1.5 * s, 0.5 * s)),
      )
      let nw-lines = (
        seg((-0.5 * s, -0.5 * s), (1.5 * s, 1.5 * s)),
        seg((-0.5 * s, 0.5 * s), (0.5 * s, 1.5 * s)),
        seg((0.5 * s, -0.5 * s), (1.5 * s, 0.5 * s)),
      )
      let h-line = seg((-0.5 * s, s / 2), (1.5 * s, s / 2))
      let v-line = seg((s / 2, -0.5 * s), (s / 2, 1.5 * s))
      let lines = if style == "ne" { ne-lines }
        else if style == "nw" { nw-lines }
        else if style == "h" { (h-line,) }
        else if style == "v" { (v-line,) }
        else if style == "cross" { ne-lines + nw-lines }
        else if style == "grid" { (h-line, v-line) }
        else { return none }
      tiling(size: (s, s), lines.join())
    }

    // Fill paint of an area-type spec: hatch pattern if requested, else the
    // solid color. `hatch` is a style string or a dict
    // (style: "ne", spacing: 5pt, stroke: ...); the flat `hatch-spacing` /
    // `hatch-stroke` keys are the fallback for unset dict entries.
    let series-paint(func-spec, fill-color) = {
      let h = func-spec.at("hatch", default: none)
      if h == none { return fill-color }
      let (style, spacing, stroke-v) = if type(h) == dictionary {
        assert("style" in h,
          message: "hatch: dictionary form requires a 'style' key, e.g. (style: \"ne\", spacing: 5pt)")
        (h.at("style"),
         h.at("spacing", default: func-spec.at("hatch-spacing", default: 5pt)),
         h.at("stroke", default: func-spec.at("hatch-stroke", default: luma(80) + 0.5pt)))
      } else {
        (h,
         func-spec.at("hatch-spacing", default: 5pt),
         func-spec.at("hatch-stroke", default: luma(80) + 0.5pt))
      }
      make-hatch-pattern(style, spacing, stroke-v)
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
      if not draw-x-axis { return false }
      if xtick-labels == none { return false }
      if calc.abs(x) < 0.0001 { return false }  // 0 handled separately
      let label-interval = x-ticks.step * xtick-label-step
      let at-interval = calc.abs(calc.rem(x, label-interval)) < 0.0001 or calc.abs(calc.rem(x, label-interval) - label-interval) < 0.0001
      if unit-label-only and calc.abs(x - 1) > 0.0001 { return false }
      at-interval
    }

    let y-has-label(y) = {
      if not draw-y-axis { return false }
      if ytick-labels == none { return false }
      if calc.abs(y) < 0.0001 { return false }  // 0 handled separately
      let label-interval = y-ticks.step * ytick-label-step
      let at-interval = calc.abs(calc.rem(y, label-interval)) < 0.0001 or calc.abs(calc.rem(y, label-interval) - label-interval) < 0.0001
      if unit-label-only and calc.abs(y - 1) > 0.0001 { return false }
      at-interval
    }

    // Extended bounds for clipping area
    let x-clip-min = xmin - x-extend.at(0) / x-scale
    let x-clip-max = xmax + x-extend.at(1) / x-scale
    let y-clip-min = ymin - y-extend.at(0) / y-scale
    let y-clip-max = ymax + y-extend.at(1) / y-scale

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

    // Clamp a data coordinate into the plot rectangle. Area-type specs
    // (fills, Riemann rectangles) are clipped with these, mirroring the
    // clip-segment clipping applied to curves.
    let clamp-x(x) = calc.max(xmin, calc.min(xmax, float(x)))
    let clamp-y(y) = calc.max(ymin, calc.min(ymax, float(y)))

    // Merge series: array with positional functions
    let all-funcs = if series != none { series + functions.pos() } else { functions.pos() }

    // Separate zoom inset specs — rendered after axes
    let is-zoom-spec(f) = type(f) == dictionary and "zoom-region" in f
    let zoom-specs = all-funcs.filter(is-zoom-spec)
    let all-funcs = all-funcs.filter(f => not is-zoom-spec(f))

    // ── Shared label-geometry helpers ──────────────────────────────────────
    // Estimated tick-label boxes (char-count heuristic, canvas units) and
    // segment/box hit tests, used by the grid label breaks, the crossed-label
    // hiding below, and the automatic function-label placement.
    let est-char-w = 0.17
    let est-char-h = 0.30
    let est-width(val) = {
      let t = format-number(val)
      if val < 0 { 0.10 + (t.len() - 1) * est-char-w } else { t.len() * est-char-w }
    }
    let boxes-overlap(a, b) = {
      a.at(0) < b.at(2) and a.at(2) > b.at(0) and a.at(1) < b.at(3) and a.at(3) > b.at(1)
    }
    let seg-hits-box(p1, p2, b) = {
      let (bx1, by1, bx2, by2) = b
      if calc.max(p1.at(0), p2.at(0)) < bx1 or calc.min(p1.at(0), p2.at(0)) > bx2 { return false }
      if calc.max(p1.at(1), p2.at(1)) < by1 or calc.min(p1.at(1), p2.at(1)) > by2 { return false }
      clip-segment(p1, p2, bx1, by1, bx2, by2) != none
    }
    let x-tick-label-box(x) = {
      let (cx, cy) = to-canvas(x, x-axis-y)
      let top = cy - tick-len - label-offset
      let w = est-width(x)
      (cx - w / 2, top - est-char-h, cx + w / 2, top)
    }
    let y-tick-label-box(y) = {
      let (cx, cy) = to-canvas(y-axis-x, y)
      let right = cx - tick-len - label-offset
      let w = est-width(y)
      (right - w, cy - est-char-h / 2, right, cy + est-char-h / 2)
    }
    let origin-label-box() = {
      let (ox, oy) = to-canvas(0, 0)
      let (dx0, dy0) = s.origin.label-offset
      (ox + dx0 - est-char-w, oy + dy0 - est-char-h, ox + dx0, oy + dy0)
    }

    // ── Pre-sampled curve polylines ────────────────────────────────────────
    // Low-resolution sampling of every series, done before anything is drawn:
    // fn-curve segments decide which tick labels a curve crosses, and together
    // with guide polylines (points series) they are the obstacles for the
    // automatic function-label placement.
    let fn-obstacle-segs = ()
    let guide-obstacle-segs = ()
    for func-spec in all-funcs {
      if type(func-spec) != dictionary { continue }
      if "zoom-region" in func-spec or "zoom-center" in func-spec { continue }
      let fn = func-spec.at("fn", default: none)
      let data-points = func-spec.at("points", default: none)
      if fn != none {
        let domain = func-spec.at("domain", default: none)
        let dmin = if domain == none { x-plot-min } else { domain.at(0) }
        let dmax = if domain == none { x-plot-max } else { domain.at(1) }
        let n = 60
        let step = (dmax - dmin) / n
        let prev = none
        // Midpoint sampling: never evaluates the domain endpoints, which are
        // often poles (fn would divide by zero exactly there).
        for i in range(n) {
          let x = dmin + (i + 0.5) * step
          let y = fn(x)
          if y == none or float(y).is-nan() { prev = none; continue }
          let p = to-canvas(x, y)
          if prev != none { fn-obstacle-segs.push((prev, p)) }
          prev = p
        }
      } else if data-points != none and func-spec.at("connect", default: true) {
        let prev = none
        for pt in data-points {
          let p = to-canvas(pt.at(0), pt.at(1))
          if prev != none { guide-obstacle-segs.push((prev, p)) }
          prev = p
        }
      }
    }
    let obstacle-segs = fn-obstacle-segs + guide-obstacle-segs

    // ── Pre-sampled area-fill boxes ────────────────────────────────────────
    // Coarse canvas-space cover of every area-type fill (Riemann bars,
    // fill-area, fill-between, fill-closed). Labels never paint their white
    // background over one of these boxes: the fill is drawn first (area
    // pass), so the white box would punch a visible hole into it. The label
    // glyphs themselves still render on top of the fill.
    let area-boxes = ()
    for func-spec in all-funcs {
      if type(func-spec) != dictionary { continue }
      if "riemann" in func-spec {
        let r-fn = func-spec.at("riemann")
        let (d1, d2) = func-spec.at("domain", default: (xmin, xmax))
        let r-n = func-spec.at("n", default: 4)
        let r-base = func-spec.at("baseline", default: 0.0)
        let r-method = func-spec.at("method", default: "right")
        let r-samples = func-spec.at("samples", default: 20)
        for r in riemann-heights(r-fn, d1, d2, r-n, r-method, r-samples) {
          if r.y == none { continue }
          let c = riemann-clip-rect(r.xl, r.xr,
            calc.min(r-base, r.y), calc.max(r-base, r.y), xmin, xmax, ymin, ymax)
          if c == none { continue }
          let (x1, y1) = to-canvas(c.xl, c.y-lo)
          let (x2, y2) = to-canvas(c.xr, c.y-hi)
          area-boxes.push((x1, y1, x2, y2))
        }
      } else if "fill" in func-spec or "fill-between" in func-spec or "fill-fn1" in func-spec {
        let base = func-spec.at("baseline", default: 0.0)
        let (fn1, fn2) = if "fill" in func-spec {
          (func-spec.at("fill"), x => base)
        } else if "fill-between" in func-spec {
          func-spec.at("fill-between")
        } else {
          (func-spec.at("fill-fn1"), func-spec.at("fill-fn2", default: x => 0.0))
        }
        let (d1, d2) = func-spec.at("domain", default: (xmin, xmax))
        let d1 = calc.max(float(d1), xmin)
        let d2 = calc.min(float(d2), xmax)
        if d2 - d1 > 1e-9 {
          let n = 40
          let step = (d2 - d1) / n
          for i in range(n) {
            let xa = d1 + i * step
            let ya = fn1(xa + step / 2)
            let yb = fn2(xa + step / 2)
            if ya == none or yb == none { continue }
            let (ya, yb) = (float(ya), float(yb))
            if ya.is-nan() or yb.is-nan() { continue }
            let (x1, y1) = to-canvas(xa, clamp-y(calc.min(ya, yb)))
            let (x2, y2) = to-canvas(xa + step, clamp-y(calc.max(ya, yb)))
            area-boxes.push((x1, y1, x2, y2))
          }
        }
      } else if "fill-closed" in func-spec {
        let (fx, fy) = func-spec.at("fill-closed")
        let (t1, t2) = func-spec.at("domain", default: (0.0, 1.0))
        let n = 40
        let (bx1, by1, bx2, by2) = (none, none, none, none)
        for i in range(n + 1) {
          let t = t1 + i * (t2 - t1) / n
          let px = fx(t)
          let py = fy(t)
          if px == none or py == none { continue }
          let (px, py) = (float(px), float(py))
          if px.is-nan() or py.is-nan() { continue }
          let (cx, cy) = to-canvas(clamp-x(px), clamp-y(py))
          bx1 = if bx1 == none { cx } else { calc.min(bx1, cx) }
          by1 = if by1 == none { cy } else { calc.min(by1, cy) }
          bx2 = if bx2 == none { cx } else { calc.max(bx2, cx) }
          by2 = if by2 == none { cy } else { calc.max(by2, cy) }
        }
        if bx1 != none { area-boxes.push((bx1, by1, bx2, by2)) }
      }
    }
    let label-over-area(b) = area-boxes.any(ab => boxes-overlap(ab, b))

    // ── Hide tick labels crossed by a function graph ───────────────────────
    // A tick value whose label box is crossed by a plotted curve is not
    // rendered — unless hiding it would leave the axis with no label at all,
    // in which case the least-crossed one is kept as the scale indicator.
    // Guide polylines (points series, e.g. dashed asymptotes) do not hide
    // labels: a label under a vertical asymptote locates it and stays.
    let hidden-x = ()
    let hidden-y = ()
    let origin-hidden = false
    if hide-crossed-tick-labels and fn-obstacle-segs.len() > 0 {
      let crossing-count(b) = {
        let hits = 0
        for (p1, p2) in fn-obstacle-segs {
          if seg-hits-box(p1, p2, b) {
            hits += 1
            if hits >= 8 { break }
          }
        }
        hits
      }
      let hide-set(ticks, has-label, on-tick-max, val-max, box-of) = {
        let infos = ()
        for v in ticks {
          if not has-label(v) { continue }
          if calc.abs(v - val-max) < 0.0001 and not on-tick-max { continue }
          infos.push((v: v, hits: crossing-count(box-of(v))))
        }
        let clean = infos.filter(i => i.hits == 0)
        if clean.len() > 0 {
          infos.filter(i => i.hits > 0).map(i => i.v)
        } else if infos.len() > 1 {
          // All crossed: keep the first non-zero label (smallest |value|,
          // positive preferred) — the unit tick reads as the scale indicator;
          // its white background keeps it legible under the curve.
          let keep = infos.sorted(key: i => (calc.abs(i.v), if i.v < 0 { 1 } else { 0 })).first().v
          infos.filter(i => calc.abs(i.v - keep) > 0.0001).map(i => i.v)
        } else { () }
      }
      if xtick-labels == auto {
        hidden-x = hide-set(x-ticks.ticks, x-has-label, xmax-on-tick, xmax, x-tick-label-box)
      }
      if ytick-labels == auto {
        hidden-y = hide-set(y-ticks.ticks, y-has-label, ymax-on-tick, ymax, y-tick-label-box)
      }
      if show-origin and calc.abs(x-axis-y) < 0.0001 and calc.abs(y-axis-x) < 0.0001 {
        let others = (x-ticks.ticks.filter(v => x-has-label(v)).len() - hidden-x.len()
          + y-ticks.ticks.filter(v => y-has-label(v)).len() - hidden-y.len())
        if others > 0 and crossing-count(origin-label-box()) > 0 {
          origin-hidden = true
        }
      }
    }
    // Majority side of a Riemann sum's rectangles relative to its baseline:
    // true when most rectangles extend below (negative function). The x_i
    // labels and the Δx bracket then move above the baseline, out of the fill.
    // Used both here (tick hiding) and in the Riemann renderer — keep in sync.
    let riemann-flip-up(fn, d1, w, n, base) = {
      let below = 0
      let above = 0
      for i in range(n) {
        let v = fn(d1 + (i + 0.5) * w)
        if v == none { continue }
        let fv = float(v)
        if fv.is-nan() { continue }
        if fv < base { below += 1 } else { above += 1 }
      }
      below > above
    }

    // ── Hide x tick labels under Riemann annotations ───────────────────────
    // x_i labels (and the Δx bracket) drawn below the axis replace the x tick
    // labels at the same positions, which would otherwise print on top.
    for func-spec in all-funcs {
      if type(func-spec) != dictionary { continue }
      if "riemann" not in func-spec { continue }
      let r-base = func-spec.at("baseline", default: 0.0)
      // Annotations are drawn at the baseline; they collide with the tick
      // labels when the baseline runs close (in cm) to the x-axis line.
      if calc.abs((r-base - x-axis-y) * y-scale) > 0.45 { continue }
      let show-xi = func-spec.at("show-xi", default: false)
      let show-dx = func-spec.at("show-dx", default: false)
      if not (show-xi or show-dx) { continue }
      let r-fn = func-spec.at("riemann")
      let (rd1, rd2) = func-spec.at("domain", default: (xmin, xmax))
      let r-n = func-spec.at("n", default: 4)
      let rw = (rd2 - rd1) / r-n
      // Flipped-up annotations sit above the axis and cannot collide.
      if riemann-flip-up(r-fn, rd1, rw, r-n, r-base) { continue }
      if show-xi {
        // Hide every numeric tick label that would overlap an x_i label —
        // both are centered on the axis, so collision is a distance in cm,
        // not an exact position match (a tick at 1 collides with x_i = 0.9).
        for t in x-ticks.ticks {
          for i in range(r-n + 1) {
            let xi = rd1 + i * rw
            if xi < xmin - 0.0001 or xi > xmax + 0.0001 { continue }
            if calc.abs((t - xi) * x-scale) < 0.45 {
              hidden-x.push(t)
              break
            }
          }
        }
        // x_0 (or any x_i) landing on the y-axis takes the origin's spot
        for i in range(r-n + 1) {
          let xi = rd1 + i * rw
          if xi >= xmin - 0.0001 and xi <= xmax + 0.0001 and calc.abs((xi - y-axis-x) * x-scale) < 0.45 {
            origin-hidden = true
          }
        }
      }
      // Without x_i labels the Δx bracket sits at axis level and covers the
      // tick labels under its rectangle. (With x_i labels it moves below the
      // label row, clear of the ticks.)
      if show-dx and not show-xi {
        let dxi = func-spec.at("dx-rect", default: auto)
        let dxi = if dxi == auto { calc.floor(r-n / 2) } else { dxi }
        for t in x-ticks.ticks {
          if t >= rd1 + dxi * rw - 0.0001 and t <= rd1 + (dxi + 1) * rw + 0.0001 {
            hidden-x.push(t)
          }
        }
      }
    }

    let is-hidden-x(x) = hidden-x.any(v => calc.abs(v - x) < 0.0001)
    let is-hidden-y(y) = hidden-y.any(v => calc.abs(v - y) < 0.0001)

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
        if x-has-label(x) and not is-hidden-x(x) and (xmax-on-tick or calc.abs(x - xmax) > 0.0001) {
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
        if y-has-label(y) and not is-hidden-y(y) and (ymax-on-tick or calc.abs(y - ymax) > 0.0001) {
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
      if show-origin and not origin-hidden and calc.abs(x-axis-y) < 0.0001 and calc.abs(y-axis-x) < 0.0001 {
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
      if draw-x-axis {
        let (x1, y-ax) = to-canvas(xmin, x-axis-y)
        let (x2, _) = to-canvas(xmax, x-axis-y)
        let x1-ext = x1 - x-extend.at(0)
        let x2-ext = x2 + x-extend.at(1)
        line((x1-ext, y-ax), (x2-ext, y-ax), stroke: s.axis.stroke, mark: (end: s.axis.arrow))
      }

      if draw-y-axis {
        let (x-ax, y1) = to-canvas(y-axis-x, ymin)
        let (_, y2) = to-canvas(y-axis-x, ymax)
        let y1-ext = y1 - y-extend.at(0)
        let y2-ext = y2 + y-extend.at(1)
        line((x-ax, y1-ext), (x-ax, y2-ext), stroke: s.axis.stroke, mark: (end: s.axis.arrow))
      }

      // Tick label rendering: optional background so curves crossing the
      // label band stay behind clean digits. The background is only painted
      // when a curve actually crosses the label box — otherwise it would
      // punch a white hole into area fills drawn underneath.
      // A label paints its background only when a curve crosses it AND it is
      // not sitting on an area fill (see area-boxes above).
      let label-crossed(b) = (
        fn-obstacle-segs.any(((p1, p2)) => seg-hits-box(p1, p2, b))
          and not label-over-area(b)
      )
      let tick-text(label, crossed: false) = {
        let t = apply-font(text(size: s.ticks.label-size, fill: s.ticks.label-fill)[#label])
        let bg = s.ticks.at("label-bg", default: white)
        if bg != none and crossed { box(fill: bg, inset: (x: 1pt, y: 0.5pt), t) } else { t }
      }
      let axis-label-text(label, at: none) = {
        let t = apply-font(text(size: s.labels.size, fill: s.labels.fill)[#label])
        let bg = s.labels.at("bg", default: white)
        // Coarse box around the label position, wide enough for any anchor.
        let over-area = if at == none { false } else {
          let (px, py) = at
          label-over-area((px - 0.5, py - 0.35, px + 0.5, py + 0.35))
        }
        if bg != none and not over-area { box(fill: bg, inset: 0.5pt, t) } else { t }
      }

      // Estimated boxes of the drawn x tick labels (and origin label), used to
      // drop y tick labels that would collide with them near the origin when
      // both axes are internal and scales are tight.
      let x-label-boxes = ()
      if xtick-labels == auto {
        for x in x-ticks.ticks {
          if calc.abs(x - xmax) < 0.0001 and not xmax-on-tick { continue }
          if not x-has-label(x) or is-hidden-x(x) { continue }
          let (bx1, by1, bx2, by2) = x-tick-label-box(x)
          x-label-boxes.push((bx1, bx2, by1, by2))
        }
      }
      if show-origin and not origin-hidden and calc.abs(x-axis-y) < 0.0001 and calc.abs(y-axis-x) < 0.0001 {
        let (bx1, by1, bx2, by2) = origin-label-box()
        x-label-boxes.push((bx1, bx2, by1, by2))
      }

      // Ticks and labels (tick-len already defined above)
      for (i, x) in if draw-x-axis { x-ticks.ticks.enumerate() } else { () } {
        // Skip tick at xmax (where arrow is), unless we keep the end tick
        if calc.abs(x - xmax) < 0.0001 and not xmax-on-tick { continue }
        let (cx, cy) = to-canvas(x, x-axis-y)
        line((cx, cy - tick-len), (cx, cy + tick-len), stroke: s.ticks.stroke)
        // Only show label if x is a multiple of (tick-step * label-step)
        // When xtick-labels is an explicit array, show by index without modulo filtering
        let label-interval = x-ticks.step * xtick-label-step
        let show-this-label = if type(xtick-labels) == array { true }
                              else { calc.abs(calc.rem(x, label-interval)) < 0.0001 or calc.abs(calc.rem(x, label-interval) - label-interval) < 0.0001 }
        // If unit-label-only, only show label for x = 1 (not -1 or other values)
        if unit-label-only and calc.abs(x - 1) > 0.0001 {
          show-this-label = false
        }
        // Avoid duplicate "0" when explicit origin label is enabled.
        if show-origin and calc.abs(x-axis-y) < 0.0001 and calc.abs(y-axis-x) < 0.0001 and calc.abs(x) < 0.0001 {
          show-this-label = false
        }
        // Hidden: label box is crossed by a plotted curve.
        if is-hidden-x(x) { show-this-label = false }
        if show-this-label and xtick-labels != none {
          let label = if xtick-labels == auto { format-number(x) }
                      else if i < xtick-labels.len() { xtick-labels.at(i) }
                      else { "" }
          let render-label = if type(label) == content { true }
                             else { label != "" and label != "0" }
          if render-label {
            content((cx, cy - tick-len - label-offset),
                    tick-text(label, crossed: label-crossed(x-tick-label-box(x))),
                    anchor: "north")
          }
        }
      }

      for (i, y) in if draw-y-axis { y-ticks.ticks.enumerate() } else { () } {
        // Skip tick at ymax (where arrow is), unless we keep the end tick
        if calc.abs(y - ymax) < 0.0001 and not ymax-on-tick { continue }
        let (cx, cy) = to-canvas(y-axis-x, y)
        line((cx - tick-len, cy), (cx + tick-len, cy), stroke: s.ticks.stroke)
        // Only show label if y is a multiple of (tick-step * label-step)
        // When ytick-labels is an explicit array, show by index without modulo filtering
        let label-interval = y-ticks.step * ytick-label-step
        let show-this-label = if type(ytick-labels) == array { true }
                              else { calc.abs(calc.rem(y, label-interval)) < 0.0001 or calc.abs(calc.rem(y, label-interval) - label-interval) < 0.0001 }
        // If unit-label-only, only show label for y = 1 (not -1 or other values)
        if unit-label-only and calc.abs(y - 1) > 0.0001 {
          show-this-label = false
        }
        // Avoid duplicate "0" when explicit origin label is enabled.
        if show-origin and calc.abs(x-axis-y) < 0.0001 and calc.abs(y-axis-x) < 0.0001 and calc.abs(y) < 0.0001 {
          show-this-label = false
        }
        // Hidden: label box is crossed by a plotted curve.
        if is-hidden-y(y) { show-this-label = false }
        if show-this-label and ytick-labels != none {
          let label = if ytick-labels == auto { format-number(y) }
                      else if i < ytick-labels.len() { ytick-labels.at(i) }
                      else { "" }
          let render-label = if type(label) == content { true }
                             else { label != "" and label != "0" }
          if render-label {
            // Skip a y label whose estimated box would collide with an x tick
            // label (happens near the origin with tight scales and centered axes).
            let w = est-width(y)
            let (x1, x2b) = (cx - tick-len - label-offset - w, cx - tick-len - label-offset)
            let (yb1, yb2) = (cy - est-char-h / 2, cy + est-char-h / 2)
            let collides = ytick-labels == auto and x-label-boxes.any(b => {
              let (bx1, bx2, by1, by2) = b
              x1 < bx2 and x2b > bx1 and yb1 < by2 and yb2 > by1
            })
            if not collides {
              content((cx - tick-len - label-offset, cy),
                      tick-text(label, crossed: label-crossed(y-tick-label-box(y))),
                      anchor: "east")
            }
          }
        }
      }

      // Origin label
      if show-origin and not origin-hidden and calc.abs(x-axis-y) < 0.0001 and calc.abs(y-axis-x) < 0.0001 {
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
        content(label-pos, tick-text([0], crossed: label-crossed(origin-label-box())),
                anchor: s.origin.label-anchor)
      }

      // Axis labels.
      // Default convention (xlabel-pos / ylabel-pos == "end"):
      //   x  → just above the axis, a little left of the right arrow (anchor SE)
      //   y  → just left of the axis, a little below the top arrow (anchor NE)
      // This keeps the labels clear of the tick numbers (which sit below / left
      // of the axis), including the end tick at xmax / ymax.
      if xlabel != none {
        let (lx, ly, default-anchor) = if xlabel-pos == "end" {
          let (base-x, base-y) = to-canvas(xmax, x-axis-y)
          (base-x + x-extend.at(1), base-y, "south-east")
        } else if xlabel-pos == "center" {
          let (cx, cy) = to-canvas((xmin + xmax) / 2, x-axis-y); (cx, cy, "north")
        } else if type(xlabel-pos) == array {
          let (cx, cy) = to-canvas(xlabel-pos.at(0), xlabel-pos.at(1)); (cx, cy, "north")
        } else {
          let (cx, cy) = to-canvas(xmax, x-axis-y); (cx, cy, "north")
        }
        let x-lbl-anchor = if xlabel-anchor == auto { default-anchor } else { xlabel-anchor }
        let (ox, oy) = xlabel-offset
        content((lx + ox, ly + oy), axis-label-text(xlabel, at: (lx + ox, ly + oy)), anchor: x-lbl-anchor)
      }

      if ylabel != none {
        let (lx, ly, default-anchor) = if ylabel-pos == "end" {
          let (base-x, base-y) = to-canvas(y-axis-x, ymax)
          (base-x, base-y + y-extend.at(1), "north-west")
        } else if ylabel-pos == "center" {
          let (cx, cy) = to-canvas(y-axis-x, (ymin + ymax) / 2); (cx, cy, "east")
        } else if type(ylabel-pos) == array {
          let (cx, cy) = to-canvas(ylabel-pos.at(0), ylabel-pos.at(1)); (cx, cy, "east")
        } else {
          let (cx, cy) = to-canvas(y-axis-x, ymax); (cx, cy, "east")
        }
        let y-lbl-anchor = if ylabel-anchor == auto { default-anchor } else { ylabel-anchor }
        let (ox, oy) = ylabel-offset
        content((lx + ox, ly + oy), axis-label-text(ylabel, at: (lx + ox, ly + oy)), anchor: y-lbl-anchor)
      }
    }

    // Plot functions and data (with manual line clipping)
    // Pending labels for the automatic label placement pass that runs after
    // the axes are drawn (obstacles were pre-sampled above).
    let label-requests = ()

    // Two passes over the series: area-type specs first (fills, hatches,
    // Riemann sums — they must stay behind the axes), then the axes with
    // ticks and labels, then line-type specs (curves, markers, guides) so
    // functions pass in FRONT of the tick labels. Crossed tick labels are
    // hidden above, so a curve only runs over the rare kept-for-scale label.
    let is-area-spec(f) = (type(f) == dictionary and (
      "fill" in f or "fill-between" in f or "fill-fn1" in f or
      "riemann" in f or "fill-closed" in f
    ))

    for pass in ("area", "axes", "line") {
    if pass == "axes" {
      draw-axes-ticks-labels()
      continue
    }
    for func-spec in all-funcs {
      let func-spec = if type(func-spec) == function { (fn: func-spec) } else { func-spec }
      if (pass == "area") != is-area-spec(func-spec) { continue }
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
          let label-domain-min = if domain == none { xmin } else { calc.max(float(domain-min), xmin) }
          let label-domain-max = if domain == none { xmax } else { calc.min(float(domain-max), xmax) }
          let explicit-anchor = if label-side != none { side-to-anchor(label-side) }
                                else { func-spec.at("label-anchor", default: auto) }
          // Placement deferred: labels are auto-placed after all series and the
          // axes are known, so they can avoid curves, axes and tick labels.
          label-requests.push((
            fn: fn,
            label: label,
            t: label-pos,
            dmin: label-domain-min,
            dmax: label-domain-max,
            anchor: explicit-anchor,
          ))
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
          content((cx, cy), apply-font(label), anchor: label-anchor)
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

        // Clip to the plot rectangle: restrict the domain, clamp the y values.
        let (d1, d2) = domain
        let d1 = calc.max(float(d1), xmin)
        let d2 = calc.min(float(d2), xmax)
        let top-pts = ()
        let bot-pts = ()

        if d2 - d1 > 1e-9 {
          let step = (d2 - d1) / samples
          for i in range(samples + 1) {
            let x = d1 + i * step
            let y = fill-fn(x)
            if y != none and not float(y).is-nan() {
              let (cx, cy-top) = to-canvas(x, clamp-y(y))
              let (_, cy-bot) = to-canvas(x, clamp-y(baseline))
              top-pts.push((cx, cy-top))
              bot-pts.push((cx, cy-bot))
            }
          }
        }

        let all-pts = top-pts + bot-pts.rev()
        if all-pts.len() > 2 {
          line(..all-pts, close: true, fill: series-paint(func-spec, fill-color), stroke: none)
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

        // Clip to the plot rectangle: restrict the domain, clamp the y values.
        let (d1, d2) = domain
        let d1 = calc.max(float(d1), xmin)
        let d2 = calc.min(float(d2), xmax)
        let fwd-pts = ()
        let bwd-pts = ()

        if d2 - d1 > 1e-9 {
          let step = (d2 - d1) / samples
          for i in range(samples + 1) {
            let x = d1 + i * step
            let y1 = fn1(x)
            let y2 = fn2(x)
            if (y1 != none and not float(y1).is-nan()
                and y2 != none and not float(y2).is-nan()) {
              let (cx, cy-top) = to-canvas(x, clamp-y(calc.max(float(y1), float(y2))))
              let (_, cy-bot)  = to-canvas(x, clamp-y(calc.min(float(y1), float(y2))))
              fwd-pts.push((cx, cy-top))
              bwd-pts.push((cx, cy-bot))
            }
          }
        }

        let all-pts = fwd-pts + bwd-pts.rev()
        if all-pts.len() > 2 {
          line(..all-pts, close: true, fill: series-paint(func-spec, fill-color), stroke: none)
        }

      // ── Text annotation at data coordinates ─────────────────────────────
      // Keys: annotation:content, pos:(x,y), anchor:string, size:length
      } else if "annotation" in func-spec {
        let ann-text   = func-spec.at("annotation")
        let ann-pos    = func-spec.at("pos")
        let ann-anchor = func-spec.at("anchor", default: "center")
        let ann-size   = func-spec.at("size", default: 9pt)  // matches note()
        let (ax, ay)   = ann-pos
        let (cx, cy)   = to-canvas(ax, ay)
        content((cx, cy), apply-font(text(ann-text, size: ann-size)), anchor: ann-anchor)

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

        let r-samples      = func-spec.at("samples", default: 20)
        let r-show-points  = func-spec.at("show-points", default: false)
        let r-point-color  = func-spec.at("point-color", default: rgb("#c94a00"))
        let r-point-size   = func-spec.at("point-size", default: 0.07)
        let r-point-label  = func-spec.at("point-label", default: none)  // auto = method text
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

        for r in riemann-heights(r-fn, d1, d2, r-n, r-method, r-samples) {
          // Dots only inside the plot rectangle (rectangles are clipped too)
          if (r.xeval != none and r.y != none
              and r.xeval >= xmin - 1e-9 and r.xeval <= xmax + 1e-9
              and r.y >= ymin - 1e-9 and r.y <= ymax + 1e-9) {
            eval-pts.push(to-canvas(r.xeval, r.y))
          }
          if r.y != none {
            // Clip the rectangle to the plot window; stroke only the edges
            // that survived so a cut-off bar reads as "continues beyond the
            // window" instead of showing a false boundary.
            let c = riemann-clip-rect(
              r.xl, r.xr,
              calc.min(r-base, r.y), calc.max(r-base, r.y),
              xmin, xmax, ymin, ymax)
            if c != none {
              let (cx1, cy1) = to-canvas(c.xl, c.y-lo)
              let (cx2, cy2) = to-canvas(c.xr, c.y-hi)
              rect((cx1, cy1), (cx2, cy2),
                fill: series-paint(func-spec, fill-color), stroke: none)
              if c.left { line((cx1, cy1), (cx1, cy2), stroke: rect-stroke) }
              if c.right { line((cx2, cy1), (cx2, cy2), stroke: rect-stroke) }
              if c.bottom { line((cx1, cy1), (cx2, cy1), stroke: rect-stroke) }
              if c.top { line((cx1, cy2), (cx2, cy2), stroke: rect-stroke) }
            }
          }
        }

        // Annotations flip above the baseline when most rectangles extend
        // below it (negative function), so they stay out of the fill.
        let flip-up = riemann-flip-up(r-fn, d1, w, r-n, r-base)
        let a-dir = if flip-up { 1.0 } else { -1.0 }

        // ── Δx bracket ──────────────────────────────────────────────────────
        let dx-di = if r-dx-rect == auto { calc.floor(r-n / 2) } else { r-dx-rect }
        if r-show-dx {
          let xl = d1 + dx-di * w
          let xr = d1 + (dx-di + 1) * w
          let (cxl, cy-base) = to-canvas(clamp-x(xl), clamp-y(r-base))
          let (cxr, _)       = to-canvas(clamp-x(xr), clamp-y(r-base))
          // With x_i labels shown, the bracket drops below the label row
          // (delimiters crossing the arrow line, dimension-line style) so no
          // label has to be skipped; alone, it hugs the axis.
          let (tick-from, tick-to, arrow-off) = if r-show-xi {
            (0.68, 0.84, 0.76)
          } else {
            (0.02, 0.10, 0.18)
          }
          let arrow-y = cy-base + a-dir * arrow-off
          line((cxl, cy-base + a-dir * tick-from), (cxl, cy-base + a-dir * tick-to), stroke: black + 0.5pt)
          line((cxr, cy-base + a-dir * tick-from), (cxr, cy-base + a-dir * tick-to), stroke: black + 0.5pt)
          line((cxl, arrow-y), (cxr, arrow-y),
               mark: (start: (symbol: "stealth", fill: black, scale: 0.35),
                      end:   (symbol: "stealth", fill: black, scale: 0.35)),
               stroke: black + 0.5pt)
          content(((cxl + cxr) / 2, arrow-y + a-dir * 0.06), r-dx-label,
                  anchor: if flip-up { "south" } else { "north" })
        }

        // ── x_i labels ──────────────────────────────────────────────────────
        if r-show-xi {
          for i in range(r-n + 1) {
            let x = d1 + i * w
            // Clip labels to the x-range
            if x < xmin - 1e-9 or x > xmax + 1e-9 { continue }
            let (cx, cy) = to-canvas(x, clamp-y(r-base))
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
            // Shift right when the xi label lands on the y-axis AND the axis
            // line actually extends into the label row (e.g. ymin < 0 with
            // baseline 0); otherwise the label can sit centered on the axis.
            let axis-in-row = if flip-up { ymax > r-base + 1e-9 } else { ymin < r-base - 1e-9 }
            let x-shift = if axis-in-row and calc.abs(x - y-axis-x) < 0.001 { 0.35 } else { 0.0 }
            content((cx + x-shift, cy + a-dir * 0.20), apply-font(lbl),
                    anchor: if flip-up { "south" } else { "north" })
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
            // Arrows first so dots render on top — only to the few nearest
            // dots; one arrow per dot criss-crosses the whole plot.
            let by-dist = eval-pts.sorted(key: p => {
              let (px, py) = p
              (px - lx) * (px - lx) + (py - ly) * (py - ly)
            })
            for (px, py) in by-dist.slice(0, calc.min(3, by-dist.len())) {
              line((lx, ly), (px, py),
                   mark: (end: (symbol: "stealth", fill: black, scale: 0.35)),
                   stroke: black + 0.5pt)
            }
            content((lx, ly), apply-font(lbl-text), anchor: "center")
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
        let (t1, t2) = par-domain
        let step = (t2 - t1) / par-samples
        let par-pts = ()
        for i in range(par-samples + 1) {
          let t = t1 + i * step
          let px = par-x(t)
          let py = par-y(t)
          if px != none and py != none and not float(px).is-nan() and not float(py).is-nan() {
            // Clamp into the plot rectangle (cheap clip; fine at 80+ samples)
            par-pts.push(to-canvas(clamp-x(px), clamp-y(py)))
          }
        }
        if par-pts.len() > 2 {
          line(..par-pts, close: true, fill: series-paint(func-spec, fill-color), stroke: none)
        }
      }

      if mark-type != "none" and points-to-draw.len() > 0 {
        for (cx, cy, i) in points-to-draw {
          if calc.rem(i, mark-interval) == 0 {
            draw-marker((cx, cy), mark-type, mark-size, mark-fill, mark-stroke)
          }
        }
      }
    }
    }  // end area/axes/line passes

    // ── Automatic function-label placement ─────────────────────────────────
    // Each label tries positions along its curve (starting at label-pos) and
    // anchors around the point, and takes the first spot that touches neither
    // a curve, an axis, a tick label, a previously placed label, nor the
    // canvas edge.  Explicit label-anchor / label-side skip the search.
    if label-requests.len() > 0 {
      // Axis lines as obstacle segments (with their extensions).
      let (ax1, ay) = to-canvas(xmin, x-axis-y)
      let (ax2, _) = to-canvas(xmax, x-axis-y)
      let (vx, vy1) = to-canvas(y-axis-x, ymin)
      let (_, vy2) = to-canvas(y-axis-x, ymax)
      let axis-segs = ()
      if draw-x-axis {
        axis-segs.push(((ax1 - x-extend.at(0), ay), (ax2 + x-extend.at(1), ay)))
      }
      if draw-y-axis {
        axis-segs.push(((vx, vy1 - y-extend.at(0)), (vx, vy2 + y-extend.at(1))))
      }

      // Tick-label boxes actually drawn (hidden ones excluded).
      let tick-boxes = ()
      for x in x-ticks.ticks {
        if x-has-label(x) and not is-hidden-x(x) and (xmax-on-tick or calc.abs(x - xmax) > 0.0001) {
          tick-boxes.push(x-tick-label-box(x))
        }
      }
      for y in y-ticks.ticks {
        if y-has-label(y) and not is-hidden-y(y) and (ymax-on-tick or calc.abs(y - ymax) > 0.0001) {
          tick-boxes.push(y-tick-label-box(y))
        }
      }
      if show-origin and not origin-hidden and calc.abs(x-axis-y) < 0.0001 and calc.abs(y-axis-x) < 0.0001 {
        tick-boxes.push(origin-label-box())
      }
      // Axis-name labels (x / y at the arrow ends, default "end" positions).
      if xlabel != none and xlabel-pos == "end" {
        let (bx, by) = to-canvas(xmax, x-axis-y)
        let (ox, oy) = xlabel-offset
        let ax = bx + x-extend.at(1) + ox
        let ay = by + oy
        let ms = measure(apply-font(text(size: s.labels.size)[#xlabel]))
        // anchored "south-east": box extends left and up from the point
        tick-boxes.push((ax - ms.width / 1cm - 0.05, ay - 0.02, ax + 0.05, ay + ms.height / 1cm + 0.02))
      }
      if ylabel != none and ylabel-pos == "end" {
        let (bx, by) = to-canvas(y-axis-x, ymax)
        let (ox, oy) = ylabel-offset
        let ax = bx + ox
        let ay = by + y-extend.at(1) + oy
        let ms = measure(apply-font(text(size: s.labels.size)[#ylabel]))
        // anchored "north-west": box extends right and down from the point
        tick-boxes.push((ax - 0.05, ay - ms.height / 1cm - 0.02, ax + ms.width / 1cm + 0.05, ay + 0.02))
      }

      // Vertical visible bounds for label boxes (plot area + extensions).
      // Horizontal bounds are computed per label: an end label may stick out
      // of the grid by its own width (the canvas grows around it), pgfplots-style.
      let vis-y1 = -0.25
      let vis-y2 = height + y-extend.at(1) + 0.35

      // Box of a label of size (w, h) anchored at point (px, py).
      let anchor-box(anchor, px, py, w, h) = {
        if anchor == "south-west" { (px, py, px + w, py + h) }
        else if anchor == "south-east" { (px - w, py, px, py + h) }
        else if anchor == "north-west" { (px, py - h, px + w, py) }
        else if anchor == "north-east" { (px - w, py - h, px, py) }
        else if anchor == "south" { (px - w / 2, py, px + w / 2, py + h) }
        else if anchor == "north" { (px - w / 2, py - h, px + w / 2, py) }
        else if anchor == "east" { (px - w, py - h / 2, px, py + h / 2) }
        else if anchor == "west" { (px, py - h / 2, px + w, py + h / 2) }
        else { (px - w / 2, py - h / 2, px + w / 2, py + h / 2) }
      }

      let placed-boxes = ()
      for req in label-requests {
        let m = measure(apply-font(req.label))
        let pad = 0.08  // content padding (2pt) + breathing room
        let w = m.width / 1cm + 2 * pad
        let h = m.height / 1cm + 2 * pad
        let vis-x1 = -(w + 0.15)
        let vis-x2 = width + x-extend.at(1) + w + 0.15

        let score-box(b) = {
          // Shrink slightly so a corner grazing its own curve doesn't count.
          let tb = (b.at(0) + 0.02, b.at(1) + 0.02, b.at(2) - 0.02, b.at(3) - 0.02)
          let score = 0
          if tb.at(0) < vis-x1 or tb.at(1) < vis-y1 or tb.at(2) > vis-x2 or tb.at(3) > vis-y2 { score += 6 }
          for (p1, p2) in axis-segs {
            // Inflate the axis by the tick length so labels also clear the tick marks.
            let ab = (calc.min(p1.at(0), p2.at(0)) - tick-len, calc.min(p1.at(1), p2.at(1)) - tick-len,
                      calc.max(p1.at(0), p2.at(0)) + tick-len, calc.max(p1.at(1), p2.at(1)) + tick-len)
            if boxes-overlap(tb, ab) { score += 4 }
          }
          let curve-hits = 0
          for (p1, p2) in obstacle-segs {
            if seg-hits-box(p1, p2, tb) {
              curve-hits += 1
              if curve-hits >= 3 { break }
            }
          }
          score += 3 * curve-hits
          for b2 in tick-boxes {
            if boxes-overlap(tb, b2) { score += 2; break }
          }
          for b2 in placed-boxes {
            if boxes-overlap(tb, b2) { score += 3; break }
          }
          score
        }

        let best = none  // (score, point, anchor, box)
        if req.anchor != auto {
          // Explicit placement: honour it as-is.
          let lx = req.dmin + (req.dmax - req.dmin) * req.t
          let ly = (req.fn)(lx)
          if ly != none and not float(ly).is-nan() and ly >= y-clip-min and ly <= y-clip-max {
            let (px, py) = to-canvas(lx, ly)
            best = (0, (px, py), req.anchor, anchor-box(req.anchor, px, py, w, h))
          }
        } else {
          let span = req.dmax - req.dmin
          let deltas = (0, -0.06, 0.06, -0.12, 0.12, -0.2, 0.2, -0.3, 0.3, -0.42, 0.42, -0.56, 0.56, -0.72, 0.72)
          let tried = ()
          for d in deltas {
            if best != none and best.at(0) == 0 { break }
            let t = calc.max(0.02, calc.min(1.0, req.t + d))
            if tried.any(v => calc.abs(v - t) < 0.005) { continue }
            tried.push(t)
            let lx = req.dmin + span * t
            let ly = (req.fn)(lx)
            if ly == none or float(ly).is-nan() or ly < y-clip-min or ly > y-clip-max { continue }
            let (px, py) = to-canvas(lx, ly)
            // Anchor preference from the local slope: lean away from the curve.
            let hh = span * 0.01
            let ya = (req.fn)(lx - hh)
            let yb = (req.fn)(lx + hh)
            let slope = if (ya != none and yb != none and not float(ya).is-nan()
              and not float(yb).is-nan() and hh > 0) {
              (float(yb) - float(ya)) / (2 * hh) * (y-scale / x-scale)
            } else { 0 }
            let anchors = if slope > 0.15 {
              ("south-east", "north-west", "south-west", "north-east", "south", "north")
            } else if slope < -0.15 {
              ("south-west", "north-east", "south-east", "north-west", "south", "north")
            } else {
              ("south-west", "south-east", "south", "north-west", "north-east", "north")
            }
            for anchor in anchors {
              let b = anchor-box(anchor, px, py, w, h)
              let sc = score-box(b)
              if best == none or sc < best.at(0) {
                best = (sc, (px, py), anchor, b)
              }
              if sc == 0 { break }
            }
          }

          // Fallback: end labels just outside the grid, vertically centred on
          // the curve (textbook style for asymptotes crowded by tick labels).
          if best == none or best.at(0) > 0 {
            for (t, anchor) in ((1.0, "west"), (0.0, "east")) {
              let lx = req.dmin + span * t
              let ly = (req.fn)(lx)
              if ly == none or float(ly).is-nan() or ly < y-clip-min or ly > y-clip-max { continue }
              let (px, py) = to-canvas(lx, ly)
              let b = anchor-box(anchor, px, py, w, h)
              let sc = score-box(b)
              if best == none or sc < best.at(0) {
                best = (sc, (px, py), anchor, b)
              }
              if sc == 0 { break }
            }
          }
        }

        if best != none {
          let (_, pt, anchor, b) = best
          content(pt, apply-font(req.label), anchor: anchor)
          placed-boxes.push(b)
        }
      }
    }

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

      let lens-shape  = zs.at("lens-shape", default: "rect")
      let is-circle   = lens-shape == "circle"

      // Canvas coords of the zoom region bounding box.
      // For a circle lens, the spy glass is a true canvas circle covering the
      // region's bounding box, and the inset magnifies uniformly in canvas
      // space (shapes are preserved; a circle stays a circle).
      let (crx1, cry1) = to-canvas(zx1, zy1)
      let (crx2, cry2) = to-canvas(zx2, zy2)
      let lens-cx = (crx1 + crx2) / 2
      let lens-cy = (cry1 + cry2) / 2
      let lens-rx = (crx2 - crx1) / 2
      let lens-ry = (cry2 - cry1) / 2
      let lens-r  = calc.max(lens-rx, lens-ry)

      // Resolve inset size: explicit, magnification-based, or default
      let z-mag  = zs.at("magnification", default: none)
      let zoom-w = if "zoom-width" in zs   { zs.at("zoom-width") }
                   else if z-mag != none   {
                     if is-circle { 2 * lens-r * z-mag }
                     else         { (zx2 - zx1) * x-scale * z-mag }
                   }
                   else                    { 3.5 }
      let zoom-h = if is-circle            { zoom-w }
                   else if "zoom-height" in zs { zs.at("zoom-height") }
                   else if z-mag != none   { (zy2 - zy1) * y-scale * z-mag }
                   else                    { 3.5 }

      // Cap the inset size so it can never dwarf the plot itself
      let size-f = calc.min(1.0, 0.8 * width / zoom-w, 0.8 * height / zoom-h)
      zoom-w = zoom-w * size-f
      zoom-h = zoom-h * size-f

      // Circle lens: widen the effective data region to the circle's bounding
      // box so sampling, grid and mapping cover the whole lens uniformly.
      if is-circle {
        zx1 = xmin + (lens-cx - lens-r) / x-scale
        zx2 = xmin + (lens-cx + lens-r) / x-scale
        zy1 = ymin + (lens-cy - lens-r) / y-scale
        zy2 = ymin + (lens-cy + lens-r) / y-scale
      }

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

      // Canvas center of the inset box
      let (cix, ciy) = {
        let at-val = zs.at("at", default: auto)
        let margin-x = zoom-w / 2 + 0.2
        let margin-y = zoom-h / 2 + 0.2
        if at-val == auto {
          // Smart default: opposite quadrant from zoom center, kept on canvas
          let nc-x = ((zx1 + zx2) / 2 - xmin) / (xmax - xmin)
          let nc-y = ((zy1 + zy2) / 2 - ymin) / (ymax - ymin)
          let tx = if nc-x > 0.5 { 0.25 } else { 0.75 }
          let ty = if nc-y > 0.5 { 0.25 } else { 0.75 }
          (calc.max(margin-x, calc.min(width - margin-x, width * tx)),
           calc.max(margin-y, calc.min(height - margin-y, height * ty)))
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

      // Connector lines between the spy glass and the inset.
      // Circle: the two external tangent lines of the two circles — they touch
      // both borders exactly and never cross either shape.
      // Rect: two non-crossing corner pairs facing each other.
      if do-connect {
        if is-circle {
          let ins-r = zoom-w / 2
          let ddx = cix - lens-cx
          let ddy = ciy - lens-cy
          let d = calc.sqrt(ddx * ddx + ddy * ddy)
          // Skip when one circle contains the other (no external tangents)
          if d > calc.abs(ins-r - lens-r) + 0.01 {
            let phi  = calc.atan2(ddx, ddy)
            let beta = calc.acos((lens-r - ins-r) / d)
            let tangent-pts = (-1.0, 1.0).map(sgn => {
              let a = phi + sgn * beta
              ((lens-cx + lens-r * calc.cos(a), lens-cy + lens-r * calc.sin(a)),
               (cix     + ins-r  * calc.cos(a), ciy     + ins-r  * calc.sin(a)))
            })
            let ((f1, t1), (f2, t2)) = tangent-pts
            if conn-fill != none {
              line(f1, t1, t2, f2, close: true, fill: conn-fill, stroke: none)
            }
            line(f1, t1, stroke: conn-stk)
            line(f2, t2, stroke: conn-stk)
          }
        } else {
          let ddx = cix - lens-cx
          let ddy = ciy - lens-cy
          let (cf1, cf2, ct1, ct2) = if calc.abs(ddx) >= calc.abs(ddy) {
            if ddx > 0 { ((crx2, cry1), (crx2, cry2), (bx1, by1), (bx1, by2)) }
            else       { ((crx1, cry1), (crx1, cry2), (bx2, by1), (bx2, by2)) }
          } else {
            if ddy > 0 { ((crx1, cry2), (crx2, cry2), (bx1, by1), (bx2, by1)) }
            else       { ((crx1, cry1), (crx2, cry1), (bx1, by2), (bx2, by2)) }
          }
          if conn-fill != none {
            line(cf1, ct1, ct2, cf2, close: true, fill: conn-fill, stroke: none)
          }
          line(cf1, ct1, stroke: conn-stk)
          line(cf2, ct2, stroke: conn-stk)
        }
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

      // Clip a segment against the inset shape (rect box or circle lens)
      let clip-seg-z(p1, p2) = if lens-shape == "circle" {
        clip-segment-ellipse(p1, p2, ic-cx, ic-cy, ic-rx, ic-ry)
      } else {
        clip-segment(p1, p2, bx1, by1, bx2, by2)
      }
      // Vertical extent of the inset at canvas x — column-wise clipping for
      // area fills (exact for x-monotone bands, including the circle lens).
      let z-band(px) = if lens-shape == "circle" {
        let t = (px - ic-cx) / ic-rx
        if calc.abs(t) >= 0.9995 { none }
        else {
          let h = ic-ry * calc.sqrt(1 - t * t)
          (ic-cy - h, ic-cy + h)
        }
      } else {
        if px < bx1 - 0.0001 or px > bx2 + 0.0001 { none } else { (by1, by2) }
      }
      // Fill the band between two sampled edges given as columns
      // (px, py-top, py-bot); none entries mark breaks and are skipped.
      let fill-band(cols, paint) = {
        let top-pts = ()
        let bot-pts = ()
        for c in cols {
          if c == none { continue }
          let (px, pt, pb) = c
          let b = z-band(px)
          if b == none { continue }
          let (blo, bhi) = b
          top-pts.push((px, calc.max(blo, calc.min(bhi, pt))))
          bot-pts.push((px, calc.max(blo, calc.min(bhi, pb))))
        }
        if top-pts.len() > 1 {
          line(..(top-pts + bot-pts.rev()), close: true, fill: paint, stroke: none)
        }
      }

      // Two passes like the main renderer: area fills first, curves on top.
      for z-pass in ("area", "line") {
      for fs in all-funcs {
        let fs = if type(fs) == function { (fn: fs) } else { fs }
        if (z-pass == "area") != is-area-spec(fs) { continue }
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
                let cl = clip-seg-z(p1, p2)
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
              draw-marker(pt-z, mk-z,
                fs.at("mark-size",   default: s.marker.size),
                fs.at("mark-fill",   default: s.marker.fill),
                fs.at("mark-stroke", default: s.marker.stroke))
            }
          }

        // ── Fill below a curve (fill-area) ───────────────────────────────
        } else if "fill" in fs {
          let fill-fn  = fs.at("fill")
          let baseline = float(fs.at("baseline", default: 0.0))
          let (fd1, fd2) = fs.at("domain", default: (xmin, xmax))
          let fd1 = calc.max(float(fd1), zx1)
          let fd2 = calc.min(float(fd2), zx2)
          let n-samp = fs.at("samples", default: 80)
          if fd2 - fd1 > 1e-9 {
            let stp = (fd2 - fd1) / n-samp
            let cols = range(n-samp + 1).map(i => {
              let x = fd1 + i * stp
              let y = fill-fn(x)
              if y == none or float(y).is-nan() { none }
              else {
                let (px, pt) = to-zoom(x, float(y))
                let (_, pb) = to-zoom(x, baseline)
                (px, pt, pb)
              }
            })
            fill-band(cols, series-paint(fs, fs.at("color", default: luma(220))))
          }

        // ── Fill between two curves (area-between) ───────────────────────
        } else if "fill-between" in fs or "fill-fn1" in fs {
          let (fn1, fn2) = if "fill-between" in fs { fs.at("fill-between") }
            else { (fs.at("fill-fn1"), fs.at("fill-fn2", default: x => 0.0)) }
          let (fd1, fd2) = fs.at("domain", default: (xmin, xmax))
          let fd1 = calc.max(float(fd1), zx1)
          let fd2 = calc.min(float(fd2), zx2)
          let n-samp = fs.at("samples", default: 80)
          if fd2 - fd1 > 1e-9 {
            let stp = (fd2 - fd1) / n-samp
            let cols = range(n-samp + 1).map(i => {
              let x = fd1 + i * stp
              let y1 = fn1(x)
              let y2 = fn2(x)
              if (y1 == none or float(y1).is-nan()
                  or y2 == none or float(y2).is-nan()) { none }
              else {
                let (px, pt) = to-zoom(x, calc.max(float(y1), float(y2)))
                let (_, pb) = to-zoom(x, calc.min(float(y1), float(y2)))
                (px, pt, pb)
              }
            })
            fill-band(cols, series-paint(fs,
              fs.at("color", default: fs.at("fill", default: luma(220)))))
          }

        // ── Riemann rectangles ───────────────────────────────────────────
        } else if "riemann" in fs {
          let r-fn = fs.at("riemann")
          let (rd1, rd2) = fs.at("domain", default: (xmin, xmax))
          let r-method = fs.at("method", default: "right")
          let r-base = float(fs.at("baseline", default: 0.0))
          let rect-stk = fs.at("stroke", default: luma(80) + 0.6pt)
          let paint = series-paint(fs, fs.at("color", default: luma(220)))
          for r in riemann-heights(r-fn, rd1, rd2, fs.at("n", default: 4),
                                   r-method, fs.at("samples", default: 20)) {
            if r.y == none { continue }
            let xl-c = calc.max(float(r.xl), zx1)
            let xr-c = calc.min(float(r.xr), zx2)
            if xr-c - xl-c <= 1e-9 { continue }
            let (pxl, pyb) = to-zoom(xl-c, r-base)
            let (pxr, pyt) = to-zoom(xr-c, r.y)
            // Fill: column-clipped band across the rectangle
            let m = 16
            fill-band(range(m + 1).map(j =>
              (pxl + j * (pxr - pxl) / m, pyt, pyb)), paint)
            // Border: the four edges, segment-clipped to the inset shape
            for (p1, p2) in (
              ((pxl, pyb), (pxl, pyt)), ((pxl, pyt), (pxr, pyt)),
              ((pxr, pyt), (pxr, pyb)), ((pxr, pyb), (pxl, pyb)),
            ) {
              let cl = clip-seg-z(p1, p2)
              if cl != none { line(cl.at(0), cl.at(1), stroke: rect-stk) }
            }
          }

        // ── Closed parametric fill (fill-closed) ─────────────────────────
        } else if "fill-closed" in fs {
          let (par-x, par-y) = fs.at("fill-closed")
          let (t1, t2) = fs.at("domain", default: (0.0, 1.0))
          let n-samp = fs.at("samples", default: 80)
          let stp = (t2 - t1) / n-samp
          let pts = ()
          for i in range(n-samp + 1) {
            let t = t1 + i * stp
            let px-d = par-x(t)
            let py-d = par-y(t)
            if (px-d == none or py-d == none
                or float(px-d).is-nan() or float(py-d).is-nan()) { continue }
            let (px, py) = to-zoom(float(px-d), float(py-d))
            // Cheap clip: clamp into the inset (radially for the circle
            // lens), mirroring the clamp-x/clamp-y clip of the main renderer.
            pts.push(if lens-shape == "circle" {
              let dx = (px - ic-cx) / ic-rx
              let dy = (py - ic-cy) / ic-ry
              let d = calc.sqrt(dx * dx + dy * dy)
              if d <= 1.0 { (px, py) }
              else { (ic-cx + dx / d * ic-rx, ic-cy + dy / d * ic-ry) }
            } else {
              (calc.max(bx1, calc.min(bx2, px)), calc.max(by1, calc.min(by2, py)))
            })
          }
          if pts.len() > 2 {
            line(..pts, close: true,
              fill: series-paint(fs, fs.at("color", default: luma(220))), stroke: none)
          }

        // ── Reference lines ──────────────────────────────────────────────
        } else if "vline" in fs {
          let x0 = fs.at("vline")
          let cl = clip-seg-z(
            to-zoom(x0, fs.at("ymin", default: ymin)),
            to-zoom(x0, fs.at("ymax", default: ymax)))
          if cl != none { line(cl.at(0), cl.at(1), stroke: fs-stk) }

        } else if "hline" in fs {
          let y0 = fs.at("hline")
          let cl = clip-seg-z(
            to-zoom(fs.at("xmin", default: xmin), y0),
            to-zoom(fs.at("xmax", default: xmax), y0))
          if cl != none { line(cl.at(0), cl.at(1), stroke: fs-stk) }

        // ── Parametric curve ─────────────────────────────────────────────
        } else if "parametric" in fs {
          let (par-x, par-y) = fs.at("parametric")
          let (t1, t2) = fs.at("domain", default: (0.0, 1.0))
          let n-samp = fs.at("samples", default: 100)
          let stp = (t2 - t1) / n-samp
          let prev = none
          for i in range(n-samp + 1) {
            let t = t1 + i * stp
            let px-d = par-x(t)
            let py-d = par-y(t)
            let p = if (px-d == none or py-d == none
                or float(px-d).is-nan() or float(py-d).is-nan()) { none }
              else { to-zoom(float(px-d), float(py-d)) }
            if prev != none and p != none {
              let cl = clip-seg-z(prev, p)
              if cl != none { line(cl.at(0), cl.at(1), stroke: fs-stk) }
            }
            prev = p
          }
        }
      }
      }  // end area/line inset passes

      // Draw axis lines inside the inset if they pass through the zoom region
      let draw-inset-line(p1, p2) = {
        let cl = clip-seg-z(p1, p2)
        if cl != none { let (cp1, cp2) = cl; line(cp1, cp2, stroke: s.axis.stroke) }
      }
      // X-axis
      if draw-x-axis and x-axis-y >= zy1 - 0.0001 and x-axis-y <= zy2 + 0.0001 {
        let (_, y-ax-z) = to-zoom(zx1, x-axis-y)
        draw-inset-line((bx1, y-ax-z), (bx2, y-ax-z))
      }
      // Y-axis
      if draw-y-axis and y-axis-x >= zx1 - 0.0001 and y-axis-x <= zx2 + 0.0001 {
        let (x-ax-z, _) = to-zoom(y-axis-x, zy1)
        draw-inset-line((x-ax-z, by1), (x-ax-z, by2))
      }

      // Spy glass shape on the main plot (drawn on top of all content)
      if lens-shape == "circle" {
        let n-c = 64
        let circ-pts = range(n-c + 1).map(i => {
          let t = i * 360deg / n-c
          (lens-cx + lens-r * calc.cos(t), lens-cy + lens-r * calc.sin(t))
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
        if is-circle {
          // Top of the circle, inside the border
          content(((bx1 + bx2) / 2, by2 - 0.12), apply-font(eff-lbl), anchor: "north")
        } else {
          content((bx1 + 0.12, by2 - 0.06), apply-font(eff-lbl), anchor: "north-west")
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
  samples: 100,
  ..args
) = {
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
    (fn: fn, stroke: stroke, domain: domain, samples: samples),
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
  l-label: auto,
  width: 3.8,
  height: 2.8,
) = {
  let xr    = 1.2
  let gap   = 0.13
  let C     = 0.9
  let slope = 0.5

  let lbl   = if a-label == auto { [#a] } else { a-label }
  let L-lbl = if l-label == auto { $L$ } else { l-label }
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
      axis-y-pos: none,
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
/// Alias for `scatter` with the same options. Use `connect: true` to join
/// the points with line segments.
#let data = scatter

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
  ..args,
  fn: none,
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
  let fn = _resolve-fn("func-plot", args, fn)
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
/// The function can be given positionally or as `fn:` (like plot series dicts).
///
/// `hatch` accepts a style string (`"ne"`, `"nw"`, `"h"`, `"v"`, `"cross"`,
/// `"grid"`) or a dict `(style: "ne", spacing: 5pt, stroke: red + 1pt)`;
/// the flat `hatch-spacing` / `hatch-stroke` arguments fill in unset entries.
///
/// Example:
/// ```typst
/// #plot(...,
///   fill-area(fn: x => calc.sin(x), domain: (0, calc.pi), color: blue.lighten(70%)),
///   (fn: x => calc.sin(x), stroke: blue + 1.2pt),
/// )
/// ```
#let fill-area(
  ..args,
  fn: none,
  domain: auto,
  baseline: 0.0,
  color: luma(220),
  hatch: none,
  hatch-spacing: 5pt,
  hatch-stroke: luma(80) + 0.5pt,
  samples: 80,
) = {
  let fn = _resolve-fn("fill-area", args, fn)
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
/// The functions can be given positionally or as `fn1:` / `fn2:`.
///
/// Hatch styles: `"ne"` (/), `"nw"` (\), `"h"`, `"v"`, `"cross"`, `"grid"` —
/// or a dict `(style: "ne", spacing: 5pt, stroke: red + 1pt)`.
///
/// Example:
/// ```typst
/// #plot(...,
///   area-between(x => calc.exp(x), x => x + 1, domain: (0, 1),
///                color: green.lighten(60%)),
/// )
/// ```
#let area-between(
  ..args,
  fn1: none,
  fn2: none,
  domain: auto,
  color: luma(220),
  hatch: none,
  hatch-spacing: 5pt,
  hatch-stroke: luma(80) + 0.5pt,
  samples: 80,
) = {
  assert(args.named().len() == 0,
    message: "area-between: unknown named arguments: " + args.named().keys().join(", "))
  let pos = args.pos()
  assert((fn1 == none) == (fn2 == none) and pos.len() == if fn1 == none { 2 } else { 0 },
    message: "area-between: expected two functions, positionally or as fn1:/fn2:")
  let (fn1, fn2) = if fn1 != none { (fn1, fn2) } else { (pos.at(0), pos.at(1)) }
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
/// - size: spy glass size (length, or number in cm) — ensures a square spy glass
/// - at: `(x, y)` data coords of inset center (`auto` = smart placement in opposite quadrant)
/// - width: inset box width (length, or number in cm; `auto` = from magnification or 3.5)
/// - height: inset box height (length, or number in cm; `auto` = from magnification or 3.5)
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
  if size != auto             { spec.insert("zoom-size-cm", to-cm(size)) }
  if width != auto            { spec.insert("zoom-width", to-cm(width)) }
  if height != auto           { spec.insert("zoom-height", to-cm(height)) }
  if magnification != auto    { spec.insert("magnification", magnification) }
  if region-fill != auto      { spec.insert("region-fill", region-fill) }
  if region-stroke != auto    { spec.insert("region-stroke", region-stroke) }
  if box-stroke != auto       { spec.insert("box-stroke", box-stroke) }
  spec.insert("box-fill", box-fill)
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
/// - point-label: content label with arrows to the nearest dots; `none` (default) = dots only,
///   `auto` = method-based text ("Left endpoints", …)
/// - point-label-pos: (x,y) in data coords for the label; `auto` = upper-right of dots
/// - show-dx: draw a Δx dimension bracket under one rectangle
/// - dx-rect: index of rectangle to annotate (0-based); `auto` = middle rectangle
/// - dx-label: content for the bracket label (default $Delta x$)
/// - show-xi: draw x₀, x₁, … labels at subdivision points below the axis
/// - xi-labels: array of content overrides; `auto` = generate x_i subscripts
/// - xi-show-values: if true, stack the numeric x value above each xi label
/// - Hatch styles: `"ne"`, `"nw"`, `"h"`, `"v"`, `"cross"`, `"grid"` —
///   or a dict `(style: "ne", spacing: 5pt, stroke: red + 1pt)`
#let riemann-sum(
  ..args,
  fn: none,
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
  point-label: none,
  point-label-pos: auto,
  show-dx: false,
  dx-rect: auto,
  dx-label: $Delta x$,
  show-xi: false,
  xi-labels: auto,
  xi-show-values: false,
) = {
  let fn = _resolve-fn("riemann-sum", args, fn)
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
/// - show-radius-marker: draw a vertical radius arrow from the axis to the profile
/// - radius-marker-x: x-position of the radius marker (auto = at x = a)
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
  show-radius-marker: false,
  radius-marker-x: auto,
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
  ..legacy,
) = {
  // Deprecated spellings kept for compatibility:
  // show-yaxis → show-y-axis, yaxis-x → radius-marker-x.
  assert(legacy.pos().len() == 0,
    message: "volume-of-revolution: unexpected extra positional arguments")
  for k in legacy.named().keys() {
    assert(k in ("show-yaxis", "yaxis-x"),
      message: "volume-of-revolution: unknown named arguments: " + k)
  }
  let show-y-axis = show-y-axis or legacy.named().at("show-yaxis", default: false)
  let radius-marker-x = if radius-marker-x != auto { radius-marker-x }
    else { legacy.named().at("yaxis-x", default: auto) }

  let width = to-cm(width)
  let height = to-cm(height)
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

  let x-sc = width / calc.max(fx-max - fx-min, 1e-9)
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
    let draw-coordinate-y-axis = show-y-axis
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
      let xv = if radius-marker-x == auto { a } else { radius-marker-x }
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
