#import "opt.typ"
#import "types.typ"
#import "geometry.typ"

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
  let (width, height) = measure(obj.content, ..data.full-size)
  // Disabled in 0.4.0, now uses callback instead of unquery
  // We still run this function for diagnostics.
  let _ = geometry.unquery(obj, regions: data.regions)
  let (x, y) = geometry.align(obj.align, dx: obj.dx, dy: obj.dy, width: width, height: height, anchor: obj.anchor)
  let obj-dims = geometry.resolve(data.full-size, width: width, height: height)
  let dims = geometry.resolve(data.free-size, x: x, y: y, ..obj-dims)
  let content = place[#move(dx: dims.x, dy: dims.y)[#{obj.content}]]

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
  }
  (type: place, content: content, display: obj.display, region: dims, contour: forbidden)
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
  // Disabled in 0.4.0, now uses callback instead of unquery
  // We still run this function for diagnostics.
  let _ = geometry.unquery(obj, regions: data.regions)
  // Calculate the absolute dimensions of the container
  let (x, y) = geometry.align(obj.align, dx: obj.dx, dy: obj.dy, width: obj.width, height: obj.height)
  let dims = geometry.resolve(data.free-size, x: x, y: y, width: obj.width, height: obj.height)
  // This container actually doesn't have any room.
  // Setting it to just be 0 is a bit of a hack, but it'll simply
  // cause it to be silently skipped.
  if dims.height < 0pt {
    dims.height = 0pt
  }
  // Select only the obstacles that may intersect this container
  let relevant-obstacles = data.obstacles.filter(exclude => {
    geometry.intersects((dims.x, dims.x + dims.width), (exclude.x, exclude.x + exclude.width), tolerance: 1mm) and not is-ignored(obj, exclude)
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
  if horizontal-marks.len() == 2 and dims.height == data.free-size.height {
    dims.height -= 0.1pt
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
  (type: box, display: none, region: dims, contour: all-zones)
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
/// - `none` means no more elements
/// - `()` means no element right now, but keep trying
/// -> opaque
#let create-data(
  /// Dimensions of the page
  /// -> size
  size: none,
  /// Optional nonzero offset on the top left corner
  /// -> size
  page-offset: (x: 0pt, y: 0pt),
  /// Elements to dispense in order
  /// -> (..elem,)
  elems: (),
) = {
  assert(size != none)
  let free-size = (
    width: size.width,
    height: size.height - page-offset.y,
  )
  (
    elems: elems.rev(),
    full-size: size,
    free-size: free-size,
    obstacles: (),
    regions: (:),
  )
}

/// Evaluates an environment passed to a callback.
/// Most of the computations are done by the values, defined in the `query`
/// module.
#let eval-callback-env(env, data) = {
  let evaled = (:)
  for (key, val) in env {
    if "type" in val and val.type == types.query {
      evaled.insert(key, (val.fun)(data))
    } else {
      evaled.insert(key, val)
    }
  }
  evaled
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
  if obj.type == types.elt.placed {
    (blocks-of-placed(data, obj), data)
  } else if obj.type == types.elt.container {
    (blocks-of-container(data, obj), data)
  } else if obj.type == types.elt.callback {
    let env = eval-callback-env(obj.env, data)
    let elts = (obj.fun)(env)
    for elt in elts.rev() {
      // TODO: validate that the element is valid in a callback
      data.elems.push(elt)
    }
    ((), data)
  } else {
    panic("There is a bug in `separate`: encountered a " + repr(obj.type))
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
  for block in elem.contour {
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
/// -> (pages: array(elem), flow: array(elem), opts: dictionary)
#let separate(
  /// A sequence of elements made from @cmd:placed, @cmd:content, @cmd:container, etc.
  /// -> array(elem)
  seq
) = {
  let pages = ()
  let flow = ()
  let elems = ()
  let opts = (:)
  let phase = 0
  let check-phase(cur, require) = {
    if cur <= require {
      require
    } else {
      panic("Incorrect sequence ordering. Options must come before or after every other element.")
    }
  }
  for obj in seq {
    if obj.type in (types.elt.placed, types.elt.container) {
      phase = check-phase(phase, 1)
      elems.push(obj)
    } else if obj.type == types.elt.callback {
      phase = check-phase(phase, 1)
      elems.push(obj)
    } else if obj.type in (types.flow.content, types.flow.colbreak, types.flow.colfill) {
      phase = check-phase(phase, 1)
      flow.push(obj)
    } else if obj.type in (types.elt.pagebreak,) {
      phase = check-phase(phase, 1)
      pages.push(elems)
      elems = ()
    } else if obj.type == types.opt.pre {
      phase = check-phase(phase, 0)
      assert(obj.field not in opts, message: "Cannot override option '" + obj.field + "'")
      opts.insert(obj.field, obj.payload)
    } else if obj.type == types.opt.post {
      phase = check-phase(phase, 2)
      assert(obj.field not in opts, message: "Cannot override option '" + obj.field + "'")
      opts.insert(obj.field, obj.payload)
    } else {
      panic("Unknown element of type " + repr(obj.type))
    }
  }
  for (mod, field) in (
    (opt.debug, "debug"),
    (opt.placement, "virtual-spacing"),
    (opt.placement, "spacing"),
    (opt.overflow, "overflow"),
    //(opt.placement, "full-page"),
  ) {
    if field not in opts {
      opts.insert(field, mod.default.at(field))
    }
  }
  pages.push(elems)
  (flow: flow, pages: pages, opts: opts) 
}

#let current-page-anchor = state("current-page-anchor", (page: 1, x: 0pt, y: 0pt))

/// Gets the position of the current page's anchor.
/// Can be called within a `layout` to know the true available space.
/// See Issue #4 (https://github.com/Vanille-N/meander.typ/issues/4)
/// for what happens when we *don't* have this mechanism.
/// #property(requires-context: true)
///
/// -> (x: length, y: length)
#let get-page-offset() = {
  let anchor = current-page-anchor.get()
  let pos = here().position()
  pos.x -= anchor.x
  pos.y -= anchor.y
  pos
}

/// Determines the appropriate layout invocation based on the placement options.
/// See details on @cmd:meander:reflow.
/// -> function
#let placement-mode(opts) = {
  let page-anchor-update = {
    place(top + left, context {
      current-page-anchor.update(here().position())
    })
  }
  let block-spacing(doc) = if opts.spacing == (:) {
    doc
  } else {
    set block(..opts.spacing)
    doc
  }
  (inner) => {
    page-anchor-update
    block-spacing({
      layout(size => inner(size))
    })
  }
  /*
  if placement == page {
    (
      wrapper:
        (inner) => {
          set block(spacing: 0em)
          page-anchor-update
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
              #page-anchor-update
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
          page-anchor-update
          layout(size => inner(size))
        },
      placeholder: (hgt) => box(width: 100%, height: hgt),
    )
  } else {
    panic("Invalid placement option")
  }
  */
}


