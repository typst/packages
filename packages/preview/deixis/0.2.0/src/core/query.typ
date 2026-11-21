#import "numbering.typ": _deixis-check-page-numbering, _deixis-page-ordinal
#import "state.typ": *
#import "pins.typ": _deixis-pin-selector
#import "native.typ": *

#let _deixis-pin-index() = {
  let named = (:)
  let scoped = (:)
  let automatic = (:)
  for p in query(<deixis-pin>) {
    let name = p.value.name
    if type(name) == str {
      if p.value.at("scope", default: none) == none {
        if name not in named { named.insert(name, ()) }
        named.at(name).push(p)
      } else {
        if name not in scoped { scoped.insert(name, ()) }
        scoped.at(name).push(p)
      }
    } else {
      // Locations are opaque identities rather than string dictionary keys.
      // Bucket by the owner's page to keep lookups local in long documents.
      let page = str(name.owner.page())
      if page not in automatic { automatic.insert(page, ()) }
      automatic.at(page).push(p)
    }
  }
  (named: named, scoped: scoped, automatic: automatic)
}

// Page restrictions are applied before first/last/unique selection. This keeps
// immediate painters on their declaration page without choosing a remote pin
// first and only then discarding it. A structured page restriction intersects
// the consumer's page; it never overrides a native flow constraint.
#let _deixis-select-pins(index, target, default: "all", page: none, single: false, required: false, validate: true) = {
  let spec = _deixis-pin-selector(target, default: default)
  let matches = if spec.scope == none { index.named.at(spec.name, default: ()) } else {
    index.scoped.at(spec.name, default: ()).filter(p => p.value.scope == spec.scope)
  }
  if spec.page != none { matches = matches.filter(p => p.location().page() == spec.page) }
  if page != none { matches = matches.filter(p => p.location().page() == page) }
  // Routing can defer unresolved/ambiguous geometry during native layout.
  // Final validation outside painters retains all existing diagnostics.
  if not validate and (matches.len() == 0 or
    (spec.select == "unique" and matches.len() > 1)) { return () }
  assert(matches.len() > 0 or not (spec.required or required),
    message: "deixis: No pin matches " + repr(target) +
      if page == none { "." } else { " on physical page " + str(page) + "." })
  if spec.select == "unique" {
    assert(matches.len() <= 1,
      message: "deixis: Ambiguous pin target " + repr(target) + "; use select: first, last, or all.")
  } else if matches.len() > 0 {
    if spec.select == "first" { matches = (matches.first(),) }
    else if spec.select == "last" { matches = (matches.last(),) }
  }
  if not validate and single and matches.len() > 1 { return () }
  assert(not single or matches.len() <= 1,
    message: "deixis: This pin anchor needs one occurrence; use select: first, last, or unique.")
  matches
}

#let _deixis-pins-for(index, names, page: none) = {
  let pins = ()
  let seen = ()
  for name in names.dedup() {
    let matches = if type(name) == dictionary and "owner" in name and "edge" in name {
      index.automatic.at(str(name.owner.page()), default: ()).filter(p => p.value.name == name)
    } else { _deixis-select-pins(index, name, page: page) }
    for pin in matches {
      if pin.location() not in seen {
        seen.push(pin.location())
        pins.push(pin)
      }
    }
  }
  pins
}

// Batch adapters resolve many notes against the same document. Keep the first
// mark/region for an identity, and every pin occurrence in document order.
// This contains query results only; it never measures or replays note content.
#let _deixis-anchor-index() = {
  let marks = (:)
  for m in query(selector(metadata).and(selector(<deixis-inline-mark>).or(<deixis-phantom-mark>))) {
    if type(m.value) != dictionary { continue }
    let id = m.value.at("internal-id", default: none)
    if id != none and str(id) not in marks { marks.insert(str(id), m) }
  }
  let regions = (:)
  for r in query(<deixis-region-mark>) {
    let id = r.value.at("internal-id", default: none)
    if id != none and str(id) not in regions { regions.insert(str(id), r) }
  }
  let pins = _deixis-pin-index()
  (marks: marks, regions: regions, pins: pins.named, pin-index: pins)
}

// Queries the document metadata to find the mark data.
#let _deixis-query-mark-data(data) = {
  if type(data) != dictionary { return none }

  let internal-id = data.at("internal-id", default: none)
  if internal-id == none {
    if "mark-lbl" in data and data.mark-lbl != none {
      internal-id = str(data.mark-lbl).slice("deixis-mark-".len())
    } else if "body-lbl" in data and data.body-lbl != none {
      internal-id = str(data.body-lbl).slice("deixis-body-".len())
    }
  }

  if internal-id != none {
    let marks = query(
      selector(metadata).and(selector(<deixis-inline-mark>).or(<deixis-phantom-mark>).or(<deixis-region-mark>)),
    )

    let match = marks.find(m => (
      type(m.value) == dictionary
        and m.value.at("internal-id", default: none) != none
        and str(m.value.internal-id) == str(internal-id)
    ))

    if match != none and match.value.at("marker-str", default: none) != none {
      return match.value
    }
  }
  return none
}

// Evaluates the final numbering string from a note registry.
// Safe to use inside context blocks for cross-module evaluation.
#let _deixis-evaluate-marker-str(reg) = {
  if type(reg) != dictionary { return none }

  // If the payload already has a computed string, use it
  if reg.at("marker-str", default: none) != none {
    return reg.marker-str
  }

  let c-marker = reg.at("marker", default: auto)
  if c-marker != auto {
    return c-marker
  }

  let c-numbering = reg.at("numbering", default: none)
  let count = reg.at("count", default: 0)

  if c-numbering != none and c-numbering != auto {
    if type(c-numbering) == dictionary {
      _deixis-check-page-numbering(c-numbering)
      let pattern = c-numbering.at("pattern", default: "1")
      return context _std-numbering(pattern, _deixis-page-ordinal(reg))
    }
    return _std-numbering(c-numbering, count)
  }

  return none
}
