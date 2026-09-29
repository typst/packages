// =====================================================
// CARTESIAN CANVAS - 2D rectangular coordinate system
// =====================================================

#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": plot
#import "draw.typ": draw-data-series-obj, draw-func-obj, draw-geo, format-label

/// Create a Cartesian (rectangular) coordinate canvas
/// Renders geometry objects with x-y axes.
///
/// Parameters:
/// - theme: Theme dictionary for styling
/// - size: Canvas size as (width, height) (default: (10, 10))
/// - width: Optional width (overrides size.at(0))
/// - height: Optional height (overrides size.at(1), or computed from width to maintain aspect)
/// - x-domain: X-axis range as (min, max) (default: (-5, 5))
/// - y-domain: Y-axis range as (min, max) (default: (-5, 5))
/// - x-tick: X-axis tick spacing (default: 1)
/// - y-tick: Y-axis tick spacing (default: 1)
/// - show-grid: Whether to show grid lines (default: false)
/// - axis-style: Style of axes - "school-book", "scientific", or none (default: "school-book")
/// - axis-label: Labels for the axes as a tuple (x-label, y-label) (default: `($x$, $y$)`)
/// - ..objects: Geometry objects to render
#let cartesian-canvas(
  theme: (:),
  size: (10, 10),
  width: none,
  height: none,
  x-domain: (-5, 5),
  y-domain: (-5, 5),
  x-tick: 1,
  y-tick: 1,
  show-grid: false,
  axis-style: "school-book",
  axis-label: ($x$, $y$),
  ..objects,
) = {
  // Compute actual size from width/height or size tuple
  // CeTZ uses 1 unit = 1cm, so we convert lengths to cm
  let x-range = x-domain.at(1) - x-domain.at(0)
  let y-range = y-domain.at(1) - y-domain.at(0)
  let aspect = y-range / x-range

  // Convert length to cm value (CeTZ units)
  let to-cm(val) = {
    if type(val) == length {
      val / 1cm // e.g., 4cm / 1cm = 4
    } else {
      val
    }
  }

  let final-size = if width != none and height != none {
    (to-cm(width), to-cm(height))
  } else if width != none {
    let w = to-cm(width)
    (w, w * aspect)
  } else if height != none {
    let h = to-cm(height)
    (h / aspect, h)
  } else {
    size
  }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let grid-col = theme.at("plot", default: (:)).at("grid", default: gray)
  let objs = objects.pos() + objects.named().at("children", default: ())
  // Color palette for multiple series
  let palette = if "palette" in theme.at("plot", default: (:)) {
    theme.plot.palette
  } else {
    (
      theme.at("plot", default: (:)).at("highlight", default: black),
      rgb("#e41a1c"), // red
      rgb("#377eb8"), // blue
      rgb("#4daf4a"), // green
      rgb("#984ea3"), // purple
      rgb("#ff7f00"), // orange
      rgb("#a65628"), // brown
      rgb("#f781bf"), // pink
    )
  }

  // Count plottable items (func, data-series, curve) to assign colors
  let get-color-index(objs) = {
    let idx = 0
    let indices = (:)
    for obj in objs {
      if type(obj) == dictionary {
        let t = obj.at("type", default: none)
        if t == "func" or t == "data-series" or t == "curve" {
          // Only count items that don't have explicit style
          if obj.at("style", default: auto) == auto or obj.at("style", default: none) == none {
            indices.insert(repr(obj), idx)
            idx += 1
          }
        }
      } else if type(obj) == array {
        for sub-obj in obj {
          if type(sub-obj) == dictionary {
            let t = sub-obj.at("type", default: none)
            if t == "func" or t == "data-series" or t == "curve" {
              if sub-obj.at("style", default: auto) == auto or sub-obj.at("style", default: none) == none {
                indices.insert(repr(sub-obj), idx)
                idx += 1
              }
            }
          }
        }
      }
    }
    indices
  }
  let color-indices = get-color-index(objs)

  // Helper to get auto color for an object
  let get-auto-color(obj) = {
    let key = repr(obj)
    if key in color-indices {
      let idx = color-indices.at(key)
      palette.at(calc.rem(idx, palette.len()))
    } else {
      theme.at("plot", default: (:)).at("highlight", default: black)
    }
  }

  // First pass: collect vectors handled by vec-add/vec-project
  let handled-vectors = ()
  for obj in objs {
    if type(obj) == dictionary {
      let t = obj.at("type", default: none)
      if t == "vector-addition" or t == "vector-projection" {
        let v1 = obj.v1
        let v2 = obj.v2
        handled-vectors.push((v1.x, v1.y))
        handled-vectors.push((v2.x, v2.y))
      }
    }
  }
  let is-handled(v) = handled-vectors.contains((v.x, v.y))

  let plot-text-size = theme.at("plot", default: (:)).at("text-size", default: 8pt)
  let plot-label-size = theme.at("plot", default: (:)).at("label-size", default: 10pt)

  // Force all text in this canvas to match the stroke color and default annotation size
  // This ensures the '0' origin label matches other ticks
  set text(fill: stroke-col, size: plot-text-size)

  cetz.canvas({
    import cetz.draw: *


    set-style(
      stroke: stroke-col,
      fill: none,
      axes: (
        stroke: stroke-col,
        tick: (stroke: stroke-col),
        grid: (stroke: (paint: grid-col)),
      ),
      tick-label: (fill: stroke-col), // Explicitly style tick labels
    )

    plot.plot(
      size: final-size,
      axis-style: axis-style,
      x-tick-step: x-tick,
      y-tick-step: y-tick,
      x-grid: show-grid,
      y-grid: show-grid,

      x-label: text(fill: stroke-col, size: plot-label-size, axis-label.at(0)),
      y-label: text(fill: stroke-col, size: plot-label-size, axis-label.at(1)),

      x-format: x => text(fill: stroke-col, size: plot-text-size, str(x)),
      y-format: y => text(fill: stroke-col, size: plot-text-size, str(y)),

      x-min: x-domain.at(0),
      x-max: x-domain.at(1),
      y-min: y-domain.at(0),
      y-max: y-domain.at(1),

      legend-style: (fill: theme.at("page-fill", default: none), stroke: stroke-col),
      

      {
        // Add corner points to ensure plot bounds are respected.
        // This also serves as a workaround for a cetz-plot annotation crash.
        plot.add(
          (
            (x-domain.at(0), y-domain.at(0)),
            (x-domain.at(1), y-domain.at(1)),
          ),
          style: (stroke: none),
          mark: none,
        )

        let bounds = (x: x-domain, y: y-domain)

        for obj in objs {
          if type(obj) == dictionary {
            let t = obj.at("type", default: none)

            if t == "func" {
              // Apply auto color if no explicit style
              let styled-obj = if obj.at("style", default: auto) == auto or obj.at("style", default: none) == none {
                obj + (style: (stroke: get-auto-color(obj)))
              } else { obj }
              draw-func-obj(styled-obj, theme, x-domain: x-domain, y-domain: y-domain, size: final-size)
            } else if t == "data-series" {
              let styled-obj = if obj.at("style", default: auto) == auto or obj.at("style", default: none) == none {
                obj + (style: (stroke: get-auto-color(obj)))
              } else { obj }
              draw-data-series-obj(styled-obj, theme, x-domain: x-domain, y-domain: y-domain)
            } else if t == "curve" {
              // Draw curve via annotate, but add label to legend
              let auto-color = get-auto-color(obj)
              let styled-obj = if obj.at("style", default: auto) == auto or obj.at("style", default: none) == none {
                obj + (style: (stroke: auto-color))
              } else { obj }
              let aspect = (x-domain, y-domain, final-size.at(0), final-size.at(1))
              plot.annotate({ draw-geo(styled-obj + (label: none), theme, bounds: bounds, aspect: aspect) })
              // Add legend entry if label present
              if obj.at("label", default: none) != none {
                let pts = obj.points
                let last = if pts.len() > 0 {
                  let p = pts.last()
                  if type(p) == dictionary { (p.x, p.y) } else { (p.at(0), p.at(1)) }
                } else { (0, 0) }
                let curve-col = if (
                  styled-obj.style != auto and styled-obj.style != none and "stroke" in styled-obj.style
                ) {
                  styled-obj.style.stroke
                } else { auto-color }
                plot.add((last,), style: (stroke: curve-col), mark: none, label: format-label(obj, obj.label))
              }
            } else if t == "vector" and is-handled(obj) {
              // Skip - handled by vec-add/vec-project
            } else if t != none {
              let aspect = (x-domain, y-domain, final-size.at(0), final-size.at(1))
              plot.annotate({
                draw-geo(obj, theme, bounds: bounds, aspect: aspect)
              })
            }
          } else if type(obj) == array {
            for sub-obj in obj {
              if type(sub-obj) == dictionary and sub-obj.at("type", default: none) == "func" {
                let styled-obj = if (
                  sub-obj.at("style", default: auto) == auto or sub-obj.at("style", default: none) == none
                ) {
                  sub-obj + (style: (stroke: get-auto-color(sub-obj)))
                } else { sub-obj }
                draw-func-obj(styled-obj, theme, x-domain: x-domain, y-domain: y-domain, size: final-size)
              } else if type(sub-obj) == dictionary and sub-obj.at("type", default: none) == "data-series" {
                let styled-obj = if (
                  sub-obj.at("style", default: auto) == auto or sub-obj.at("style", default: none) == none
                ) {
                  sub-obj + (style: (stroke: get-auto-color(sub-obj)))
                } else { sub-obj }
                draw-data-series-obj(styled-obj, theme, x-domain: x-domain, y-domain: y-domain)
              } else if type(sub-obj) == dictionary {
                let t = sub-obj.at("type", default: none)
                if t == "vector" and is-handled(sub-obj) {
                  // Skip
                } else {
                  let aspect = (x-domain, y-domain, final-size.at(0), final-size.at(1))
                  plot.annotate({
                    draw-geo(sub-obj, theme, bounds: bounds, aspect: aspect)
                  })
                }
              }
            }
          }
        }
      },
    )
  })
}

