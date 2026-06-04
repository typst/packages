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
