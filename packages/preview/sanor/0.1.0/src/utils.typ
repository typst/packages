#let merge-dicts(dict, base: (:)) = {
  for (key, val) in dict {
    if type(val) == dictionary and key in base.keys() {
      base.insert(key, merge-dicts(dict.at(key), base: base.at(key)))
    } else {
      base.insert(key, val)
    }
  }
  return base
}

#let pipe(base, ..funcs) = {
  funcs.pos().fold(base, (acc, f) => f(acc))
}