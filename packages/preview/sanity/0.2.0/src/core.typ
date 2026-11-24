#let version = "0.2.0"

#let severity-order = ("info", "warning", "error")

#let finding(
  id,
  severity,
  message,
  target: none,
  page: none,
  page-label: none,
  order: 0,
) = (
  id: id,
  severity: severity,
  message: message,
  target: target,
  page: page,
  page-label: page-label,
  order: order,
)

/// whether anything here should fail a build, "info" never does
#let blocking(findings) = findings.any(f => f.severity != "info")

#let default-checks = (
  "unreferenced-figure": true,
  "unreferenced-table": true,
  "unreferenced-listing": true,
  "unreferenced-equation": true,
  "unreferenced-footnote": true,
  // labelling sections you never cross-reference is common enough that
  // this would mostly produce (a lot of) noise (so false by default)
  "unreferenced-heading": false,
  "duplicate-label": true,
  "heading-level-skip": true,
  // a rule of the journals that number by first mention
  "reference-order": false,
  "missing-caption": true,
  "empty-caption": true,
  "missing-label": true,
  "duplicate-caption": false,
  "uncited-entry": true,
  "bibliography-not-checked": true,
  "orphaned-ignore": true,
  "missing-alt-text": false,
  "table-without-header": false,
)

#let default-severities = (
  "unreferenced-figure": "warning",
  "unreferenced-table": "warning",
  "unreferenced-listing": "warning",
  "unreferenced-equation": "warning",
  "unreferenced-footnote": "warning",
  "unreferenced-heading": "warning",
  // a duplicated label makes every reference to it a hard compile error
  "duplicate-label": "error",
  "heading-level-skip": "warning",
  "reference-order": "warning",
  "missing-caption": "warning",
  "empty-caption": "warning",
  "missing-label": "warning",
  "duplicate-caption": "warning",
  "uncited-entry": "warning",
  "bibliography-not-checked": "info",
  "orphaned-ignore": "warning",
  "missing-alt-text": "warning",
  "table-without-header": "warning",
)

// a typo in a check id would otherwise turn a check off, or silence one, in
// silence
#let assert-known(ids) = {
  for id in ids {
    assert(
      type(id) == str and id in default-checks,
      message: "sanity: no such check: " + repr(id),
    )
  }
}

#let config(checks: (:), severities: (:), bib-keys: none) = {
  assert-known(checks.keys() + severities.keys())
  for (id, level) in severities {
    assert(
      level in severity-order,
      message: "sanity: severity for " + id + " must be info, warning or error",
    )
  }

  (
    checks: default-checks + checks,
    severities: default-severities + severities,
    bib-keys: bib-keys,
  )
}

#let describe(elem) = {
  if elem.target != none {
    elem.noun + " <" + elem.target + ">"
  } else if elem.at("source", default: none) != none {
    elem.noun + " " + repr(elem.source)
  } else if elem.page-label != none {
    elem.noun + " on page " + elem.page-label
  } else {
    elem.noun
  }
}

#let _whitespace = ("space", "linebreak", "parbreak", "h", "v")

#let _breaks = ("space", "linebreak", "parbreak")

#let text-of(it) = {
  if it == none { return "" }
  if type(it) == str { return it }
  if type(it) != content { return "" }

  if it.has("text") { return it.text }
  if it.has("children") { return it.children.map(text-of).join("") }
  if it.has("body") and it.body != none { return text-of(it.body) }

  let func = repr(it.func())
  // an apostrophe is a letter's business, and a caption reads badly without it
  if func == "smartquote" { return if it.double { "\"" } else { "'" } }
  if func == "cite" { return "@" + str(it.key) }
  if func == "ref" { return "@" + str(it.target) }
  if func in _breaks { " " } else { "" }
}

#let _runs = regex("\\s+")

#let comparable(it) = text-of(it).replace(_runs, " ").trim()

#let _merge-counts(a, b) = {
  for (key, n) in b { a.insert(key, a.at(key, default: 0) + n) }
  a
}

#let citation-tally-of(it) = {
  if it == none { return (:) }
  if type(it) != content { return (:) }
  let func = it.func()
  if func == std.cite { return (str(it.key): 1) }
  if func == std.ref { return (str(it.target): 1) }
  if it.has("children") {
    return it.children.fold((:), (out, c) => _merge-counts(out, citation-tally-of(c)))
  }
  if it.has("body") and it.body != none { return citation-tally-of(it.body) }
  (:)
}

/// whether a piece of content says nothing at all
#let blank(it) = {
  if it == none { return true }
  if type(it) == str { return it.trim() == "" }
  if type(it) != content { return false }

  if it.has("text") { return it.text.trim() == "" }
  if it.has("children") { return it.children.all(blank) }
  if it.has("body") and it.body != none { return blank(it.body) }
  repr(it.func()) in _whitespace
}
