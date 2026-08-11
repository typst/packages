#import "../assertations.typ"
#import "../logic/limits.typ": compute-primitive-limits
#import "../logic/process-coordinates.typ": all-data-coordinates, convert-rect
#import "../process-styles.typ": twod-ify-alignment
#import "../logic/time.typ"




#let flip-gradient(gradient, axis: "x") = {
  let angle = gradient.angle()
  
  if axis == "y" and angle in (90deg, 270deg, -90deg) {
    angle = -angle
  }
  if axis == "x" and angle in (0deg, 180deg, -180deg) {
    angle = angle + 180deg
  }
  (gradient.kind())(
    ..gradient.stops(),
    angle: angle,
    space: gradient.space(),
  )
}


// Convert a rectangle (or ellipse) to one with no negative width or height, 
// providing an offset correction. 
#let normalize-rect(
  rect, dx: 0pt, dy: 0pt
) = {
  let fields = rect.fields()
  let body = fields.remove("body")
  let width = rect.width
  let height = rect.height
  let fill = rect.fill
  
  if body == none and type(fill) != gradient {
    return (rect, dx, dy)
  }


  if (
    (height.ratio == 0% and height.length < 0pt) or 
    (height.length == 0pt and height.ratio < 100%)
  ) {
    dy += height
    height *= -1
    if type(fill) == gradient {
      fill = flip-gradient(fill, axis: "y")
    }
  }
  if (
    (width.ratio == 0% and width.length < 0pt) or 
    (width.length == 0pt and width.ratio < 100%)
  ) {
    dx += width
    width *= -1
    if type(fill) == gradient {
      fill = flip-gradient(fill, axis: "x")
    }
  }

  let content = (rect.func())(..fields, width: width, height: height, fill: fill, body)
  
  return (content, dx, dy)
}


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
  /// -> float | relative | datetime
  x, 

  /// The y coordinate of the origin.
  /// -> float | relative | datetime
  y,

  /// The rectangle's width. 
  /// -> auto | float | relative | duration
  width: auto,

  /// The rectangle's height. 
  /// -> auto | float | relative | duration
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

  
  let datetime-axes = (:)

  if type(width) == duration {
    assert(
      type(x) == datetime,
      message: "The rectangle width can only be a duration if the x-coordinate is a datetime"
    )
    width = width.seconds()
  }

  if type(height) == duration {
    assert(
      type(y) == datetime,
      message: "The rectangle height can only be a duration if the y-coordinate is a datetime"
    )
    height = height.seconds()
  }

  if type(x) == datetime {
    x = time.to-seconds(x).first()
    datetime-axes.x = true
  }
  if type(y) == datetime {
    y = time.to-seconds(y).first()
    datetime-axes.y = true
  }

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

      let (dx, width, dy, height) = convert-rect(
        x, y, 
        width, height, 
        transform, 
        align: twod-ify-alignment(align)
      )




      let rect = std.rect(
          fill: fill, 
          stroke: stroke,
          radius: radius, 
          inset: inset, 
          outset: outset,
          width: width,
          height: height,
          body
      )


      (rect, dx, dy) = normalize-rect(rect, dx: dx, dy: dy)

      place(dx: dx, dy: dy, rect)
    },
    xlimits: compute-primitive-limits.with((x, if all-data-coordinates((x, width)) { x + width } else { x })),
    ylimits: compute-primitive-limits.with((y, if all-data-coordinates((y, height)) { y + height } else { y })),
    label: label,
    datetime: datetime-axes,
    legend: true,
    clip: clip,
    z-index: z-index
  )
}
