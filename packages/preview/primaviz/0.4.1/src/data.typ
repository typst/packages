// data.typ — Helpers for loading and reshaping JSON into chart-ready formats
//
// Usage:
//   #import "@preview/primaviz:0.4.1": *
//   #let raw = json("sales.json")
//   #bar-chart(load-simple(raw))

/// Reshape a JSON object or array into simple `(labels, values)` format.
///
/// Accepts:
/// - dict: `{"Jan": 300, "Feb": 303}` → labels from keys, values from values
/// - array of pairs: `[["Jan", 300], ["Feb", 303]]`
/// - array of objects: `[{"label": "Jan", "value": 300}, ...]`
/// - already-shaped: `{"labels": [...], "values": [...]}` (passed through)
///
/// -> dictionary
#let load-simple(raw) = {
  if type(raw) == dictionary {
    // Already in our format?
    if "labels" in raw and "values" in raw {
      return raw
    }
    // Dict of key: value pairs
    let keys = raw.keys()
    let vals = keys.map(k => raw.at(k))
    (labels: keys, values: vals)
  } else if type(raw) == array {
    if raw.len() == 0 { return (labels: (), values: ()) }
    let first = raw.at(0)
    if type(first) == array {
      // Array of [label, value] pairs
      (labels: raw.map(p => str(p.at(0))), values: raw.map(p => p.at(1)))
    } else if type(first) == dictionary {
      // Array of {label: ..., value: ...} objects
      let lkey = if "label" in first { "label" } else if "name" in first { "name" } else { "key" }
      let vkey = if "value" in first { "value" } else { "val" }
      (labels: raw.map(r => str(r.at(lkey))), values: raw.map(r => r.at(vkey)))
    } else {
      // Plain array of values — generate numeric labels
      (labels: array.range(raw.len()).map(i => str(i)), values: raw)
    }
  } else {
    panic("load-simple: expected dict or array, got " + str(type(raw)))
  }
}

/// Reshape JSON into multi-series `(labels, series)` format.
///
/// Accepts:
/// - dict of dicts: `{"Q1": {"A": 10, "B": 20}, "Q2": {"A": 15, "B": 25}}`
///   → labels from outer keys, series from inner keys
/// - dict with `labels` + `series`: passed through
/// - array of objects: `[{"period": "Q1", "A": 10, "B": 20}, ...]`
///   with `label-key` specifying which field holds labels (default: first string field)
///
/// -> dictionary
#let load-series(raw, label-key: none) = {
  if type(raw) == dictionary {
    if "labels" in raw and "series" in raw { return raw }
    // Dict of dicts: outer keys = labels, inner keys = series names
    let labels = raw.keys()
    let first-inner = raw.at(labels.at(0))
    let series-names = first-inner.keys()
    let series = series-names.map(name => (
      name: name,
      values: labels.map(lbl => raw.at(lbl).at(name, default: 0)),
    ))
    (labels: labels, series: series)
  } else if type(raw) == array {
    if raw.len() == 0 { return (labels: (), series: ()) }
    let first = raw.at(0)
    // Find label key: explicit, or first string-valued field
    let lk = if label-key != none { label-key } else {
      let found = none
      for k in first.keys() {
        if type(first.at(k)) == str { found = k; break }
      }
      if found == none { first.keys().at(0) } else { found }
    }
    let labels = raw.map(r => str(r.at(lk)))
    let series-keys = first.keys().filter(k => k != lk)
    let series = series-keys.map(name => (
      name: name,
      values: raw.map(r => r.at(name, default: 0)),
    ))
    (labels: labels, series: series)
  } else {
    panic("load-series: expected dict or array, got " + str(type(raw)))
  }
}

