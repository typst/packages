#import "../geometry.typ"

#let fill-boxes(body, ..containers, size: (:)) = {
  let full = ()
  let body = body
  for cont in containers.pos() {
    if body == none {
      full.push((cont, none))
      continue
    }
    import "bisect.typ"
    let max-dims = measure(box(height: cont.height, width: cont.width), ..size)
    let (fits, overflow) = bisect.fill-box(max-dims)[#body]
    full.push((cont, fits))
    body = overflow
  }
  full
}

#let smart-fill-boxes(body, avoid: (), boxes: (), extend: 1em, size: (:)) = {
  let full = ()
  let body = body
  for cont in boxes {
    if body == none {
      full.push((cont, none))
      continue
    }
    // Leave it a little room
    // 1em margin at the bottom to let it potentially add an extra line
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
        if geometry.intersects((new-hi, lo), (full-box.dy, full-box.dy + full-box.height + lineskip)) {
          new-hi = calc.max(new-hi, full-box.dy + full-box.height + lineskip)
        }
      }
    }
    if new-hi > lo { continue }
    cont.dy = new-hi
    cont.height = lo - new-hi

    import "../bisect/default.typ" as bisect
    let max-dims = measure(box(height: cont.height, width: cont.width), ..size)
    let (fits, overflow) = bisect.fill-box(max-dims)[#body]
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

#let reflow(ct) = layout(size => {
  import "../tiling/default.typ" as tiling
  let (flow, obstacles, containers) = tiling.separate(ct)
  let forbidden = tiling.forbidden-rectangles(obstacles, margin: 5pt, size: size)
  forbidden.display

  let allowed = tiling.tolerable-rectangles(containers, avoid: forbidden.rects, size: size)

  for (container, content) in smart-fill-boxes(
    size: size,
    avoid: forbidden.rects,
    boxes: allowed.rects,
    [#flow],
  ) {
    place(dx: container.dx, dy: container.dy, {
      box(width: container.width, height: container.height, {
        content
      })
    })
  }
})

// TODO: count previous allowed boxes when splitting new ones
// TODO: allow controling the alignment inside boxes
// TODO: forbid stretching the boxes beyond major containers
// TODO: handle pagebreaks
// TODO: hyphenation
