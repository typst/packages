// JSON Schema (draft 7 subset) → Typst-schema translator. Anything
// not supported panics rather than silently dropping the constraint.

#import "kinds.typ": (
  str-type, content-type, number-type, integer-type, bool-type, null-type,
  array-of, object, date-string, datetime-string, uri-string, email-string,
  pattern-string, enum-of, const-of, any-of, one-of, not-of,
)

#let _format-kinds = (
  "uri": uri-string,
  "email": email-string,
  "date": date-string,
  "date-time": datetime-string,
)

// One panic prefix so every diagnostic from this module is grep-able
// by "schema-from-json-schema —".
#let _bail(msg) = panic("gairm-import: schema-from-json-schema — " + msg)

// `seen` is the chain of refs traversed so far; a repeat means a
// cycle (e.g. `definitions.alias → alias`) — panic before Typst's
// recursion limit fires deep in the stack.
#let _resolve-ref(ref, root, seen) = {
  if not ref.starts-with("#/") {
    _bail(
      "only internal $ref (starting with \"#/\") is supported, got: "
        + repr(ref)
        + ".",
    )
  }
  if ref in seen {
    _bail(
      "cyclic $ref detected: "
        + seen.map(repr).join(" → ")
        + " → "
        + repr(ref)
        + ".",
    )
  }
  if ref == "#/" {
    _bail("$ref \"#/\" cannot reference the document root.")
  }
  let parts = ref.slice(2).split("/").filter(p => p != "")
  parts.fold(root, (acc, key) => {
    if type(acc) != dictionary or key not in acc {
      _bail(
        "$ref "
          + repr(ref)
          + " could not be resolved (segment "
          + repr(key)
          + " missing).",
      )
    }
    acc.at(key)
  })
}

#let _unsupported-keywords = (
  "if",
  "then",
  "else",
  "dependencies",
  "dependentRequired",
  "dependentSchemas",
)

// Composition keywords (#108). Each must stand alone on its node
// (annotation-only siblings excepted) — a sibling `type` / `properties`
// / constraint would be silently ignored otherwise, and this module's
// contract is to bail rather than drop.
#let _composition-keywords = ("allOf", "anyOf", "oneOf", "not")

// Annotation-only keywords tolerated beside a composition keyword —
// they carry no validation semantics the engine could drop.
#let _annotation-keywords = (
  "$schema",
  "$id",
  "$comment",
  "title",
  "description",
  "default",
  "examples",
  "readOnly",
  "writeOnly",
  "deprecated",
  "definitions",
  "$defs",
)

#let _require-lone-composition(js, keyword) = {
  let extras = js
    .keys()
    .filter(k => k != keyword and k not in _annotation-keywords)
  if extras.len() > 0 {
    _bail(
      "sibling keywords beside "
        + repr(keyword)
        + " are not supported: "
        + extras.map(repr).join(", ")
        + ". Move them into the composition members.",
    )
  }
}

#let _require-member-array(js, keyword) = {
  let members = js.at(keyword)
  if type(members) != array or members.len() == 0 {
    _bail(
      repr(keyword)
        + " must be a non-empty array of schemas, got: "
        + repr(members)
        + ".",
    )
  }
  for m in members {
    if type(m) != dictionary {
      _bail(
        repr(keyword)
          + " members must be schema objects, got: "
          + repr(m)
          + ".",
      )
    }
  }
  members
}

