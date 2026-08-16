// Certificates — pill-row rendering with optional issuer grouping.
// Multi-issuer clusters get a labelled-divider header; singleton
// issuers pool into a trailing unlabelled group.

#import "../internal/state.typ": _body_size_state
#import "../internal/text.typ": _present
#import "../internal/primitives.typ": tag, divider, _labelled_divider
#import "../internal/icons.typ": icon
#import "../internal/dates.typ": _format_date

// Normalises a cert into the (name, date, url) triple the renderer
// consumes. Returns `none` for entries with no usable name so callers
// can filter them in one pass. `date` / `url` are normalised to `none`
// when absent or empty so downstream `!= none` checks don't render an
// orphan date snippet or a link with an empty target.
#let _normalise_cert(cert) = {
  let name = cert.at("name", default: "")
  if not _present(name) { return none }
  let date = cert.at("date", default: none)
  let url = cert.at("url", default: none)
  (
    name: name,
    date: if _present(date) { date } else { none },
    url: if _present(url) { url } else { none },
  )
}

// Buckets by issuer in insertion order; multi-issuer clusters survive
// as their own group keyed by the shared issuer, singletons pool into
// a trailing heterogeneous group with no issuer label.
//
// Returns an array of `(issuer, items)` records. `items` carries full
// `_normalise_cert` triples (name + date + url) so the renderer can
// emit inline dates and link wrapping without re-reading the source.
// `issuer` is `none` for the trailing singleton group (its certs come
// from different issuers, so no single label fits) or for clusters
// whose `issuer` field is missing / empty.
#let _build_cert_groups(certs) = {
  // Normalise "no issuer" (key missing, explicit `none`, or empty
  // string) to the literal "" key so they all bucket together; we
  // can't key the dict on `none` (Typst dicts require string keys).
  let by-issuer = (:)
  for cert in certs {
    let item = _normalise_cert(cert)
    if item == none { continue }
    let raw = cert.at("issuer", default: "")
    let issuer = if raw == none { "" } else { raw }
    by-issuer.insert(issuer, by-issuer.at(issuer, default: ()) + (item,))
  }
  let groups = ()
  let singletons = ()
  for (issuer, items) in by-issuer.pairs() {
    if items.len() > 1 {
      groups.push((issuer: if issuer == "" { none } else { issuer }, items: items))
    } else {
      singletons.push(items.first())
    }
  }
  if singletons.len() > 0 { groups.push((issuer: none, items: singletons)) }
  groups
}

// Builds a pill body containing the cert name and, when a date is
// supplied, a middot separator + small calendar icon + date — all in
// the pill's own text rendering. The icon and date are wrapped in a
// box so they never break across lines; only the middot's surrounding
// space is a valid break point if the pill has to wrap. The date is
// routed through `_format_date` so it honours `preferences.dateFormat`
// the same way the work / education / awards / publications dates do.
#let _cert_tag(item, prefs, labels) = context {
  let body-size = _body_size_state.get()
  // Guard on _present so an empty-string `date` doesn't render an
  // orphan bullet + calendar icon followed by no text.
  let body = if _present(item.at("date", default: none)) {
    let formatted = _format_date(item.date, prefs, labels)
    let cal = icon("calendar", size: 0.75 * body-size, shift: 0.1 * body-size)
    let bullet = h(0.35 * body-size) + [·] + h(0.35 * body-size)
    [#item.name#bullet#box[#cal#formatted]]
  } else {
    [#item.name]
  }
  let pill = tag(body)
  if item.url != none { link(item.url, pill) } else { pill }
}

#let _certificates(certs, labels, prefs, group: true) = {
  if certs.len() == 0 { return }
  // Decide whether to emit the heading *after* filtering — otherwise
  // a list of certs whose `name` is empty would still render a bare
  // "Certifications" heading with nothing under it.
  //
  // Each group is `(issuer, items)` where `items` carries full
  // `_normalise_cert` triples. In flat (non-grouped) mode each cert
  // becomes its own one-element "group" with no issuer label so the
  // row flows as a single uniformly-pilled strip.
  let groups = if group {
    _build_cert_groups(certs)
  } else {
    let items = certs.map(_normalise_cert).filter(c => c != none)
    if items.len() > 0 { ((issuer: none, items: items),) } else { () }
  }
  if groups.len() == 0 { return }
  [== #labels.certificates]
  // Each group's issuer (when present) leads its row as a labelled
  // dashed divider — replacing the plain inter-group divider with one
  // that names the issuer. Groups without an issuer (the pooled
  // singletons cluster, or every group in flat mode) get the plain
  // divider; the first group is preceded by no divider regardless so
  // the section starts flush against the heading.
  for (i, g) in groups.enumerate() {
    if g.issuer != none { _labelled_divider(g.issuer) }
    else if i > 0 { divider() }
    block(breakable: false, { for item in g.items { _cert_tag(item, prefs, labels) } })
  }
}
