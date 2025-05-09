#import "../libs/elembic/lib.typ" as e


/// A title for a diagram. Titles can be placed at the top (default),
/// left, right, or bottom of a diagram. 
#let title(

  /// The content to show in the title. 
  /// -> any
  body,

  /// Position of the title in the diagram. 
  /// -> left | top | right | bottom
  position: top,

  /// Horizontal offset. 
  /// -> length
  dx: 0pt,

  /// Vertical offset. 
  /// -> length
  dy: 0pt,

  /// Padding between the axes and the title. 
  /// -> length
  pad: 0.5em,
  
) = {
  assert(
    position in (top, bottom, left, right), 
    message: "`position` needs to be one of \"top\", \"left\", \"bottom\", and \"right\""
  )

  (
    body: body,
    position: position,
    dx: dx,
    dy: dy,
    pad: pad
  )
}


#let title = e.element.declare(
  "title",
  prefix: "lilaq",

  display: it => it.body,

  fields: (
    e.field("body", content, required: true),
    e.field("position", alignment, default: top),
    e.field("dx", length, default: 0pt),
    e.field("dy", length, default: 0pt),
    e.field("pad", length, default: 0.5em),
  )
)
