#import "../core/native.typ": _std-target
#import "../layout/geometry.typ": _deixis-box-bounds, _deixis-box-port
#import "connections.typ": _deixis-connection-node

#let _deixis-frame-node(role, page, bounds, identity) = _deixis-connection-node(role, page,
  ("top", "bottom", "left", "right").map(side => _deixis-box-port(bounds, side)),
  bounds: bounds, identity: identity)

// Probes surround only the real painted body frame, never its measurement.
#let _deixis-body-corners(identity) = {
  // HTML export has no geometry for connections to select.
  if _std-target() == "html" { return }
  let probe(corner) = [#metadata((identity: str(identity), corner: corner))<deixis-body-corner>]
  place(top + left, probe("tl"))
  place(top + right, probe("tr"))
  place(bottom + left, probe("bl"))
  place(bottom + right, probe("br"))
}

// Opt-in inline-body frames use native nonbreaking containers. No content is
// measured/replayed here, and adding an edge cannot change their layout.
#let _deixis-single-body-frame(body, identity, inline: false) = {
  let framed = box({
    _deixis-body-corners(identity)
    body
  })
  if inline { framed }
  else { block(above: 0pt, below: 0pt, breakable: false, framed) }
}

// Only a single complete live span can identify a body point. Measurement
// emits neither spans nor destinations. Keep locations, not body content or
// renderer callbacks, and never make a missing end fall back to another label.
#let _deixis-body-spans() = {
  let records = (:)
  let tags = ((<deixis-rendered-start>, "start"), (<deixis-rendered-end>, "end"),
    (<deixis-body-destination>, "destination"))
  for (tag, field) in tags {
    for item in query(tag) {
      let uid = str(item.value.internal-id)
      if uid not in records { records.insert(uid, (start: (), end: (), destination: ())) }
      records.at(uid).at(field).push(item.location())
    }
  }
  let result = (:)
  for (uid, record) in records {
    if record.values().any(locations => locations.len() != 1) { continue }
    let start = record.start.first()
    let end = record.end.first()
    if end.page() < start.page() { continue }
    result.insert(uid, (start: start, end: end, destination: record.destination.first()))
  }
  result
}

#let _deixis-body-point(span, identity, point) = {
  let location = span.at(point)
  let pos = location.position()
  _deixis-frame-node("body", location.page(), _deixis-box-bounds(pos.x, pos.y, pos.x, pos.y),
    (annotation: identity, point: point))
}

// Margin plans already know exact numeric frames. Inset frames use actual native
// corners, including custom placement transforms. Reject fragmented/duplicated
// frames rather than silently selecting one of several live bodies.
#let _deixis-body-nodes(spans: auto) = {
  let result = (:)
  for frame in query(<deixis-body-frame>) {
    let uid = str(frame.value.identity)
    if uid not in result { result.insert(uid, ()) }
    result.at(uid).push(frame.value.node)
  }
  let corners = (:)
  for probe in query(<deixis-body-corner>) {
    let uid = probe.value.identity
    if uid not in corners { corners.insert(uid, ()) }
    corners.at(uid).push(probe)
  }
  for (uid, probes) in corners {
    if probes.len() != 4 or probes.map(p => p.value.corner).dedup().len() != 4 { continue }
    let page = probes.first().location().page()
    if probes.any(p => p.location().page() != page) { continue }
    let pos = probes.map(p => p.location().position())
    let bounds = _deixis-box-bounds(calc.min(..pos.map(p => p.x)), calc.min(..pos.map(p => p.y)),
      calc.max(..pos.map(p => p.x)), calc.max(..pos.map(p => p.y)))
    if uid not in result { result.insert(uid, ()) }
    result.at(uid).push(_deixis-frame-node("body", page, bounds, uid))
  }
  // Every adapter needs one complete live payload and destination. An outer
  // frame alone cannot prove that a custom renderer emitted its body once.
  let spans = if spans == auto { _deixis-body-spans() } else { spans }
  let insets = (:)
  for inset in query(<deixis-inset-note>) {
    insets.insert(str(inset.value.internal-id), true)
  }
  for (uid, frames) in result {
    let span = spans.at(uid, default: none)
    let valid = span != none and frames.all(frame => span.values().all(location => {
      if location.page() != frame.page { return false }
      // Native bottom probes can stay in the first fragment, including when a
      // body continues into another column on the same page. Live boundaries
      // outside that inset rectangle disprove the single-frame interpretation.
      // This is a guard, not a reconstruction of missing continuation bounds.
      if uid not in insets { return true }
      let pos = location.position()
      let b = frame.bounds
      let tolerance = 0.01pt
      (pos.x >= b.left - tolerance and pos.x <= b.right + tolerance and
        pos.y >= b.top - tolerance and pos.y <= b.bottom + tolerance)
    }))
    if not valid { let _ = result.remove(uid) }
  }
  result
}
