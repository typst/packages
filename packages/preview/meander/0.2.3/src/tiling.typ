#import "std.typ"
#import "geometry.typ"

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


/// #property(requires-context: true)
/// See: @cmd:tiling:next-elem to explain #arg[data].
/// This function computes the effective obstacles from an input object,
/// as well as the display and debug outputs.
/// -> blocks
#let blocks-of-placed(
  /// Internal state.
  /// -> opaque
  data,
  /// Object to measure, pad, and place.
  /// -> elem
  obj,
) = {
  let (width, height) = measure(obj.content, ..data.size)
  let obj = geometry.unquery(obj, regions: data.regions)
  let (x, y) = geometry.align(obj.align, dx: obj.dx, dy: obj.dy, width: width, height: height, anchor: obj.anchor)
  let dims = geometry.resolve(data.size, x: x, y: y, width: width, height: height)
  let display = if obj.display {
    place[#move(dx: dims.x, dy: dims.y)[#{obj.content}]]
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
  for dims in bounds {
    forbidden.push((..dims, tags: obj.tags))
    debug += place[#move(dx: dims.x, dy: dims.y)[#box(stroke: red, fill: pat-forbidden(30pt), width: dims.width, height: dims.height)]]
  }
  (type: place, debug: debug, display: display, blocks: forbidden)
}

/// Eliminates non-candidates by determining if the obstacle is ignored by the container.
#let is-ignored(
  /// Must have the field #arg[invisible],
  /// as containers do.
  container,
  /// Must have the field #arg[tags],
  /// as obstacles do.
  obstacle,
) = {
  for label in container.invisible {
    if label in obstacle.tags {
      return true
    }
  }
  false
}

/// See: @cmd:tiling:next-elem to explain #arg[data].
/// Computes the effective containers from an input object,
/// as well as the display and debug outputs.
/// -> blocks
#let blocks-of-container(
  /// Internal state.
  /// -> opaque
  data,
  /// Container to segment.
  /// -> elem
  obj,
) = {
  // Calculate the absolute dimensions of the container
  let obj = geometry.unquery(obj, regions: data.regions)
  let (x, y) = geometry.align(obj.align, dx: obj.dx, dy: obj.dy, width: obj.width, height: obj.height)
  let dims = geometry.resolve(data.size, x: x, y: y, width: obj.width, height: obj.height)
  // Select only the obstacles that may intersect this container
  let relevant-obstacles = data.obstacles.filter(exclude => {
    geometry.intersects((dims.x, dims.x + dims.width), (exclude.x, exclude.x + exclude.width)) and not is-ignored(obj, exclude)
  })
  // Cut the zone horizontally at every top or bottom of an intersecting obstacle
  let horizontal-marks = (dims.y, dims.y + dims.height)
  for exclude in relevant-obstacles {
    for line in (exclude.y, exclude.y + exclude.height) {
      if geometry.between(dims.y, line, dims.y + dims.height) {
        horizontal-marks.push(line)
      }
    }
  }
  // This hack helps solve a problem when the container has the height of the whole
  // page: `measure(box(height: 100%), ..size).height` is equal to
  // `measure(box(height: 200%), ..size).height`
  if horizontal-marks.len() == 2 and dims.height == data.size.height {
    horizontal-marks.push(data.size.height / 2)
  }
  horizontal-marks = horizontal-marks.sorted()

  let debug = []
  let all-zones = ()
  // Then for every horizontal region delimited by two adjacent marks,
  // compute the vertical segments.
  for (hi, lo) in horizontal-marks.windows(2) {
    // Further filter the obstacles for better performance.
    let relevant-obstacles = relevant-obstacles.filter(exclude => {
      geometry.intersects((hi, lo), (exclude.y, exclude.y + exclude.height), tolerance: 1mm)
    })
    let vertical-marks = (dims.x, dims.x + dims.width)
    for exclude in relevant-obstacles {
      for line in (exclude.x, exclude.x + exclude.width) {
        if geometry.between(dims.x, line, dims.x + dims.width) {
          vertical-marks.push(line)
        }
      }
    }
    vertical-marks = vertical-marks.sorted()

    // A zone is naturally the space between two adjacent vertical marks,
    // if and only if it does not intersect any obstacle.
    let new-zones = ()
    for (l, r) in vertical-marks.windows(2) {
      if r - l < 1mm { continue }
      let available = true
      for exclude in relevant-obstacles {
        if geometry.intersects((l, r), (exclude.x, exclude.x + exclude.width), tolerance: 1mm) {
          available = false
        }
      }
      if available {
        new-zones.push((x: l, width: r - l))
      }
    }
    for zone in new-zones {
      assert(lo >= hi)
      assert(zone.width >= 0pt)
      debug += place(dx: zone.x, dy: hi)[
        #box(width: zone.width, height: lo - hi, fill: pat-allowed(30pt), stroke: green)
      ]
      all-zones.push((
        x: zone.x, y: hi, height: lo - hi, width: zone.width,
        bounds: dims, // upper limits on how this zone can grow
        margin: obj.margin,
        style: obj.style,
        invisible: obj.invisible,
        tags: obj.tags,
      ))
    }
  }
  (type: box, debug: debug, display: none, blocks: all-zones)
}

/// Applies an element's margin to itself.
/// -> elem
#let add-self-margin(
  /// Inner element.
  /// -> elem
  elem
) = {
  if "margin" not in elem { return elem }
  let margin = elem.margin
  let (left, top, right, bottom) = if type(margin) == dictionary {
    let rest = margin.at("rest", default: 0pt)
    let x = margin.at("x", default: rest)
    let y = margin.at("y", default: rest)
    let top = margin.at("top", default: y)
    let bottom = margin.at("bottom", default: y)
    let left = margin.at("left", default: x)
    let right = margin.at("right", default: x)
    (left, top, right, bottom)
  } else {
    (margin, margin, margin, margin)
  }
  elem.x -= left
  elem.y -= top
  elem.width += left + right
  elem.height += top + bottom
  elem
}

