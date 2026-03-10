#import "geometry.typ"

/// Thread text through a list of boxes in order,
/// allowing the boxes to stretch vertically to accomodate for uneven tiling.
///
/// -> (..content,)
#let smart-fill-boxes(
  /// Flowing text.
  /// -> content
  body,
  /// Obstacles to avoid.
  /// A list of `(x: length, y: length, width: length, height: length)`.
  /// -> (..block,)
  avoid: (),
  /// Boxes to fill.
  /// A list of `(x: length, y: length, width: length, height: length, bound: block)`.
  ///
  /// `bound` is the upper limit of how much to stretch the container,
  /// i.e. also `(x: length, y: length, width: length, height: length)`.
  ///
  /// -> (..block,)
  boxes: (),
  /// How much the baseline can extend downwards (within the limits of `bounds`).
  /// -> length
  extend: 1em,
  /// Dimensions of the container as given by `layout`.
  /// -> (width: length, height: length)
  size: none,
) = {
  assert(size != none)
  let full = ()
  let body-queue = body.rev()
  let body = none
  for cont in boxes {
    if body == none {
      if body-queue.len() == 0 {
        full.push((cont, none))
        continue
      } else {
        body = body-queue.pop().data
      }
    }
    // Leave it a little room
    // 0.5em margin at the bottom to let it potentially add an extra line
    let old-lo = cont.dy + cont.height
    let new-lo = old-lo + geometry.resolve(size, y: 0.5em).y
    new-lo = calc.min(new-lo, cont.bounds.y + cont.bounds.height)
    for no-box in avoid {
      if geometry.intersects((cont.dx, cont.dx + cont.width), (no-box.x, no-box.x + no-box.width), tolerance: 1mm) {
        if geometry.intersects((old-lo, new-lo), (no-box.y, no-box.y), tolerance: 0mm) {
          new-lo = calc.min(new-lo, no-box.y)
        }
      }
    }
    cont.height = new-lo - cont.dy
    // As much as it wants on the top to fill previously unused space
    let old-hi = cont.dy
    let new-hi = cont.bounds.y
    let lineskip = geometry.resolve(size, y: 0.65em).y
    let lo = cont.dy + cont.height
    for no-box in avoid {
      if new-hi > lo { continue }
      if geometry.intersects((cont.dx, cont.dx + cont.width), (no-box.x, no-box.x + no-box.width), tolerance: 1mm) {
        if geometry.intersects((new-hi, lo), (no-box.y, no-box.y + no-box.height), tolerance: 1mm) {
          new-hi = calc.max(new-hi, no-box.y + no-box.height)
        }
      }
    }
    for (full-box,_) in full {
      if new-hi > lo { continue }
      if geometry.intersects((cont.dx, cont.dx + cont.width), (full-box.dx, full-box.dx + full-box.width), tolerance: 1mm) {
        if geometry.intersects((new-hi, lo), (full-box.dy, full-box.dy + full-box.height + lineskip), tolerance: 1mm) {
          new-hi = calc.max(new-hi, full-box.dy + full-box.height + lineskip)
        }
      }
    }
    if new-hi > lo { continue }
    cont.dy = new-hi
    cont.height = lo - new-hi

    import "bisect.typ" as bisect
    let max-dims = measure(box(height: cont.height, width: cont.width), ..size)
    let (fits, overflow) = bisect.fill-box(max-dims, size: size)[#body]
    if fits == none { continue }
    let actual-dims = measure(box(width: cont.width)[#fits], ..size)
    if actual-dims.height < 1mm { continue }
    cont.width = actual-dims.width
    cont.height = actual-dims.height
    full.push((cont, fits))
    body = overflow
  }
  full
}

/// Segment the input content according to the tiling algorithm,
/// then thread the flowing text through it.
///
/// -> content
#let reflow(
  /// See module `tiling` for how to format this content.
  /// -> content
  ct,
  /// Whether to show the boundaries of boxes.
  /// -> bool
  debug: false,
) = context layout(size => {
  import "tiling.typ" as tiling
  let (flow, obstacles, containers) = tiling.separate(ct)
  let forbidden = tiling.forbidden-rectangles(obstacles, size: size)
  forbidden.display
  if debug {
    forbidden.debug
  }

  let allowed = tiling.tolerable-rectangles(containers, avoid: forbidden.rects, size: size)

  for (container, content) in smart-fill-boxes(
    size: size,
    avoid: forbidden.rects,
    boxes: allowed.rects,
    flow,
  ) {
    place(dx: container.dx, dy: container.dy, {
      box(width: container.width, height: container.height, stroke: if debug { green } else { none }, {
        content
      })
    })
  }
})