/// Shorthand for a plot with functions only
#let graph-canvas(
  theme: (:),
  size: (10, 8),
  width: none,
  height: none,
  x-domain: (-5, 5),
  y-domain: (-5, 5),
  ..funcs,
) = {
  cartesian-canvas(
    theme: theme,
    size: size,
    width: width,
    height: height,
    x-domain: x-domain,
    y-domain: y-domain,
    axis-style: "school-book",
    ..funcs,
  )
}

/// Canvas with pi-labeled x-axis (for trigonometric functions)
#let trig-canvas(
  theme: (:),
  size: (10, 8),
  width: none,
  height: none,
  x-domain: (-2 * calc.pi, 2 * calc.pi),
  y-domain: (-2, 2),
  pi-divisor: 2, // Tick every π/pi-divisor
  ..objects,
) = {
  // Convert length to cm value (CeTZ units)
  let to-cm(val) = if type(val) == length { val / 1cm } else { val }

  let x-range = x-domain.at(1) - x-domain.at(0)
  let y-range = y-domain.at(1) - y-domain.at(0)
  let aspect = y-range / x-range

  let final-size = if width != none and height != none {
    (to-cm(width), to-cm(height))
  } else if width != none {
    let w = to-cm(width)
    (w, w * aspect)
  } else if height != none {
    let h = to-cm(height)
    (h / aspect, h)
  } else {
    size
  }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)

  // Color palette for multiple series
  let palette = if "palette" in theme.at("plot", default: (:)) {
    theme.plot.palette
  } else {
    (
      theme.at("plot", default: (:)).at("highlight", default: black),
      rgb("#e41a1c"), // red
      rgb("#377eb8"), // blue
      rgb("#4daf4a"), // green
      rgb("#984ea3"), // purple
      rgb("#ff7f00"), // orange
      rgb("#a65628"), // brown
      rgb("#f781bf"), // pink
    )
  }

  // Count plottable items to assign colors
  let objs = objects.pos()
  let get-color-index(objs) = {
    let idx = 0
    let indices = (:)
    for obj in objs {
      if type(obj) == dictionary {
        let t = obj.at("type", default: none)
        if t == "func" or t == "data-series" or t == "curve" {
          if obj.at("style", default: auto) == auto or obj.at("style", default: none) == none {
            indices.insert(repr(obj), idx)
            idx += 1
          }
        }
      }
    }
    indices
  }
  let color-indices = get-color-index(objs)

  // Helper to get auto color for an object
  let get-auto-color(obj) = {
    let key = repr(obj)
    if key in color-indices {
      let idx = color-indices.at(key)
      palette.at(calc.rem(idx, palette.len()))
    } else {
      theme.at("plot", default: (:)).at("highlight", default: black)
    }
  }

  let d = pi-divisor
  let gcd(a, b) = if b == 0 { a } else { gcd(b, calc.rem(a, b)) }

  let plot-text-size = theme.at("plot", default: (:)).at("text-size", default: 8pt)
  let plot-label-size = theme.at("plot", default: (:)).at("label-size", default: 10pt)

  let x-format = x => {
    let n = int(calc.round(x * d / calc.pi))
    let g = gcd(calc.abs(n), d)
    let num = calc.quo(n, g)
    let denom = calc.quo(d, g)

    text(fill: stroke-col, size: plot-text-size, {
      if num == 0 { $0$ } else if denom == 1 {
        if num == 1 { $pi$ } else if num == -1 { $-pi$ } else { $#num pi$ }
      } else {
        if num == 1 { $pi / #denom$ } else if num == -1 { $-pi / #denom$ } else { $#num / #denom pi$ }
      }
    })
  }

  // Force all text in this canvas to match the stroke color
  set text(fill: stroke-col, size: plot-text-size)

  cetz.canvas({
    import cetz.draw: *

    set-style(stroke: stroke-col, fill: none)

    plot.plot(
      size: final-size,
      axis-style: "school-book",
      x-tick-step: calc.pi / d,
      y-tick-step: 1,

      x-label: text(fill: stroke-col, $x$),
      y-label: text(fill: stroke-col, $y$),

      x-format: x-format,
      y-format: y => text(fill: stroke-col, size: plot-text-size, str(y)),

      x-min: x-domain.at(0),
      x-max: x-domain.at(1),
      y-min: y-domain.at(0),
      y-max: y-domain.at(1),

      legend-style: (fill: theme.at("page-fill", default: none), stroke: stroke-col),

      {
        let bounds = (x: x-domain, y: y-domain)
        for obj in objs {
          if type(obj) == dictionary {
            let t = obj.at("type", default: none)
            if t == "func" {
              // Apply auto color if no explicit style
              let styled-obj = if obj.at("style", default: auto) == auto or obj.at("style", default: none) == none {
                obj + (style: (stroke: get-auto-color(obj)))
              } else { obj }
              draw-func-obj(styled-obj, theme, x-domain: x-domain, y-domain: y-domain, size: final-size)
            } else if t == "data-series" {
              let styled-obj = if obj.at("style", default: auto) == auto or obj.at("style", default: none) == none {
                obj + (style: (stroke: get-auto-color(obj)))
              } else { obj }
              draw-data-series-obj(styled-obj, theme, x-domain: x-domain, y-domain: y-domain)
            } else if (
              t != none
            ) {
              plot.annotate({ draw-geo(obj, theme, bounds: bounds) })
            }
          }
        }
      },
    )
  })
}
