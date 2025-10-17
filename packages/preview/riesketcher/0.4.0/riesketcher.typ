#import "@preview/cetz-plot:0.1.2"
#import "util.typ": _validate-partition, _validate-tagged-partition

/// Draw a Riemann sum of a function, and optionally plot the function.
///
/// - fn (function): The function to draw a Riemann sum of.
/// - domain (array): Tuple of the domain of `fn`. If a tuple value is `auto`, that
///   value is set to `start`/`end`.
/// - start (number): The starting point for the bars. Used only if `partition`
///   is not a valid array; otherwise, the first value of `partition` is used.
/// - end (number): The ending point for the bars. Used only if `partition` is
///   not a valid array; otherwise, the last value of `partition` is used.
/// - n (number): Number of bars. Used only if `partition` is not a valid array;
///   otherwise, the number of bars is determined by the length of `partition`.
/// - method (string): Determines where the sample points for bar heights are
///   taken (`left`, `mid`/`midpoint`, or `right`). Used only if `tags` is not a
///   valid array; otherwise, bar heights are taken from `tags`.
/// - partition (array, none): (optional) Array of partition points. If valid, it
///   overrides `start`, `end`, and `n`; otherwise, equal partitions are
///   generated from `start`, `end`, and `n`.
/// - tags (array, none): (optional) Array of sample points for bar heights. If
///   valid, it overrides `method`; otherwise, sample points are determined by
///   `method`.
/// - transparency (number): Transparency fill of bars.
/// - dot-radius (number): Radius of dots.
/// - plot (boolean): Whether to add plot of the function.
/// - plot-grid (boolean): Show grid on plot.
/// - plot-x-tick-step (number): X tick step of plot.
/// - plot-y-tick-step (number): Y tick step of plot.
/// - positive-color (color): Color of positive bars.
/// - negative-color (color): Color of negative bars.
/// - plot-line-color (color): Color of plotted line.
/// - size (tuple): The width and height of the plot area, given as a tuple
///   `(width, height)`. Controls the overall size of the rendered Riemann sum
///   and function plot.
#let riesketcher(
  fn,
  start: 0,
  end: 10,
  domain: (auto, auto),
  n: 10,
  partition: none,
  tags: none,
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
  let delta-x = 0  // store fallback bar width if partition is invalid

  // check if partition is valid
  let is-valid-partition = _validate-partition(partition)
  if is-valid-partition {
    start = partition.at(0)
    end = partition.at(-1)
    n = partition.len() - 1
  } else {
    delta-x = (end - start) / n
    partition = range(0, n + 1).map(k => start + delta-x * k)
  }

  // Adjust the function domain if set to auto
  if domain.at(0) == auto { domain.at(0) = start }
  if domain.at(1) == auto { domain.at(1) = end }

  // calculate bar widths
  let bar-widths = if is-valid-partition {
    range(0, partition.len() - 1).map(k => partition.at(k + 1) - partition.at(k))
  } else {
    range(0, n).map(x => delta-x)
  }

  // check if tags are valid
  let is-valid-tags = _validate-tagged-partition(partition, tags)

  // calculate bar heights
  let bar-y = none
  if is-valid-tags {
    bar-y = tags.zip(tags.map(fn))
  } else {
    let horizontal-hand-offset = 0%
    if method == "right" {
      horizontal-hand-offset = 100%
    }
    else if method == "mid" or method == "midpoint" {
      horizontal-hand-offset = 50%
    }
    bar-y = range(0, n).map(k => {
      let x = partition.at(k) + bar-widths.at(k) * horizontal-hand-offset / 100%
      (x, fn(x))
    })
  }

  let col-trans(color, opacity) = {
    let space = color.space()
    space(..color.components(alpha: false), opacity)
  }

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
      for k in range(0, n) {
        let x = partition.at(k)
        let y = bar-y.at(k).at(1)
        cetz-plot.plot.add-bar(((x, y),),
          bar-width: bar-widths.at(k),
          bar-position: "start",
          style: if y >= 0 { positive-bar-style } else { negative-bar-style })
      }

      if plot {
        cetz-plot.plot.add(
          domain: domain,
          x => fn(x),
          style: (stroke: plot-line-color + 1.5pt))
      }

      for k in range(0, n) {
        let (x, y) = bar-y.at(k)
        cetz-plot.plot.add(((x, y),),
          mark: "o",
          style: (stroke: none),
          mark-size: dot-radius,
          mark-style: if y >= 0 { positive-dot-style } else { negative-dot-style })
      }
    }
  )
}
