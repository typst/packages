#import "../core/declarations.typ": _deixis-omitted
#import "../core/query.typ": _deixis-anchor-index, _deixis-pins-for
#import "../core/references.typ": _deixis-reference-identities
#import "../core/occurrences.typ": _deixis-occurrence-index
#import "../layout/geometry.typ": _deixis-inline-bounds, _deixis-region-bounds
#import "frames.typ": _deixis-body-nodes, _deixis-frame-node, _deixis-body-spans, _deixis-body-point
#import "occurrences.typ": _deixis-occurrence-nodes
#import "pins.typ": _deixis-pin-node
#import "../core/visibility.typ": _deixis-is-hidden, _deixis-hidden-identities
#import "attached.typ": _deixis-attached-nodes, _deixis-attached-endpoint

// Query evidence only. No live content, measuring, or destination fallback.
#let _deixis-endpoint-index() = {
  let locations = (:)
  for mark in query(<deixis-mark-destination>) {
    let uid = str(mark.value.internal-id)
    if uid not in locations { locations.insert(uid, mark.location()) }
  }
  let regions = (:)
  for region in query(<deixis-region-occurrence>) {
    let data = region.value
    if data.occurrence-name == none { continue }
    let uid = str(data.internal-id)
    if uid not in regions { regions.insert(uid, (:)) }
    regions.at(uid).insert(data.occurrence-name, region)
  }
  let spans = _deixis-body-spans()
  let hidden-bodies = _deixis-hidden-identities(selector(<deixis-inline-note>).or(<deixis-inset-note>)
    .or(<deixis-margin-note>).or(<deixis-footnote>).or(<deixis-endnote>).or(<deixis-body-visibility>))
  (identities: _deixis-reference-identities(), anchors: _deixis-anchor-index(),
    locations: locations, bodies: _deixis-body-nodes(spans: spans), spans: spans,
    occurrences: _deixis-occurrence-index(), repeated: _deixis-occurrence-nodes(), repeated-regions: regions,
    hidden-bodies: hidden-bodies, attached: _deixis-attached-nodes())
}

#let _deixis-region-node(index, region, identity, target-page) = {
  let pins = _deixis-pins-for(index.anchors.pin-index, region.value.pins)
  if pins.len() == 0 { return none }
  let first = calc.min(..pins.map(p => p.location().page()))
  let last = calc.max(..pins.map(p => p.location().page()))
  let page = if target-page == none { first } else { calc.clamp(target-page, first, last) }
  let bounds = _deixis-region-bounds(pins, page, padding: region.value.styles.at("padding", default: 0pt))
  _deixis-frame-node("mark", page, bounds, identity)
}

#let _deixis-original-node(index, uid, target-page) = {
  let region = index.anchors.regions.at(uid, default: none)
  if region != none { return _deixis-region-node(index, region, (annotation: uid, occurrence: none), target-page) }
  let mark = index.anchors.marks.at(uid, default: none)
  let loc = index.locations.at(uid, default: none)
  if mark == none or loc == none { return none }
  let data = mark.value
  let pos = loc.position()
  let bounds = _deixis-inline-bounds(pos.x, pos.y, data.at("marker-width", default: 0pt),
    data.at("text-size", default: 11pt), has-inline-box: data.at("has-inline-box", default: false))
  _deixis-frame-node("mark", loc.page(), bounds, (annotation: uid, occurrence: none))
}

#let _deixis-connection-body-node(index, target, target-id, validate: false) = {
  let fail(message) = { if validate { panic("deixis: " + message) }; none }
  let body = none
  if "node" in target {
    body = _deixis-attached-endpoint(index.attached, target, target.at("declaration-page", default: none), "body", validate: validate)
    if body == none or _deixis-is-hidden(body) { return none }
  } else if "pin" in target {
    body = _deixis-pin-node(index.anchors.pin-index, target.pin, "body", validate: validate)
    if body == none { return none }
    if _deixis-is-hidden(body) { return none }
  } else if target.point != none {
    let span = index.spans.at(target-id, default: none)
    if span == none {
      return fail("Connection body point " + repr(target.target) + " requires one complete live body span and destination. Print collected notes and preserve exactly one start/end span; missing, suppressed, or duplicated bodies cannot be selected.")
    }
    body = _deixis-body-point(span, target-id, target.point)
    let frames = index.bodies.at(target-id, default: ())
    if frames.len() == 1 and "margin-context" in frames.first() {
      body += (margin-context: frames.first().margin-context)
    }
  } else {
    let note = index.identities.notes.at(target-id)
    if note.at("body-type", default: none) not in ("margin-note", "inset-note", "inline-note") {
      return fail("Connection body endpoints currently require a margin, inset, or framed inline body. Use point: start or end for a printed collected body.")
    }
    let bodies = index.bodies.at(target-id, default: ())
    if bodies.len() != 1 {
      if note.at("body-type", default: none) == "inline-note" {
        return fail("Connection inline body " + repr(target.target) + " needs one painted frame. Set breakable: false on deixis-inline-note-body and preserve its single live body, or choose point: start or end.")
      }
      return fail("Connection body " + repr(target.target) + " needs one painted frame with one complete live span and destination; missing, fragmented (including same-page columns), duplicated, or out-of-frame inset bodies cannot be selected. Use point: start or end for a live content boundary.")
    }
    body = bodies.first()
  }
  body
}

