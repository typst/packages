/// A short, human-readable name for a labelled element's kind, for the
/// orphan-labels table -- a figure's own `supplement` when it has one
/// (`[Figure]`/`[Table]`, whatever the figure itself would print),
/// falling back to a generic name for anything else queried.
#let kind-label(it) = {
  if it.func() == figure {
    if it.supplement != none { it.supplement } else { [#it.kind] }
  } else if it.func() == heading {
    [Heading]
  } else if it.func() == math.equation {
    [Equation]
  } else {
    [#it.func()]
  }
}

/// Every labelled `heading`/`figure`/`math.equation` in the manuscript
/// span `start`..`end` (see `instrument.typ`) that no `ref` anywhere in
/// the bundle ever targets -- the same `query(ref).map(r => r.target)`
/// technique `@preview/palimpsest`'s own `pinpoint.typ` (`has-conflicting-label`)
/// already uses, ported here since neither package depends on the
/// other. Deliberately bundle-wide for the *referencing* side (a label
/// could legitimately be cited from a satellite document, e.g. an
/// checkitoff checklist excerpt) -- only the *candidate* labels themselves
/// are scoped to the manuscript, via `.after(start).before(end)`, for
/// the same self-pollution reason `words.typ`/`inventory.typ` already
/// document.
#let orphan-labels(start, end) = {
  let referenced = query(ref).map(r => r.target)
  let candidates = query(
    selector(heading).or(selector(figure)).or(selector(math.equation)).after(start).before(end),
  )
  candidates
    .map(it => (
      kind: kind-label(it),
      label: it.fields().at("label", default: none),
      page: it.location().page(),
    ))
    .filter(it => it.label != none and it.label not in referenced)
}
