#import "collect.typ"
#import "references.typ"
#import "order.typ"
#import "structure.typ"
#import "captions.typ"
#import "citations.typ"
#import "accessibility.typ"
#import "ignores.typ"

/// whether the author asked to hear nothing about this finding
#let _silenced(f, ignored) = {
  if f.target == none or f.target not in ignored { return false }
  let ids = ignored.at(f.target)
  ids == none or f.id in ids
}

#let analyse(cfg) = {
  let doc = collect.collected()
  let elements = doc.elements
  let refs = collect.references()
  let bibs = collect.bibliographies()

  let findings = ()
  findings += references.run(elements, refs.labels, cfg)
  findings += order.run(elements, refs.order, cfg)
  findings += structure.run(elements, cfg)
  findings += captions.run(elements, cfg)
  findings += accessibility.run(doc.images, doc.tables, cfg)

  let from-bibliography = if bibs.len() > 0 and not collect.prints-full-bibliography(bibs) {
    if cfg.bib-keys == none {
      citations.not-checked(collect.bibliography-sources(bibs), cfg)
    } else {
      citations.run(cfg.bib-keys, collect.cited-keys(elements), cfg)
    }
  } else { () }
  findings += from-bibliography.enumerate().map(((i, f)) => f + (order: doc.count + i))

  let exemptions = collect.ignores()
  let ignored = (:)
  for entry in exemptions {
    let ids = entry.at("checks", default: none)
    if entry.target in ignored {
      let already = ignored.at(entry.target)
      ids = if already == none or ids == none { none } else { already + ids }
    }
    ignored.insert(entry.target, ids)
  }
  findings = findings.filter(f => not _silenced(f, ignored))

  let orphaned = doc.count + from-bibliography.len()
  findings += ignores
    .run(
      exemptions,
      cfg.bib-keys,
      cfg,
      bibliography-unknown: bibs.len() > 0 and cfg.bib-keys == none,
    )
    .enumerate()
    .map(((i, f)) => f + (order: orphaned + i))

  // one finding of a kind per element
  let seen = (:)
  let unique = ()
  for f in findings {
    if f.target != none {
      let key = f.id + "\u{0}" + f.target
      if key in seen { continue }
      seen.insert(key, true)
    }
    unique.push(f)
  }
  findings = unique

  // report in reading order
  let stride = findings.len() + 1
  findings = findings
    .enumerate()
    .sorted(key: ((i, f)) => f.order * stride + i)
    .map(((i, f)) => (
      id: f.id,
      severity: f.severity,
      message: f.message,
      target: f.target,
      page: f.page,
      page-label: f.page-label,
    ))

  let locations = (:)
  if collect.paged() {
    let wanted = (:)
    for f in findings {
      if f.target != none { wanted.insert(f.target, true) }
    }
    for elem in elements {
      if elem.target == none or elem.target not in wanted { continue }
      if elem.target in locations { continue }
      locations.insert(elem.target, elem.location)
    }
  }

  (findings: findings, locations: locations)
}
