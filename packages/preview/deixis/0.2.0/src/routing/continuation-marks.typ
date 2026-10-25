#import "heads.typ": _deixis-resolve-stroke
#import "../core/utils.typ": resolve-signed-len

// Keep visual presets in the existing continuation field. Callbacks retain their
// local origin/peer lookup; auto retains the original query-free filled dot.
#let _deixis-continuation-spec(value) = {
  if value in (auto, none) or type(value) == function { return value }
  let spec = if type(value) == str { (shape: value) } else { value }
  assert(type(spec) == dictionary and spec.keys().all(k => k in ("shape", "size", "stroke", "fill", "link")),
    message: "deixis: connector.continuation must be auto, none, dot, portal, a renderer, or a shape/size/stroke/fill/link dictionary.")
  let shape = spec.at("shape", default: "portal")
  assert(shape in ("dot", "portal"), message: "deixis: connector.continuation shape must be dot or portal.")
  let size = spec.at("size", default: auto)
  assert(size == auto or type(size) == length,
    message: "deixis: connector.continuation size must be auto or a positive length.")
  if size != auto {
    size = resolve-signed-len(size)
    assert(size > 0pt, message: "deixis: connector.continuation size must be positive.")
  }
  let target = spec.at("link", default: none)
  assert(target in (none, "peer", "counterpart"),
    message: "deixis: connector.continuation link must be none, peer or counterpart.")
  (shape: shape, size: size, stroke: spec.at("stroke", default: auto), fill: spec.at("fill", default: auto), link: target)
}

#let _deixis-prepare-continuation-mark(spec, shaft-stroke) = {
  if type(spec) != dictionary or shaft-stroke == none { return none }
  let shaft = _deixis-resolve-stroke(shaft-stroke)
  let outline = if spec.stroke == auto {
    if spec.shape == "portal" { shaft } else { none }
  } else { _deixis-resolve-stroke(spec.stroke) }
  if outline != none {
    // Small rings remain solid even on a dashed connector.
    outline = stroke(paint: outline.paint, thickness: outline.thickness, dash: none)
  }
  let fill = if spec.fill == auto { if spec.shape == "portal" { none } else { shaft.paint } } else { spec.fill }
  if outline == none and fill == none { return none }
  let size = if spec.size == auto {
    if spec.shape == "dot" { 3 * resolve-signed-len(shaft.thickness) }
    else { calc.max(4pt, 3 * resolve-signed-len(shaft.thickness)) }
  } else { spec.size }
  let radius = size / 2
  // End the shaft at the ring's inner edge without an opaque background patch.
  // Account for round/square caps so their ink cannot enter the hollow center.
  let cap = if shaft.cap in ("round", "square") { resolve-signed-len(shaft.thickness) / 2 } else { 0pt }
  let trim = if spec.shape == "portal" {
    calc.max(0pt, radius - if outline == none { 0pt } else { resolve-signed-len(outline.thickness) / 2 }) + cap
  } else { 0pt }
  (shape: spec.shape, size: size, radius: radius, stroke: outline, fill: fill, trim: trim, link: spec.link)
}

#let _deixis-paint-continuation-mark(mark, point, document: (:)) = {
  let drawing = circle(radius: mark.radius, fill: mark.fill, stroke: mark.stroke)
  let continuation = document.at("continuation", default: none)
  if mark.link != none and continuation != none {
    let target = if mark.link == "peer" { continuation.peer } else { (continuation.counterpart)() }
    if target != none { drawing = link(target.destination, drawing) }
  }
  place(top + left, dx: point.first() - mark.radius, dy: point.last() - mark.radius,
    drawing)
}
