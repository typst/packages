#import "occurrences.typ": _deixis-occurrence-name
#import "pins.typ": _deixis-pin-selector, _deixis-pin-name, _deixis-pin-scope

// A role-specific shorthand keeps simple calls short without using one label as
// an ambiguous body/mark/occurrence selector. Selection never changes placement.
#let _deixis-endpoint-selector(value, role) = {
  if type(value) == dictionary and "node" in value {
    assert(value.keys().all(k => k in ("node", "scope", "page")),
      message: "deixis: An attached node endpoint accepts node, scope and page; configure sockets through connector.ports.")
    let page = value.at("page", default: none)
    assert(page == none or (type(page) == int and page > 0),
      message: "deixis: An attached node endpoint page must be none or a positive physical page integer.")
    return (role: role, node: _deixis-pin-name(value.node), scope: _deixis-pin-scope(value.at("scope", default: none)), page: page)
  }
  if type(value) == dictionary and "pin" in value {
    assert(value.keys() == ("pin",), message: "deixis: A connection pin endpoint accepts only pin; configure its direction/gap through connector.ports.")
    let _ = _deixis-pin-selector(value.pin, default: "unique")
    return (role: role, pin: value.pin)
  }
  if type(value) in (str, label) { value = ((role): value) }
  let keys = if role == "mark" { ("mark", "occurrence") } else { ("body", "point") }
  assert(type(value) == dictionary and role in value and value.keys().all(k => k in keys),
    message: "deixis: Connection " + role + " selector must be an ID/label or a dictionary with " + repr(keys) + ".")
  let id = value.at(role)
  assert(type(id) in (str, label) and str(id).len() > 0,
    message: "deixis: Connection endpoint ID must be a nonempty string or label.")
  let result = (role: role, target: str(id), occurrence: if role == "mark" {
    _deixis-occurrence-name(value.at("occurrence", default: none))
  } else { none })
  if role == "body" {
    let point = value.at("point", default: none)
    assert(point == none or point in ("start", "end"),
      message: "deixis: Connection body point must be start, end, or none for the complete frame.")
    result += (point: point)
  }
  result
}
