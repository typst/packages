#import "../assertations.typ"
#import "../logic/limits.typ": compute-primitive-limits
#import "../logic/process-coordinates.typ": all-data-coordinates, convert-rect


/// Plots an ellipse with origin `(x, y)`. The origin coordinates as well
/// as width and height can either be given as 
/// - data coordinates (`int` or `float`),
/// - or absolute coordinates from the top left corner of the data area (`length`),
/// - or in percent relative to the data area (`ratio`),
/// - or a combination of the latter two (`relative`).  
/// 
/// Note that coordinate types can also be mixed (e.g., a length for `x` and a scalar for `y`).
/// 
/// 
/// For example in order to access the center, you can write `(50%, 50%)`. 
/// 
/// 
/// ```example
/// #lq.diagram(
///   width: 3cm, height: 3cm,
///   lq.ellipse(2, 2, width: 10, height: 4, fill: yellow),
///   lq.ellipse(10, 4, width: 4, height: 4, fill: red),
///   lq.ellipse(50%, 50%, width: 45%, height: 45%, stroke: blue)
/// )
/// ```
/// 
#let ellipse(
  
  /// The x coordinate of the origin.
  /// -> float | relative 
  x, 

  /// The y coordinate of the origin.
  /// -> float | relative 
  y,

  /// The width of the ellipse. 
  /// -> auto | float | relative
  width: auto,

  /// The height of the ellipse. 
  /// -> auto | float | relative
  height: auto, 

  /// How to fill the ellipse.  
  /// -> none | color | gradient | tiling
  fill: none,

  /// How to stroke the ellipse.
  /// -> auto | none | stroke
  stroke: auto,

  /// How much to pad the content of the ellipse. See the built-in [`std.ellipse#inset`](https://typst.app/docs/reference/visualize/ellipse/#parameters-inset).
  /// -> relative | dictionary
  inset: 5pt,

  /// How much to expand the ellipse beyond its defined size.
  /// See the built-in [`std.ellipse#outset`](https://typst.app/docs/reference/visualize/ellipse/#parameters-outset).
  /// -> relative | dictionary
  outset: 0pt,

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

  /// An optional body to place inside the ellipse. If `width` and/or `height` are set to `auto`, they will adapt to the content. 
  /// -> any
  ..body

) = {
  assertations.assert-no-named(body, fn: "ellipse")
  (
    x: x, 
    y: y,
    plot: (plot, transform) => { 
      if "make-legend" in plot {
        return std.ellipse(
          width: 100%, height: 100%, 
          fill: fill, stroke: stroke
        )
      }

      let (x1, width, y1, height) = convert-rect(x, y, width, height, transform)
      place(dx: x1, dy: y1, 
        std.ellipse(
          width: width, 
          height: height, 
          fill: fill, 
          stroke: stroke, 
          inset: inset, 
          outset: outset,
          body.pos().at(0, default: none)
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
