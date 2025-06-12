
#import "../process-styles.typ": twod-ify-alignment
#import "../libs/elembic/lib.typ" as e
#import "spine.typ": spine


/// A tick or subtick on a diagram axis. A tick consists of a tick mark on the axis and
/// a tick label, usually a number denoting the coordinate value. 
#let tick(
  
  /// Position of the tick in data coordinates. 
  /// -> float
  value, 

  /// The content for the tick label. 
  /// -> any
  label: none,

  /// Whether this is a subtick. 
  /// -> bool
  sub: false,

  /// How to stroke the tick mark. If set to `auto`, the stroke is inherited 
  /// the axis spine. 
  /// -> auto | stroke
  stroke: auto,

  /// How much to shorten sub ticks compared to regular ticks. 
  /// -> float
  shorten-sub: 0.5,

  /// Where to align the tick. For example, if set to `right`, the tick label is
  /// shown to the left of the tick, aligning at its right side. Ticks on a 
  /// $y$-axis on the left side of the diagram will typically be aligned on the
  /// right. 
  /// -> left | top | right | bottom
  align: right,

  /// The padding to add between the tick and the tick label. 
  /// -> length
  pad: 0.5em,
  
  /// The length of the tick on the inside of the axis. Here, the tick label
  /// is considered to be on the _outside_. For example, if @tick.align is set
  /// to `right`, the inset determines the tick length to the right of the 
  /// axis spine. 
  /// -> length
  inset: 4pt,

  /// Length of the tick on the outside of the axis, see @tick.inset. For
  /// example, if @tick.align is set to `right`, the inset determines the tick
  /// length to the left of the axis spine. 
  /// -> length
  outset: 0pt
  
) = {}



#let tick = e.element.declare(
  "tick",
  prefix: "lilaq",

  display: it => e.get(e-get => {
    let angle = if it.align in (top, bottom) { 90deg } else { 0deg }
    let factor = if it.sub { it.shorten-sub } else { 1 }
    let length = (it.inset + it.outset) * factor
    
    let stroke = it.stroke
    if stroke == auto { 
      stroke = e-get(spine).stroke 
    }

    box(inset: (repr(it.align): it.pad + it.outset * factor), {
      place(
        twod-ify-alignment(it.align), 
        pad(
          ..(repr(it.align): -it.pad - length),
          line(length: length, angle: angle, stroke: stroke)
        )
      )
      it.label
    })
  }),

  labelable: false,

  fields: (
    e.field("value", float, required: true),
    e.field("sub", bool, default: false),
    e.field("label", e.types.any, default: none),
    e.field("align", e.types.wrap(alignment, fold: none), default: right),
    e.field("stroke", e.types.smart(stroke), default: auto),
    e.field("shorten-sub", float, default: 0.5),
    e.field("pad", length, default: 0.5em),
    e.field("inset", length, default: 3pt),
    e.field("outset", length, default: 0pt),
  )
)


#tick(34, label: [34])
#tick(34, label: [34], align: left)
#tick(34, label: [34], align: top)
#tick(34, label: [34], align: bottom)

#tick(34, label: [34], inset: 2pt)
#tick(34, label: [34], align: left, inset: 2pt)
#tick(34, label: [34], align: top, inset: 2pt)
#tick(34, label: [34], align: bottom, inset: 2pt)




/// A tick label, usually a number denoting the coordinate value. 
/// This type exists prominently to enable `show` rules on tick labels. 
#let tick-label(

  /// Content to show in the label. 
  /// -> content
  body

) = {}



#let tick-label = e.element.declare(
  "tick-label",
  prefix: "lilaq",

  display: it => {
    it.body
  },

  fields: (
    e.field("body", content, required: true),
  )
)
