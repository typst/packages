#import "@preview/cetz:0.4.0": canvas, draw
#import "@preview/cetz-plot:0.1.2": plot

#set page(width: auto, height: auto, margin: .5cm)

#let style = (stroke: black, fill: rgb(0, 0, 200, 75))

#let f(x, rho: .4, sigma: 0) = 1 / calc.sqrt(2 * calc.pi * rho * rho) * calc.exp(-calc.pow(x - sigma, 2)/(2 * rho * rho))

#set text(size: 10pt, fill: white)

#canvas(background: gray.darken(80%), {
  import draw: *

  set-style(
    axes: (
      stroke: 1pt + white,
      tick: (stroke: 1pt + white),
      fill: gray.darken(60%),
      minor-tick: (stroke: white),
      grid: (stroke: (thickness: .5pt, paint: white, dash: "dotted")),
    ),
    legend: (
      fill: black.transparentize(60%),
      stroke: none,
      padding: .3cm,
      offset: (-.1, -.1)
    )
  )

  let x-format = x => {
    if x > 0 { $mu + #{x}sigma$ }
    else if x < 0 { $mu - #{calc.abs(x)}sigma$ }
    else { $mu$ }
  }

  plot.plot(size: (12, 8),
    x-tick-step: 1,
    y-tick-step: 1,
    x-format: x-format,
    y-max: 1.1,
    y-min: -.1,
    x-grid: true,
    y-grid: true,
    x-label: none,
    y-label: none,
    legend: "inner-north-east",
    {
      plot.add(f, domain: (-3, +3),
        style: (stroke: green),
        label: $y = 1/sqrt(2 pi sigma^2) exp(-(x - mu)^2/(2 sigma^2)) $,
        samples: 200,
      )
    })

  // Add some padding
  rect((-1, -1), (13, 9))
})
