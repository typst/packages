#import "../process-styles.typ": twod-ify-alignment
#import "../logic/process-coordinates.typ": transform-point


/// Places any type of content in the data area. The coordinates of the origin
/// can be given as data coordinates, as percentage relative to the data area
/// or in absolute lengths (see @rect). 
/// 
/// ```example
/// #lq.diagram(
///   lq.place(0.5, 0.5)[Hello],
///   lq.place(0%, -0.25, align: left)[
///     Text placed at `x: 0%` and `y: -0.25`
///   ]
/// )
/// ```
/// 
/// Unlike other plotting commands, @place is not clipped to the data area by
/// default and the z-index is one higher, making the placed content appear 
/// on top of most other diagram objects. 
/// 
/// ```example
/// #lq.diagram(
///   lq.plot((1, 2, 3), (1, 2.1, 3)),
///   lq.place(
///     10%, 0%, 
///     align: left,
///     box(fill: yellow, inset: 2pt)[
///       Here comes the plot🎶 ↓
///     ]
///   )
/// )
/// ```
/// Clipping can be activated via @place.clip and the z-index can be changed
/// through @place.z-index.  
/// 
/// 
/// With @place, a smaller plot can also be placed within another plot. 
/// 
/// ```example
/// #let xs = lq.linspace(-5, 5, num: 20)
/// 
/// #lq.diagram(
///   lq.plot((1,2,3), (1,2,3)),
///   lq.place(25%, 50%,
///     lq.diagram(
///       title: [mini],
///       width: 40pt, height: 30pt, 
///       lq.plot(xs, xs.map(x => x*x))
///     )
///   )
/// )
/// ```
/// 
#let place(

  /// The $x$ coordinate of the origin.
  /// -> float | relative 
  x, 

  /// The $y$ coordinate of the origin.
  /// -> float | relative 
  y,

  /// The content to place in the data area. 
  /// -> any
  body,

  /// How to align the content at the origin coordinates. 
  /// -> alignment
  align: center + horizon,

  /// Whether to clip the plot to the data area. See @plot.clip. 
  /// -> bool
  clip: false,
  
  /// Determines the $z$ position of the content in the order of rendered diagram
  /// objects. See @plot.z-index.  
  /// -> int | float
  z-index: 3,

) = {
  (
    plot: (plot, transform) => { 
      let (px, py) = transform-point(x, y, transform)
      std.place(
        dx: px, dy: py,
        std.place(twod-ify-alignment(align), body),
      )
    },
    xlimits: () => none,
    ylimits: () => none,
    label: none,
    clip: clip,
    z-index: z-index
  )
}