// allOf: the object-merge subset — every member must translate to an
// object schema; shapes union (a duplicate key must carry an EQUAL
// sub-schema), required-keys union, additionalProperties must agree
// across all members (undeclared counts as closed). Non-object
// composition (e.g. string + extra constraints) stays out of scope;
// deep-merging conflicting sub-schemas is a rabbit hole the engine's
// flat kinds can't express.
#let _merge-all-of(members) = {
  for m in members {
    if m.kind != "object" {
      _bail(
        "allOf members must all be object schemas; got kind "
          + repr(m.kind)
          + ". Non-object composition is out of scope.",
      )
    }
  }
  let shape = (:)
  let required = ()
  let additional = none
  for m in members {
    for (key, sub) in m.shape {
      if key in shape and shape.at(key) != sub {
        _bail(
          "allOf members declare conflicting schemas for key "
            + repr(key)
            + ".",
        )
      }
      shape.insert(key, sub)
    }
    required += m
      .at("required-keys", default: ())
      .filter(k => k not in required)
  }
  // additionalProperties must agree across ALL members, with an
  // undeclared member counting as closed (`none`) — silently taking
  // the open (or typed) member's value would accept keys another
  // member rejects.
  let additionals = members.map(m => m.at("additional", default: none))
  for a in additionals {
    if a != additionals.at(0) {
      _bail(
        "allOf members declare conflicting additionalProperties (open, closed, and typed members must all agree).",
      )
    }
  }
  object(shape, required-keys: required, additional: additionals.at(0))
}

// Constraint keywords that would genuinely tighten an enum / const
// value set. The engine's enum kind checks membership only, so these
// must bail rather than translate to a schema that silently ignores
// them. (`type` beside enum/const stays accepted: membership already
// pins the shape, so it's redundant rather than dropped.)
#let _membership-incompatible-keywords = (
  "format",
  "pattern",
  "minLength",
  "maxLength",
  "minimum",
  "maximum",
  "exclusiveMinimum",
  "exclusiveMaximum",
  "multipleOf",
  "minItems",
  "maxItems",
  "uniqueItems",
)

// Bail at translate time on bad-shape values; better than a kind
// dict the validator can't reason about.
#let _require-nonneg-int(js, key) = {
  let v = js.at(key)
  if type(v) != int or v < 0 {
    _bail(repr(key) + " must be a non-negative integer, got: " + repr(v) + ".")
  }
  v
}

#let _require-number(js, key) = {
  let v = js.at(key)
  if type(v) not in (int, float) {
    _bail(repr(key) + " must be a number, got: " + repr(v) + ".")
  }
  v
}

// Cross-constraint contradictions (min > max, etc.) translate cleanly
// but reject every input — catch them up front so the diagnostic
// fires at translate time, not as a mystery validation failure.
#let _require-ordered(lower-key, lower, upper-key, upper, sep) = {
  if lower != none and upper != none and not (lower <= upper) {
    _bail(
      lower-key
        + " ("
        + repr(lower)
        + ") "
        + sep
        + " "
        + upper-key
        + " ("
        + repr(upper)
        + ") is unsatisfiable.",
    )
  }
}
#let _require-strict(lower-key, lower, upper-key, upper) = {
  if lower != none and upper != none and not (lower < upper) {
    _bail(
      lower-key
        + " ("
        + repr(lower)
        + ") and "
        + upper-key
        + " ("
        + repr(upper)
        + ") leave no satisfying value.",
    )
  }
}

#let _with-string-constraints(js, dict) = {
  let result = dict
  if "minLength" in js {
    result.insert("min-length", _require-nonneg-int(js, "minLength"))
  }
  if "maxLength" in js {
    result.insert("max-length", _require-nonneg-int(js, "maxLength"))
  }
  _require-ordered(
    "minLength",
    result.at("min-length", default: none),
    "maxLength",
    result.at("max-length", default: none),
    ">",
  )
  result
}

