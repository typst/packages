
#import "../libs/elembic/lib.typ" as e


/// An error bar object for a plot. This type allows for quick configuration and 
/// complete restyling of error bars. For drawing plots with error bars, 
/// use @plot. 
/// 
/// ```example
/// #lq.diagram(
///   lq.plot(
///     (1, 2, 3, 4),
///     (1, 2, 1.5, 2.1),
///     xerr: .2,
///     yerr: (.2, .1, .2, .2),
///   )
/// )
/// ```
/// 
/// The default styling can be changed through set rules
/// ```example
/// #show: lq.set-errorbar(stroke: 1pt + red, cap: none)
/// 
/// #lq.diagram(
///   lq.plot(
///     (1, 2, 3, 4),
///     (1, 2, 1.5, 2.1),
///     xerr: .2,
///     yerr: (.2, .1, .2, .2),
///   )
/// )
/// ```
#let errorbar(

  /// The kind of error bar: horizontal (`"x"`) or vertical (`"y"`). 
  /// -> "x" | "y"
  kind: "x",

  /// The length of the cap. If set to `none`, no cap is drawn. 
  /// -> none | length
  cap: 3pt,

  /// How to stroke the error bar. If set to `auto`, the stroke is inherited 
  /// the plot. 
  /// -> auto | stroke
  stroke: auto,

  /// How to stroke the cap. If set to `auto`, the stroke is inherited 
  /// from @errorbar.stroke. 
  /// -> auto | stroke
  cap-stroke: auto,
  
) = {}



#let errorbar = e.element.declare(
  "errorbar",
  prefix: "lilaq",

  display: it => {
    set curve(stroke: it.stroke) if it.stroke != auto

    if it.kind == "x" {
      place(horizon, curve(curve.line((100%, 0pt))))
    } else {
      place(center + horizon, curve(curve.line((0pt, 100%))))
    }
  
    if it.cap != none {
      set curve(stroke: it.cap-stroke) if it.cap-stroke != auto

      if it.kind == "x" {
        let cap = curve(curve.line((0pt, it.cap)))
        place(left + horizon, cap)
        place(right + horizon, cap)
      } else {
        let cap = curve(curve.line((it.cap, 0pt)))
        place(center + top, cap)
        place(center + bottom, cap)
      }
    }
  },

  labelable: false,

  fields: (
    e.field("kind", str, default: "x"),
    e.field("stroke", e.types.smart(stroke), default: auto),
    e.field("cap", e.types.option(length), default: 2.5pt),
    e.field("cap-stroke", e.types.smart(stroke), default: auto),
  )
)

