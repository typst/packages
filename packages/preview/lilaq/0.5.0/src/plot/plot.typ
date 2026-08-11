#import "../algorithm/bezier-interpolation.typ": bezier-splines
#import "../logic/limits.typ": plot-lim
#import "../process-styles.typ": merge-strokes, merge-fills
#import "../assertations.typ"
#import "../logic/process-coordinates.typ": filter-nan-points, stepify
#import "../utility.typ": if-auto
#import "../style/styling.typ": mark, prepare-mark, prepare-path
#import "../model/errorbar.typ": errorbar
#import "../logic/time.typ"

#let get-errorbar-stroke(base-stroke) = {
  if base-stroke == auto { return stroke() }
  if base-stroke == none { return stroke() }
  return stroke()
  return stroke(thickness: base-stroke.thickness, paint: base-stroke.paint)
}

// Process error inputs of the form as documented in @plot.xerr. 
#let process-errors(err, n /* basically x.len() */, kind: "x") = {

  if type(err) in (int, float) {
    err = (p: (err,) * n, m: (err,) * n)

  } else if type(err) == dictionary {
    assert(
      "m" in err and "p" in err,
      message: "Error bar dictionaries must contain both \"p\" and \"m\""
    )
    if err.keys().len() != 2 {
      let key = err.keys().filter(x => x not in ("m", "p")).first()
      assert(
        false,
        message: "Errorbar dictionary contains unexpected key \"" + key + "\", expected \"p\" and \"m\""
      )
    }

    if type(err.m) in (int, float) {
      err.m = (err.m,) * n
    } else if type(err.m) == array {
      assert(
        err.m.len() == n,
        message: "The length of `" + kind + "err.m` does not match the number of data points"
      )
    } else {
      assert(false, message: "`" + kind + "err.m` expects a float or an array")
    }
    if type(err.p) in (int, float) {
      err.p = (err.p,) * n
    } else if type(err.p) == array {
      assert(
        err.p.len() == n,
        message: "The length of `" + kind + "err.p` does not match the number of data points"
      )
    } else {
      assert(false, message: "`" + kind + "err.p` expects a float or an array")
    }

  } else if type(err) == array {
    assert(
      err.len() == n, 
      message: "The length of `" + kind + "err` (" + str(err.len()) + ") does not match the number of data points"
    )

    err = err.map(e => {
      if type(e) in (int, float) { (p: e, m: e) }
      else if type(e) == dictionary { 
        assert("p" in e and "m" in e, message: "Errorbar dictionaries must contain both \"m\" and \"p\"")
        e
      }
      else { assert(false, message: "Expected a single uncertainty or a dictionary, found " + repr(e))}
    })
    err = (p: err.map(e => e.p), m: err.map(e => e.m))

  } else {
    assert(
      false, 
      message: "`" + kind + "err` expects a float, an array, or a dictionary with the keys \"p\" and \"m\"."
    )

  }
  err
}


