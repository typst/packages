#import "std.typ"
#import "geometry.typ"

/// Core function to create an obstacle.
/// -> obstacle
#let placed(
  /// Reference position on the page (or in the parent container).
  /// -> alignment
  align,
  /// Horizontal displacement.
  /// -> relative
  dx: 0% + 0pt,
  /// Vertical displacement.
  /// -> relative
  dy: 0% + 0pt,
  /// An array of functions to transform the bounding box of the content.
  /// By default, a 5pt margin.
  /// See `contour.typ` for a list of available functions.
  /// -> (..function,)
  boundary: (auto,),
  /// Whether the obstacle is shown.
  /// Useful for only showing once an obstacle that intersects several invocations.
  /// Contrast the following:
  /// - `boundary: contour.phantom` will display the object without using it as an obstacle,
  /// - `display: false` will use the object as an obstacle but not display it.
  /// -> bool
  display: true,
  /// Inner content.
  /// -> content
  content,
) = {
  ((
    type: place,
    align: align,
    dx: dx,
    dy: dy,
    boundary: boundary,
    display: display,
    content: content
  ),)
}

/// Core function to create a container.
/// -> container
#let container(
  /// Location on the page.
  /// -> alignment
  align: top + left,
  /// Horizontal displacement.
  /// -> relative
  dx: 0% + 0pt,
  /// Vertical displacement.
  /// -> relative
  dy: 0% + 0pt,
  /// Width of the container.
  /// -> relative
  width: 100%,
  /// Height of the container.
  /// -> relative
  height: 100%,
) = {
  ((
    type: box,
    align: align,
    dx: dx,
    dy: dy,
    width: width,
    height: height,
  ),)
}

#let pagebreak() = {
  ((
    type: std.pagebreak,
  ),)
}

/// Core function to add flowing content.
/// -> flowing
#let content(
  /// Inner content.
  /// -> content
  data
) = {
  ((
    type: text,
    data: data,
  ),)
}

/// Splits the input sequence into obstacles, containers, and flowing content.
///
/// An "obstacle" is data produced by the `placed` function.
/// It can contain arbitrary content, and defines a zone where flowing content
/// cannot be placed.
///
/// A "container" is produced by the function `container`.
/// It defines a region where (once the obstacles are subtracted) is allowed
/// to contain flowing content.
///
/// Lastly flowing content is produced by the function `content`.
/// It will be threaded through every available container in order.
///
/// ```typ
/// #separate({
///   // This is an obstacle
///   placed(top + left, box(width: 50pt, height: 50pt))
///   // This is a container
///   container(height: 50%)
///   // This is flowing content
///   content[#lorem(50)]
/// })
/// ```
///
/// -> (containers: (..box,), obstacles: (..box,), flow: (..content,))
#let separate(
  /// -> content
  seq
) = {
  let pages = ()
  let flow = ()
  let placed = ()
  let free = ()
  for obj in seq {
    if obj.type == place {
      placed.push(obj)
    } else if obj.type == box {
      free.push(obj)
    } else if obj.type == text {
      flow.push(obj)
    } else if obj.type == std.pagebreak {
      pages.push((obstacles: placed, containers: free))
      placed = ()
      free = ()
    } else {
      panic("Unknown element of type " + repr(obj.type))
    }
  }
  pages.push((obstacles: placed, containers: free))
  (flow: flow, pages: pages) 
}

/// Pattern with red crosses to display forbidden zones.
/// -> pattern
#let pat-forbidden(
  /// Size of the tiling.
  /// -> length
  sz,
) = tiling(size: (sz, sz))[
  #place(box(width: 100%, height: 100%, stroke: none, fill: red.transparentize(95%)))
  #place(line(start: (25%, 25%), end: (75%, 75%), stroke: red + 0.1pt))
  #place(line(start: (25%, 75%), end: (75%, 25%), stroke: red + 0.1pt))
]

/// Pattern with green pluses to display allowed zones.
/// -> pattern
#let pat-allowed(
  /// Size of the tiling.
  /// -> length
  sz,
) = tiling(size: (sz, sz))[
  #place(box(width: 100%, height: 100%, stroke: none, fill: green.transparentize(95%)))
  #place(line(start: (25%, 50%), end: (75%, 50%), stroke: green + 0.1pt))
  #place(line(start: (50%, 25%), end: (50%, 75%), stroke: green + 0.1pt))
]

