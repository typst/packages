

/// A label for a diagram axis. 
#let label(
  
  /// Content to show in the label. 
  /// -> any
  body,

  /// Horizontal offset. 
  /// -> length
  dx: 0pt,

  /// Vertical offset. 
  /// -> length
  dy: 0pt,

  /// Padding between the axis (and its ticks and labels) and the label. 
  /// -> length
  pad: 0.75em,

  /// Angle at which the label is drawn. The label of a `y` axis is often 
  /// drawn at `-90deg`. 
  /// -> angle
  angle: 0deg
  
) = {
  (
    body: body,
    dx: dx,
    dy: dy,
    pad: pad,
    angle: angle
  )
}



#import "../libs/elembic/lib.typ" as e

#let label = e.element.declare(
  "label",
  prefix: "lilaq",

  display: it => rotate(it.angle, it.body, reflow: true),

  fields: (
    e.field("body", content, required: true),
    e.field("dx", length, default: 0pt),
    e.field("dy", length, default: 0pt),
    e.field("pad", length, default: .7em),
    e.field("angle", angle, default: 0deg),
  )
)



#let xlabel = label
#let ylabel = label.with(angle: -90deg)
