

/// A label for a diagram axis. 
#let label(
  
  /// Content to show in the label. 
  /// -> any
  body,

  /// The kind of axis that the label is attached to.
  /// -> "x" | "y"
  kind: "x",

  /// Horizontal offset. 
  /// -> length
  dx: 0pt,

  /// Vertical offset. 
  /// -> length
  dy: 0pt,

  /// Padding between the axis (and its ticks and labels) and the label. 
  /// When this is set to `none`, the label is drawn directly on the axis
  /// (ignoring the ticks).
  /// -> none | length
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



#import "@preview/elembic:1.1.1" as e

#let label = e.element.declare(
  "label",
  prefix: "lilaq",

  display: it => {
    let angle = it.angle
    if it.angle == auto { 
      angle = if it.kind == "y" { -90deg } else { 0deg }
    }
    rotate(angle, it.body, reflow: true)
  },

  fields: (
    e.field("body", e.types.option(content), required: true),
    e.field("dx", relative, default: 0pt),
    e.field("dy", relative, default: 0pt),
    e.field(
      "kind", 
      e.types.union(
        e.types.literal("x"), 
        e.types.literal("y")
      ), 
      default: "x"
    ),
    e.field("pad", e.types.option(length), default: .7em),
    e.field("angle", e.types.smart(angle), default: auto),
  )
)



#let xlabel = label.with(kind: "x")
#let ylabel = label.with(kind: "y")