#import "@preview/elembic:1.1.0" as e
#import "@preview/tiptoe:0.3.1"


/// The spine of a diagram axis (the line drawn along the axis). 
#let spine(
  
  /// How to stroke the spine of the axis. 
  /// -> none | stroke
  stroke: (thickness: 0.5pt, cap: "square"),

  /// Places an arrow tip on the axis spine. This expects a mark as specified by
  /// the #link("https://typst.app/universe/package/tiptoe")[tiptoe package]. 
  /// -> none | tiptoe.mark
  tip: none,

  /// Places an arrow tail on the axis spine. This expects a mark as specified by 
  /// the #link("https://typst.app/universe/package/tiptoe")[tiptoe package]. 
  /// -> none | tiptoe.mark
  toe: none

) = {}




#let spine = e.element.declare(
  "spine",
  prefix: "lilaq",

  display: it => {
    if it.stroke == none { return }
    let line
    if it.kind == "x" {
      line = tiptoe.line.with(tip: it.tip, toe: it.toe)
    } else if it.kind == "y"{
      line = tiptoe.line.with(angle: 90deg, tip: it.toe, toe: it.tip)
    }
    line(length: 100%, stroke: it.stroke)
  },

  fields: (
    e.field("stroke", e.types.option(stroke), default: (thickness: 0.5pt, cap: "square")),
    e.field(
      "kind", 
      e.types.union(e.types.literal("x"), e.types.literal("y")), 
      default: "x"
    ),
    e.field("tip", e.types.option(function), default: none),
    e.field("toe", e.types.option(function), default: none),
  )
)
