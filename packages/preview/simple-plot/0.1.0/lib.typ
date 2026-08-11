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
    label-size: 0.8em,
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
    size: 1em,
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
    let magnitude = calc.pow(10, calc.floor(calc.log(range, base: 10)))
    let normalized = range / magnitude
    if normalized <= 2 { magnitude * 0.5 }
    else if normalized <= 5 { magnitude }
    else { magnitude * 2 }
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
/// - style (none, dictionary): Style overrides
/// - ..functions: Function/data specifications to plot
#let plot(
  xmin: auto,
  xmax: auto,
  ymin: auto,
  ymax: auto,
  width: auto,
  height: auto,
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
  let width = resolve(width, "width", 8)
  let height = resolve(height, "height", 6)
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

  let s = merge-styles(style)

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
          line((cx, 0), (cx, height), stroke: s.grid.minor.stroke)
        }
      }
      for i in range(ny) {
        let y = ymin + i * minor-y-step
        if y <= ymax {
          let cy = (y - ymin) * y-scale
          line((0, cy), (width, cy), stroke: s.grid.minor.stroke)
        }
      }
    }

    // Major grid
    if show-grid == "major" or show-grid == "both" or show-grid == true {
      for x in x-ticks.ticks {
        let cx = (x - xmin) * x-scale
        line((cx, 0), (cx, height), stroke: s.grid.major.stroke)
      }
      for y in y-ticks.ticks {
        let cy = (y - ymin) * y-scale
        line((0, cy), (width, cy), stroke: s.grid.major.stroke)
      }
    }

    // Axes
    let (x1, y-ax) = to-canvas(xmin, x-axis-y)
    let (x2, _) = to-canvas(xmax, x-axis-y)
    line((x1, y-ax), (x2, y-ax), stroke: s.axis.stroke, mark: (end: s.axis.arrow))

    let (x-ax, y1) = to-canvas(y-axis-x, ymin)
    let (_, y2) = to-canvas(y-axis-x, ymax)
    line((x-ax, y1), (x-ax, y2), stroke: s.axis.stroke, mark: (end: s.axis.arrow))

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
    if calc.abs(x-axis-y) < 0.0001 and calc.abs(y-axis-x) < 0.0001 {
      let (ox, oy) = to-canvas(0, 0)
      content((ox - tick-len - s.ticks.label-offset, oy - tick-len - s.ticks.label-offset),
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

    // Plot functions and data
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
        let domain-min = func-spec.at("domain", default: (xmin, xmax)).at(0)
        let domain-max = func-spec.at("domain", default: (xmin, xmax)).at(1)
        let samples = func-spec.at("samples", default: s.plot.samples)
        let step = (domain-max - domain-min) / samples
        let current-segment = ()

        for i in range(samples + 1) {
          let x = domain-min + i * step
          let y = fn(x)
          if y != none and not (y).is-nan() and y >= ymin and y <= ymax {
            let (cx, cy) = to-canvas(x, y)
            current-segment.push((cx, cy))
            points-to-draw.push((cx, cy, i))
          } else if current-segment.len() > 1 {
            line(..current-segment, stroke: stroke-style)
            current-segment = ()
          } else {
            current-segment = ()
          }
        }
        if current-segment.len() > 1 {
          line(..current-segment, stroke: stroke-style)
        }

        if label != none {
          let label-pos = func-spec.at("label-pos", default: 0.8)
          let label-anchor = func-spec.at("label-anchor", default: "south-west")
          let lx = domain-min + (domain-max - domain-min) * label-pos
          let ly = fn(lx)
          if ly != none and not (ly).is-nan() and ly >= ymin and ly <= ymax {
            let (cx, cy) = to-canvas(lx, ly)
            content((cx, cy), label, anchor: label-anchor)
          }
        }

      } else if data-points != none {
        let connect = func-spec.at("connect", default: true)
        let canvas-points = ()
        for (i, pt) in data-points.enumerate() {
          let (x, y) = pt
          if x >= xmin and x <= xmax and y >= ymin and y <= ymax {
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
          let label-anchor = func-spec.at("label-anchor", default: "south-west")
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
