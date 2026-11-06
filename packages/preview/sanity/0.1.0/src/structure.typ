#import "core.typ": describe, finding

/// same label on two elements
#let _duplicates(elements, cfg) = {
  let id = "duplicate-label"
  if not cfg.checks.at(id, default: false) { return () }

  let groups = (:)
  for elem in elements {
    if elem.target == none { continue }
    groups.insert(elem.target, groups.at(elem.target, default: ()) + (elem,))
  }

  let out = ()
  for (target, group) in groups {
    if group.len() < 2 { continue }

    let pages = group.map(e => e.page-label).filter(p => p != none).dedup()
    out.push(finding(
      id,
      cfg.severities.at(id),
      "label <" + target + "> is attached to " + str(group.len()) + " elements"
        + if pages.len() > 1 { " (pages " + pages.join(", ") + ")" } else { "" },
      target: target,
      page: group.first().page,
      page-label: group.first().page-label,
      order: group.first().order,
    ))
  }
  out
}

#let _level-skips(elements, cfg) = {
  let id = "heading-level-skip"
  if not cfg.checks.at(id, default: false) { return () }

  let out = ()
  let previous = none
  for elem in elements {
    if elem.group != "heading" { continue }
    let level = elem.element.level

    if previous != none and level > previous + 1 {
      out.push(finding(
        id,
        cfg.severities.at(id),
        describe(elem) + " jumps from level " + str(previous) + " to level " + str(level),
        target: elem.target,
        page: elem.page,
        page-label: elem.page-label,
        order: elem.order,
      ))
    }
    previous = level
  }
  out
}

#let run(elements, cfg) = _duplicates(elements, cfg) + _level-skips(elements, cfg)
