#let keep-keys(dict, keys: (), reorder: false) = {
  let out = (:)
  if not reorder {
    // Keep original insertion order
    keys = dict.keys().filter(key => key in keys)
  }
  for key in keys.filter(key => key in dict) {
    out.insert(key, dict.at(key))
  }
  out
}

#let is-numeric-type(typ) = {
  typ in (int, float)
}

#let unique-record-keys(rows) = {
  rows.map(row => row.keys()).sum(default: ()).dedup()
}

#let is-internal-field(key) = {
  key.starts-with("__")
}

#let is-external-field(key) = not is-internal-field(key)

#let remove-internal-fields(data) = {
  let out = (:)
  for key in data.keys().filter(is-external-field) {
    out.insert(key, data.at(key))
  }
  out
}

#let dict-from-pairs(pairs) = {
  let out = (:)
  for (key, value) in pairs {
    out.insert(key, value)
  }
  out
}

#let default-dict(keys, value: none) = {
  dict-from-pairs(keys.map(key => (key, value)))
}

#let merge-nested-dicts(a, b, recurse: false) = {
  if recurse {
    panic("Recursive merging not implemented yet")
  }
  let merged = (:)
  for (key, val) in a {
    if type(val) == dictionary and type(b.at(key, default: none)) == dictionary {
      val += b.at(key)
    } else {
      val = b.at(key, default: val)
    }
    merged.insert(key, val)
  }
  for key in b.keys().filter(key => key not in a) {
    merged.insert(key, b.at(key))
  }
  merged
}

#let transpose-values(values) = {
  let out = ()
  for (ii, row) in values.enumerate() {
    for (jj, value) in row.enumerate() {
      if ii == 0 {
        out.push(())
      }
      out.at(jj).push(value)
    }
  }
  out
}

#let assert-is-type(value, allowed-type, value-name) = {
  let value-type = type(value)
  assert(
    value-type == allowed-type,
    message: "`" + value-name + "` must be type " + repr(allowed-type) + ", got: " + value-type
  )
}

#let assert-list-of-type(values, allowed-type, value-name) = {
  let iterator = if type(values) == dictionary {
    values
  } else if type(values) == array {
    values.enumerate()
  } else {
    panic("Expected a list or dictionary for " + value-name + ", got: " + type(values))
  }
  for (index, value) in iterator {
    assert-is-type(value, allowed-type, value-name + ".at(" + repr(index) + ")")
  }
}

#let assert-rectangular-matrix(values) = {
  assert-is-type(values, array, "values")
  if values.len() == 0 {
    return
  }
  assert-list-of-type(values, array, "values")
  let row-lengths = values.map(row => row.len())
  assert(
    row-lengths.dedup().len() == 1,
    message: "Expected a rectangular 2D matrix, got lengths: " + repr(row-lengths)
  )
}

#let eval-str-or-function(
  func-or-str,
  mode: "markup",
  scope: (:),
  default-if-auto: (arg) => arg,
  positional: (),
  keyword: (:),
) = {
  if type(positional) != array {
    positional = (positional, )
  }
  if func-or-str == auto {
    func-or-str = default-if-auto
  }
  let typ = type(func-or-str)
  if typ == function {
    return func-or-str(..positional, ..keyword)
  }
  if typ == content and func-or-str.has("text") {
    func-or-str = func-or-str.text
  } else if typ == content {
    return func-or-str
  }
  if type(func-or-str) != str {
    panic("Expected a function, string, or raw content, got " + typ + ": " + repr(func-or-str))
  }
  return eval(func-or-str, mode: mode, scope: scope)
}