#import "../process-styles.typ": merge-strokes
#import "../math.typ": minmax
#import "../assertations.typ"
#import "../logic/time.typ"



#let render-hlines(plot, transform) = {
  let min = plot.min
  let max = plot.max

  if "make-legend" in plot {
    return line(length: 100%, stroke: plot.style.stroke)
  }

  if min == auto { min = 0% }
  else {
    (min, _) = transform(min, 1)
  }
  if max == auto { max = 100% }
  else {
    (max, _) = transform(max, 1)
  }

  for y in plot.y {
    let (_, yy) = transform(1, y)
    place(line(start: (min, yy), end: (max, yy), stroke: plot.style.stroke))
  }
}



/// Draws a set of horizontal lines into the diagram.
/// 
/// By default, the lines are indefinite and span the entire width of the
/// diagram, independent of the limits, however, through `min` and `max`, 
/// beginning and end of the line can be fixed to an $x$ coordinate, 
/// respectively. 
/// ```example
/// #lq.diagram(
///   xlim: (0, 7),
///   lq.hlines(1, 1.1, stroke: teal, label: "Indefinite"),
///   lq.hlines(2, stroke: blue, min: 2, label: "Fixed start"),
///   lq.hlines(3, stroke: purple, max: 2, label: "Fixed end"),
///   lq.hlines(4, stroke: red, min: 1, max: 3, label: "Fixed"),
/// ) 
/// ```
#let hlines(

  /// The $y$ coordinate(s) of one or more horizontal lines to draw. 
  /// -> int | float
  ..y, 

  /// The beginning of the line as an $x$ coordinate. If set to `auto`, the line will 
  /// always start at the left edge of the diagram. 
  /// -> auto | int | float
  min: auto,
  
  /// The end of the line as an $x$ coordinate. If set to `auto`, the line will 
  /// always end at the right edge of the diagram. 
  /// -> auto | int | float
  max: auto,

  /// How to stroke the lines. 
  /// -> stroke
  stroke: black,
  
  /// The legend label for this plot. See @plot.label. 
  /// -> content
  label: none,
  
  /// Determines the $z$ position of this plot in the order of rendered diagram
  /// objects. See @plot.z-index.  
  /// -> int | float
  z-index: 2,
  
) = {
  assertations.assert-no-named(y)
  y = y.pos()
  
  let datetime-axes = (:)
  if type(y.at(0, default: 0)) == datetime {
    y = time.to-seconds(..y)
    datetime-axes.y = true
  }

  stroke = merge-strokes(stroke)

  let xlimits = none
  if min != auto {
    xlimits = (min, min)
  }
  if max != auto {
    xlimits = (if min == auto { max } else { min }, max)
  }

  (
    y: y,
    label: label,
    min: min, 
    max: max,
    style: (
      stroke: stroke,
    ),
    plot: render-hlines,
    xlimits: () => xlimits,
    ylimits: () => minmax(y),
    datetime: datetime-axes,
    legend: true,
    z-index: z-index
  )
}

