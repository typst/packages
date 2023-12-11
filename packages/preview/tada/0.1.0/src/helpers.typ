#let keep-keys(dict, keys: ()) = {
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

#let assert-is-type(value, allowed-type, value-name) = {
  let value-type = type(value)
  assert(
    value-type == allowed-type,
    message: "`" + value-name + "` must be a" + repr(allowed-type) + ", got: " + value-type
  )
}

#let assert-list-of-type(values, allowed-type, value-name) = {
  let iterator = if type(values) == dictionary {
    values
  } else if type(values) == array {
    values.enumerate()
  } else {
    panic("Expected a list or dictionary, got: " + type(values))
  }
  for (index, value) in iterator {
    assert-is-type(value, allowed-type, value-name + ".at(" + repr(index) + ")")
  }
}