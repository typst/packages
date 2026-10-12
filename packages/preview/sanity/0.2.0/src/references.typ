#import "core.typ": describe, finding

#let check-id = (
  figure: "unreferenced-figure",
  table: "unreferenced-table",
  listing: "unreferenced-listing",
  equation: "unreferenced-equation",
  heading: "unreferenced-heading",
  footnote: "unreferenced-footnote",
)

#let run(elements, referenced, cfg) = {
  let out = ()
  for elem in elements {
    if elem.target == none or not elem.numbered { continue }
    if elem.target in referenced { continue }

    let id = check-id.at(elem.noun, default: check-id.at(elem.group, default: none))
    if id == none or not cfg.checks.at(id, default: false) { continue }

    out.push(finding(
      id,
      cfg.severities.at(id),
      describe(elem) + " is never referenced",
      target: elem.target,
      page: elem.page,
      page-label: elem.page-label,
      order: elem.order,
    ))
  }
  out
}
