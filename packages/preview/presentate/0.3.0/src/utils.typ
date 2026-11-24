#import "@preview/oxifmt:1.0.0": strfmt

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

#let pipe(..funcs) = {
  return (base) => funcs.pos().fold(base, (acc, f) => f(acc))
}

#let map-dict-values(dict, func) = dict.pairs().map(((k, v)) => (k, func(v))).to-dict()