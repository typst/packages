#import "state.typ": deixis-system, _deixis-registry
#import "occurrences.typ": _deixis-occurrence-destinations, _deixis-occurrence-destination

#let _deixis-index-reference(aliases, key, uid) = {
  assert(key not in aliases or aliases.at(key) == uid,
    message: "deixis: Duplicate note ID " + repr(key) + "; this ID already belongs to another annotation.")
  aliases.insert(key, uid)
  aliases
}

// A shared index of identities and destinations, never rendered content. Inspect
// only known Deixis declarations; unrelated labelled metadata remains native.
#let _deixis-reference-identities() = {
  let registry = _deixis-registry(deixis-system.final())
  let notes = registry.notes
  let aliases = registry.id-index
  let elements = query(selector(<deixis-inline-note>).or(<deixis-footnote>)
    .or(<deixis-endnote>).or(<deixis-margin-note>).or(<deixis-inset-note>))
  for element in elements {
    let data = element.value
    let uid = data.at("internal-id", default: none)
    if uid == none { continue }
    uid = str(uid)
    if uid not in notes or notes.at(uid).at("count-id", default: none) == none { notes.insert(uid, data) }
    let public-id = data.at("id", default: none)
    if public-id != none { aliases = _deixis-index-reference(aliases, str(public-id), uid) }
  }
  for uid in notes.keys() {
    for prefix in ("deixis-body-", "deixis-mark-") {
      let key = prefix + uid
      if key not in aliases { aliases.insert(key, uid) }
    }
  }
  (notes: notes, aliases: aliases)
}

#let _deixis-validate-reference-identities() = {
  let identities = _deixis-reference-identities()
  let seen = (:)
  for destination in query(<deixis-body-destination>) {
    let data = destination.value
    let uid = str(data.internal-id)
    // Public layout helpers can also format synthetic records independently
    // of annotations. Their caller owns those identities and repetitions.
    if uid not in identities.notes { continue }
    assert(uid not in seen,
      message: "deixis: A body emitted more than one destination for "
        + repr(data.at("id", default: uid))
        + ". Custom renderers must emit deixis-generate-body-marker or deixis-generate-body-meta once, not both, and must not duplicate a complete built-in renderer.")
    seen.insert(uid, true)
  }
}

#let _deixis-reference-index(details: false) = {
  let identities = _deixis-reference-identities()
  let notes = identities.notes
  let aliases = identities.aliases
  let locations = (:)
  let elements = (:)
  for element in query(selector(<deixis-body-destination>).or(<deixis-mark-destination>)) {
    let data = element.value
    let uid = str(data.internal-id)
    let is-body = element.label == <deixis-body-destination>
    let key = (if is-body { "deixis-body-" } else { "deixis-mark-" }) + uid
    if key not in locations {
      locations.insert(key, element.location())
      if details { elements.insert(key, element) }
    }
    if is-body {
      if uid not in notes or notes.at(uid).at("count-id", default: none) == none { notes.insert(uid, data) }
      let public-id = data.at("id", default: none)
      if public-id != none {
        aliases.insert(str(public-id), uid)
        if str(public-id) not in locations { locations.insert(str(public-id), element.location()) }
      }
    }
  }
  let destinations = (:)
  for (uid, data) in notes {
    let body = "deixis-body-" + uid
    let mark = "deixis-mark-" + uid
    for internal in (body, mark) {
      if internal in locations and internal not in aliases { aliases.insert(internal, uid) }
    }
    let public-id = data.at("id", default: none)
    let dest = if public-id != none { locations.at(str(public-id), default: none) } else { none }
    if dest == none { dest = locations.at(body, default: none) }
    if dest == none { dest = locations.at(mark, default: none) }
    destinations.insert(uid, dest)
  }
  (notes: notes, aliases: aliases, locations: locations, elements: elements,
    destinations: destinations, details: details)
}

#let _deixis-reference-target(index, target) = {
  let key = str(target)
  let uid = index.aliases.at(key, default: none)
  if uid == none { return none }
  let data = index.notes.at(uid)
  let dest = index.destinations.at(uid, default: none)
  let body = "deixis-body-" + uid
  let mark = "deixis-mark-" + uid
  // Explicit internal labels still select their particular component.
  if key in (mark, body) and key in index.locations {
    dest = index.locations.at(key, default: dest)
  }
  let dest-key = if key in (mark, body) and key in index.locations { key }
    else if body in index.locations { body } else if mark in index.locations { mark } else { none }
  let dest-label = if dest-key == none { none } else { label(dest-key) }
  // HTML links use the internal label's explicit id at the same destination.
  let resolved = (uid: uid, data: data, dest: dest, html-dest: dest-label)
  if not index.details { return resolved }
  resolved + (
    dest-label: dest-label,
    element: if dest-key == none { metadata(data) } else { index.elements.at(dest-key) })
}

// One metadata element represents one reference call or repeated mark. Resolve
// aliases once; origins are available before deferred marker/style resolution.
#let _deixis-reference-sites(destinations: false) = {
  // Measurement counts early origins. Only live backlinks resolve the optional
  // painted frame, which can have wrapped away from its early source record.
  let index = _deixis-reference-identities()
  let painted = if destinations { _deixis-occurrence-destinations(index.aliases) } else { none }
  let sites = (:)
  for marker in query(selector(<deixis-ref-marker>).or(<deixis-mark-occurrence>)) {
    let seen = (:)
    let uids = marker.value.targets.map(target => index.aliases.at(target, default: none))
    for uid in uids {
      if uid == none or uid in seen { continue }
      seen.insert(uid, true)
      if uid not in sites { sites.insert(uid, ()) }
      let origin = if destinations { _deixis-occurrence-destination(painted, marker, uid) } else { marker.location() }
      sites.at(uid).push(origin)
    }
  }
  sites
}
