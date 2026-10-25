// All public producers normalize here. Private automatic corner identities are
// opaque dictionaries and are validated only by their internal construction.
#let _deixis-validate-pin-name(name) = {
  assert(type(name) in (str, label) and str(name).len() > 0,
    message: "deixis: A public pin name must be a nonempty string or label.")
}

#let _deixis-pin-name(name) = {
  _deixis-validate-pin-name(name)
  str(name)
}

#let _deixis-pin-scope(scope) = {
  assert(scope == none or type(scope) == location or
    (type(scope) in (str, label) and str(scope).len() > 0),
    message: "deixis: Pin scope must be none, a nonempty string/label, or a native location.")
  if type(scope) == label { str(scope) } else { scope }
}

// Strings retain each consumer's legacy selection policy. Structured targets
// are explicit: require a match and default to one unambiguous occurrence.
#let _deixis-pin-selector(target, default: "all") = {
  if type(target) in (str, label) {
    return (name: _deixis-pin-name(target), scope: none, select: default, page: none, required: false)
  }
  assert(type(target) == dictionary and "name" in target,
    message: "deixis: A pin target must be a name or a (name:, scope:, select:, page:) dictionary.")
  assert(target.keys().all(k => k in ("name", "scope", "select", "page")),
    message: "deixis: Unknown pin target field; expected name, scope, select, or page.")
  let name = _deixis-pin-name(target.name)
  let scope = _deixis-pin-scope(target.at("scope", default: none))
  let select = target.at("select", default: "unique")
  assert(select in ("all", "first", "last", "unique"),
    message: "deixis: Pin select must be all, first, last, or unique.")
  let page = target.at("page", default: none)
  assert(page == none or (type(page) == int and page > 0),
    message: "deixis: Pin page must be a positive physical page number or none.")
  (name: name, scope: scope, select: select, page: page, required: true)
}

// The same explicit reference names a routing endpoint, a custom attachment,
// or a waypoint. Padding belongs to region geometry, never to this point.
#let _deixis-routing-pin-spec(value, waypoint: false) = {
  let keys = if waypoint { ("pin", "offset") } else { ("pin", "side", "gap") }
  assert(value.keys().all(k => k in keys),
    message: "deixis: A routing pin accepts " + repr(keys) + ".")
  let _ = _deixis-pin-selector(value.pin, default: "unique")
  if waypoint {
    let offset = value.at("offset", default: (0pt, 0pt))
    assert(type(offset) == array and offset.len() == 2 and offset.all(v => type(v) == length),
      message: "deixis: A pin waypoint offset needs two lengths; a point has no percentage basis.")
    return (pin: value.pin, offset: offset)
  }
  let side = value.at("side", default: auto)
  if type(side) == alignment { side = repr(side) }
  assert(side == auto or side in ("top", "bottom", "left", "right"),
    message: "deixis: A pin port side must be auto, top, bottom, left, or right.")
  let gap = value.at("gap", default: 0pt)
  assert(type(gap) == length, message: "deixis: A pin port gap must be a length.")
  assert(side != auto or gap == 0pt,
    message: "deixis: A pin port with a gap needs an explicit side for its outward direction.")
  (pin: value.pin, side: side, gap: gap)
}

#let _deixis-pin-extra(extra) = {
  assert(type(extra) == dictionary, message: "deixis: Pin extra-data must be a dictionary.")
  let reserved = ("name", "scope", "padding", "dx", "dy", "type", "hidden")
  assert(extra.keys().all(k => k not in reserved),
    message: "deixis: Pin extra-data cannot replace reserved fields " + repr(reserved))
  extra
}

#let _deixis-pin-coordinate(value) = {
  assert(type(value) in (length, ratio, relative),
    message: "deixis: Pin coordinates must be lengths or percentages, optionally combined.")
  value
}

#let _deixis-pin-spec(spec) = {
  if type(spec) == array {
    assert(spec.len() == 2, message: "deixis: A pin coordinate pair needs exactly two entries.")
    spec = (dx: spec.first(), dy: spec.last())
  }
  assert(type(spec) == dictionary, message: "deixis: A pin specification must be a coordinate pair or dictionary.")
  let keys = ("dx", "dy", "padding", "extra-data", "anchor", "offset")
  assert(spec.keys().all(k => k in keys), message: "deixis: Unknown pin option; expected " + repr(keys))
  let dx = spec.at("dx", default: 0pt)
  let dy = spec.at("dy", default: 0pt)
  if "anchor" in spec or "offset" in spec {
    assert("dx" not in spec and "dy" not in spec,
      message: "deixis: Use pin anchor/offset or dx/dy, not both.")
    let anchor = spec.at("anchor", default: top + left)
    let anchors = (
      (top + left, (0%, 0%)), (top + center, (50%, 0%)), (top + right, (100%, 0%)),
      (horizon + left, (0%, 50%)), (horizon + center, (50%, 50%)), (horizon + right, (100%, 50%)),
      (bottom + left, (0%, 100%)), (bottom + center, (50%, 100%)), (bottom + right, (100%, 100%)),
      (left, (0%, 50%)), (right, (100%, 50%)), (top, (50%, 0%)), (bottom, (50%, 100%)),
      (center, (50%, 50%)), (horizon, (50%, 50%)),
    )
    let matched = anchors.find(pair => pair.first() == anchor)
    assert(matched != none, message: "deixis: Pin anchor must be a native alignment.")
    let offset = spec.at("offset", default: (0pt, 0pt))
    assert(type(offset) == array and offset.len() == 2,
      message: "deixis: Pin offset needs exactly two coordinates.")
    dx = matched.last().first() + _deixis-pin-coordinate(offset.first())
    dy = matched.last().last() + _deixis-pin-coordinate(offset.last())
  }
  (dx: _deixis-pin-coordinate(dx), dy: _deixis-pin-coordinate(dy),
    padding: spec.at("padding", default: 0pt),
    extra-data: _deixis-pin-extra(spec.at("extra-data", default: (:))))
}

#let _deixis-pin-delimiter(value) = {
  assert(value == none or type(value) == str,
    message: "deixis: Pin delimiters must be literal strings or none; use pattern for regular expressions.")
  value
}

#let _deixis-escape-pin-delimiter(value) = value.clusters().map(ch => {
  if ch in ("\\", ".", "^", "$", "|", "?", "*", "+", "(", ")", "[", "]", "{", "}") { "\\" + ch } else { ch }
}).join()

#let _deixis-pin-pattern(prefix, postfix, pattern) = {
  if pattern != auto {
    assert(pattern == none or type(pattern) == regex, message: "deixis: Pin pattern must be a regex, none, or auto.")
    return pattern
  }
  prefix = _deixis-pin-delimiter(prefix)
  postfix = _deixis-pin-delimiter(postfix)
  if prefix == none or prefix == "" { return none }
  let start = _deixis-escape-pin-delimiter(prefix)
  if postfix == none or postfix == "" { regex(start + "([a-zA-Z0-9_-]+)") }
  else { regex(start + "([a-zA-Z0-9_-]+?)" + _deixis-escape-pin-delimiter(postfix)) }
}
