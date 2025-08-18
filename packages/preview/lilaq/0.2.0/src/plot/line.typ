#import "../logic/process-coordinates.typ": convert-vertex
#import "../logic/limits.typ": compute-primitive-limits
#import "@preview/tiptoe:0.3.0"


/// Draws a line into the data area. 
/// ```example
/// #lq.diagram(
///   width: 3cm, height: 3cm,
///   lq.line((1, 2), (5, 4))
/// )
/// ```
/// The coordinates can also be given relative to the data area 
/// (`0%` means at the very left/top and `100%` at the very right/bottom)
/// ```example
/// #lq.diagram(
///   width: 3cm, height: 3cm,
///   lq.line((0%, 0%), (100%, 100%))
/// )
/// ```
/// or mixed between relative, absolute and data values. 
/// ```example
/// #lq.diagram(
///   width: 3cm, height: 3cm,
///   lq.line(
///     stroke: (paint: blue, dash: "dashed"),
///     (1, 100%), (4, 10pt)
///   )
/// )
/// ```
/// 
/// Arrow tips and tails can be added to a line through the arguments `tip` and `toe`. 
/// This is supported via the Typst package 
/// #link("https://typst.app/universe/package/tiptoe")[tiptoe].
/// ```example
/// #import "@preview/tiptoe:0.3.0"
/// #let xs = lq.arange(-5, 6)
/// 
/// #lq.diagram(
///   lq.plot(xs, xs.map(x => x*x)),
///   lq.line(
///     tip: tiptoe.stealth,
///     toe: tiptoe.bar,
///     (0, 10), (4, 16)
///   )
/// )
/// ```
/// 
#let line(

  /// The start point of the line. Coordinates can be given as
  /// - data coordinates (`int` or `float`),
  /// - or absolute coordinates from the top left corner of the data area 
  ///   (`length`),
  /// - or in percent relative to the data area (`ratio`),
  /// - or a combination of the latter two (`relative`).  
  /// -> array
  start, 

  /// The end point of the line, see @line.start. 
  /// -> array
  end,

  /// How to stroke the line. 
  /// -> stroke
  stroke: stroke(),
  
  /// The legend label for this plot. See @plot.label. 
  /// -> content
  label: none,

  /// Places an arrow tip on the line. This expects a mark as specified by
  /// the #link("https://typst.app/universe/package/tiptoe")[tiptoe package]. 
  /// -> none | tiptoe.mark
  tip: none,
  
  /// Places an arrow tail on the line. This expects a mark as specified by 
  /// the #link("https://typst.app/universe/package/tiptoe")[tiptoe package]. 
  /// -> none | tiptoe.mark
  toe: none,
  
  /// Whether to clip the plot to the data area. See @plot.clip. 
  /// -> bool
  clip: true,
  
  /// Determines the $z$ position of this plot in the order of rendered diagram objects. 
  /// See @plot.z-index.  
  /// -> int | float
  z-index: 2,

) = {
  let vertices = (start, end)
  (
    plot: (plot, transform) => { 
      if "make-legend" in plot {
        return std.line(length: 100%, stroke: stroke)
      }

      let (start, end) = vertices.map(convert-vertex.with(transform: transform))
      if tip == none and toe == none {
        return place(std.line(
          stroke: stroke,
          start: start, end: end
        ))
      }
      place(tiptoe.line(
        stroke: stroke,
        start: start, end: end,
        tip: tip, toe: toe
      ))
    },
    xlimits: compute-primitive-limits.with(vertices.map(x => x.at(0))),
    ylimits: compute-primitive-limits.with(vertices.map(x => x.at(1))),
    label: label,
    legend: true,
    clip: clip,
    z-index: z-index
  )
}
