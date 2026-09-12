#import "/src/cetz.typ": draw

/// Coordinate resolve that just forwards (plot: (x, y)) coordinates
/// as (x, y).
#let stup-resolver(ctx, point) = {
  if type(point) == dictionary and "plot" in point {
    return point.plot
  }

  return point
}

/// Plot axis coordinate resolver
let default-resolver(ctx, point) = {
  if type(point) == dictionary and "plot" in point {
    let names = point.at("axes", default: ("x", "y"))

    let p = point.plot
    return names.map(name => ctx.cetz-plot-axes.at(name)).enumerate().map(((i, ax)) => {
      (ax.to)(p.at(i))
    })
  }

  return c
}
