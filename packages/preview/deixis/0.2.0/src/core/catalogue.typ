#import "state.typ": deixis-system, _deixis-registry
#import "targets.typ": _deixis-check-setup-state, _deixis-resolve-target, _deixis-scope-name, _deixis-scope-key
#import "selection.typ": _deixis-selection-filter, _deixis-selection-matches, _deixis-selection-boundaries
#import "occurrences.typ": _deixis-occurrence-destinations, _deixis-occurrence-destination
#import "../render/summary.typ": _deixis-note-summary

#let _deixis-check-unpaired(value) = assert(value in (false, true, "mark", "body"),
  message: "deixis: include-unpaired must be false, true, mark, or body.")

// Collect declarations and navigation evidence without painting, measuring, or
// exposing executable body/passage content. Public records share this one model.
#let _deixis-note-catalogue(target, thread, include-types, exclude-types, series, include-unpaired, after, before) = {
  _deixis-check-setup-state()
  _deixis-check-unpaired(include-unpaired)
  let include-types = _deixis-selection-filter(include-types, "include-types")
  let exclude-types = _deixis-selection-filter(exclude-types, "exclude-types", allow-auto: false)
  let series = _deixis-selection-filter(series, "series")
  let thread = if thread == auto { auto } else { _deixis-scope-name(thread, "Thread filter") }
  let domain = if target == auto { none } else { _deixis-resolve-target(deixis-system.get(), target).render-id }
  let bounds = _deixis-selection-boundaries(after, before)
  let registry = _deixis-registry(deixis-system.final())
  let tags = (
    "deixis-inline-mark": "inline-mark", "deixis-region-mark": "region-mark", "deixis-phantom-mark": "phantom-mark",
    "deixis-inline-note": "inline-note", "deixis-footnote": "footnote", "deixis-endnote": "endnote",
    "deixis-margin-note": "margin-note", "deixis-inset-note": "inset-note",
  )
  let select = selector(<deixis-mark-occurrence>)
  for tag in tags.keys() { select = select.or(label(tag)) }
  let lower = if bounds.after == none { 0 } else { query(select.before(bounds.after, inclusive: true)).len() }
  let upper = if bounds.before == none { none } else { query(select.before(bounds.before)).len() }
  let entries = (:)
  let repeats = (:)
  for (order, elem) in query(select).enumerate() {
    let data = elem.value
    if elem.label == <deixis-mark-occurrence> {
      let uid = registry.id-index.at(data.targets.first(), default: none)
      if uid == none { continue }
      if uid not in repeats { repeats.insert(uid, ()) }
      repeats.at(uid).push((element: elem, order: order))
      continue
    }
    let kind = tags.at(str(elem.label))
    let is-mark = kind.ends-with("-mark")
    let uid = data.at("internal-id", default: none)
    // Anonymous decorations/bodies remain separate entries, even with identical
    // text. Named and private wrapper identities combine only their own parts.
    let key = if uid == none { "anonymous-" + str(order) } else { str(uid) }
    let entry = entries.at(key, default: (mark: none, body: none))
    entry.insert(if is-mark { "mark" } else { "body" }, (element: elem, order: order, type: kind))
    entries.insert(key, entry)
  }

  let mark-dests = (:)
  let body-dests = (:)
  let starts = (:)
  let ends = (:)
  let render-orders = (:)
  for (tag, field) in ((<deixis-mark-destination>, "mark"), (<deixis-body-destination>, "body")) {
    for elem in query(tag) {
      let uid = str(elem.value.internal-id)
      if field == "mark" and uid not in mark-dests { mark-dests.insert(uid, elem.location()) }
      if field == "body" and uid not in body-dests { body-dests.insert(uid, elem.location()) }
    }
  }
  // One native-order scan supplies both span validity and body order. Separate
  // start/end scans cannot detect an end preceding its start on the same page.
  let start-first = (:)
  let render-index = 0
  for elem in query(selector(<deixis-rendered-start>).or(<deixis-rendered-end>)) {
    let uid = str(elem.value.internal-id)
    let is-start = elem.label == <deixis-rendered-start>
    if uid not in start-first { start-first.insert(uid, is-start) }
    if is-start {
      if uid not in starts { starts.insert(uid, ()) }
      starts.at(uid).push(elem.location())
      if uid not in render-orders { render-orders.insert(uid, render-index) }
      render-index += 1
    } else {
      if uid not in ends { ends.insert(uid, ()) }
      ends.at(uid).push(elem.location())
    }
  }
  let occurrence-dests = _deixis-occurrence-destinations(registry.id-index)
  let result = ()
  for (uid, entry) in entries {
    if entry.mark == none and include-unpaired not in (true, "body") { continue }
    if entry.body == none and include-unpaired not in (true, "mark") { continue }
    let anchor = if entry.mark != none { entry.mark } else { entry.body }
    if anchor.order < lower or (upper != none and anchor.order >= upper) { continue }
    let selected = if entry.body != none { entry.body } else { entry.mark }
    let data = selected.element.value
    let kind = selected.type
    let note-series = data.at("series", default: "default")
    let note-domain = data.at("target-id", default: "page")
    if not _deixis-selection-matches(kind, include-types) or kind in exclude-types { continue }
    if not _deixis-selection-matches(note-series, series) { continue }
    if domain != none and note-domain != domain { continue }
    if thread != auto and note-domain != _deixis-scope-key("thread", thread) { continue }
    // Reuse the declaration's resolved marker; never call numbering/renderers
    // from a query. Phantom/hidden marks can have a count with no visible marker.
    let marker = data.at("marker-str", default: none)
    if marker == none and entry.mark != none { marker = entry.mark.element.value.at("marker-str", default: none) }
    let marks = ()
    if entry.mark != none {
      let m = entry.mark
      marks.push((loc: m.element.location(), dest: mark-dests.at(uid, default: m.element.location()),
        order: m.order, type: m.type, original: true, occurrence: none,
        summary: _deixis-note-summary(m.element.value.at("body", default: none))))
    }
    for repeat in repeats.at(uid, default: ()) {
      let site = repeat.element
      marks.push((loc: site.location(), dest: _deixis-occurrence-destination(occurrence-dests, site, uid),
        order: repeat.order, type: site.value.kind + "-mark", original: false,
        occurrence: site.value.name, summary: _deixis-note-summary(site.value.at("passage", default: none))))
    }
    marks = marks.sorted(key: m => m.order)
    let body = if entry.body != none {
      let first = starts.at(uid, default: ())
      let last = ends.at(uid, default: ())
      let complete = (first.len() == 1 and last.len() == 1 and start-first.at(uid)
        and last.first().page() >= first.first().page())
      (loc: entry.body.element.location(), order: entry.body.order, dest: body-dests.at(uid, default: none),
        render-order: if first.len() == 1 { render-orders.at(uid) } else { none },
        start: if complete { first.first() } else { none }, end: if complete { last.first() } else { none },
        summary: _deixis-note-summary(data.at("body", default: none)))
    } else { none }
    let dest = if entry.mark != none { mark-dests.at(uid, default: anchor.element.location()) }
      else if body.dest != none { body.dest } else { body.loc }
    result.push((id: data.at("id", default: none), data: data.at("data", default: (:)), type: kind, series: note-series,
      count: data.at("count", default: none), accent: data.at("accent", default: none), marker: marker, styles: data.at("styles", default: (:)),
      loc: anchor.element.location(), order: anchor.order, dest: dest,
      marks: marks, body: body,
      summary: if body != none { body.summary } else { marks.find(m => m.original).summary }))
  }
  result.sorted(key: note => note.order)
}
