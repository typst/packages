#import "native.typ": _std-target
#import "visibility.typ": _deixis-metadata
#import "state.typ": deixis-system, _deixis-registry

#let _deixis-occurrence-name(name) = {
  assert(name == none or (type(name) in (str, label) and str(name).len() > 0),
    message: "deixis: occurrence must be a nonempty string or label, or none.")
  if name == none { none } else { str(name) }
}

#let _deixis-occurrence-target(registry, target) = registry.id-index.at(str(target), default: none)

// Names are scoped to the annotation, including calls through different aliases.
// This index uses source origins, not painted geometry, so duplicate diagnostics
// do not depend on layout convergence or whether a hidden occurrence has a box.
#let _deixis-occurrence-index() = {
  let registry = _deixis-registry(deixis-system.final())
  let result = (:)
  for site in query(<deixis-mark-occurrence>) {
    let name = site.value.at("name", default: none)
    if name == none { continue }
    let uid = _deixis-occurrence-target(registry, site.value.targets.first())
    if uid == none { continue } // The repeat's target diagnostic owns this case.
    if uid not in result { result.insert(uid, (:)) }
    assert(name not in result.at(uid),
      message: "deixis: Duplicate occurrence " + repr(name) + " for the same annotation.")
    result.at(uid).insert(name, site)
  }
  result
}

#let _deixis-validate-occurrences() = {
  let _ = _deixis-occurrence-index()
}

// Painted return points are shared by backlinks and semantic note queries.
// Keep source order separate: a named inline frame can wrap away from its call,
// and a region can be painted at pins on another page.
#let _deixis-occurrence-destinations(aliases) = {
  let inline = (:)
  for corner in query(<deixis-occurrence-corner>).filter(c => c.value.corner == "tl") {
    let uid = aliases.at(corner.value.target, default: none)
    if uid == none { continue }
    if uid not in inline { inline.insert(uid, (:)) }
    inline.at(uid).insert(corner.value.name, corner.location())
  }
  let regions = (:)
  for origin in query(<deixis-occurrence-destination>) {
    let page = str(origin.value.owner.page())
    if page not in regions { regions.insert(page, ()) }
    regions.at(page).push(origin)
  }
  (inline: inline, regions: regions)
}

#let _deixis-occurrence-destination(index, site, uid) = {
  let result = site.location()
  let name = site.value.at("name", default: none)
  if name != none and uid in index.inline {
    result = index.inline.at(uid).at(name, default: result)
  }
  let owner = site.value.at("owner", default: none)
  if owner != none {
    let found = index.regions.at(str(owner.page()), default: ()).find(p => p.value.owner == owner)
    if found != none { result = found.location() }
  }
  result
}

// A named repeat has one native inline frame, including its marker and passage.
// Four corner probes preserve its page-space envelope under native transforms.
#let _deixis-occurrence-frame(body, target, name) = {
  // HTML export has no geometry for connections to select.
  if _std-target() == "html" { return body }
  let corner(which) = [#_deixis-metadata((target: str(target), name: name, corner: which), <deixis-occurrence-corner>)]
  box({
    place(top + left, corner("tl"))
    place(top + right, corner("tr"))
    place(bottom + left, corner("bl"))
    place(bottom + right, corner("br"))
    body
  })
}