#let render-plot(plot, transform) = {
  let (points, runs) = filter-nan-points(plot.x.zip(plot.y), generate-runs: true)

  if "make-legend" in plot {
    runs = (((0, 0.5), (1, 0.5)),)
    points = ((0.5, 0.5),)
    if plot.yerr != none { plot.yerr = (p: (.5,), m: (.5,),) }
    if plot.xerr != none { plot.xerr = (p: (.25,), m: (.25,)) }
    plot.mark.every = none
  }



  let line = merge-strokes(plot.style.stroke, plot.style.color)
  if line != none {
    show: prepare-path.with(
      stroke: line,
      element: curve
    )

    let (step, smooth) = (plot.style.step, plot.style.smooth)
    if step != none and smooth {
      panic("`step` and `smooth` are mututally exclusive")
    }

    for run in runs {
      if run.len() == 0 { continue }

      if step != none { run = stepify(run, step: step )}
      run = run.map(p => transform(..p))
      if run.len() > 2 and smooth {
        let x = run.map(((x, _)) => x)
        let y = run.map(((_, y)) => y)

        let points = bezier-splines(x, y)

        place(curve(curve.move(points.at(0)), ..points
          .slice(1)
          .chunks(3)
          .map(p => curve.cubic(..p))))
      } else {
        place(curve(
          curve.move(run.first()),
          ..run.slice(1).map(curve.line)
        ))
      }
    }
  }



  let errorbar-stroke = prepare-path.with(
    stroke: merge-strokes(
      ..((dash: "solid"), plot.style.stroke, plot.style.color).filter(x => x != none)
    )
  )


  let filter = {
    let every = plot.mark.every
    if every == 1 { none }
    else if type(every) == int {
      let n = plot.x.len()
      arr => range(calc.quo(n, every)).map(i => arr.at(i * every))
    } else if type(every) == dictionary {
      assertations.assert-dict-keys(every, mandatory: ("n",), optional: ("start", "end"))
      let size = plot.x.len()
      let start = every.at("start", default: 0)
      let end = every.at("end", default: size + 1)
      if end < 0 { end = size + end }
      assert(start >= 0 and start < size, message: "Invalid start index " + str(start))

      arr => range(calc.quo(end - start, every.n))
      .map(i => arr.at(i * every.n + start))
    } else if type(every) == array {
      arr => every.map(i => arr.at(i))
    }
  }

  if filter != none { points = filter(points) }
  

  if plot.xerr != none {
    show: errorbar-stroke

    let (p, m) = plot.xerr
    if filter != none { 
      p = filter(p)
      m = filter(m)
    }
    
    points.zip(p, m).map((((x, y), p, m)) => {
      let (p0, p1) = (transform(x - m, y), transform(x + p, y))

      place(
        dx: p0.at(0),
        dy: p0.at(1),
        box(width: p1.at(0) - p0.at(0), errorbar(kind: "x"))
      )
      
    }).join()
  }
  
  if plot.yerr != none {
    show: errorbar-stroke
    
    let (p, m) = plot.yerr
    if filter != none { 
      p = filter(p)
      m = filter(m)
    }

    points.zip(p, m).map((((x, y), p, m)) => {
      let (p0, p1) = (transform(x, y - m), transform(x, y + p))
      let (y0, y1) = (p0.at(1), p1.at(1)).sorted()

      place(
        dx: p1.at(0),
        dy: y0,
        box(height: y1 - y0, errorbar(kind: "y"))
      )
      
    }).join()
  }
  

  
  show: prepare-mark.with(
    func: plot.mark.mark, 
    color: plot.style.color,
    fill: plot.mark.fill,
    size: plot.mark.size
  )
  
  let marker = mark()
  let transformed-points = points.map(p => transform(..p))
  transformed-points.map(((x, y)) => place(dx: x, dy: y, marker)).join()

}




