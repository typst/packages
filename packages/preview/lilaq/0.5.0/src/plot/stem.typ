#import "../assertations.typ"
#import "../logic/limits.typ": bar-lim
#import "../logic/time.typ"
#import "../process-styles.typ":  merge-strokes, merge-fills
#import "../logic/process-coordinates.typ": filter-nan-points
#import "../math.typ": minmax
#import "../utility.typ": if-auto
#import "../style/styling.typ": mark, prepare-mark, prepare-line

#let render-stem(plot, transform) = {
  let marker = plot.style.mark
  let marker = mark()
  
  
  let (xmin, xmax) = (plot.xlimits)()
  
  if "make-legend" in plot {
    xmin = 0
    xmax = 1
    plot.x = (.5,)
    plot.y = (.8,)
    plot.base = 0
  }
  
  let (x1, y0) = transform(xmin, plot.base)
  let (x2, y0) = transform(xmax, plot.base)
  let points = filter-nan-points(plot.x.zip(plot.y)).map(p => transform(..p))

  show: prepare-mark.with(
    func: plot.style.mark, 
    color: merge-fills(plot.style.color),
    size: plot.style.mark-size
  )
  
    
  {
    
    
    show: prepare-line.with(
      stroke: merge-strokes(plot.style.stroke, plot.style.color)
    )
    
    

    points.map(((x, y)) => place(line(start: (x, y0), end: (x, y)))).join()
    
  }

  if plot.style.base-stroke != none {
    set line(stroke: (cap: "square"))
    place(line(
      start: (x1, y0), 
      end: (x2, y0), 
      stroke: plot.style.base-stroke
    ))
  }
  
  points.map(((x, y)) => place(dx: x, dy: y, marker)).join()
}




/// Creates a vertical stem plot. 
/// 
/// ```example
/// #let x = lq.linspace(0, 10, num: 30)
///   
/// #lq.diagram(
///   lq.stem(
///     x, 
///     x.map(calc.cos), 
///     color: orange, 
///     mark: "d",
///     base: -0.25,
///     base-stroke: black,
///   )
/// )
/// ```
///
/// Also see @hstem for horizontal stem plots. 
#let stem(

  /// An array of $x$ coordinates. 
  /// -> array
  x, 
  
  /// Specifies either an array of $y$ coordinates or a function that takes an
  /// `x` value and returns a corresponding `y` coordinate. The number of $x$ 
  /// and $y$ coordinates must match. 
  /// -> array | function
  y, 

  /// Combined color for line and marks. See also the parameter @stem.line 
  /// which takes precedence over `color`, if set. 
  /// -> auto | color
  color: auto,
  
  /// The line style to use for this plot (takes precedence over @stem.color). 
  /// -> auto | stroke
  stroke: auto, 
  
  /// The mark to use to mark data points. See @plot.mark. 
  /// -> auto | none | lq.mark | str
  mark: auto, 
  
  /// Size of the marks. 
  /// -> auto | length
  mark-size: auto,
  
  /// Defines the $y$ coordinate of the base line.
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
  
  assertations.assert-matching-data-dimensions(x, y, fn-name: "stem")

  

  (
    x: x,
    y: y,
    base: base,
    label: label,
    style: (
      mark: mark,
      color: color,
      mark-size: mark-size,
      stroke: merge-strokes(stroke, color),
      base-stroke: base-stroke
    ),
    plot: render-stem,
    xlimits: () => minmax(x),
    ylimits: () => bar-lim(y, (base,)),
    datetime: datetime-axes,
    legend: true,
    ignores-cycle: false,
    clip: clip,
    z-index: z-index
  )
}