/// Initializes the initial value of the internal data for the reentering
/// `next-elem`.
/// -> opaque
#let create-data(
  /// Dimensions of the page
  /// -> size
  size: none,
  /// Elements to dispense in order
  /// -> (..elem,)
  elems: (),
) = {
  assert(size != none)
  (
    elems: elems.rev(),
    size: size,
    obstacles: (),
    regions: (:),
  )
}

/// This function is reentering, allowing interactive computation of the layout.
/// Given its internal state #arg[data], @cmd:tiling:next-elem uses the helper functions
/// @cmd:tiling:blocks-of-placed and @cmd:tiling:blocks-of-container to compute
/// the dimensions of the next element, which may be an obstacle or a container.
/// -> (elem, opaque)
#let next-elem(
  /// Internal state, stores
  /// - #arg[size] the available page dimensions,
  /// - #arg[elems] the remaining elements to handle in reverse order (they will be `pop`ped),
  /// - #arg[obstacles] the running accumulator of previous obstacles;
  /// -> opaque
  data,
) = {
  let data = data
  if data.elems.len() == 0 { return (none, data) }
  let obj = data.elems.pop()
  if obj.type == place {
    (blocks-of-placed(data, obj), data)
  } else if obj.type == box {
    (blocks-of-container(data, obj), data)
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
    for tag in block.tags {
      let current = data.regions.at(str(tag), default: block)
      let x = calc.min(current.x, block.x)
      let y = calc.min(current.y, block.y)
      let xmax = calc.max(current.x + current.width, block.x + block.width)
      let ymax = calc.max(current.y + current.height, block.y + block.height)
      data.regions.insert(str(tag), (
        x: x,
        y: y,
        width: xmax - x,
        height: ymax - y,
      ))
    }
  }
  data
}

/// Splits the input sequence into pages of elements (either obstacles or containers),
/// and flowing content.
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
/// -> (pages: array(elem), flow: array(elem))
#let separate(
  /// A sequence of elements made from @cmd:placed, @cmd:content, @cmd:container, etc.
  /// -> array(elem)
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
    } else if obj.type == pad {
      flow.push(obj)
    } else {
      panic("Unknown element of type " + repr(obj.type))
    }
  }
  pages.push(elems)
  (flow: flow, pages: pages) 
}

/// Determines the appropriate layout invocation based on the placement mode.
/// See details on @cmd:meander:reflow.
/// -> function
#let placement-mode(placement) = {
  if placement == page {
    (
      wrapper:
        (inner) => {
          set block(spacing: 0em)
          layout(size => inner(size))
        },
      placeholder: (_) => none,
    )
  } else if placement == float {
    (
      wrapper:
        (inner) => {
          place(top + left)[
            #box(width: 100%, height: 100%)[
              #layout(size => inner(size))
            ]
          ]
        },
      placeholder: (_) => none,
    )
  } else if placement == box {
    (
      wrapper:
        (inner) => {
          layout(size => inner(size))
        },
      placeholder: (hgt) => box(width: 100%, height: hgt),
    )
  } else {
    panic("Invalid placement option")
  }
}