#let _with-number-constraints(js, dict) = {
  let result = dict
  if "minimum" in js {
    result.insert("minimum", _require-number(js, "minimum"))
  }
  if "maximum" in js {
    result.insert("maximum", _require-number(js, "maximum"))
  }
  if "exclusiveMinimum" in js {
    result.insert("exclusive-minimum", _require-number(js, "exclusiveMinimum"))
  }
  if "exclusiveMaximum" in js {
    result.insert("exclusive-maximum", _require-number(js, "exclusiveMaximum"))
  }
  if "multipleOf" in js {
    let v = _require-number(js, "multipleOf")
    if v <= 0 { _bail("\"multipleOf\" must be > 0, got: " + repr(v) + ".") }
    result.insert("multiple-of", v)
  }
  let mn = result.at("minimum", default: none)
  let mx = result.at("maximum", default: none)
  let emn = result.at("exclusive-minimum", default: none)
  let emx = result.at("exclusive-maximum", default: none)
  _require-ordered("minimum", mn, "maximum", mx, ">")
  // Exclusive bound leaves no value when it meets/crosses an inclusive
  // bound on the same side (e.g. exclusiveMinimum: 5 demands > 5,
  // maximum: 5 demands ≤ 5).
  _require-strict("exclusiveMinimum", emn, "maximum", mx)
  _require-strict("minimum", mn, "exclusiveMaximum", emx)
  _require-strict("exclusiveMinimum", emn, "exclusiveMaximum", emx)
  result
}

#let _with-array-constraints(js, dict) = {
  let result = dict
  if "minItems" in js {
    result.insert("min-items", _require-nonneg-int(js, "minItems"))
  }
  if "maxItems" in js {
    result.insert("max-items", _require-nonneg-int(js, "maxItems"))
  }
  if "uniqueItems" in js {
    let v = js.at("uniqueItems")
    if type(v) != bool {
      _bail("\"uniqueItems\" must be a boolean, got: " + repr(v) + ".")
    }
    if v { result.insert("unique-items", true) }
  }
  _require-ordered(
    "minItems",
    result.at("min-items", default: none),
    "maxItems",
    result.at("max-items", default: none),
    ">",
  )
  result
}

