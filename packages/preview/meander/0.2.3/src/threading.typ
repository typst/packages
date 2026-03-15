#import "geometry.typ"
#import "elems.typ"
#import "tiling.typ"

/// #property(requires-context: true)
/// Thread text through a list of boxes in order,
/// allowing the boxes to stretch vertically to accomodate for uneven tiling.
///
/// -> (full: , overflow: overflow)
#let smart-fill-boxes(
  /// Flowing text.
  /// -> content
  body,
  /// An array of @type:block to avoid.
  /// -> (..block,)
  avoid: (),
  /// An array of @type:block to fill.
  ///
  /// The #arg[bound] parameter of @type:block is used to know how much
  /// the container is allowed to stretch.
  ///
  /// -> (..block,)
  boxes: (),
  /// Dimensions of the container as given by #typ.layout.
  /// -> size
  size: none,
) = {
  assert(size != none)
  let text-size = text.size
  let par-leading = par.leading

  let full = ()

  let body-queue = body.rev()
  let body = (data: none)
  let cont-queue = boxes.rev()
  let cont = none
  let current-fill = none
  let force-break = false

  while true {
    if cont == none {
      if cont-queue.len() == 0 { break }
      cont = cont-queue.pop()
    }
    if body.data == none {
      if body-queue.len() == 0 { break }
      body = body-queue.pop()
    }

    if body.type == pad {
      full.push((cont, current-fill))
      while cont-queue.len() > 0 {
        full.push((cont-queue.pop(), none))
      }
      break
    }
    if body.type == std.colbreak {
      force-break = true
    }

    if current-fill == none {
      text-size = body.style.at("size", default: text.size)
      par-leading = body.style.at("leading", default: par.leading)
    }
    // Leave it a little room
    // 0.5em margin at the bottom to let it potentially add an extra line
    let old-lo = cont.y + cont.height
    let new-lo = old-lo + geometry.resolve(size, y: 0.5 * text-size).y
    new-lo = calc.min(new-lo, cont.bounds.y + cont.bounds.height)
    for no-box in avoid {
      if tiling.is-ignored(cont, no-box) { continue }
      if geometry.intersects((cont.x, cont.x + cont.width), (no-box.x, no-box.x + no-box.width), tolerance: 1mm) {
        if geometry.intersects((old-lo, new-lo), (no-box.y, no-box.y), tolerance: 0mm) {
          new-lo = calc.min(new-lo, no-box.y)
        }
      }
    }
    cont.height = new-lo - cont.y
    // As much as it wants on the top to fill previously unused space
    let old-hi = cont.y
    let new-hi = cont.bounds.y
    let lineskip = geometry.resolve(size, y: par-leading.em * text-size + par-leading.abs).y
    let lo = cont.y + cont.height
    for no-box in avoid {
      if tiling.is-ignored(cont, no-box) { continue }
      if new-hi > lo { continue }
      if geometry.intersects((cont.x, cont.x + cont.width), (no-box.x, no-box.x + no-box.width), tolerance: 1mm) {
        if geometry.intersects((new-hi, lo), (no-box.y, no-box.y + no-box.height), tolerance: 1mm) {
          new-hi = calc.max(new-hi, no-box.y + no-box.height)
        }
      }
    }
    for (full-box,_) in full {
      if new-hi > lo { continue }
      if geometry.intersects((cont.x, cont.x + cont.width), (full-box.x, full-box.x + full-box.width), tolerance: 1mm) {
        if geometry.intersects((new-hi, lo), (full-box.y, full-box.y + full-box.height + lineskip), tolerance: 1mm) {
          new-hi = calc.max(new-hi, full-box.y + full-box.height + lineskip)
        }
      }
    }
    if new-hi > lo {
      // Drop this box
      cont = none
      continue
    }
    cont.y = new-hi
    cont.height = lo - new-hi

    import "bisect.typ" as bisect
    let max-dims = measure(box(height: cont.height, width: cont.width), ..size)
    let (fits, overflow) = bisect.fill-box(max-dims, size: size, cfg: body.style, [#current-fill] + [#body.data])
    if fits == none {
      // Drop this box
      cont = none
      continue
    }
    if overflow == none and body-queue.len() > 0 and not force-break {
      // It all fits, try more
      current-fill = fits
      body.data = none
      continue
    }
    let actual-dims = measure(box(width: cont.width)[#fits], ..size)
    if actual-dims.height < 1mm {
      // Drop this box
      cont = none
      continue
    }
    cont.width = actual-dims.width
    cont.height = actual-dims.height
    full.push((cont, fits))
    current-fill = none
    body.data = overflow
    if force-break {
      break
    }
  }
  let overflow = body-queue
  if body.data != none { overflow.push(body) }
  (full: full, overflow: overflow.rev())
}

