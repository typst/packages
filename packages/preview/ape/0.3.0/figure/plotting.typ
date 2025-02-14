#import "@preview/cetz:0.3.1"
#import "@preview/cetz-plot:0.1.0": plot

#let plotting(
  functions,
  /*
  (
    (
      fn:
      x => x,
      domain: (start, end),
      projection: (x: ((0, "0"),), y: ((0, "1"),)),
      stroke: color,
    ),
      fn: x => x,
      domain: (start, end),
      projection: (x: ((0, "0"),), y: ((0, "1"),)),
      stroke: color,

  )
  */
  domain: (-0.3, 5),
  samples: 200,
  steps: (none, none),
  axis-style: "school-book",
  axis: ("x", "y"), // axis name
  size: (14, 7), // blueprint size
) = {
  import calc: *
  import cetz.draw: *

  let domain-min-x = domain.at(0)
  for function in functions {
    if function.keys().contains("domain") {
      if function.domain.at(0) < domain-min-x {
        domain-min-x = function.domain.at(0)
      }
    }
  }

  let domain-max-x = domain.at(0)
  for function in functions {
    if function.keys().contains("domain") {
      if function.domain.at(0) > domain-max-x {
        domain-max-x = function.domain.at(0)
      }
    }
  }

  let size-domain = domain-max-x - domain-min-x

  let amplitude-y = {
    let max-total = 0
    let min-total = 0
    let precision = ceil(samples / 5)
    for function in functions {
      if function.keys().contains("fn") and function.keys().contains("domain") {
        let m = (function.fn)(function.domain.at(0))
        let m-temp = m
        for i in range(precision) {
          if ((function.fn)(domain.at(0) + i * (domain.at(1) - domain.at(0)) / precision) > m-temp) {
            m-temp = (function.fn)(domain.at(0) + i * (domain.at(1) - domain.at(0)) / precision)
          }
          if ((function.fn)(domain.at(0) + i * (domain.at(1) - domain.at(0)) / precision) < m-temp) {
            m-temp = (function.fn)(domain.at(0) + i * (domain.at(1) - domain.at(0)) / precision)
          }
        }
        if m > -0.2 { m = -0.2 }
        if m-temp < 0.2 { m-temp = 0.2 }
        if m-temp > max-total {
          max-total = m-temp
        }
        if m < min-total {
          min-total = m
        }
      }
    }
    round((max-total - min-total) / 2 * 100) / 100
  }

  let sgn(x) = {
    if x == 0 { return 1 }
    return abs(x) / x
  }

  let projection-x(function, x, label) = {
    plot.add-vline(x, max: function(x), min: 0, style: (stroke: (dash: "dashed")))
    if label.len() > 0 {
      plot.annotate({
        content((x, -(0.1 * sgn(function(x))) * 1 / (size.at(1) / 7) * amplitude-y), [#label])
      })
    }
  }

  let projection-y(function, x, label) = {
    plot.add-hline(function(x), max: x, min: 0, style: (stroke: (dash: "dashed")))
    if label.len() > 0 {
      plot.annotate({
        content((0, function(x)), [#label])
      })
    }
  }

  return cetz.canvas({
    set-style(axes: (stroke: .5pt, tick: (stroke: .5pt)))

    plot.plot(
      size: size,
      x-tick-step: steps.at(0),
      y-tick-step: steps.at(1),
      axis-style: axis-style,
      x-label: axis.at(0),
      y-label: axis.at(1),
      x-min: domain.at(0),
      x-max: domain.at(1),
      {
        for function in functions {
          if function.keys().contains("fn") {
            let dm = if function.keys().contains("domain") { function.domain } else { domain }
            let st = if function.keys().contains("stroke") { function.stroke } else { black }
            
            plot.add(
              function.fn,
              domain: dm,
              style: (stroke: st),
              samples: samples,
            )

            if function.keys().contains("projection") {
              if function.projection.keys().contains("x") {
                for x in function.projection.x {
                  if type(x) == array {
                    projection-x(function.fn, x.at(0), x.at(1))
                  } else {
                    projection-x(function.fn, x, "")
                  }
                }
              }
              
              if function.projection.keys().contains("y") {
                for y in function.projection.y {
                  if type(y) == array {
                    projection-y(function.fn, y.at(0), y.at(1))
                  } else {
                    projection-y(function.fn, y, "")
                  }
                }
              }
            }
          }
        }
      }
    )
  })
}
