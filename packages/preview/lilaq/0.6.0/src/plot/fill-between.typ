#import "../assertations.typ"
#import "../algorithm/bezier-interpolation.typ": bezier-splines
#import "../process-styles.typ": merge-strokes, merge-fills
#import "../logic/process-coordinates.typ": filter-nan-points, stepify
#import "../logic/time.typ"
#import "../math.typ": minmax
#import "../style/styling.typ": prepare-path


#let render-fill-between(plot, transform) = {
  
  let y2 = if plot.y2 == none { (0,)*plot.x.len() } else { plot.y2 }
  
  let (points, runs) = filter-nan-points(plot.x.zip(plot.y1, y2), generate-runs: true)

  show: prepare-path.with(
    fill: plot.style.fill,
    stroke: plot.style.stroke,
    element: curve
  )
  
  if "make-legend" in plot {
    curve(curve.move((0%, 0%)), curve.line((0%, 100%)), curve.line((100%, 100%)), curve.line((100%, 0%)), curve.close())
  } else {
    for run in runs {
      if run.len() == 0 { continue }
      
      let run-y1 = run.map(((x, y1, y2)) => transform(x, y1))
      let run-y2 = run.map(((x, y1, y2)) => transform(x, y2))

      let (step, smooth) = (plot.style.step, plot.style.smooth)
    
      if plot.style.step != none {
        run-y1 = stepify(run-y1, step: plot.style.step)
        run-y2 = stepify(run-y2, step: plot.style.step)
      }

      let segments = if run.len() > 2 and smooth {
        run-y1 = bezier-splines(..array.zip(..run-y1))
        run-y2 = bezier-splines(..array.zip(..run-y2)).rev()
        (
          curve.move(run-y1.first()),
          ..run-y1
            .slice(1)
            .chunks(3)
            .map(p => curve.cubic(..p)),
          curve.line(run-y2.first()),
          ..run-y2
            .slice(1)
            .chunks(3)
            .map(p => curve.cubic(..p)),
        )
      } else {
        let cycle = (run-y1 + run-y2.rev())
        (
          curve.move(cycle.first()),
          ..cycle.slice(1).map(curve.line),
        )
      }
    
      place(
        curve(..segments, curve.close(mode: "straight"))
      )
    }
  }
}


/// Fills the area between two graphs. 
/// 
/// ```example
/// #let xs = lq.linspace(-1, 2)
/// #lq.diagram(
///   lq.fill-between(
///     xs, 
///     xs.map(calc.sin),
///     y2: xs.map(calc.cos),
///   )
/// )
/// ```
/// or the area between one graph and the $x$-axis:
/// ```example
/// #let xs = lq.linspace(0, 3, num: 80)
/// #lq.diagram(
///   lq.fill-between(
///     label: [Maxwell-distribution],
///     xs, 
///     xs.map(x => x*x*calc.exp(-x*x*1.3)),
///   )
/// )
/// ```
#let fill-between(

  /// An array of $x$ data coordinates. Data coordinates need to be of type `int` or `float`. 
  /// -> array
  x, 
  
  /// Specifies either an array of $y$ coordinates or a function that takes an
  /// `x` value and returns a corresponding `y` coordinate. The number of $x$ 
  /// and $y$ coordinates must match. 
  /// -> array | function
  y1, 
  
  /// An second array (or function) of $y$ data coordinates. If this is `none`, 
  /// the area between the coordinates `y1` and the $x$-axis is filled. 
  /// -> none | array | function
  y2: none,

  /// How to stroke the area. 
  /// -> auto | none | stroke
  stroke: none,

  /// How to fill the area. 
  /// -> auto | none | color | gradient | tiling
  fill: auto,
  
  /// Step mode for plotting the lines. See @plot.step. 
  /// -> none | start | end | center
  step: none,
  
  /// Interpolates the data set using Bézier splines instead of connecting the
  /// points with straight lines. Also see @plot.smooth. 
  ///
  /// -> bool
  smooth: false,

  /// The legend label for this plot. See @plot.label. 
  /// -> content
  label: none,
  
  /// Determines the $z$ position of this plot in the order of rendered diagram 
  /// objects. See @plot.z-index.  
  /// -> int | float
  z-index: 2,
  
) = {  
  if type(y1) == function {
    y1 = x.map(y1)
  }
  if type(y2) == function {
    y2 = x.map(y2)
  }

  let datetime-axes = (:)
  if type(x.at(0, default: 0)) == datetime {
    x = time.to-seconds(..x)
    datetime-axes.x = true
  }
  
  assertations.assert-matching-data-dimensions(x, x, y1: y1, y2: y2, fn-name: "fill-between")
  assert(step in (none, start, end, center))


  if step != none and smooth {
    panic("`step` and `smooth` are mututally exclusive")
  }

  (
    x: x,
    y1: y1,
    y2: y2,
    label: label,
    style: (
      fill: fill,
      stroke: stroke,
      step: step,
      smooth: smooth,
    ),
    plot: render-fill-between,
    xlimits: () => minmax(x),
    ylimits: () => minmax(y1 + y2 + if y2 == none {(0,)}),
    datetime: datetime-axes,
    legend: true,
    ignores-cycle: false,
    z-index: z-index
  )
}
