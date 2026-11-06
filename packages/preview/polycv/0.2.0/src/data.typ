// Data loading, `inherit:` resolution and schema validation, shared by the
// cv.typ / letter.typ / application.typ entrypoints so they stay thin.
#import "@preview/jsonschemeyst:0.0.1": validate

// Recursively merge a child over its parent: dicts merge key by key, arrays
// merge by index, other values are replaced. `none` (yaml `~`) keeps the parent
// value, so a customized file only lists what changes.
#let deep-merge(base, over) = {
  if over == none {
    base
  } else if type(base) == dictionary and type(over) == dictionary {
    let out = base
    for (k, v) in over { out.insert(k, deep-merge(base.at(k, default: none), v)) }
    out
  } else if type(base) == array and type(over) == array {
    range(calc.max(base.len(), over.len())).map(i => deep-merge(
      base.at(i, default: none),
      over.at(i, default: none),
    ))
  } else { over }
}

// Directory part of a path ("sub/cv-fr.yml" -> "sub/", "cv-fr.yml" -> "").
#let dir-of(f) = {
  let parts = f.split("/")
  if parts.len() <= 1 { "" } else { parts.slice(0, -1).join("/") + "/" }
}

// Resolve `inherit: <path>` chains. `load` is a closure the caller passes in
// (e.g. `f => yaml(f)`); it must be defined in the user's file so relative
// paths resolve against the project, not this package.
#let load-inherited(f, load) = {
  let raw = load(f)
  let parent = raw.at("inherit", default: none)
  if parent == none {
    raw
  } else {
    let _ = raw.remove("inherit")
    deep-merge(load-inherited(dir-of(f) + parent, load), raw)
  }
}

// Load a data file, resolve its `inherit:` chain, and validate the merged
// document against the bundled JSON Schema. On invalid data the compile stops
// with the offending field's path (e.g. `/meta/locale`). Returns the data.
#let load-cv-data(f, load) = {
  let data = load-inherited(f, load)
  let _ = validate(read("schema.json"), json.encode(data))
  data
}
