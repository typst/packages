#import "../core/utils.typ" as utils

#let _deixis-box-bounds(left, top, right, bottom) = (
  left: left, top: top, right: right, bottom: bottom,
  center-x: (left + right) / 2, center-y: (top + bottom) / 2,
)

// Split a breakable scope into usable page-local frames. Native block insets
// repeat on continuation fragments; include ancestor insets for nested blocks.
// The horizontal offset follows changing duplex margins, while native fragments
// retain the measured block width. The first/last boundaries remain exact probes.
#let _deixis-block-segments(start, end, right-edge, page-frames) = {
  let first = start.location().page()
  let last = end.location().page()
  let first-frame = page-frames.at(str(first), default: none)
  let first-left = if first-frame == none { utils.get-page-margins(first).left } else { first-frame.margins.left }
  let x = start.location().position().x
  let width = right-edge.location().position().x - x
  let result = ()
  for p in range(first, last + 1) {
    let frame = page-frames.at(str(p), default: none)
    if frame == none { continue }
    result.push((
      page: p, inst-id: start.value.id, binding: frame.binding,
      start-x: x + frame.margins.left - first-left, text-width: width,
      top: if p == first { start.location().position().y } else {
        frame.margins.top + start.value.at("top-inset", default: 0pt)
      },
      bottom: if p == last { end.location().position().y } else {
        frame.height - frame.margins.bottom - start.value.at("bottom-inset", default: 0pt)
      },
      l-space: start.value.l-space, r-space: start.value.r-space,
    ))
  }
  result
}

// Inline marks have typographic bounds rather than an arbitrary body's measured
// frame. Keep this approximation identical for anchoring, routing and highlights.
#let _deixis-inline-bounds(x, y, width, size, has-inline-box: false) = {
  let size = if type(size) == length { size } else { 11pt }
  _deixis-box-bounds(x, y - size * if has-inline-box { 0.9 } else { 0.8 }, x + width, y + size * 0.2)
}

#let _deixis-port-bounds(ports) = _deixis-box-bounds(
  calc.min(..ports.map(p => p.x)), calc.min(..ports.map(p => p.y)),
  calc.max(..ports.map(p => p.x)), calc.max(..ports.map(p => p.y)),
)

#let _deixis-box-port(bounds, side, at: 50%, gap: 0pt) = {
  let side = if type(side) == alignment { repr(side) } else { side }
  let vertical = side in ("left", "right")
  let normal = (top: (0, -1), bottom: (0, 1), left: (-1, 0), right: (1, 0)).at(side)
  let x = if vertical { bounds.at(side) } else { bounds.left + (bounds.right - bounds.left) * at }
  let y = if vertical { bounds.top + (bounds.bottom - bounds.top) * at } else { bounds.at(side) }
  (x: x + normal.at(0) * gap, y: y + normal.at(1) * gap,
    dir: if vertical { "horizontal" } else { "vertical" }, id: side, normal: normal)
}

#let _deixis-select-port(ports, spec, bounds) = {
  if type(spec) == dictionary and "resolved-pin" in spec { return spec.resolved-pin }
  let side = if type(spec) == dictionary { spec.side } else { spec }
  let side = if type(side) == alignment { repr(side) } else { side }
  let at = if type(spec) == dictionary { spec.at("at", default: auto) } else { auto }
  let gap = if type(spec) == dictionary { utils.resolve-signed-len(spec.at("gap", default: 0pt)) } else { 0pt }
  let reference = _deixis-box-port(bounds, side, at: if at == auto { 50% } else { at }, gap: gap)
  if at == auto {
    // A selected side is a continuous segment. Fixed percentages are points.
    // Automatic candidate sets remain the placement adapter's policy.
    let vertical = side in ("left", "right")
    reference + (x-range: if vertical { (reference.x, reference.x) } else { (bounds.left, bounds.right) },
      y-range: if vertical { (bounds.top, bounds.bottom) } else { (reference.y, reference.y) })
  } else { reference }
}

// Pure page-segment geometry: points are normalized before entering this layer.
#let _deixis-segment-bounds(points, page-num, page-top, page-bottom, padding: 0pt) = {
  assert(points.len() > 0)
  let first-page = calc.min(..points.map(p => p.page))
  let last-page = calc.max(..points.map(p => p.page))
  let pad = utils.get-margins(padding)
  let left = calc.min(..points.map(p => p.x - p.padding.left)) - utils.resolve-signed-len(pad.left)
  let right = calc.max(..points.map(p => p.x + p.padding.right)) + utils.resolve-signed-len(pad.right)
  let local = points.filter(p => p.page == page-num)
  let top = page-top
  let bottom = page-bottom
  if local.len() > 0 {
    if page-num == first-page {
      top = calc.min(..local.map(p => p.y - p.padding.top)) - utils.resolve-signed-len(pad.top)
    }
    if page-num == last-page {
      bottom = calc.max(..local.map(p => p.y + p.padding.bottom)) + utils.resolve-signed-len(pad.bottom)
    }
  } else if page-num < first-page { top = page-bottom } else if page-num > last-page { bottom = page-top }
  _deixis-box-bounds(left, top, right, bottom) + (first-page: first-page, last-page: last-page)
}

// Document adapter: convert locations and context-dependent lengths once.
#let _deixis-region-bounds(pins, page-num, padding: 0pt) = {
  let frames = query(<deixis-page-frame>)
  let frame = frames.find(f => f.value.page == page-num)
  let margins = if frame == none { utils.get-page-margins(page-num) } else { frame.value.margins }
  let page-height = if frame == none { page.height } else { frame.value.height }
  let height = utils.resolve-len(if type(page-height) == length { page-height } else { utils.default-page-size.height })
  let points = pins.map(pin => {
    let pos = pin.location().position()
    (page: pin.location().page(), x: pos.x, y: pos.y,
      padding: pin.value.at("padding", default: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt)))
  })
  _deixis-segment-bounds(points, page-num, utils.resolve-len(margins.top),
    height - utils.resolve-len(margins.bottom), padding: padding)
}
