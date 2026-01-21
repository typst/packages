#import "@preview/cetz:0.1.2"

/// Draw a Riemann sum of a function, and optionally plot the function.
///
/// - fn (function): The function to draw a Riemann sum of.
/// - start (number): Where to start drawing bars.
/// - end (number): Where to end drawing bars.
/// - n (number): Number of bars (please make $Delta x =1$).
/// - y-scale (number): Y scale of bars.
/// - x-offset (number): X offset of bars.
/// - y-offset (number): Y offset of bars.
/// - hand (string): Where points are derrived from. Can be "left", "mid"/"midpoint", or "right".
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
  n: 10,
  y-scale: 1,
  x-offset: 0,
  y-offset: 0,
  hand: "left",
  transparency: 40%,
  dot-radius: 0.055,
  plot: true,
  plot-grid: false,
  plot-x-tick-step: auto,
  plot-y-tick-step: auto,
  positive-color: color.green,
  negative-color: color.red,
  plot-line-color: color.blue,
) = {

    let hand-offset = 0
    let mark-horizontal = "-left"
    if hand == "right" {
      hand-offset = 1
      mark-horizontal = "-right"
    } 
    else if hand == "mid" or hand == "midpoint" {
      hand-offset = 0.5
      mark-horizontal = ""
    }

    let col-trans(color, opacity) = {
      let space = color.space()
      space(..color.components(alpha: false), opacity)
    }

    if plot {
     cetz.plot.plot(
       size: (end + x-offset, end),
       x-grid: plot-grid,
       y-grid: plot-grid,
       axis-style: "school-book",
       x-tick-step: plot-x-tick-step,
       y-tick-step: plot-y-tick-step,
       {
         cetz.plot.add(
           domain: (start - x-offset, end),
           x => fn(x),
           style: (
            stroke: plot-line-color + 1.5pt,
          ),
        )
      })
    }

    // Doesn't work if Delta n != 1
    // Should be `for i in range(start, end, step: (end - start)/n).map(...`
    // https://github.com/typst/typst/issues/2908
    for i in range(start, end).map(x => x * n/(end - start)) {
      let height = fn(i + hand-offset)
      let bar-color = positive-color
      let mark-vertical = "top"
      if fn(i) <= 0 {
        bar-color = negative-color
        mark-vertical = "bottom"
      }
      cetz.draw.fill(col-trans(
        bar-color.lighten(70%).darken(8%),
        transparency
      ))
      cetz.draw.rect(
        (i + x-offset, y-offset),
        (i + x-offset + 1, (height/y-scale) + y-offset),
        stroke: col-trans(bar-color.darken(30%), 90%) + 1.1pt,
        name: "r"
      )
      cetz.draw.circle(
        "r." + mark-vertical + mark-horizontal,
        radius: dot-radius,
        fill: bar-color
      )
   }
}
