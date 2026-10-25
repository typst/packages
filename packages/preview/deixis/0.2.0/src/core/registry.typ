#import "state.typ": *
#import "palette.typ": _deixis-palette-next, _deixis-palette-finish
#import "counter.typ": _deixis-counter-series, _deixis-read-counter, _deixis-write-counter

#let _deixis-registry-uid(registry-box, id) = {
  let registry = registry-box.value
  assert(type(id) == location or (type(id) in (str, label) and str(id).len() > 0),
    message: "deixis: A note ID must be a nonempty string or label.")
  if type(id) != location { return registry.id-index.at(str(id), default: none) }
  // Locations have no string key. Native membership tests over halved slices
  // find the first registration without one script callback per note. Stay
  // inline: passing the unboxed registry to a helper would hash it per call.
  let locs = registry.auto-locs
  if not locs.contains(id) { return none }
  let low = 0
  let high = locs.len()
  while high - low > 1 {
    let mid = calc.quo(low + high, 2)
    if locs.slice(low, mid).contains(id) { high = mid } else { low = mid }
  }
  registry.auto-uids.at(low)
}
#let _deixis-note-uid(sys, id) = _deixis-registry-uid(sys.registry, id)

// Registry updates are pure state transformations. A body may precede its mark.
#let _deixis-register-body(sys, id, body, body-type) = {
  let registry = _deixis-registry(sys)
  let id-key = if type(id) == location { "" } else { str(id) }
  let uid = _deixis-registry-uid(sys.registry, id)
  let record = (body: body, body-type: body-type)
  if uid == none {
    if id-key in registry.pending-bodies {
      panic("deixis: A note can have only one body. Duplicate body for " + repr(id) + ".")
    }
    registry.pending-bodies.insert(id-key, record)
  } else {
    let note = registry.notes.at(uid)
    assert(note.at("count-id", default: none) != none,
      message: "deixis: of must name an original mark, not a standalone body.")
    if "body-type" in note {
      panic("deixis: A note can have only one body. Duplicate body for " + repr(id) + ".")
    }
    registry.notes.insert(uid, note + record)
  }
  sys + (registry: metadata(registry))
}

// A named standalone body is an identity without a mark or counter owner.
#let _deixis-register-standalone(sys, id, body, body-type, data: (:)) = {
  let registry = _deixis-registry(sys)
  if _deixis-registry-uid(sys.registry, id) != none or str(id) in registry.pending-bodies {
    panic("deixis: Duplicate note ID detected: " + repr(str(id)) + ". Use of to attach a body to an original mark.")
  }
  let sys = _deixis-palette-next(sys)
  let uid = "id-" + str(id)
  registry.id-index.insert(str(id), uid)
  registry.notes.insert(uid, (internal-id: uid, id: id, data: data, body: body, body-type: body-type,
    count: none, marker-str: none, accent: sys.annotation-accent))
  _deixis-palette-finish(sys + (registry: metadata(registry)))
}

#let _deixis-validate-attachments() = {
  let pending = _deixis-registry(deixis-system.final()).pending-bodies.keys()
  assert(pending.len() == 0,
    message: "deixis: of must name an original mark. Missing declaration for " + repr(pending) + ". Use id for a standalone body.")
}

#let _deixis-register-mark(sys, id, resolved, series, payload) = {
  let sys = if "annotation-accent" in sys { sys } else { _deixis-palette-next(sys) }
  let key = if type(id) == location { "" } else { str(id) }
  if _deixis-note-uid(sys, id) != none {
    panic("deixis: Duplicate note ID detected: " + repr(key) + ". Use deixis-mark(of: ...) for reuse, or deixis-ref for a reference.")
  }
  // Unnumbered originals (resolved numbering none) take no counter value.
  _deixis-counter-series(series)
  let count = none
  if payload.numbering != none {
    count = _deixis-read-counter(sys, resolved.count-id, series) + 1
    sys = _deixis-write-counter(sys, resolved.count-id, series, count)
  }
  let registry = _deixis-registry(sys)
  let uid = registry.note-uid + 1
  // Public identities must not depend on how many deferred marks were found.
  let uid-key = if type(id) == location { str(uid) } else { "id-" + key }
  let note = payload + (
    id: if type(id) == location { none } else { id },
    internal-id: if type(id) == location { uid } else { uid-key }, target-id: resolved.render-id, inst-id: resolved.inst-id,
    count-id: resolved.count-id, accent: sys.annotation-accent,
    series: series, count: count,
  )
  if type(id) != location and key in registry.pending-bodies {
    note += registry.pending-bodies.remove(key)
  }
  registry.notes.insert(uid-key, note)
  if type(id) == location {
    registry.auto-locs.push(id)
    registry.auto-uids.push(uid-key)
  } else {
    registry.id-index.insert(key, uid-key)
  }
  registry.note-uid = uid
  _deixis-palette-finish(sys + (registry: metadata(registry)))
}

#let _deixis-resolve-note(sys, id) = {
  let registry = _deixis-registry(sys)
  let uid = _deixis-registry-uid(sys.registry, id)
  if uid == none { none } else { registry.notes.at(uid) }
}

// Each wrapper closes over its own ID before either component is evaluated.
#let _deixis-with-auto-id(render) = context { render(here()) }
