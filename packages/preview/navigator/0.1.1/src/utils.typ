/// Merges two dictionaries recursively.
#let merge-dicts(dict-a, base: (:)) = {
  for (key, val) in dict-a {
    if type(val) == dictionary and key in base.keys() {
      base.insert(key, merge-dicts(dict-a.at(key), base: base.at(key)))
    }
    else {
      base.insert(key, val)
    }
  }
  return base
}

/// Standardized slide title component (visual only, no heading)
#let slide-title(content, size: 1.2em, weight: "bold", color: black, inset: (bottom: 0.8em)) = {
  if content == none { return none }
  block(
    width: 100%, 
    inset: inset, 
    text(size: size, weight: weight, fill: color, content)
  )
}
