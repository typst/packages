#import "state.typ": deixis-system

// Numbering records are literal values after component/type scope resolution.
#let _deixis-check-page-numbering(value) = {
  assert(value.keys().all(k => k in ("restart", "pattern"))
    and value.at("restart", default: none) == "page"
    and type(value.at("pattern", default: "1")) in (str, function),
    message: "deixis: numbering record must be (restart: \"page\", pattern: \"1\").")
}

// Shared identity/geometry index. The boxed registry keeps its executable body
// payloads out of argument hashing; this function never executes those bodies.
#let _deixis-page-numbering-index(registry-box) = {
  let locations = (:)
  for origin in query(<deixis-mark-destination>) {
    let uid = str(origin.value.internal-id)
    if uid not in locations { locations.insert(uid, origin.location()) }
  }
  // Hidden originals still consume slots, like the assigned counter. Phantom
  // marks and provisional layout passes can supply their semantic location.
  for origin in query(selector(<deixis-inline-mark>).or(<deixis-region-mark>).or(<deixis-phantom-mark>)) {
    let uid = origin.value.at("internal-id", default: none)
    if uid != none and str(uid) not in locations { locations.insert(str(uid), origin.location()) }
  }
  let streams = (:)
  let ordinals = (:)
  for (uid, original) in registry-box.value.notes {
    let owner = original.at("count-id", default: none)
    if owner == none or original.count == none or uid not in locations { continue }
    let series = original.series
    let page = str(locations.at(uid).page())
    let owner-streams = streams.at(owner, default: (:))
    let pages = owner-streams.at(series, default: (:))
    let ordinal = pages.at(page, default: 0) + 1
    pages.insert(page, ordinal)
    owner-streams.insert(series, pages)
    streams.insert(owner, owner-streams)
    ordinals.insert(uid, ordinal)
  }
  ordinals
}

#let _deixis-page-ordinal(reg) = {
  _deixis-page-numbering-index(deixis-system.final().registry)
    .at(str(reg.internal-id), default: reg.count)
}