/// From a set of obstacles (see `separate`: an obstacle is any `placed` content)
/// construct the blocks `(x: length, y: length, width: length, height: length)`
/// that surround the obstacles.
///
/// The return value is as follows:
/// - `rects`, a list of `block`s `(x: length, y: length, width: length, height: length)`
/// - `display`, show this to include the placed content in the final output
/// - `debug`, show this to include helper boxes to visualize the layout
///
/// -> (rects: (..box,), display: content, debug: content)
#let forbidden-rectangles(
  /// Array of all the obstacles that are placed on this document.
  /// -> (..box,)
  obstacles,
  /// Dimensions of the parent container, as provided by `layout`.
  /// -> (width: length, height: length)
  size: none
) = {
  if size == none { panic("Need to provide a size") }
  let forbidden = ()
  let display = []
  let debug = []
  for elem in obstacles {
    let (width, height) = measure(elem.content, ..size)
    let (x, y) = geometry.align(elem.align, dx: elem.dx, dy: elem.dy, width: width, height: height)
    let dims = geometry.resolve(size, x: x, y: y, width: width, height: height)
    if elem.display {
      display += place[#move(dx: dims.x, dy: dims.y)[#elem.content]]
    }

    // Apply the boundary redrawing functions in order to know the true
    // footprint of the object in the layout.
    let bounds = (dims,)
    for func in elem.boundary {
      let func = if func != auto { func } else {
        import "contour.typ"
        contour.margin(5pt).at(0)
      }
      bounds = bounds.map(func).flatten()
    }
    for obj in bounds {
      forbidden.push(obj)
      debug += place[#move(dx: obj.x, dy: obj.y)[#box(stroke: red, fill: pat-forbidden(30pt), width: obj.width, height: obj.height)]]
    }
  }
  (rects: forbidden, display: display, debug: debug)
}

/// Partition the complement of `avoid` into `containers` as a series of rectangles.
///
/// The algorithm is roughly as follows:
/// ```
/// for container in containers {
///   horizontal-cuts = sorted(top and bottom of zone for zone in avoid)
///   for (top, bottom) in horizontal-cuts.windows(2) {
///     vertical-cuts = sorted(
///       left and right of zone for zone in avoid
///       if zone intersects (top, bottom)
///     )
///     new zone (top, bottom, left, right)
///   }
/// }
/// ```
/// The main difficulty is in bookkeeping and handling edge cases
/// (weird intersections, margins of error, containers that overflow the page, etc.)
/// There are no heuristics to exclude zones that are too small,
/// and no worries about zones that intersect vertically.
/// That would be the threading algorithm's job.
///
/// Blocks are given an additional field `bounds` that dictate the upper
/// limit of how much this block is allowed to stretch vertically, set to
/// the dimensions of the container that produced this block.
///
/// -> (rects: (..box,), debug: content)
#let tolerable-rectangles(
  /// Array of the containers in which content can be placed.
  /// -> (..box,)
  containers,
  /// Array of all the obstacles that are placed on this document.
  /// Will be subtracted from `containers`.
  /// -> (..box,)
  avoid: (),
  /// Dimensions of the parent container, as provided by `layout`.
  /// -> (width: length, height: length)
  size: none,
) = {
  if size == none { panic("Need to provide a size") }
  let zones-to-fill = ()
  let debug = []
  // TODO: include previous zones when cutting horizontally
  for zone in containers {
    let (x, y) = geometry.align(zone.align, dx: zone.dx, dy: zone.dy, width: zone.width, height: zone.height)
    let dims = geometry.resolve(size, x: x, y: y, width: zone.width, height: zone.height)
    // Cut the zone horizontally
    // The 3pt margin is because if the box exceeds the page, `measure` can't see
    // the difference anymore.
    let horizontal-marks = (dims.y, dims.y + dims.height - 3pt)
    for no-zone in avoid {
      if dims.y <= no-zone.y and no-zone.y <= dims.y + dims.height - 3pt {
        horizontal-marks.push(no-zone.y)
      }
      if dims.y <= no-zone.y + no-zone.height and no-zone.y + no-zone.height <= dims.y + dims.height - 3pt {
        horizontal-marks.push(no-zone.y + no-zone.height)
      }
    }
    horizontal-marks = horizontal-marks.sorted()
    for (hi, lo) in horizontal-marks.windows(2) {
      let vertical-marks = (dims.x, dims.x + dims.width)
      let relevant-forbidden = ()
      for no-zone in avoid {
        if geometry.intersects((hi, lo), (no-zone.y, no-zone.y + no-zone.height), tolerance: 1mm) {
          relevant-forbidden.push(no-zone)
          if geometry.between(dims.x, no-zone.x, dims.x + dims.width) {
            vertical-marks.push(no-zone.x)
          }
          if geometry.between(dims.x, no-zone.x + no-zone.width, dims.x + dims.width) {
            vertical-marks.push(no-zone.x + no-zone.width)
          }
        }
      }
      let vertical-marks = vertical-marks.sorted()
      let valid-zones = ()
      for (l, r) in vertical-marks.windows(2) {
        if r - l < 1mm { continue }
        let available = true
        for no-zone in relevant-forbidden {
          if geometry.intersects((l, r), (no-zone.x, no-zone.x + no-zone.width), tolerance: 1mm) { available = false }
        }
        if available {
          valid-zones.push((x: l, width: r - l))
        }
      }
      let bounds = dims
      for zone in valid-zones {
        assert(lo >= hi)
        assert(zone.width >= 0pt)
        debug += place(dx: zone.x, dy: hi)[#box(width: zone.width, height: lo - hi, fill: pat-allowed(30pt), stroke: green)]
        zones-to-fill.push((dx: zone.x, dy: hi, height: lo - hi, width: zone.width, bounds: bounds))
      }
    }
  }
  (rects: zones-to-fill, debug: debug)
}

/// Debug version of the toplevel `reflow`,
/// that only displays the partitioned layout.
/// -> content
#let regions(
  /// Content to be segmented and have its layout displayed.
  /// -> content
  ct,
  /// Whether to show the placed objects.
  /// -> bool
  display: true,
) = layout(size => {
  let (pages,) = separate(ct)
  for (idx, (containers, obstacles)) in pages.enumerate() {
    if idx != 0 {
      colbreak()
    }
    let forbidden = forbidden-rectangles(obstacles, size: size)
    if display {
      forbidden.display
    }
    forbidden.debug

    let allowed = tolerable-rectangles(containers, avoid: forbidden.rects, size: size)
    allowed.debug
  }
})