#let _from-json-schema(js, root, seen) = {
  // Before the $ref early return: `$ref` beside a composition keyword
  // must bail as a non-annotation sibling — resolving the ref first
  // would silently drop the composition.
  for keyword in _composition-keywords {
    if keyword in js { _require-lone-composition(js, keyword) }
  }
  if "$ref" in js {
    let ref = js.at("$ref")
    if type(ref) != str {
      _bail("\"$ref\" must be a string, got: " + repr(type(ref)) + ".")
    }
    return _from-json-schema(
      _resolve-ref(ref, root, seen),
      root,
      seen + (ref,),
    )
  }
  for keyword in _unsupported-keywords {
    if keyword in js {
      _bail(
        "unsupported JSON Schema keyword: "
          + repr(keyword)
          + ". Conditional schemas (if/then/else) and dependencies are out of scope.",
      )
    }
  }
  if "allOf" in js {
    return _merge-all-of(
      _require-member-array(js, "allOf").map(m => _from-json-schema(
        m,
        root,
        seen,
      )),
    )
  }
  if "anyOf" in js {
    return any-of(
      _require-member-array(js, "anyOf").map(m => _from-json-schema(
        m,
        root,
        seen,
      )),
    )
  }
  if "oneOf" in js {
    return one-of(
      _require-member-array(js, "oneOf").map(m => _from-json-schema(
        m,
        root,
        seen,
      )),
    )
  }
  if "not" in js {
    let member = js.at("not")
    if type(member) != dictionary {
      _bail("\"not\" must be a schema object, got: " + repr(member) + ".")
    }
    return not-of(_from-json-schema(member, root, seen))
  }
  // enum / const take precedence over `type` — membership constrains
  // shape on its own, so any accompanying type keyword is redundant.
  if "enum" in js or "const" in js {
    for keyword in _membership-incompatible-keywords {
      if keyword in js {
        _bail(
          repr(keyword)
            + " cannot be combined with enum/const — membership already pins the exact values; fold the constraint into the values instead.",
        )
      }
    }
  }
  if "enum" in js {
    let values = js.at("enum")
    if type(values) != array {
      _bail(
        "\"enum\" must be an array of values, got: " + repr(type(values)) + ".",
      )
    }
    return enum-of(values)
  }
  if "const" in js { return const-of(js.at("const")) }
  let t = js.at("type", default: none)
  if t == "string" {
    // Format wins over pattern when both are present — composing two
    // gates is more moving parts than the engine needs.
    let fmt = js.at("format", default: none)
    let base = if fmt != none {
      if fmt not in _format-kinds {
        _bail("unsupported string format: " + repr(fmt) + ".")
      }
      _format-kinds.at(fmt)
    } else {
      let pat = js.at("pattern", default: none)
      if pat != none {
        if type(pat) != str {
          _bail("\"pattern\" must be a string, got: " + repr(type(pat)) + ".")
        }
        pattern-string(pat, expected: "matching " + repr(pat))
      } else {
        str-type
      }
    }
    return _with-string-constraints(js, base)
  }
  if t == "number" or t == "integer" {
    // `integer` keeps its integral constraint (kinds.typ's integer-type)
    // rather than flattening to plain number — silently dropping the
    // constraint would violate this module's contract.
    return _with-number-constraints(js, if t == "integer" {
      integer-type
    } else { number-type })
  }
  if t == "array" {
    let items = js.at("items", default: none)
    if items == none {
      _bail("array schema missing \"items\".")
    }
    if type(items) != dictionary {
      _bail(
        "\"items\" must be a schema object, got: " + repr(type(items)) + ".",
      )
    }
    return _with-array-constraints(js, array-of(_from-json-schema(
      items,
      root,
      seen,
    )))
  }
  if t == "object" {
    let has-props = "properties" in js
    let has-ap = "additionalProperties" in js
    // Fully open with no constraints inverts the engine's strict intent.
    if not has-props and not has-ap {
      _bail(
        "open object schemas (`type: \"object\"` with no `properties` "
          + "or `additionalProperties`) are out of scope; every field "
          + "must be declared or covered by `additionalProperties`.",
      )
    }
    let props = if has-props { js.at("properties") } else { (:) }
    if type(props) != dictionary {
      _bail("\"properties\" must be an object, got: " + repr(type(props)) + ".")
    }
    let required = js.at("required", default: ())
    if type(required) != array {
      _bail(
        "\"required\" must be an array of field names, got: "
          + repr(type(required))
          + ".",
      )
    }
    let additional = if not has-ap {
      none
    } else {
      let ap = js.at("additionalProperties")
      if ap == false { none } else if ap == true { true } else if (
        type(ap) == dictionary
      ) { _from-json-schema(ap, root, seen) } else {
        _bail(
          "\"additionalProperties\" must be a schema, true, or false, got: "
            + repr(ap)
            + ".",
        )
      }
    }
    return object(
      props
        .pairs()
        .map(((k, v)) => (k, _from-json-schema(v, root, seen)))
        .to-dict(),
      required-keys: required,
      additional: additional,
    )
  }
  if t == "boolean" { return bool-type }
  if t == "null" { return null-type }
  if type(t) == array {
    // [X, "null"] → X: under null-as-absent every kind already accepts
    // null, so a wrapper would be a no-op. Multi-non-null unions need
    // discriminated-union machinery that's out of scope.
    if t.len() == 2 and "null" in t {
      let non-null = t.filter(x => x != "null")
      if non-null.len() == 1 {
        return _from-json-schema((..js, type: non-null.at(0)), root, seen)
      }
    }
    _bail(
      "union `type` arrays are only supported as nullable wraps `[X, \"null\"]`, got: "
        + repr(t)
        + ".",
    )
  }
  _bail(
    "unrecognised JSON Schema fragment (no recognised \"type\" or \"$ref\"); keys: "
      + repr(js.keys())
      + ".",
  )
}

// `path("…")` is read via json() so callers can skip the double-wrap.
// Non-dict/non-path inputs are rejected at the boundary so the
// diagnostic carries the standard schema-from-json-schema prefix
// instead of failing deep inside _from-json-schema.
#let schema-from-json-schema(js) = {
  let parsed = if type(js) == path {
    json(js)
  } else if type(js) == dictionary {
    js
  } else {
    _bail(
      "expected a parsed JSON Schema dict or path(...), got: "
        + repr(type(js))
        + ".",
    )
  }
  _from-json-schema(parsed, parsed, ())
}