/// Standard plotting method for 2d data with lines and/or marks and optional  
/// error bars. Points where the $x$ or $y$ coordinate is `nan` are skipped. 
/// 
/// ```example
/// #let x = lq.linspace(0, 10)
/// 
/// #lq.diagram(
///   lq.plot(x, x => calc.sin(x + 0.541))
/// )
/// ```
/// The $y$ coordinates can be given either as an array or as a function to be
/// evaluated for all $x$ coordinates. 
/// 
/// By default, the line and mark style is determined by the current 
/// @diagram.cycle. However, they can be configured per plot with the options 
/// @plot.color, @plot.mark,
/// and @plot.stroke. 
/// 
/// This function is also intended for creating plots with error bars. 
/// Error bars can be styled through the @errorbar type. 
/// 
/// ```example
/// #lq.diagram(
///   lq.plot(
///     range(8), (3, 6, 2, 6, 5, 9, 0, 4),
///     yerr: (1, 1, .7, .8, .2, .6, .5, 1),
///     stroke: none, 
///     mark: "star",
///     mark-size: 6pt
///   )
/// )
/// ```
#let plot(
  
  /// An array of $x$ coordinates. Data coordinates need to be of type `int` or `float`. 
  /// -> array
  x, 
  
  /// Specifies either an array of $y$ coordinates or a function that takes an
  /// `x` value and returns a corresponding `y` coordinate. The number of $x$ 
  /// and $y$ coordinates must match. 
  /// -> array | function
  y, 
  
  /// Optional errors/uncertainties for $x$ coordinates. Symmetric errors can
  /// be specified as a
  /// - a constant (e.g., `xerr: 1.5`) or
  /// - an array with the same length as @plot.x for individual errors per 
  ///   data point (e.g., `xerr: (0.5, 1, 1.5)`). 
  /// 
  /// Asymmetric errors can be given as
  /// - a dictionary with the keys `p` (plus) and `m` (minus) with either a 
  ///   constant value or arrays with the same length as @plot.x (e.g., 
  ///   `xerr: (p: 1, m: 2)`) or
  /// - an array of dictionaries per data point, each filled with single `p` 
  ///   and `m` values (e.g., `xerr: ((p: 1, m: 2), (p: 2, m: 3))`). 
  /// 
  /// The look of the error bars can be controlled through the type @errorbar. 
  /// -> none | array | dictionary
  xerr: none,
  
  /// Optional errors/uncertainties for $y$ coordinates. See @plot.xerr. 
  /// 
  /// The look of the error bars can be controlled through @errorbar. 
  /// -> none | array
  yerr: none,
  
  /// Combined color for line and marks. See also the parameters @plot.stroke and 
  /// @plot.mark-fill which take precedence over `color`, if set. 
  /// -> auto | color
  color: auto,
  
  /// The line style to use for this plot (takes precedence over @plot.color). 
  /// -> auto | stroke
  stroke: auto, 
  
  /// The mark to use to mark data points. This may either be a mark (such as 
  /// `lq.mark.x`) or a registered mark string, see @mark. 
  /// -> auto | none | lq.mark | string
  mark: auto, 
  
  /// Size of the marks. For variable-size mark plots, use the plot type @scatter. 
  /// -> auto | length
  mark-size: auto,
  
  /// Color of the marks (takes precedence over @plot.color). 
  /// TODO: this parameter should eventually be removed. Instead one
  /// would be able to set mark color and stroke through
  /// ```
  /// #lq.diagram(
  ///  plot(..), // normal plot
  ///  {
  ///    set mark(fill: red, stroke: black)
  ///    plot(..)
  ///  }
  ///)
  /// ```
  /// This again reduces the API. `mark.size` however is common enough to deserve 
  /// its own parameter. 
  /// -> auto | color
  mark-color: auto,
  
  /// Step mode for plotting the lines. 
  /// - `none`: Consecutive data points are connected with a straight line. 
  /// - `start`: The interval $(x_{i-1}, x_i]$ takes the value of $x_i$. 
  /// - `center`: The value switches half-way between consecutive $x$ positions. 
  /// - `end`: The interval $[x_i, x_{i+1})$ takes the value of $x_i$. 
  ///
  /// #details[
  ///   ```example
  ///   #import lilaq
  ///
  ///   #lq.diagram(
  ///     lq.plot(
  ///       range(8), (3,6,2,6,5,9,0,4),
  ///       step: center
  ///     )
  ///   )
  ///   ```
  /// ]
  /// -> none | start | end | center
  step: none,

  /// Interpolates the data set using Bézier splines instead of connecting the points with straight lines.
  ///
  /// Note: If two or fewer points are given, linear interpolation is used.
  ///
  /// #details[
  ///   ```example
  ///   #import lilaq
  ///   #lq.diagram(
  ///     lq.plot(
  ///       range(8), (3, 6, 2, 6, 5, 9, 0, 4),
  ///       smooth: true
  ///     )
  ///   )
  ///   ```
  /// ]
  ///
  /// -> bool
  smooth: false,

  /// Specifies the interval of marks to plot. This can be used to skip
  /// marks while still drawing lines between all points.
  /// - `none`: All marks are plotted.
  /// - `int`: Every $n$-th mark is plotted.
  /// - `array`: All marks with the given indices are plotted.
  /// - `dict`: A dictionary with the keys `n`, `start` (start index), and 
  ///   `end` (end index, negative indices count from the end) can be used 
  ///   to specify a range of marks to plot.
  /// 
  /// #details[
  ///   ```example
  ///   #lq.diagram(
  ///     lq.plot(
  ///       range(20),
  ///       range(20).map(x => x*x),
  ///       every: 4
  ///     )
  ///   )
  ///   ```
  /// ]
  /// -> none | int | array | dict
  every: none,
  
  /// The legend label for this plot. If not given, the plot will not appear in the 
  /// legend. 
  /// -> any
  label: none,
  
  /// Whether to clip the plot to the data area. This is usually a good idea for plots 
  /// with lines but it does also clip part of marks that lie right on an axis. 
  /// #details[
  ///   Comparison between clipped and non-clipped plot. 
  ///   ```example
  ///   #lq.diagram(
  ///     margin: 0%,
  ///     lq.plot(
  ///       (1, 2, 3), (2.5, 1.9, 1.5), 
  ///       mark: "o", 
  ///     ),
  ///     lq.plot(
  ///       (1, 2, 3), (1, 2.1, 3), 
  ///       mark: "o", 
  ///       clip: false
  ///     )
  ///   )
  ///   ```
  /// ]
  /// -> bool
  clip: true,
  
  /// Specifies the $z$ position of this plot in the order of rendered diagram 
  /// objects. This makes it also possible to render plots in front of the axes 
  /// which have a z-index of `20`. 
  /// #details[
  ///   In this example, the points are listed before the bars in the legend but 
  ///   they are still drawn in front of the bars. 
  ///   ```example
  ///   #lq.diagram(
  ///     legend: (position: bottom),
  ///     lq.plot(
  ///       (1, 2, 3, 4), (2, 3, 4, 5),
  ///       mark-size: 10pt,
  ///       z-index: 2.01,
  ///       label: [Points],
  ///     ),
  ///     lq.bar(
  ///       (1, 2, 3, 4), (2, 3, 4, 5),
  ///       label: [Bars],
  ///     )
  ///   )
  ///   ```
  /// ]
  /// -> int | float
  z-index: 2,
  
) = {
  if type(y) == function {
    y = x.map(y)
  }

  let datetime-axes = (:)
  if type(x.at(0, default: 0)) == datetime {
    x = time.to-seconds(..x)
    datetime-axes.x = true
  }
  if type(y.at(0, default: 0)) == datetime {
    y = time.to-seconds(..y)
    datetime-axes.y = true
  }

  assertations.assert-matching-data-dimensions(x, y, fn-name: "plot")
  
  assert(step in (none, start, end, center))

  if xerr != none { xerr = process-errors(xerr, x.len(), kind: "x") }
  if yerr != none { yerr = process-errors(yerr, x.len(), kind: "y") }


  (
    x: x,
    y: y,
    xerr: xerr,
    yerr: yerr,
    label: label,
    mark: (
      mark: mark,
      fill: mark-color,
      size: mark-size,
      every: every
    ),
    style: (
      stroke: stroke,
      color: color,
      step: step,
      smooth: smooth
    ),
    plot: render-plot,
    xlimits: () => plot-lim(x, err: xerr),
    ylimits: () => plot-lim(y, err: yerr),
    datetime: datetime-axes,
    legend: true,
    ignores-cycle: false,
    clip: clip,
    z-index: z-index
  )
}
