#import "@preview/cetz-plot:0.1.2"
#import "util.typ": _validate-partition

/// Illustrate the chained trapezoidal rule of a function, and optionally plot the
/// function.
///
/// - fn (function): The function to illustrate the chained trapezoidal rule of.
/// - domain (array): Tuple of the domain of `fn`. If a tuple value is `auto`, that
///   value is set to `start`/`end`.
/// - start (number): The starting point for the trapezoids. Used only if
///   `partition` is not a valid array; otherwise, the first value of `partition`
///   is used.
/// - end (number): The ending point for the trapezoids. Used only if `partition`
///   is not a valid array; otherwise, the last value of `partition` is used.
/// - n (number): Number of trapezoids. Used only if `partition` is not a valid
///   array; otherwise, the number of trapezoids is determined by the length of
///   `partition`.
/// - partition (array, none): (optional) Array of partition points. If valid, it
///   overrides `start`, `end`, and `n`; otherwise, equal partitions are generated
///   from `start`, `end`, and `n`.
/// - transparency (number): Transparency fill of trapezoids.
/// - dot-radius (number): Radius of dots.
/// - plot (boolean): Whether to add plot of the function.
/// - plot-grid (boolean): Show grid on plot.
/// - plot-x-tick-step (number): X tick step of plot.
/// - plot-y-tick-step (number): Y tick step of plot.
/// - positive-color (color): Color of positive trapezoids.
/// - negative-color (color): Color of negative trapezoids.
/// - plot-line-color (color): Color of plotted line.
/// - size (tuple): The width and height of the plot area, given as a tuple
///   `(width, height)`. Controls the overall size of the rendered Riemann sum
///   and function plot.
#let trapezoidal(
  fn,
  start: 0,
  end: 10,
  domain: (auto, auto),
  n: 10,
  partition: none,
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
  // check if partition is valid
  let is-valid-partition = _validate-partition(partition)
  if is-valid-partition {
    start = partition.at(0)
    end = partition.at(-1)
    n = partition.len() - 1
  } else {
    let delta-x = (end - start) / n
    partition = range(0, n + 1).map(k => start + delta-x * k)
  }

  // Adjust the function domain if set to auto
  if domain.at(0) == auto { domain.at(0) = start }
  if domain.at(1) == auto { domain.at(1) = end }

  // calculate data points
  let data-points = partition.zip(partition.map(fn))

  let col-trans(color, opacity) = {
    let space = color.space()
    space(..color.components(alpha: false), opacity)
  }

  let positive-trapezoid-style = (
    fill: col-trans(positive-color.lighten(30%), transparency),
    stroke: col-trans(positive-color.darken(30%), 90%) + 1.1pt
  )
  let negative-trapezoid-style = (
    : ..positive-trapezoid-style,
    fill: col-trans(negative-color.lighten(30%), transparency),
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

  cetz-plot.plot.plot(
    size: size,
    x-grid: plot-grid,
    y-grid: plot-grid,
    x-label: $x$,
    y-label: $y$,
    axis-style: if plot { "school-book" } else { none },
    x-tick-step: plot-x-tick-step,
    y-tick-step: plot-y-tick-step,
    {
      // plot curve
      if plot {
        cetz-plot.plot.add(
          domain: domain,
          x => fn(x),
          style: (stroke: (paint: plot-line-color, thickness: 1.5pt, dash: "dashed"))
        )
      }

      // then plot trapezoids
      for k in range(n) {
        let (x0, y0) = data-points.at(k)
        let (x1, y1) = data-points.at(k + 1)
        let subdata = ((x0, y0), (x1, y1))
        if (y0 >= 0 and y1 < 0) or (y0 < 0 and y1 >= 0) {
          let x-intersect = x0 + (x1 - x0) * (0 - y0) / (y1 - y0)
          subdata.insert(1, (x-intersect, 0))
        }
        for p in range(subdata.len() - 1) {
          let (xl, yl) = subdata.at(p)
          let (xr, yr) = subdata.at(p + 1)
          cetz-plot.plot.add(((xl, 0), (xl, yl), (xr, yr), (xr, 0)),
            style: if yl > 0 or yr > 0 { positive-trapezoid-style } else { negative-trapezoid-style },
            fill: true
          )
        }
      }

      // plot dots
      for point in data-points {
        let (x, y) = point
        cetz-plot.plot.add((point,),
          mark: "o",
          style: (stroke: none),
          mark-size: dot-radius,
          mark-style: if y >= 0 { positive-dot-style } else { negative-dot-style }
        )
      }
    }
  )
}
