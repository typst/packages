#import "core.typ": describe, finding

#let id = "reference-order"

/// for example journal that numbers figures by first mention expects the mentions
/// to walk down the document in the order the elements do
#let run(elements, sequence, cfg) = {
  if not cfg.checks.at(id, default: false) { return () }

  let by-target = (:)
  for elem in elements {
    if elem.target == none or not elem.numbered { continue }
    // headings and footnotes are numbered too
    if elem.group not in ("figure", "table") { continue }
    if elem.target in by-target { continue }
    by-target.insert(elem.target, elem)
  }

  let seen = (:)
  let furthest = (:)
  let out = ()
  for target in sequence {
    if target in seen or target not in by-target { continue }
    seen.insert(target, true)

    let elem = by-target.at(target)
    let last = furthest.at(elem.noun, default: none)
    if last == none or elem.order > last.order {
      furthest.insert(elem.noun, elem)
      continue
    }

    out.push(finding(
      id,
      cfg.severities.at(id),
      describe(elem) + " is numbered before <" + last.target + ">"
        + " but first referenced after it",
      target: elem.target,
      page: elem.page,
      page-label: elem.page-label,
      order: elem.order,
    ))
  }
  out
}
