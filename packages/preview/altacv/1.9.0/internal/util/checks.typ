// Generic input checks behind every guided panic: "must be …" with
// the value got, the rules that drive it, unknown-key and enum checks,
// and their prose lists.

#import "values.typ": _round-half

// A string quoted; any other value (an alignment) as Typst writes it.
#let _quote(s) = if type(s) == str { "\"" + s + "\"" } else { repr(s) }

// `"a" or "b"`, `"a", "b", or "c"`.
#let _prose-list(items) = items.join(
  ", ",
  last: if items.len() == 2 { " or " } else { ", or " },
)

// The shared "must be …" panic.
#let _require(name, value, ok, expected) = {
  if not ok { panic(name + " must be " + expected + ", got: " + repr(value)) }
}

// The shared "Unknown …" panic: `found` and `supported` come
// formatted; `hint` follows the list.
#let _unknown(what, found, supported, hint: "") = panic(
  "Unknown " + what + ": " + found + ". Supported: " + supported + "." + hint,
)

#let _check-unknown-keys(candidates, allowed, what) = {
  let unknown = candidates.filter(k => k not in allowed)
  if unknown.len() > 0 {
    _unknown(
      what + " key(s)",
      unknown.map(_quote).join(", "),
      allowed.map(_quote).join(", "),
    )
  }
}

// Rules for `_check` and `_check-rules`: `(ok, expected)`, where `ok`
// tests the value and `expected` completes "<name> must be …".
#let _type-rule(types, expected) = (v => type(v) in types, expected)
#let _bool-rule = _type-rule((bool,), "a bool")
#let _number-rule = _type-rule((int, float), "a number")
#let _positive-int-rule = (
  v => type(v) == int and v >= 1,
  "a positive integer",
)
#let _list-rule(types, expected) = (
  v => type(v) == array and v.all(x => type(x) in types),
  expected,
)
#let _dict-rule(types, expected) = (
  v => type(v) == dictionary and v.values().all(x => type(x) in types),
  expected,
)
#let _enum-rule(allowed) = (
  v => v in allowed,
  _prose-list(allowed.map(_quote)),
)

#let _check(name, value, (ok, expected)) = _require(
  name,
  value,
  ok(value),
  expected,
)

// Each `key: rule` against `values.at(key)`, named `prefix + key`.
// `optional` skips a key `values` doesn't have.
#let _check-rules(values, rules, prefix: "", optional: false) = for (
  key,
  rule,
) in rules {
  if not optional or key in values {
    _check(prefix + key, values.at(key), rule)
  }
}

#let _check-type(name, value, allowed, expected) = _check(
  name,
  value,
  _type-rule(allowed, expected),
)

// `value` a dictionary whose keys are all in `allowed`.
#let _check-keys(name, value, allowed) = {
  _check-type(name, value, (dictionary,), "a dictionary")
  _check-unknown-keys(value.keys(), allowed, name)
}

// A rating on a `max`-dot scale: a number from 0 to `max`, in halves.
// Half dots are the only fraction drawable; rejecting others stops
// `3.1` and `3.9` silently rounding alike.
#let _check-rating(name, value, max) = {
  _check(name, value, _number-rule)
  _require(
    name,
    value,
    value >= 0 and value <= max,
    "between 0 and " + str(max),
  )
  _require(name, value, _round-half(value) == value, "a multiple of 0.5")
}
