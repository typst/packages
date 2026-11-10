#import "../core/utils.typ": resolve-signed-len
#import "../layout/geometry.typ": _deixis-block-segments
#import "numeric.typ": _deixis-numeric-length

// Placement is separate from continuation appearance/linking. Freeze font
// lengths once; percentage coordinates retain the physical page width basis.
#let _deixis-spill-spec(value) = {
  if value == auto or value in ("content", "page") { return value }
  assert(type(value) == dictionary and value.keys().sorted() == ("left", "right"),
    message: "deixis: connector.spill must be auto, content, page, or a left/right coordinate dictionary.")
  value.pairs().fold((:), (out, pair) => {
    let (key, v) = pair
    assert(type(v) in (length, ratio, relative), message: "deixis: connector.spill coordinates must be lengths or percentages of page width.")
    let absolute = if type(v) == ratio { 0pt } else { resolve-signed-len(if type(v) == relative { v.length } else { v }) }
    let percent = if type(v) == length { 0% } else if type(v) == relative { v.ratio } else { v }
    assert(_deixis-numeric-length(absolute) and percent / 100% == percent / 100%
      and calc.abs(percent / 100%) < calc.inf,
      message: "deixis: connector.spill coordinates must be finite.")
    out + ((key): absolute + percent)
  })
}

#let _deixis-spill-frame(frame, margin, page-frames) = {
  let result = (left: frame.margins.left, right: frame.width - frame.margins.right,
    top: frame.margins.top, bottom: frame.height - frame.margins.bottom,
    left-space: frame.margins.left, right-space: frame.margins.right)
  if margin == none { return result }
  if "frame" in margin and margin.at("page", default: frame.page) == frame.page { return margin.frame }
  if margin.scope == none { return result }
  let start = query(<deixis-block-start>).find(b => b.value.id == margin.scope)
  let end = query(<deixis-block-end>).find(b => b.value.id == margin.scope)
  let right = query(<deixis-block-right>).find(b => b.value.id == margin.scope)
  let frames = page-frames.fold((:), (out, f) => out + ((str(f.value.page)): f.value))
  let segments = if start == none or end == none or right == none { () }
    else { _deixis-block-segments(start, end, right, frames) }
  let local = segments.find(s => s.page == frame.page)
  assert(local != none, message: "deixis: Automatic margin spill needs an accepted target-scope frame on this physical page; choose connector.spill: content/page or an explicit split.")
  (left: local.start-x, right: local.start-x + local.text-width, top: local.top, bottom: local.bottom,
    left-space: local.l-space, right-space: local.r-space)
}

#let _deixis-spill-region(spec, frame, margin: none, page-frames: ()) = {
  let geometry = _deixis-spill-frame(frame, if spec == auto { margin } else { none }, page-frames)
  let region = if spec == "page" { (left: 0pt, right: frame.width) }
    else if type(spec) == dictionary {
      let coordinate(v) = if type(v) == ratio { frame.width * v }
        else if type(v) == relative { v.length + frame.width * v.ratio } else { v }
      (left: coordinate(spec.left), right: coordinate(spec.right))
    } else if spec == auto and margin != none {
      if margin.side in (left, "left") { (left: geometry.left - geometry.left-space, right: geometry.left) }
      else { (left: geometry.right, right: geometry.right + geometry.right-space) }
    } else { (left: geometry.left, right: geometry.right) }
  assert(region.left >= 0pt and region.right <= frame.width and region.left < region.right,
    message: "deixis: connector.spill needs a positive horizontal interval within the physical page; adjust margins/scope or select an explicit region.")
  region + (top: geometry.top, bottom: geometry.bottom,
    kind: if type(spec) == dictionary { "custom" } else if spec == auto and margin != none { "margin" }
      else if spec == "page" { "page" } else { "content" })
}
