#import "commands.typ": _deixis-paint-command, _deixis-emit-paint-commands
#import "../marks/region.typ": _deixis-region-paint-commands
#import "../routing/overlay.typ": _deixis-connection-paint-commands
#import "../notes/footnote.typ": _deixis-footnote-paint-commands
#import "../notes/inset.typ": _deixis-inset-paint-commands
#import "../notes/margin.typ": _deixis-margin-paint-output
#import "../core/visibility.typ": _deixis-is-hidden
#import "body.typ": _deixis-html-render-group

// Discover keys from declaration/configuration values only. Pages, endpoint
// geometry, reservations, and packing are resolved independently inside bands.
// Gather per adapter to avoid running every adapter for every note's priority.
#let _deixis-overlay-priorities(layer) = {
  let result = (region: (0,), connection: (0,), footnote: (0,), inset: (0,), margin: (0,))
  let hints = query(<deixis-paint-priorities>).map(m => m.value).flatten().dedup()
  for kind in result.keys() { result.at(kind) += hints }
  for mark in query(selector(<deixis-region-mark>).or(<deixis-region-occurrence>)) {
    let data = mark.value
    if data.layer != "flow" and (data.layer == layer or layer == "foreground") {
      result.region.push(data.at("z-index", default: 0))
    }
  }
  for note in query(selector(<deixis-footnote>).or(<deixis-inset-note>).or(<deixis-margin-note>)) {
    let data = note.value
    if data.layer == layer {
      let kind = if data.body-type == "footnote" { "footnote" }
        else if data.body-type == "inset-note" { "inset" } else { "margin" }
      result.at(kind).push(data.at("z-index", default: 0))
    }
    if data.at("link", default: "none") not in (none, false, "none") and data.at("link-layer", default: "foreground") == layer {
      result.connection.push(data.at("link-z-index", default: 0))
    }
  }
  for edge in query(<deixis-connection>) {
    if edge.value.options.layer == layer and edge.value.options.route not in (none, false, "none") {
      result.connection.push(edge.value.options.at("z-index", default: 0))
    }
  }
  for (kind, values) in result { result.insert(kind, values.dedup().sorted()) }
  result
}

// Keep stable independent adapter contexts; a flat geometry/live-body context
// creates self-dependencies for notes containing regions. Bands are ordered by
// priority then existing phase. A unit's painter runs only in its selected band.
#let _deixis-paint-page-overlay(layer) = {
  let priorities = _deixis-overlay-priorities(layer)
  let emit(commands, priority) = _deixis-emit-paint-commands(commands, deferred: false, priority: priority)
  let bands = ()
  for priority in priorities.region {
    bands.push(_deixis-paint-command("region-band", (layer, priority),
      () => emit(_deixis-region-paint-commands(layer: layer), priority), priority: priority))
  }
  for priority in priorities.connection {
    bands.push(_deixis-paint-command("connection-band", (layer, priority),
      () => emit(_deixis-connection-paint-commands(layer), priority), priority: priority))
  }
  for priority in priorities.footnote {
    bands.push(_deixis-paint-command("footnote-band", (layer, priority),
      () => emit(_deixis-footnote-paint-commands(layer: layer), priority), priority: priority))
  }
  for priority in priorities.inset {
    bands.push(_deixis-paint-command("inset-band", (layer, priority),
      () => emit(_deixis-inset-paint-commands(layer: layer), priority), priority: priority))
  }
  for priority in priorities.margin {
    bands.push(_deixis-paint-command("margin-band", (layer, priority), () => {
      let output = _deixis-margin-paint-output(layer: layer)
      // Zero always exists, including when every live body uses another band.
      // Custom batches publish their own intrinsic evidence when painted once.
      if priority == 0 { place(top + left, output.evidence) }
      emit(output.commands, priority)
    }, priority: priority))
  }
  _deixis-emit-paint-commands(bands)
}

// HTML export has no page layers. Margin and inset bodies (including comments)
// follow the document as one list in declaration order, like their reading
// order in tagged PDF. Markers and backlinks link both ways; connectors and
// region shapes have no HTML form and are omitted.
#let _deixis-html-overlay-bodies() = [#metadata(none)<deixis-html-notes>#context {
  // Setup can be reapplied; only its last application lists the bodies.
  if query(selector(<deixis-html-notes>).after(here())).len() > 0 { return }
  let seen = (:)
  let notes = ()
  for note in query(selector(<deixis-margin-note>).or(<deixis-inset-note>)) {
    let uid = str(note.value.internal-id)
    if _deixis-is-hidden(note.value) or uid in seen { continue }
    seen.insert(uid, true)
    notes.push(note.value)
  }
  if notes.len() > 0 { html.elem("aside", attrs: (class: "deixis-notes"), _deixis-html-render-group(notes)) }
}]
