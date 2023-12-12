#import "@preview/cetz:0.1.2"

#let riemann(
  // Function
  fn,
  // Start
  start: 0,
  // End
  end: 10,
  // Number of bars (please made Delta x = 1)
  n: 10,
  // Y scale
  y-scale: 1,
  // X offset
  x-offset: 0,
  // Y offset
  y-offset: 0,
  // Hand of graph. Can be left, mid/midpoint, or right
  hand: "left",
  // Transparency fill of bars
  transparency: 40%,
  // Radius of dots
  dot-radius: 0.055,
  // Whether to add plot
  plot: true,
  // Show grid on plot
  plot-grid: false,
  // X tick step of plot
  plot-x-tick-step: auto,
  // Y tick step of plot
  plot-y-tick-step: auto,
  // Color of positive bars
  positive-color: color.green,
  // Color of negative bars
  negative-color: color.red,
  // Color of plotted line
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