#let dict-at(dict, ..keys, default: (:)) = {
  if dict == none {
    assert(default != none, message: "dict is none and default is none")
    return default
  }

  assert(keys.pos().len() > 0, message: "no keys provided")
  let items = keys.pos()

  let result = items
    .slice(0, -1)
    .fold(dict, (acc, key) => acc.at(key, default: ()))
    .at(items.last(), default: default)

  assert.ne(
    result,
    (:),
    message: "color not found in palette and no default was provided",
  )
  result
}
