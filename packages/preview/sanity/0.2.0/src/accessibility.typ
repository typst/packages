#import "core.typ": describe, finding

/// both checks are off by default
#let run(images, tables, cfg) = {
  let out = ()

  let id = "missing-alt-text"
  if cfg.checks.at(id, default: false) {
    for img in images {
      if img.element.alt != none { continue }
      out.push(finding(
        id,
        cfg.severities.at(id),
        describe(img) + " has no alt text",
        target: img.target,
        page: img.page,
        page-label: img.page-label,
        order: img.order,
      ))
    }
  }

  let id = "table-without-header"
  if cfg.checks.at(id, default: false) {
    for tbl in tables {
      if tbl.element.children.any(c => c.func() == table.header) { continue }
      out.push(finding(
        id,
        cfg.severities.at(id),
        describe(tbl) + " has no header row",
        target: tbl.target,
        page: tbl.page,
        page-label: tbl.page-label,
        order: tbl.order,
      ))
    }
  }

  out
}
