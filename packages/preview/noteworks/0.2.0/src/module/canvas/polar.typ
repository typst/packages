// =====================================================
// POLAR CANVAS - Polar coordinate system
// =====================================================

#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": plot
#import "draw.typ": draw-data-series-obj, draw-func-obj, draw-geo

/// Create a polar coordinate canvas
/// Renders geometry objects with circular grid and radial lines.
///
/// Parameters:
/// - theme: Theme dictionary for styling
/// - size: Canvas size as (width, height) (default: (10, 10))
/// - width: Optional width (overrides size)
/// - height: Optional height
/// - radius: Maximum radius (default: 5)
/// - tick: Radial tick spacing (default: 1)
/// - margin: Extra margin beyond radius (default: 0.5)
/// - show-angles: Whether to show angle labels (default: true)
/// - ..objects: Geometry objects to render
#let polar-canvas(
  theme: (:),
  size: (10, 10),
  width: none,
  height: none,
  radius: 5,
  tick: 1,
  margin: 0.5,
  show-angles: true,
  ..objects,
) = {
  // Convert length to cm value (CeTZ units)
  let to-cm(val) = if type(val) == length { val / 1cm } else { val }

  let final-size = if width != none and height != none {
    (to-cm(width), to-cm(height))
  } else if width != none {
    let w = to-cm(width)
    (w, w) // Polar is typically square
  } else if height != none {
    let h = to-cm(height)
    (h, h)
  } else {
    size
  }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let grid-col = theme.at("plot", default: (:)).at("grid", default: gray)
  let effective-radius = radius + margin

  // Color palette for multiple series
  let palette = theme
    .at("plot", default: (:))
    .at("palette", default: (
      black, // black (first)
      rgb("#e41a1c"), // red
      rgb("#377eb8"), // blue
      rgb("#4daf4a"), // green
      rgb("#984ea3"), // purple
      rgb("#ff7f00"), // orange
      rgb("#a65628"), // brown
      rgb("#f781bf"), // pink
    ))

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

  cetz.canvas({
    import cetz.draw: *

    set-style(stroke: stroke-col, fill: stroke-col)

    plot.plot(
      size: final-size,
      axis-style: none,
      x-tick-step: none,
      y-tick-step: none,
      x-grid: false,
      y-grid: false,
      x-min: -effective-radius,
      x-max: effective-radius,
      y-min: -effective-radius,
      y-max: effective-radius,
      legend-style: (fill: theme.at("page-fill", default: none), stroke: stroke-col),

      {
        // Workaround for cetz-plot crash: initialize data bounds
        plot.add(((0, 0),), style: (stroke: none), mark: none)

        // Draw polar grid as annotation
        plot.annotate({
          on-layer(-1, {
            // Concentric circles
            let num-circles = calc.floor(radius / tick)
            for i in range(1, num-circles + 1) {
              let r = i * tick
              circle((0, 0), radius: r, stroke: (paint: grid-col, thickness: 0.75pt), fill: none)
            }

            // Radial lines (every 30°)
            for deg in range(0, 180, step: 30) {
              line(
                (calc.cos(deg * 1deg) * effective-radius, calc.sin(deg * 1deg) * effective-radius),
                (calc.cos((deg + 180) * 1deg) * effective-radius, calc.sin((deg + 180) * 1deg) * effective-radius),
                stroke: (paint: grid-col, thickness: 0.75pt),
              )
            }

            // Polar axis (bold arrow)
            line(
              (0, 0),
              (effective-radius, 0),
              stroke: (paint: stroke-col, thickness: 1pt),
              mark: (end: ">", fill: stroke-col),
            )

            // Radius tick labels
            for i in range(1, num-circles + 1) {
              let r = i * tick
              let label = if calc.rem(r, 1) == 0 { str(int(r)) } else { str(calc.round(r, digits: 2)) }
              content((r, -0.3), text(fill: stroke-col, size: 7.5pt, label), anchor: "north")
            }

            // Angle labels
            if show-angles {
              for deg in (0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330) {
                let rad = deg * 1deg
                let label-r = effective-radius + 0.3
                let anchor = if deg == 0 { "west" } else if deg == 90 { "south" } else if deg == 180 {
                  "east"
                } else if deg == 270 { "north" } else if deg < 90 { "south-west" } else if deg < 180 {
                  "south-east"
                } else if deg < 270 { "north-east" } else { "north-west" }

                content(
                  (label-r * calc.cos(rad), label-r * calc.sin(rad)),
                  text(fill: stroke-col, size: 7pt, $#deg degree$),
                  anchor: anchor,
                )
              }
            }
          })
        })

        // Draw geometry objects
        let bounds = (x: (-effective-radius, effective-radius), y: (-effective-radius, effective-radius))

        for obj in objs {
          if type(obj) == dictionary {
            let t = obj.at("type", default: none)
            if t == "func" {
              // Apply auto color if no explicit style
              let styled-obj = if obj.at("style", default: auto) == auto or obj.at("style", default: none) == none {
                obj + (style: (stroke: get-auto-color(obj)))
              } else { obj }
              draw-func-obj(
                styled-obj,
                theme,
                x-domain: (-effective-radius, effective-radius),
                y-domain: (-effective-radius, effective-radius),
                size: final-size,
              )
            } else if t == "data-series" {
              let styled-obj = if obj.at("style", default: auto) == auto or obj.at("style", default: none) == none {
                obj + (style: (stroke: get-auto-color(obj)))
              } else { obj }
              draw-data-series-obj(
                styled-obj,
                theme,
                x-domain: (-effective-radius, effective-radius),
                y-domain: (-effective-radius, effective-radius),
              )
            } else if t != none {
              plot.annotate({ draw-geo(obj, theme, bounds: bounds) })
            }
          }
        }
      },
    )
  })
}
