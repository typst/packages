
== Cetz Graphique

#import "@preview/cetz-plot:0.1.0": plot


#let tracer(
  functions,
  /*
  (
    (
      fn:
      x => x,
      domain: (debut, fin),
      projection: (x: (), y:()),
                  stroke: couleur,
    ),
      fn: x => x,
      domain: (debut, fin),
      projection: (x: (), y:()),
                  stroke: couleur,

  )
  */
  domain: (-0.3, 5),
  samples: 200,
  steps: (none, none),
  axisStyle: "school-book",
  axis: ("x", "y"), // axis name
  size: (14, 7), // blueprint size
) = context {
  import calc: *
  import cetz.draw: *


  let domainMinX = domain.at(0)
  for f in functions {
    if f.keys().contains("domain") {
      if f.domain.at(0) < domainMinX {
        domainMinX = f.domain.at(0)
      }
    }
  }

  let domainMaxX = domain.at(0)
  for f in functions {
    if f.keys().contains("domain") {
      if f.domain.at(0) > domainMaxX {
        domainMaxX = f.domain.at(0)
      }
    }
  }


  let SizeDomain = domainMaxX - domainMinX


  let amplitudeY() = {
    let max_tot = 0
    let min_tot = 0
    let precision = ceil(samples / 5)
    for f in functions {
      if f.keys().contains("fn") and f.keys().contains("domain") {
        let M = (f.fn)(f.domain.at(0))
        let m = (f.fn)(f.domain.at(0))
        for i in range(precision) {
          if ((f.fn)(domain.at(0) + i * (domain.at(1) - domain.at(0)) / precision) > M) {
            M = (f.fn)(domain.at(0) + i * (domain.at(1) - domain.at(0)) / precision)
          }
          if ((f.fn)(domain.at(0) + i * (domain.at(1) - domain.at(0)) / precision) < m) {
            m = (f.fn)(domain.at(0) + i * (domain.at(1) - domain.at(0)) / precision)
          }
        }
        if m > -0.2 { m = -0.2 }
        if M < 0.2 { M = 0.2 }
        if M > max_tot {
          max_tot = M
        }
        if m < min_tot {
          min_tot = m
        }
      }
    }

    return round((max_tot - min_tot) / 2 * 100) / 100
  }


  let sgn(x) = {
    if x == 0 {
      return 1
    }
    return abs(x) / x
  }

  let projectionX(fn, x, label) = {
    plot.add-vline(x, max: fn(x), min: 0, style: (stroke: (dash: "dashed")))

    if label.len() > 0 {
      plot.annotate({
        content((x, -(0.1 * sgn(fn(x))) * 1 / (size.at(1) / 7) * amplitudeY()), [#label])
      })
    }
  }

  [#amplitudeY()]


  let ProjectionSurY(x1, x2) = {
    if (x1 > 0) { return x1 }
    if (x2 < 0) { return x2 }
    return 0
  }

  let projectionY(fn, x, label) = {
    plot.add-hline(
      fn(x),
      max: x,
      min: ProjectionSurY(domain.at(0), domain.at(1)),
      style: (stroke: (dash: "dashed")),
    )

    /*if label.len() > 0 {
      plot.annotate({
        content(
          (- (0.2 + domain.at(0)) * sgn(x) + label.len() / 10 , fn(x)),
          [#label]
        )
      })
    }
    */
    if label.len() > 0 {
      plot.annotate({
        content(
          (
            ProjectionSurY(domain.at(0), domain.at(1)) + (sgn(x) * (-0.18 - label.len() / 9)) * 1 / (size.at(0) / 14),
            fn(x),
          ),
          [#label],
        )
      })
    }
  }


  cetz.canvas({
    // Set-up a thin axis style
    set-style(axes: (stroke: .5pt, tick: (stroke: .5pt)))


    plot.plot(
      size: (size.at(0), size.at(1)),

      x-tick-step: steps.at(0),
      y-tick-step: steps.at(1),

      axis-style: axisStyle,

      x-label: axis.at(0),
      y-label: axis.at(1),

      x-min: domainMinX,
      {
        for f in functions {
          if f.keys().contains("projection") and f.projection.keys().contains("x") {
            for pX in f.projection.x {
              if (type(pX) == "array") {
                projectionX(f.fn, pX.at(0), pX.at(1))
              } else {
                projectionX(f.fn, pX, "")
              }
            }
          }

          if f.keys().contains("projection") and f.projection.keys().contains("y") {
            for pX in f.projection.y {
              if (type(pX) == "array") {
                projectionY(f.fn, pX.at(0), pX.at(1))
              } else {
                projectionY(f.fn, pX, "")
              }
            }
          }

          let dm = domain

          if f.keys().contains("domain") {
            dm = f.domain
          }

          plot.add(
            f.fn,
            domain: dm,
            style: (stroke: black),
            samples: samples,
          )
        } 
      },
    ) 
  }) 
}
















