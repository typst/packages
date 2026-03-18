
#import "../process-styles.typ": merge-strokes
#import "../math.typ": minmax




#let render-vlines(plot, transform) = {
  let min = plot.min
  let max = plot.max

  if "make-legend" in plot {
    return std.line(length: 100%, stroke: plot.style.line)
  }

  if min == auto { min = 100% }
  else {
    (_, min) = transform(1, min)
  }
  if max == auto { max = 0% }
  else {
    (_, max) = transform(1, max)
  }

  for x in plot.x {
    let (xx, _) = transform(x, 1)
    place(line(start: (xx, min), end: (xx, max), stroke: plot.style.line))
  }
}



/// Draws a set of vertical lines into the diagram. 
/// ```example
/// #lq.diagram(
///   ylim: (0, 7),
///   lq.vlines(1, 1.1, line: teal, label: "Indefinite"),
///   lq.vlines(2, line: blue, min: 2, label: "Fixed start"),
///   lq.vlines(3, line: purple, max: 2, label: "Fixed end"),
///   lq.vlines(4, line: red, min: 1, max: 3, label: "Fixed"),
/// )
/// ```
#let vlines(

  /// The $x$ coordinate(s) of one or more vertical lines to draw. 
  /// -> int | float
  ..x, 

  /// The beginning of the line as $y$ coordinate. If set to `auto`, the line will 
  /// always start at the bottom of the diagram. 
  /// -> auto | int | float
  min: auto,
  
  /// The end of the line as $y$ coordinate. If set to `auto`, the line will 
  /// always end at the top of the diagram. 
  /// -> auto | int | float
  max: auto,

  /// How to stroke the lines
  /// -> stroke
  line: blue,
  
  /// The legend label for this plot. See @plot.label. 
  /// -> content
  label: none,
  
  /// Determines the $z$ position of this plot in the order of rendered diagram
  /// objects.  See @plot.z-index.  
  /// -> int | float
  z-index: 2,
  
) = {
  x = x.pos()

  line = merge-strokes(line)

  let ylimits = none
  if min != auto {
    ylimits = (min, min)
  }
  if max != auto {
    ylimits = (if min == auto { max } else { min }, max)
  }

  (
    x: x,
    min: min, 
    max: max,
    label: label,
    style: (
      line: line,
    ),
    plot: render-vlines,
    xlimits: () => minmax(x),
    ylimits: () => ylimits,
    legend: true,
    z-index: z-index
  )
}
