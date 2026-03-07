#let merge-dicts(dictA, base: (:)) = {
  for (key, val) in dictA {
    if type(val) == dictionary and key in base.keys() {
      base.insert(key, merge-dicts(dictA.at(key), base: base.at(key)))
    } else {
      base.insert(key, val)
    }
  }
  return base
}

// This can be used to create multiple column layout.
#let multicols(columns, ..kwargs) = grid(columns: columns, gutter: 1em, ..kwargs)


