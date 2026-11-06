// typst-mode: util.typ
// Structural type-system helpers shared by record.typ and enum.typ:
//   _match        — does a value `v` match an expected type `t`?
//   _fetch_method — bind a batch of methods into a copy of `self`.

// Reserve actual implementation keys, not all underscore-prefixed names:
// application fields such as a tag's `_parent` remain valid.
#let _type_reserved_names = (
  "_type",
  "_type_id",
  "_fields",
  "_variants",
  "_methods",
  "_register",
)

#let _check_names(names, forbidden) = {
  for name in names {
    assert(
      not (name in forbidden),
      message: "name `" + name + "` conflicts with a reserved name or data field",
    )
  }
}

// Valid schemas are native types or custom record/enum types, never wildcards.
#let _is_type(t) = {
  if type(t) == type { return true }
  if type(t) != dictionary { return false }
  (
    ("_type_id" in t)
      and (type(t.at("_fields", default: none)) == dictionary or type(t.at("_variants", default: none)) == dictionary)
      and type(t.at("new", default: none)) == function
      and type(t.at("compare", default: none)) == function
  )
}

// Compare type descriptions without implicit wildcard types.
#let _type_accepts(expected, actual) = {
  if type(expected) == type {
    expected == actual
  } else if type(expected) == dictionary {
    let compare = expected.at("compare", default: none)
    if type(compare) == function { compare(actual) } else { false }
  } else {
    false
  }
}

// Structural type match: `t` is the expected type, `v` the actual value.
// Raw types (`int`, `str`, ...) match against `type(v)`; custom types match
// against the type stored in a value's `_type`.
#let _match(t, v) = {
  if not _is_type(t) { return false }
  let tv = type(v)
  if type(t) == type {
    // a raw type such as `int` or `str`: compare directly
    t == tv
  } else if tv == dictionary and dictionary.keys(v).contains("_type") {
    // `v` is a custom instance: compare its `_type` against the expected one
    _type_accepts(t, v._type)
  } else {
    // `t` is a custom type but `v` is not a custom instance.
    false
  }
}

// Bind a batch of methods into a copy of `self`.
// `fn(name)` must return a function of shape `(self, ..rest) => ...`; the
// result maps every method name to `fn(name)`. Callers pass `fn` as the
// `this_call` closure, which is what keeps `self` pointing at the current
// (possibly extended) type or instance.
#let _fetch_method(self, fn, methods) = {
  let m = (:)
  for name in methods {
    m.insert(name, fn(name))
  }
  self + m
}
