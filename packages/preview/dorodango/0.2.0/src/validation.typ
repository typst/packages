#let _fail(msg) = panic("squircle: " + msg)

// Joins like Typst's own diagnostics: `a, b, and c`. `join` renders two items
// as `a, and b`, hence the special case.
#let _oxford(items, conj) = {
  if items.len() == 2 {
    items.at(0) + " " + conj + " " + items.at(1)
  } else { items.join(", ", last: ", " + conj + " ") }
}

#let _list-keys(keys) = _oxford(keys.map(k => "\"" + k + "\""), "and")

#let _list-types(types) = _oxford(types.map(str), "or")

#let _bad-keys(val, allowed) = val.keys().filter(k => k not in allowed)

#let _key-error(name, bad, allowed) = _fail(
  name
    + ": "
    + (if bad.len() == 1 { "unexpected key " } else { "unexpected keys " })
    + _list-keys(bad)
    + ", valid keys are "
    + _list-keys(allowed),
)

#let _found(value) = str(type(value))

#let _expect(name, value, accepted, expected) = {
  if type(value) not in accepted {
    _fail(name + ": expected " + expected + ", found " + _found(value))
  }
}

#let _relative-types = (length, ratio, relative)

// Not `_list-types(accepted)`: that spells the union out as "auto, length,
// ratio, or relative length", where `rect` says "auto or relative length".
#let _validate-size(name, value, fraction-ok: false) = {
  let accepted = (type(auto),) + _relative-types
  if fraction-ok { accepted.push(fraction) }
  _expect(
    name,
    value,
    accepted,
    "auto or relative length" + if fraction-ok { " or fraction" } else { "" },
  )
}

#let _validate-fill(value) = _expect(
  "fill",
  value,
  (color, gradient, tiling, type(none)),
  "paint or none",
)

// No `x`/`y` keys here, unlike `_side-keys`. `rect` rejects them too.
#let _corner-keys = (
  "top-left",
  "top-right",
  "bottom-right",
  "bottom-left",
  "left",
  "top",
  "right",
  "bottom",
  "rest",
)

#let _side-keys = ("left", "top", "right", "bottom", "x", "y", "rest")

// Tells a per-side dictionary from a dictionary of stroke properties.
#let _is-side-dict(val) = (
  type(val) == dictionary and _bad-keys(val, _side-keys).len() == 0
)

#let _validate-relative(name, value) = _expect(
  name,
  value,
  _relative-types,
  "relative length",
)

#let _validate-relative-or-dict(name, value, keys) = {
  if type(value) != dictionary {
    return _validate-relative(name, value)
  }

  let bad = _bad-keys(value, keys)
  if bad.len() > 0 { _key-error(name, bad, keys) }
  for (key, item) in value {
    _validate-relative(name + "." + key, item)
  }
}

#let _stroke-keys = ("paint", "thickness", "cap", "join", "dash", "miter-limit")

// Ordered so that `_list-types` renders them the way `rect` does. A side also
// takes `none` (leave unstroked) but not `auto`, having no per-side default.
#let _stroke-input-types = (length, color, gradient, tiling, dictionary, stroke)
#let _stroke-side-types = _stroke-input-types + (type(none),)

#let _as-stroke(name, value) = {
  _expect(name, value, _stroke-input-types, _list-types(_stroke-input-types))
  if type(value) == dictionary {
    let bad = _bad-keys(value, _stroke-keys)
    if bad.len() > 0 { _key-error(name, bad, _stroke-keys) }
  }
  stroke(value)
}

#let _validate-stroke(value) = {
  if value in (auto, none) { return value }
  if type(value) != dictionary { return _as-stroke("stroke", value) }

  if _is-side-dict(value) {
    let out = (:)
    for (key, item) in value {
      // `auto` is the one input a whole `stroke` takes that a side does not,
      // so it is rejected here rather than by `_as-stroke`.
      if item == auto {
        _fail(
          "stroke."
            + key
            + ": expected "
            + _list-types(_stroke-side-types)
            + ", found auto",
        )
      } else if item == none {
        out.insert(key, none)
      } else {
        out.insert(key, _as-stroke("stroke." + key, item))
      }
    }
    return out
  }

  if _bad-keys(value, _stroke-keys).len() == 0 {
    return _as-stroke("stroke", value)
  }

  // Neither kind of dictionary: either a key belongs to no set, or the two
  // sets were mixed.
  let all-keys = _side-keys + _stroke-keys
  let bad = _bad-keys(value, all-keys)
  if bad.len() > 0 {
    _key-error("stroke", bad, all-keys)
  } else {
    _fail("stroke: cannot mix side keys with stroke-property keys")
  }
}

#let _validate-body(args) = {
  // This positional sink also catches misspelt names. Explain `body:`, then
  // use `rect`'s wording for any other unknown argument.
  let named = args.named()
  if "body" in named {
    _fail(
      "unexpected named argument \"body\"; "
        + "the body must be specified positionally",
    )
  }
  if named.len() > 0 {
    _fail("unexpected argument: " + named.keys().first())
  }

  let positional = args.pos()
  if positional.len() > 1 {
    _fail(
      "expected at most one positional body, found " + str(positional.len()),
    )
  }
  if positional.len() == 0 or positional.first() == none { return none }

  let body = positional.first()
  if type(body) == content { body } else if type(body) in (str, symbol) {
    [#body]
  } else {
    _fail(
      "body: expected content, string, symbol, or none, found " + _found(body),
    )
  }
}
