#import "geometry.typ": _deixis-segment-length, _deixis-cut-segment
#import "../core/utils.typ": resolve-signed-len

// Public cut records describe distance along the original drawable route.
// None and an empty array deliberately leave the existing shaft unchanged.
#let _deixis-cut-specs(value) = {
  if value == none { return () }
  let specs = if type(value) == dictionary { (value,) } else { value }
  assert(type(specs) == array, message: "deixis: connector.cuts must be none, a cut dictionary, or an array of cut dictionaries.")
  specs.map(spec => {
    assert(type(spec) == dictionary and spec.keys().all(k => k in ("at", "length", "from", "to")),
      message: "deixis: connector.cuts records accept (at:, length:) or (from:, to:).")
    let centered = "at" in spec or "length" in spec
    assert(if centered { spec.keys().sorted() == ("at", "length") }
      else { spec.keys().sorted() == ("from", "to") },
      message: "deixis: connector.cuts records need exactly (at:, length:) or (from:, to:), without mixing forms.")
    let resolved = (:)
    for (key, value) in spec {
      assert(type(value) in (length, ratio),
        message: "deixis: connector.cuts " + key + " must be a nonnegative length or percentage.")
      let value = if type(value) == length { resolve-signed-len(value) } else { value }
      assert(if type(value) == length { value >= 0pt } else { value >= 0% },
        message: "deixis: connector.cuts " + key + " cannot be negative.")
      if key == "length" {
        assert(if type(value) == length { value > 0pt } else { value > 0% },
          message: "deixis: connector.cuts length must be positive.")
      }
      resolved.insert(key, value)
    }
    resolved
  })
}

// Resolve, clip, sort, and merge before touching geometry. Native provisional
// routes may be short/empty: out-of-range and reversed intervals stay empty.
#let _deixis-prepare-cuts(specs, length) = {
  let point(value) = if type(value) == ratio { value * length } else { value }
  let intervals = ()
  for spec in specs {
    let a = if "at" in spec { point(spec.at) - point(spec.length) / 2 } else { point(spec.from) }
    let b = if "at" in spec { point(spec.at) + point(spec.length) / 2 } else { point(spec.to) }
    a = calc.max(0pt, calc.min(a, length))
    b = calc.max(0pt, calc.min(b, length))
    if b - a > 0.00001pt { intervals.push((from: a, to: b)) }
  }
  let merged = ()
  for interval in intervals.sorted(key: i => i.from) {
    if merged.len() > 0 and interval.from <= merged.last().to + 0.00001pt {
      merged.last().to = calc.max(merged.last().to, interval.to)
    } else { merged.push(interval) }
  }
  merged
}

#let _deixis-segment-interval(segment, start, end, length) = {
  let kept = if end >= length - 0.00001pt { segment }
    else { _deixis-cut-segment(segment, end).first() }
  if start <= 0.00001pt { kept } else { _deixis-cut-segment(kept, start).last() }
}

// Work only on head-trimmed geometry, with an offset into the original route.
// Splitting line/cubic records restricts the existing curve; no interpolation,
// node selection, layout query, head sizing, or body execution occurs here.
#let _deixis-cut-path(segments, cuts, offset: 0pt) = {
  if cuts.len() == 0 { return segments }
  let result = ()
  let current = offset
  let first-cut = 0
  for segment in segments {
    let length = _deixis-segment-length(segment)
    let end = current + length
    while first-cut < cuts.len() and cuts.at(first-cut).to <= current { first-cut += 1 }
    let cursor = current
    let index = first-cut
    while index < cuts.len() and cuts.at(index).from < end {
      let cut = cuts.at(index)
      let before = calc.min(end, cut.from)
      if before - cursor > 0.00001pt {
        result.push(_deixis-segment-interval(segment, cursor - current, before - current, length))
      }
      cursor = calc.max(cursor, cut.to)
      if cursor >= end { break }
      index += 1
    }
    if end - cursor > 0.00001pt {
      result.push(_deixis-segment-interval(segment, cursor - current, length, length))
    }
    current = end
  }
  result
}
