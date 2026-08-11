#import "../assertations.typ"
#import "../logic/limits.typ": compute-primitive-limits
#import "../logic/process-coordinates.typ": all-data-coordinates, convert-rect
#import "../process-styles.typ": twod-ify-alignment


/// Plots a rectangle or square with origin `(x, y)`. The origin coordinates as well
/// as width and height can either be given as 
/// - data coordinates (`int` or `float`),
/// - or absolute coordinates from the top left corner of the data area (`length`),
/// - or in percent relative to the data area (`ratio`),
/// - or a combination of the latter two (`relative`).  
/// 
/// Note that coordinate types can also be mixed (e.g., a length for `x` and a scalar for `y`).
/// 
/// For example in order to access the center, you can write `(50%, 50%)`. 
/// 
/// ```example
/// #lq.diagram(
///   width: 3cm, height: 3cm,
///   lq.rect(2, 2, width: 10, height: 4, fill: yellow),
///   lq.rect(10, 4, width: 4, height: 4, fill: red),
///   lq.rect(50%, 50%, width: 45%, height: 45%, stroke: blue)
/// )
/// ```
/// 
#let rect(
  
  /// The x coordinate of the origin.
  /// -> float | relative 
  x, 

  /// The y coordinate of the origin.
  /// -> float | relative 
  y,

  /// The rectangle's width. 
  /// -> auto | float | relative
  width: auto,

  /// The rectangle's height. 
  /// -> auto | float | relative
  height: auto, 

  /// How to align the rectangle at the origin. 
  /// -> alignment
  align: left + top,

  /// How to fill the rectangle.  
  /// -> none | color | gradient | tiling
  fill: none,

  /// How to stroke the rectangle.
  /// -> auto | none | stroke
  stroke: auto,

  /// The corner rounding radius of the rectangle.  
  /// -> relative
  radius: 0pt,

  /// How much to pad the content of the rectangle. See the built-in [`std.rect#inset`](https://typst.app/docs/reference/visualize/rect/#parameters-inset).
  /// -> relative | dictionary
  inset: 5pt,

  /// How much to expand the rectangle beyond its defined size.
  /// See the built-in [`std.rect#outset`](https://typst.app/docs/reference/visualize/rect/#parameters-outset).
  /// -> relative | dictionary
  outset: 0pt,

  /// The legend label for this plot. See @plot.label. 
  /// -> content
  label: none,

  /// Whether to clip the plot to the data area. See @plot.clip. 
  /// -> bool
  clip: true,
  
  /// Determines the $z$ position of this plot in the order of rendered diagram objects. 
  /// See @plot.z-index.  
  /// -> int | float
  z-index: 2,

  /// An optional body to place inside the rectangle. 
  /// -> any
  ..body

) = {
  assertations.assert-no-named(body, fn: "rect")
  
  let body = body.pos().at(0, default: none)

  (
    x: x, 
    y: y,
    plot: (plot, transform) => { 
      if "make-legend" in plot {
        return std.rect(
          width: 100%, height: 100%, 
          fill: fill, stroke: stroke, radius: radius
        )
      }

      let (x1, width, y1, height) = convert-rect(
        x, y, 
        width, height, 
        transform, 
        align: twod-ify-alignment(align)
      )

      place(dx: x1, dy: y1, 
        std.rect(
          width: width, 
          height: height, 
          fill: fill, 
          stroke: stroke,
          radius: radius, 
          inset: inset, 
          outset: outset,
          body
        )
      )
    },
    xlimits: compute-primitive-limits.with((x, if all-data-coordinates((x, width)) { x + width } else { x })),
    ylimits: compute-primitive-limits.with((y, if all-data-coordinates((y, height)) { y + height } else { y })),
    label: label,
    legend: true,
    clip: clip,
    z-index: z-index
  )
}
