#import "../libs/elembic/lib.typ" as e


/// An axis grid for highlighting tick positions in the diagram area. The 
/// grid lines are determined from the ticks located by the tick locators
/// of the main $x$ and $y$ axes for vertical and horizontal grid lines, 
/// respectively. 
/// 
/// One way to set up the grid stroke is with a style rule. The stroke 
/// for the grid lines at the main ticks is controlled by @grid.stroke
/// ```example
/// #show: lq.set-grid(stroke: teal)
/// 
/// #lq.diagram(
/// 
/// )
/// ```
/// and the stroke of the subticks by @grid.stroke-sub:
/// ```example
/// #show: lq.set-grid(stroke-sub: 0.5pt + luma(90%))
/// 
/// #lq.diagram(
/// 
/// )
/// ```
/// 
/// Through the parameter @diagram.grid, the look of the grid can also be 
/// controlled directly for an individual diagram. 
/// ```example
/// #lq.diagram(
///   grid: (stroke: black, stroke-sub: 0.25pt)
/// )
/// ```
/// 
/// Aside from `#show: lq.set-grid(stroke: none)`, the grid can be turned off 
/// entirely with the short-hand `grid: none`. 
/// ```example
/// #lq.diagram(
///   grid: none
/// )
/// ```
#let grid(

  /// A list of tick positions as absolute length coordinates within the 
  /// diagram frame. This is automatically filled by @diagram with the ticks 
  /// resulting from the axes' tick locators. 
  /// -> array
  ticks,

  /// Whether the ticks passed to @grid.ticks are subticks. 
  /// -> bool
  sub,

  /// The axis kind: horizontal (`"x"`) or vertical (`"y"`). 
  /// -> "x" | "y"
  kind: "x",

  /// How to stroke grid lines. 
  /// -> none | stroke
  stroke: 0.5pt + luma(80%),

  /// How to stroke grid lines for subticks. If `auto`, the style is inherited
  /// from @grid.stroke. 
  /// -> auto | none | stroke
  stroke-sub: none,

  /// Determines the $z$ position of the grid in the order of rendered diagram
  /// objects. See @plot.z-index.  
  /// -> int | float
  z-index: 0,
  
) = {}


// A stroke type that can also be auto or none and that still
// folds correctly. During folding auto and none override an 
// existing stroke fully. 
#let auto-none-stroke = e.types.wrap(
  e.types.smart(e.types.option(stroke)),
  fold: old-fold => (outer, inner) => if inner in (none, auto) or outer in (none, auto) { inner } else { (e.types.native.stroke_.fold)(outer, inner) }
)


#let grid = e.element.declare(
  "grid",
  prefix: "lilaq",

  display: it => {

    let stroke = if it.sub { it.stroke-sub } else { it.stroke }
    if stroke == none { return }

    let line
    if it.kind == "x" {
      line = tick => place(
        std.line(start: (tick, 0%), end: (tick, 100%), stroke: stroke)
      )
    } else if it.kind == "y" {
      line = tick => place(
        std.line(start: (0%, tick), end: (100%, tick), stroke: stroke)
      )
    }

    it.ticks.map(line).join()
  },

  fields: (
    e.field("ticks", array, required: true),
    e.field("sub", bool, required: true),
    e.field("kind", str, default: "x"),
    e.field("stroke", e.types.option(stroke), default: 0.5pt + luma(80%)),
    e.field("stroke-sub", auto-none-stroke, default: none),
    e.field("z-index", float, default: 0),
  ),
)
