// Pair accepted physical fragments by their declaration, never by endpoint
// names or coincident relay coordinates. Evidence is independent of user output.
// Custom continuation/shaft callbacks and opt-in counterpart-linked native
// markers publish it; ordinary native dots/portals add no pairing lookup.
#let _deixis-continuation-site(identity, layer, continuation) = {
  if identity == none or continuation == none or continuation.at("status", default: "incomplete") != "resolved" { return [] }
  [#metadata((identity: identity, layer: layer, page: continuation.page,
    direction: continuation.direction, point: continuation.point, normal: continuation.normal))<deixis-continuation-site>]
}

// A lazy contextual read avoids a remote query/layout dependency for callbacks
// that only need the existing real peer node. Never route or replay callbacks to
// manufacture the opposite point. A suppressed/unresolved fragment stays absent.
#let _deixis-counterpart-lookup(identity, layer, direction, peer-page) = () => {
  if identity == none or peer-page == none { return none }
  let opposite = if direction == "outgoing" { "incoming" } else { "outgoing" }
  let found = query(<deixis-continuation-site>).map(m => m.value).filter(v => (
    v.identity == identity and v.layer == layer and v.direction == opposite and v.page == peer-page
  ))
  assert(found.len() <= 1,
    message: "deixis: A continuation counterpart needs one accepted opposite fragment on its physical page; duplicated painting is ambiguous.")
  if found.len() == 0 { return none }
  let site = found.first()
  (page: site.page, point: site.point, normal: site.normal, direction: site.direction,
    destination: (page: site.page, x: site.point.first(), y: site.point.last()))
}
