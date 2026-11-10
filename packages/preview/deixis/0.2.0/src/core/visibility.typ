// Native show-rule scope follows hide ancestry even when page overlays and
// footer entries interleave a hidden passage across several physical pages.
// Only drawing evidence is marked; semantic declarations, hints, and arbitrary
// user metadata/payloads remain untouched. No global visibility state is used.
#let _deixis-is-hidden(data) = {
  let inherited = data.at("render-context", default: none)
  data.at("hidden", default: false) or (inherited != none and inherited.at("hidden", default: false))
}

#let _deixis-metadata(value, tag) = [#metadata((value: value, tag: tag))<deixis-paint-source>]
#let _deixis-live-paint-source(it, hidden: false) = {
  let value = if hidden { it.value.value + (hidden: true,) } else { it.value.value }
  [#metadata(value)#it.value.tag]
}

#let _deixis-body-visibility(data) = {
  let uid = data.at("internal-id", default: none)
  if uid != none { _deixis-metadata((internal-id: uid,), <deixis-body-visibility>) }
}

#let _deixis-hidden-identities(selection) = {
  let result = (:)
  for item in query(selection) {
    let uid = item.value.at("internal-id", default: none)
    if uid != none and _deixis-is-hidden(item.value) { result.insert(str(uid), true) }
  }
  result
}

// A probe's native show rule supplies context before creating a page footnote.
// It adds no contextual wrapper around the live body or measurement.
#let _deixis-visibility-probe(render) = [#metadata(render)<deixis-visibility-probe>]
#let _deixis-live-visibility(it) = (it.value)(false)

#let _deixis-native-hide(it) = {
  show metadata.where(label: <deixis-paint-source>): source => _deixis-live-paint-source(source, hidden: true)
  show metadata.where(label: <deixis-visibility-probe>): probe => (probe.value)(true)
  // Return the original element so native and host show rules still compose.
  it
}

// Page layers and queued page-footer entries are native roots, outside the
// caller's hide ancestry. Host-owned hooks need these rules too, even when
// their content was configured before the document/slide setup wrapper.
#let _deixis-visible-root(body) = {
  show metadata.where(label: <deixis-paint-source>): _deixis-live-paint-source
  show metadata.where(label: <deixis-visibility-probe>): _deixis-live-visibility
  show metadata.where(label: <deixis-inline-mark-output>): it => (it.value)(false)
  show hide: _deixis-native-hide
  body
}
