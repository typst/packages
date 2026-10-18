#import "core.typ": blank, comparable, describe, finding

/// enough of a caption to recognise it by
#let _excerpt(words) = {
  let shown = words.clusters()
  if shown.len() > 45 { repr(shown.slice(0, 45).join()) + " .." } else { repr(words) }
}

#let _finding(id, elem, message, cfg) = finding(
  id,
  cfg.severities.at(id),
  describe(elem) + " " + message,
  target: elem.target,
  page: elem.page,
  page-label: elem.page-label,
  order: elem.order,
)

#let run(elements, cfg) = {
  let out = ()
  let captions = (:)

  for elem in elements {
    if elem.group not in ("figure", "table") { continue }

    let caption = elem.element.caption

    if caption == none {
      let id = "missing-caption"
      if elem.target == none or not cfg.checks.at(id, default: false) { continue }
      out.push(_finding(id, elem, "has no caption", cfg))
      continue
    }

    if blank(caption.body) {
      let id = "empty-caption"
      if not cfg.checks.at(id, default: false) { continue }
      out.push(_finding(id, elem, "has an empty caption", cfg))
      continue
    }

    let wants-label = (
      elem.target == none
        and elem.numbered
        and cfg.checks.at("missing-label", default: false)
    )
    let wants-duplicates = cfg.checks.at("duplicate-caption", default: false)
    if not (wants-label or wants-duplicates) { continue }

    let words = comparable(caption.body)

    let id = "missing-label"
    if wants-label {
      // there is no label to name it by
      out.push(finding(
        id,
        cfg.severities.at(id),
        elem.noun + " " + _excerpt(words) + " has no label",
        page: elem.page,
        page-label: elem.page-label,
        order: elem.order,
      ))
    }

    let id = "duplicate-caption"
    // a caption sanity cannot read as text says nothing about another one
    if not wants-duplicates or words == "" { continue }

    let key = elem.noun + "\u{0}" + words
    if key in captions {
      out.push(_finding(
        id,
        elem,
        "has the same caption as " + describe(captions.at(key)),
        cfg,
      ))
    } else {
      captions.insert(key, elem)
    }
  }
  out
}
