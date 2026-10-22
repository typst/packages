#import "native.typ": *
// Native rectangular values are distinct from component/type scope maps.
#let _deixis-edge-stroke(value) = type(value) == dictionary and (
  value.len() == 0 or value.keys().any(k => k in ("top", "right", "bottom", "left", "x", "y", "rest"))
)

#let _deixis-normalize-stroke(value) = {
  if value in (none, auto) { return value }
  if _deixis-edge-stroke(value) {
    // Let Typst expand x/y/rest and validate native edge names. Missing edges
    // stay absent here; consumers requesting all four edges default to none.
    let edges = rect(stroke: value).stroke
    if type(edges) != dictionary { return _deixis-normalize-stroke(edges) }
    let normalized = (:)
    for (side, stroke) in edges { normalized.insert(side, _deixis-normalize-stroke(stroke)) }
    return normalized
  }
  let s = _std-stroke(value)
  if s.thickness != auto { return s }
  _std-stroke(cap: s.cap, dash: s.dash, join: s.join, miter-limit: s.miter-limit,
    paint: s.paint, thickness: 1pt)
}

#let _deixis-stroke-edges(value) = {
  if value in (none, auto) { return none }
  let stroke = _deixis-normalize-stroke(value)
  if type(stroke) != dictionary { return (top: stroke, right: stroke, bottom: stroke, left: stroke) }
  (top: stroke.at("top", default: none), right: stroke.at("right", default: none),
    bottom: stroke.at("bottom", default: none), left: stroke.at("left", default: none))
}

#let _deixis-radius-corners(value) = {
  // Native box expands top/bottom/left/right/rest consistently, including mixed
  // shorthand and explicit corner precedence. Inspecting it does not lay it out.
  let radius = if type(value) == dictionary { box(radius: value).radius } else { value }
  let scalar = if radius == auto { 0pt } else { radius }
  let corner(key) = {
    let v = if type(radius) == dictionary { radius.at(key, default: 0pt) } else { scalar }
    if type(v) == relative and v.ratio == 0% { v.length } else { v }
  }
  (top-left: corner("top-left"), top-right: corner("top-right"),
    bottom-left: corner("bottom-left"), bottom-right: corner("bottom-right"))
}
