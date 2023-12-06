#let filtered-dict(dict, keys: ()) = {
  let out = (:)
  for key in keys {
    out.insert(key, dict.at(key, default: none))
  }
  out
}

#let is-numeric-type(typ) = {
  typ in (int, float)
}

#let unique-row-keys(rows) = {
  rows.map(row => row.keys()).sum(default: ()).dedup()
}

#let is-internal-field(key) = {
  key.starts-with("__")
}

#let is-external-field(key) = not is-internal-field(key)

#let remove-internal-fields(rows) = {
  rows.map(row => {
    for key in row.keys() {
      if is-internal-field(key) {
        let _ = row.remove(key)
      }
    }
    row
  })
}