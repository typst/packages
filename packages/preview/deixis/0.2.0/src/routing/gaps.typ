#import "geometry.typ": _deixis-add, _deixis-scale, _deixis-distance, _deixis-segment-tangent
#import "heads.typ": _deixis-resolve-stroke
#import "../core/utils.typ": resolve-signed-len
#import "../core/native.typ": *

// Gap decoration is independent from endpoint heads and page-continuation dots.
#let _deixis-gap-mark-spec(value) = {
  if value == none { return none }
  let spec = if type(value) == str { (shape: value) } else { value }
  assert(type(spec) == dictionary and spec.keys().all(k => k in ("shape", "size", "stroke")),
    message: "deixis: gap-marks must be none, bar, slash, or a dictionary with shape, size, and stroke.")
  let shape = spec.at("shape", default: "slash")
  assert(shape in ("bar", "slash"), message: "deixis: gap-marks shape must be bar or slash.")
  let size = spec.at("size", default: auto)
  assert(size == auto or type(size) == length,
    message: "deixis: gap-marks size must be auto or a positive length; percentages have no gap-size basis.")
  if size != auto {
    assert(resolve-signed-len(size) > 0pt, message: "deixis: gap-marks size must be positive.")
  }
  (shape: shape, size: size, stroke: spec.at("stroke", default: auto))
}

#let _deixis-prepare-gap-marks(spec, shaft-stroke) = {
  let spec = _deixis-gap-mark-spec(spec)
  if spec == none or shaft-stroke == none { return none }
  let line-stroke = _deixis-resolve-stroke(shaft-stroke)
  let mark-stroke = if spec.stroke == auto { line-stroke } else { _deixis-resolve-stroke(spec.stroke) }
  if mark-stroke == none { return none }
  // Short continuation ticks stay solid, even on a dashed/dotted shaft.
  mark-stroke = _std-stroke(paint: mark-stroke.paint, thickness: mark-stroke.thickness,
    cap: mark-stroke.cap, join: mark-stroke.join, dash: none, miter-limit: mark-stroke.miter-limit)
  let size = if spec.size == auto { calc.max(5pt, resolve-signed-len(mark-stroke.thickness) * 4) }
    else { resolve-signed-len(spec.size) }
  spec + (size: size, stroke: mark-stroke)
}

// A gap needs visible geometry on both sides. This naturally excludes undrawn
// endpoint chunks and gaps whose neighboring shaft was consumed by a head.
#let _deixis-path-gaps(segments) = {
  let gaps = ()
  for i in range(1, segments.len()) {
    let before = segments.at(i - 1)
    let after = segments.at(i)
    if _deixis-distance(before.end, after.start) > 0.00001pt {
      gaps.push((start: before.end, end: after.start,
        start-tangent: _deixis-segment-tangent(before, end: true),
        end-tangent: _deixis-segment-tangent(after)))
    }
  }
  gaps
}

#let _deixis-paint-gap-marks(gaps, spec, origin: (0pt, 0pt)) = {
  if spec == none { return () }
  let elements = ()
  for gap in gaps {
    for (tip, tangent) in ((gap.start, gap.start-tangent), (gap.end, gap.end-tangent)) {
      let normal = (-tangent.at(1), tangent.at(0))
      let axis = if spec.shape == "bar" { normal }
        else { ((normal.at(0) + tangent.at(0)) / calc.sqrt(2), (normal.at(1) + tangent.at(1)) / calc.sqrt(2)) }
      let center = _deixis-add(origin, tip)
      let start = _deixis-add(center, _deixis-scale(axis, -spec.size / 2))
      let end = _deixis-add(center, _deixis-scale(axis, spec.size / 2))
      elements.push(place(top + left, line(start: start, end: end, stroke: spec.stroke)))
    }
  }
  elements
}
