
#let if-else(condition, tru-val, fal-val) = {
  if condition { tru-val } else { fal-val }
}

#let if-none(obj, tru-val, fal-val) = {
  if-else(obj == none, tru-val, fal-val)
}

// Utility: Require Key
#let req-key(dict, key, warn: none) = {
  if key not in dict.keys() {
    if (warn == none) {
      dict.insert(key, none)
    } else {
      assert(false, message: warn)
    }
  }
  return dict
}

// Require keys
#let req-keys(dict, keys, warn: none) = {
  for key in keys { dict = req-key(dict, key) }
  return dict
}