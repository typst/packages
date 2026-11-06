#import "@preview/cetz:0.2.0"

/// Draw a Riemann sum of a function, and optionally plot the function.
///
/// - fn (function): The function to draw a Riemann sum of.
/// - domain (array): Tuple of the domain of fn. If a tuple value is auto, that
///   value is set to start/end.
/// - start (number): Where to start drawing bars.
/// - end (number): Where to end drawing bars.
/// - n (number): Number of bars
/// - y-scale (number): Y scale of bars.
/// - method (string): Where points are derrived from. Can be "left", "mid"/"midpoint", or "right".
/// - transparency (number): Transparency fill of bars.
/// - dot-radius (number): Radius of dots.
/// - plot (boolean): Whether to add plot of the function.
/// - plot-grid (boolean): Show grid on plot.
/// - plot-x-tick-step (number): X tick step of plot.
/// - plot-y-tick-step (number): Y tick step of plot.
/// - positive-color (color): Color of positive bars.
/// - negative-color (color): Color of negative bars.
/// - plot-line-color (color): Color of plotted line.
#let riesketcher(
  fn,
  start: 0,
  end: 10,
  domain: (auto, auto),
  n: 10,
  y-scale: 1,
  method: "left",
  transparency: 40%,
  dot-radius: 0.15,
  plot: true,
  plot-grid: false,
  plot-x-tick-step: auto,
  plot-y-tick-step: auto,
  positive-color: color.green,
  negative-color: color.red,
  plot-line-color: color.blue,
  size: (5, 5),
) = {
    // Adjust the function domain if set to auto
    if domain.at(0) == auto { domain.at(0) = start }
    if domain.at(1) == auto { domain.at(1) = end }

    let horizontal-hand-offset = 0%
    if method == "right" {
      horizontal-hand-offset = 100%
    }
    else if method == "mid" or method == "midpoint" {
      horizontal-hand-offset = 50%
    }

    let col-trans(color, opacity) = {
      let space = color.space()
      space(..color.components(alpha: false), opacity)
    }

    let delta = end - start
    let bar-width = (end - start) / n
    let bar-position = if method == "left" {
      "start"
    } else if method == "right" {
      "end"
    } else {
      "center"
    }

    let bar-y = range(0, n).map(x => {
      let x = start + bar-width * (x + horizontal-hand-offset / 100%)
      (x, fn(x))
    })

    let positive-bar-style = (
      fill: col-trans(positive-color.lighten(70%).darken(8%), transparency),
      stroke: col-trans(positive-color.darken(30%), 90%) + 1.1pt
    )
    let negative-bar-style = (
      : ..positive-bar-style,
      fill: col-trans(negative-color.lighten(70%).darken(8%), transparency),
      stroke: col-trans(negative-color.darken(30%), 90%) + 1.1pt
    )
    let positive-dot-style = (
      stroke: black,
      fill: positive-color
    )
    let negative-dot-style = (
      : ..positive-dot-style,
      fill: negative-color,
    )

    cetz.plot.plot(
      size: size,
      x-grid: plot-grid,
      y-grid: plot-grid,
      axis-style: if plot { "school-book" } else { none },
      x-tick-step: plot-x-tick-step,
      y-tick-step: plot-y-tick-step,
      {
        for (x, y) in bar-y {
          cetz.plot.add-bar(((x, y),),
            bar-width: bar-width,
            bar-position: bar-position,
            style: if y >= 0 { positive-bar-style } else { negative-bar-style })
        }

        if plot {
          cetz.plot.add(
            domain: domain,
            x => fn(x),
            style: (stroke: plot-line-color + 1.5pt))
        }

        for (x, y) in bar-y {
          cetz.plot.add(((x, y),),
            mark: "o",
            style: (stroke: none),
            mark-size: dot-radius,
            mark-style:if y >= 0 { positive-dot-style } else { negative-dot-style })
        }
      })
}
