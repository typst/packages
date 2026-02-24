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
  /// Styling options for the content that ends up inside this container.
  /// If you don't find the option you want here, check if it might be in
  /// the `style` parameter of `content` instead.
  /// - `align`: flush text `left`/`center`/`right`
  /// - `text-fill`: color of text
  /// -> dictionnary
  style: (:),
  /// Margin around the eventually filled container so that text from
  /// other paragraphs doesn't come too close.
  /// -> length
  margin: 5mm,
) = {
  ((
    type: box,
    align: align,
    dx: dx,
    dy: dy,
    width: width,
    height: height,
    style: style,
    margin: margin,
  ),)
}

/// Continue layout to next page.
#let pagebreak() = {
  ((
    type: std.pagebreak,
  ),)
}

/// Continue content to next container.
#let colbreak() = {
  ((
    type: std.colbreak,
    data: none,
    style: (
      size: auto,
      lang: auto,
      leading: auto,
      hyphenate: auto,
    )
  ),)
}

/// Core function to add flowing content.
/// -> flowing
#let content(
  /// Inner content.
  /// -> content
  data,
  /// Applies `#set text(size: ...)`.
  /// -> length
  size: auto,
  /// Applies `#set text(lang: ...)`.
  /// -> string
  lang: auto,
  /// Applies `#set text(hyphenate: ...)`.
  /// -> bool
  hyphenate: auto,
  /// Applies `#set par(leading: ...)`.
  /// -> length
  leading: auto,
) = {
  if size != auto {
    data = text(size: size, data)
  }
  if lang != auto {
    data = text(lang: lang, data)
  }
  if hyphenate != auto {
    data = text(hyphenate: hyphenate, data)
  }
  if leading != auto {
    data = [#set par(leading: leading); #data]
  }
  ((
    type: text,
    data: data,
    style: (
      size: size,
      lang: lang,
      leading: leading,
      hyphenate: hyphenate,
    ),
  ),)
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


/// See: `next-elem` to explain `data`.
/// This function computes the effective obstacles from an input object,
/// as well as the display and debug outputs.
/// -> elem
#let elem-of-placed(
  /// Internal state.
  /// -> opaque
  data,
  /// Object to measure, pad, and place.
  /// -> placed
  obj,
) = {
  let (width, height) = measure(obj.content, ..data.size)
  let (x, y) = geometry.align(obj.align, dx: obj.dx, dy: obj.dy, width: width, height: height)
  let dims = geometry.resolve(data.size, x: x, y: y, width: width, height: height)
  let display = if obj.display {
    place[#move(dx: dims.x, dy: dims.y)[#obj.content]]
  } else { none }

  // Apply the boundary redrawing functions in order to know the true
  // footprint of the object in the layout.
  let bounds = (dims,)
  for func in obj.boundary {
    let func = if func != auto { func } else {
      import "contour.typ"
      contour.margin(5pt).at(0)
    }
    bounds = bounds.map(func).flatten()
  }
  let forbidden = ()
  let debug = []
  for obj in bounds {
    forbidden.push(obj)
    debug += place[#move(dx: obj.x, dy: obj.y)[#box(stroke: red, fill: pat-forbidden(30pt), width: obj.width, height: obj.height)]]
  }
  (type: place, debug: debug, display: display, blocks: forbidden)
}

/// See: `next-elem` to explain `data`.
/// Computes the effective containers from an input object,
/// as well as the display and debug outputs.
/// -> elem
#let elem-of-container(
  /// Internal state.
  /// -> opaque
  data,
  /// Container to segment.
  /// -> container
  obj,
) = {
  let (x, y) = geometry.align(obj.align, dx: obj.dx, dy: obj.dy, width: obj.width, height: obj.height)
  let dims = geometry.resolve(data.size, x: x, y: y, width: obj.width, height: obj.height)
  // Cut the zone horizontally
  let horizontal-marks = (dims.y, dims.y + dims.height)
  for no-zone in data.obstacles {
    if dims.y <= no-zone.y and no-zone.y <= dims.y + dims.height {
      horizontal-marks.push(no-zone.y)
    }
    if dims.y <= no-zone.y + no-zone.height and no-zone.y + no-zone.height <= dims.y + dims.height {
      horizontal-marks.push(no-zone.y + no-zone.height)
    }
  }
  if horizontal-marks.len() == 2 and dims.height == data.size.height {
    horizontal-marks.push(data.size.height / 2)
  }
  horizontal-marks = horizontal-marks.sorted()

  let debug = []
  let zones-to-fill = ()
  for (hi, lo) in horizontal-marks.windows(2) {
    let vertical-marks = (dims.x, dims.x + dims.width)
    let relevant-forbidden = ()
    for no-zone in data.obstacles {
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
    let style = obj.style
    for zone in valid-zones {
      assert(lo >= hi)
      assert(zone.width >= 0pt)
      debug += place(dx: zone.x, dy: hi)[#box(width: zone.width, height: lo - hi, fill: pat-allowed(30pt), stroke: green)]
      zones-to-fill.push((x: zone.x, y: hi, height: lo - hi, width: zone.width, bounds: bounds, style: style, margin: obj.margin))
    }
  }
  (type: box, debug: debug, display: none, blocks: zones-to-fill)
}

/// Applies an element's margin to itself
/// -> elem
#let add-auto-margin(elem) = {
  if "margin" not in elem { return elem }
  elem.x -= elem.margin
  elem.y -= elem.margin
  elem.width += 2 * elem.margin
  elem.height += 2 * elem.margin
  elem
}

/// This function is reentering, allowing interactive computation of the layout.
/// Given its internal state `data`, `next-elem` uses the helper functions
/// `elem-of-placed` and `elem-of-container` to compute the dimensions of the
/// next element, which may be an obstacle or a container.
/// -> (elem, opaque)
#let next-elem(
  /// Internal state, stores
  /// - `size` the available page dimensions,
  /// - `elems` the remaining elements to handle in reverse order (they will be `pop`ped),
  /// - `obstacles` the running accumulator of previous obstacles;
  /// -> opaque
  data,
) = {
  let data = data
  if data.elems.len() == 0 { return (none, data) }
  let obj = data.elems.pop()
  if obj.type == place {
    (elem-of-placed(data, obj), data)
  } else if obj.type == box {
    (elem-of-container(data, obj), data)
  } else {
    panic("There is a bug in `separate`")
  }
}

/// Updates the internal state to include the newly created element.
/// -> opaque
#let push-elem(
  /// Internal state.
  /// -> opaque
  data,
  /// Element to register.
  /// -> elem
  elem,
) = {
  let data = data
  for block in elem.blocks {
    data.obstacles.push(block)
  }
  data
}

/// Splits the input sequence into pages of elements (either obstacles or containers),
/// and flowing content.
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
/// -> (pages: array, flow: (..content,))
#let separate(
  /// A sequence of constructors `placed`, `container`, and `content`.
  /// -> seq
  seq
) = {
  let pages = ()
  let flow = ()
  let elems = ()
  for obj in seq {
    if obj.type == place or obj.type == box {
      elems.push(obj)
    } else if obj.type == text {
      flow.push(obj)
    } else if obj.type == std.pagebreak {
      pages.push(elems)
      elems = ()
    } else if obj.type == std.colbreak {
      flow.push(obj)
    } else {
      panic("Unknown element of type " + repr(obj.type))
    }
  }
  pages.push(elems)
  (flow: flow, pages: pages) 
}

