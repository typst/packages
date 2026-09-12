// Block catalogs for the manual, built from the dialect locales the renderer
// itself uses (scripts/scratchblocks-wasm/data/dialects/locales/*.toml).
//
// A locale lists every block's spec ("zeige Zahl %1"), shape and slot kinds.
// `catalog-entries` turns each spec into the text notation a document would
// write — `%1` becomes `()`, `[ v]`, `<>`, an LED matrix or a melody as its
// slot says, a C-block gets its end marker — and groups the entries by
// category, so the manual can render every block of a dialect live.

// The notation for one placeholder, by slot kind.
#let _slot(kind) = {
  if kind == "dropdown" { "[ v]" } else if kind == "matrix" {
    "[#...#|.#.#.|..#..|.#.#.|#...#]"
  } else if kind == "melody" { "[C D E F - - - -]" } else if kind == "statement" { "" } else { "()" }
}

// The text a document writes for a spec.
#let spec-text(spec, shape, slots, end: "ende") = {
  let kinds = if slots == none { () } else { slots.split(",").map(s => s.trim()) }
  let text = spec.replace(regex("%(\d+)"), m => {
    let n = int(m.captures.at(0))
    let kind = if n - 1 < kinds.len() { kinds.at(n - 1) } else { "value" }
    _slot(kind)
  })
  let text = text.replace(regex("[ \t]+"), " ").trim()
  let text = if shape == "reporter" { "(" + text + ")" } else if shape == "boolean" { "<" + text + ">" } else { text }
  if shape.contains("c-block") { text + "\n" + end } else { text }
}

/// Every block of a locale as `(category, id, text)`, grouped by category in
/// the order the categories first appear; the markers (`scratchblocks:end`,
/// `control_else`) are left out.
///
/// - locale (dictionary): a dialect locale, `toml("…/makecode-de.toml")`
/// - end (str): the end marker of that dialect's language
/// - only (array | none): category names to keep, `none` for all
/// -> dictionary: category → array of (id: …, text: …)
#let catalog-entries(locale, end: "ende", only: none) = {
  let specs = locale.at("specs", default: (:))
  let shapes = locale.at("shapes", default: (:))
  let categories = locale.at("categories", default: (:))
  let slots = locale.at("slots", default: (:))
  let groups = (:)
  for (id, spec) in specs {
    let shape = shapes.at(id, default: "stack")
    if id in ("scratchblocks:end", "control_else") or shape in ("cend", "celse") { continue }
    let category = categories.at(id, default: "")
    if only != none and category not in only { continue }
    let entry = (id: id, text: spec-text(spec, shape, slots.at(id, default: none), end: end))
    if category in groups { groups.at(category).push(entry) } else { groups.insert(category, (entry,)) }
  }
  groups
}