/// Reshape JSON into scatter `(x, y)` or `(x, y, labels)` format.
///
/// Accepts:
/// - dict with `x` + `y` arrays: passed through
/// - array of objects: `[{"x": 1, "y": 2}, ...]` or `[{"x": 1, "y": 2, "label": "A"}, ...]`
/// - array of pairs/triples: `[[1, 2], [3, 4]]`
///
/// -> dictionary
#let load-scatter(raw) = {
  if type(raw) == dictionary {
    if "x" in raw and "y" in raw { return raw }
    panic("load-scatter: dict must have 'x' and 'y' keys")
  } else if type(raw) == array {
    if raw.len() == 0 { return (x: (), y: ()) }
    let first = raw.at(0)
    if type(first) == dictionary {
      let result = (x: raw.map(r => r.at("x")), y: raw.map(r => r.at("y")))
      if "label" in first or "name" in first {
        let lk = if "label" in first { "label" } else { "name" }
        result.insert("labels", raw.map(r => str(r.at(lk))))
      }
      result
    } else if type(first) == array {
      let result = (x: raw.map(p => p.at(0)), y: raw.map(p => p.at(1)))
      if first.len() >= 3 {
        result.insert("labels", raw.map(p => str(p.at(2))))
      }
      result
    } else {
      panic("load-scatter: array elements must be dicts or arrays")
    }
  } else {
    panic("load-scatter: expected dict or array")
  }
}

/// Reshape JSON into bubble `(x, y, size)` format.
///
/// Like `load-scatter` but requires a size dimension.
///
/// Accepts:
/// - dict with `x`, `y`, `size` arrays: passed through
/// - array of objects: `[{"x": 1, "y": 2, "size": 5}, ...]`
/// - array of triples: `[[1, 2, 5], [3, 4, 8]]`
///
/// -> dictionary
#let load-bubble(raw) = {
  if type(raw) == dictionary {
    if "x" in raw and "y" in raw and "size" in raw { return raw }
    panic("load-bubble: dict must have 'x', 'y', and 'size' keys")
  } else if type(raw) == array {
    if raw.len() == 0 { return (x: (), y: (), size: ()) }
    let first = raw.at(0)
    if type(first) == dictionary {
      let result = (
        x: raw.map(r => r.at("x")),
        y: raw.map(r => r.at("y")),
        size: raw.map(r => r.at("size")),
      )
      if "label" in first or "name" in first {
        let lk = if "label" in first { "label" } else { "name" }
        result.insert("labels", raw.map(r => str(r.at(lk))))
      }
      result
    } else if type(first) == array {
      let result = (
        x: raw.map(p => p.at(0)),
        y: raw.map(p => p.at(1)),
        size: raw.map(p => p.at(2)),
      )
      if first.len() >= 4 {
        result.insert("labels", raw.map(p => str(p.at(3))))
      }
      result
    } else {
      panic("load-bubble: array elements must be dicts or arrays")
    }
  } else {
    panic("load-bubble: expected dict or array")
  }
}

/// Reshape JSON into hierarchical format for sunburst/treemap.
///
/// Accepts:
/// - already-shaped: `{"name": "root", "value": 100, "children": [...]}` (passed through)
/// - flat array with parent refs: `[{"name": "A", "value": 10, "parent": null}, {"name": "B", "value": 5, "parent": "A"}]`
///
/// -> dictionary
#let load-hierarchy(raw) = {
  if type(raw) == dictionary {
    if "name" in raw { return raw }
    panic("load-hierarchy: dict must have 'name' key")
  } else if type(raw) == array {
    // Flat array with parent references → build tree
    // First pass: index by name
    let by-name = (:)
    for item in raw {
      let name = str(item.at("name"))
      by-name.insert(name, (
        name: name,
        value: item.at("value", default: 0),
        children: (),
      ))
    }
    // Second pass: attach children to parents
    let roots = ()
    for item in raw {
      let name = str(item.at("name"))
      let parent = item.at("parent", default: none)
      if parent == none or parent == "" {
        roots.push(name)
      } else {
        let p = str(parent)
        if p in by-name {
          let node = by-name.at(p)
          node.children = node.children + (by-name.at(name),)
          by-name.insert(p, node)
        }
      }
    }
    // Recursive rebuild: re-resolve each node's children from by-name
    // to pick up grandchildren etc. Typst supports recursive let-functions.
    let rebuild(name) = {
      let node = by-name.at(name)
      if node.children.len() > 0 {
        let resolved = node.children.map(c => rebuild(c.name))
        (name: node.name, value: node.value, children: resolved)
      } else {
        (name: node.name, value: node.value)
      }
    }
    if roots.len() == 1 {
      rebuild(roots.at(0))
    } else {
      (name: "root", value: roots.map(r => by-name.at(r).value).sum(), children: roots.map(r => rebuild(r)))
    }
  } else {
    panic("load-hierarchy: expected dict or array")
  }
}