/// Debug version of the toplevel `reflow`,
/// that only displays the partitioned layout.
/// -> content
#let regions(
  /// Input sequence to segment.
  /// Constructed from `placed`, `container`, and `content`.
  /// -> seq
  seq,
  /// Whether to show the placed objects (`true`),
  /// or only their hitbox (`false`).
  /// -> bool
  display: true,
  /// Controls relation to other content on the page.
  /// See analoguous `placement` option on `reflow`.
  placement: page,
) = {
  // TODO: extract to aux function. Same for `reflow`.
  let wrapper(inner) = {
    if placement == page {
      set block(spacing: 0em)
      layout(size => inner(size))
    } else if placement == float {
      place(top + left)[
        #box(width: 100%, height: 100%)[
          #layout(size => inner(size))
        ]
      ]
    } else if placement == box {
      layout(size => inner(size))
    } else {
      panic("Invalid placement option")
    }
  }
  wrapper(size => {
    let (pages,) = separate(seq)
    for (idx, elems) in pages.enumerate() {
      if idx != 0 {
        colbreak()
      }
      let data = (elems: elems.rev(), size: size, obstacles: ())
      while true {
        // Compute
        let (elem, _data) = next-elem(data)
        if elem == none { break }
        data = _data

        // Show
        if display { elem.display }
        elem.debug

        // Record
        data = push-elem(data, elem)
      }
    }
  })
}
