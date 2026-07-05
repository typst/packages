#import "@preview/t4t:0.3.2": is

// Joins two dictionaries together by inserting `new` values into `old`.
// When only-update is true, values will only be inserted if they keys exist in old.
#let combine-dict(new, old, only-update: false) = {
  for (k, v) in new {
    if not only-update or k in old {
      old.insert(k, v)
    }
  }
  return old
}

#let content-to-string(it) = {
  return if type(it) == str {
    it
  } else if it == [ ] {
    " "
  } else if it.has("children") {
    it.children.map(content-to-string).join()
  } else if it.has("body") {
    content-to-string(it.body)
  } else if it.has("text") {
    it.text
  } else if it.has("base") { // attach
    content-to-string(it.base) + "^" + content-to-string(it.t)
  }
}