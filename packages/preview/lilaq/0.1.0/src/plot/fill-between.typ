#import "../assertations.typ"
#import "../process-styles.typ": merge-strokes, merge-fills
#import "../logic/process-coordinates.typ": filter-nan-points, stepify
#import "../math.typ": minmax
#import "../cycle.typ": prepare-path

#let render-fill-between(plot, transform) = {
  
  let y2 = if plot.y2 == none { (0,)*plot.x.len() } else { plot.y2 }
  
  let (points, runs) = filter-nan-points(plot.x.zip(plot.y1, y2), generate-runs: true)

  show: prepare-path.with(
    fill: plot.style.fill,
    stroke: plot.style.stroke,
    element: polygon
  )
  
  if "make-legend" in plot {
    polygon((0%, 0%), (0%, 100%), (100%, 100%), (100%, 0%))
  } else {
      for run in runs {
      let there = run.map(x => x.slice(0,2))
      let back = run.map(x => (x.at(0), x.at(2)))
      if plot.style.step != none {
        there = stepify(there, step: plot.style.step)
        back = stepify(back, step: plot.style.step)
      }
      

    else {
        place(polygon(
          ..((there + back.rev()).map(p => transform(..p))))
        )
      }
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

  
  /// An array of $y$ data coordinates. The number of $x$ and $y$ coordinates must match. 
  /// -> array
  y1, 

  
  /// An second array of $y$ data coordinates. If this is `none`, the area between the coordinates `y1` and the $x$-axis is filled. 
  /// -> none | array
  y2: none,

  /// How to stroke the area. 
  /// -> none | stroke
  stroke: none,

  /// How to fill the area. 
  /// -> none | color | gradient | tiling
  fill: auto,
  
  /// Step mode for plotting the lines. See @plot.step. 
  /// -> none | start | end | center
  step: none,
  
  /// The legend label for this plot. See @plot.label. 
  /// -> content
  label: none,
  
  /// Determines the $z$ position of this plot in the order of rendered diagram 
  /// objects. See @plot.z-index.  
  /// -> int | float
  z-index: 2,
  
) = {
  
  assertations.assert-matching-data-dimensions(x, x, y1: y1, y2: y2, fn-name: "fill-between")
  
  (
    x: x,
    y1: y1,
    y2: y2,
    label: label,
    style: (
      fill: fill,
      stroke: stroke,
      step: step,
    ),
    plot: render-fill-between,
    xlimits: () => minmax(x),
    ylimits: () => minmax(y1 + y2 + if y2 == none {(0,)}),
    legend: true,
    z-index: z-index
  )
}
