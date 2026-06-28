#import "../assertations.typ"
#import "../logic/limits.typ": bar-lim
#import "../process-styles.typ": merge-strokes, merge-fills
#import "../logic/process-coordinates.typ": filter-nan-points
#import "../math.typ": minmax
#import "../utility.typ": if-auto
#import "../style/styling.typ": mark, prepare-mark, prepare-line



#let render-hstem(plot, transform) = {
  let marker = mark()
  set line(stroke: plot.style.stroke)

  let (ymin, ymax) = (plot.ylimits)()
  
  if "make-legend" in plot {
    ymin = 0
    ymax = 1
    plot.x = (.75,)
    plot.y = (.5,)
    plot.base = .25
  }
  
  let (x0, y1) = transform(plot.base, ymin)
  let (x0, y2) = transform(plot.base, ymax)

  

  
  show: prepare-mark.with(
    func: plot.style.mark, 
    color: merge-fills(plot.style.color),
    size: plot.style.mark-size
  )
  show: prepare-line.with(
    stroke: merge-strokes(plot.style.stroke, plot.style.color)
  )

  let points = filter-nan-points(plot.x.zip(plot.y)).map(p => transform(..p))

  points.map(((x, y)) => place(line(start: (x0, y), end: (x, y)))).join()
  
  if plot.style.base-stroke != none {
    set line(stroke: (cap: "square"))
    place(line(
      start: (x0, y1), 
      end: (x0, y2), 
      stroke: plot.style.base-stroke
    ))
  }
  
  points.map(((x, y)) => place(dx: x, dy: y, marker)).join()
}


/// Creates a horizontal stem plot. 
/// ```example
/// #let ys = lq.linspace(0, 10, num: 20)
///   
/// #lq.diagram( 
///   lq.hstem(
///     ys.map(calc.cos), 
///     ys, 
///     color: orange, 
///     mark: "d",
///     base-stroke: black,
///   )
/// ) 
/// ```
///
/// Also see @stem for vertical stem plots. 
#let hstem(

  /// An array of $x$ coordinates. 
  /// -> array
  x, 
  
  /// An array of $y$ coordinates. The number of $x$ and $y$ coordinates 
  /// must match. 
  /// -> array
  y, 

  /// Combined color for line and marks. See also the parameters @hstem.line 
  /// and @hstem.mark-color which take precedence over `color`, if set. 
  /// -> auto | color
  color: auto,
  
  /// The line style to use for this plot (takes precedence over @hstem.color). 
  /// -> auto | stroke
  stroke: auto, 
  
  /// The mark to use to mark data points. See @plot.mark. 
  /// -> auto | none | lq.mark | str
  mark: auto, 
  
  /// Size of the marks. 
  /// -> length
  mark-size: 5pt,
  
  /// Color of the marks (takes precedence over @hstem.color). 
  /// -> auto | color
  mark-color: auto,
  
  /// Defines the $x$ coordinate of the base line.
  /// -> int | float
  base: 0,

  /// How to stroke the base line. 
  /// -> stroke
  base-stroke: red,
  
  /// The legend label for this plot. See @plot.label. 
  /// -> content
  label: none,
  
  /// Whether to clip the plot to the data area. See @plot.clip. 
  /// -> bool
  clip: true,
  
  /// Determines the $z$ position of this plot in the order of rendered diagram
  /// objects. See @plot.z-index.  
  /// -> int | float
  z-index: 2,
  
) = {
  assertations.assert-matching-data-dimensions(x, y, fn-name: "hstem")
  (
    x: x,
    y: y,
    base: base,
    label: label,
    style: (
      color: color,
      mark: mark,
      mark-size: mark-size,
      mark-color: merge-fills(mark-color, color),
      stroke: merge-strokes(stroke, color),
      base-stroke: base-stroke
    ),
    plot: render-hstem,
    xlimits: () => bar-lim(x, (base,)),
    ylimits: () => minmax(y),
    legend: true,
    ignores-cycle: false,
    clip: clip,
    z-index: z-index
  )
}