#let _deixis-connection-endpoints(index, declaration, validate: false) = {
  let fail(message) = {
    if validate { panic("deixis: " + message) }
    none
  }
  let source = declaration.source
  let target = declaration.target
  let external-source = "pin" in source or "node" in source
  let external-target = "pin" in target or "node" in target
  let source-id = if external-source { none } else { index.identities.aliases.at(source.target, default: none) }
  let target-id = if external-target { none } else { index.identities.aliases.at(target.target, default: none) }
  if (not external-source and _deixis-omitted(source.target)) or (not external-target and _deixis-omitted(target.target)) { return none }
  if not external-source and source-id == none { return fail("Unknown connection mark target " + repr(source.target) + ".") }
  if not external-target and target-id == none { return fail("Unknown connection body target " + repr(target.target) + ".") }
  if not external-source and source.occurrence != none {
    let sites = index.occurrences.at(source-id, default: (:))
    if source.occurrence not in sites {
      return fail("Unknown connection occurrence " + repr(source.occurrence) + " for " + repr(source.target) + ".")
    }
    let site = sites.at(source.occurrence)
    let region = index.repeated-regions.at(source-id, default: (:)).at(source.occurrence, default: none)
    let frame = index.repeated.at(source-id, default: (:)).at(source.occurrence, default: none)
    if (
      (region != none and _deixis-is-hidden(region.value)) or (frame != none and _deixis-is-hidden(frame))
        or _deixis-is-hidden(site.value)
    ) { return none }
  } else if not external-source {
    let mark = index.anchors.regions.at(source-id, default: index.anchors.marks.at(source-id, default: none))
    if mark != none and _deixis-is-hidden(mark.value) { return none }
  }
  if _deixis-is-hidden(declaration) or (target-id != none and target-id in index.hidden-bodies) { return none }
  // A covered pin source suppresses the edge before requiring a live target
  // frame/span, just as covered original and reused mark sources do.
  let pin-source = none
  if external-source {
    pin-source = if "node" in source {
      _deixis-attached-endpoint(index.attached, source, declaration.location.page(), "mark", validate: validate)
    } else { _deixis-pin-node(index.anchors.pin-index, source.pin, "mark", validate: validate) }
    if pin-source == none or _deixis-is-hidden(pin-source) { return none }
  }
  let body = _deixis-connection-body-node(index, if "node" in target {
    target + (declaration-page: declaration.location.page())
  } else { target }, target-id, validate: validate)
  if body == none { return none }
  let mark = if external-source {
    pin-source
  } else if source.occurrence == none { _deixis-original-node(index, source-id, body.page) } else {
    let region = index.repeated-regions.at(source-id, default: (:)).at(source.occurrence, default: none)
    if region != none {
      _deixis-region-node(index, region, (annotation: source-id, occurrence: source.occurrence), body.page)
    } else { index.repeated.at(source-id, default: (:)).at(source.occurrence, default: none) }
  }
  if mark == none {
    if external-source { return none }
    return fail("Connection source " + repr(source.target) + " has no drawable mark frame. Inline repeats without a marker/passage and unresolved region pins have no routing ports.")
  }
  if _deixis-is-hidden(mark) { return none }
  let accent(id) = if id == none { none } else { index.identities.notes.at(id).at("accent", default: none) }
  let paint = accent(target-id)
  (source: mark, target: body, accent: if paint != none { paint } else { accent(source-id) })
}
