// JSON Schema (draft 7 subset) → Typst-schema translator. Anything
// not supported panics rather than silently dropping the constraint.

#import "kinds.typ": (
  str-type, content-type, number-type, array-of, object,
  date-string, datetime-string, uri-string, email-string, pattern-string,
  enum-of, const-of,
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
    _bail("only internal $ref (starting with \"#/\") is supported, got: " + repr(ref) + ".")
  }
  if ref in seen {
    _bail("cyclic $ref detected: " + seen.map(repr).join(" → ") + " → " + repr(ref) + ".")
  }
  if ref == "#/" {
    _bail("$ref \"#/\" cannot reference the document root.")
  }
  let parts = ref.slice(2).split("/").filter(p => p != "")
  parts.fold(root, (acc, key) => {
    if type(acc) != dictionary or key not in acc {
      _bail("$ref " + repr(ref) + " could not be resolved (segment " + repr(key) + " missing).")
    }
    acc.at(key)
  })
}

#let _unsupported-keywords = (
  "allOf", "anyOf", "oneOf", "not",
  "if", "then", "else",
  "dependencies", "dependentRequired", "dependentSchemas",
)

#let _from-json-schema(js, root, seen) = {
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
        "unsupported JSON Schema keyword: " + repr(keyword) +
          ". Composition keywords (allOf/anyOf/oneOf) and conditional schemas are out of scope.",
      )
    }
  }
  // enum / const take precedence over `type` — membership constrains
  // shape on its own, so any accompanying type keyword is redundant.
  if "enum" in js {
    let values = js.at("enum")
    if type(values) != array {
      _bail("\"enum\" must be an array of values, got: " + repr(type(values)) + ".")
    }
    return enum-of(values)
  }
  if "const" in js { return const-of(js.at("const")) }
  let t = js.at("type", default: none)
  if t == "string" {
    // Format wins over pattern when both are present — composing two
    // gates is more moving parts than the engine needs.
    let fmt = js.at("format", default: none)
    if fmt != none {
      if fmt not in _format-kinds {
        _bail("unsupported string format: " + repr(fmt) + ".")
      }
      return _format-kinds.at(fmt)
    }
    let pat = js.at("pattern", default: none)
    if pat != none {
      if type(pat) != str {
        _bail("\"pattern\" must be a string, got: " + repr(type(pat)) + ".")
      }
      return pattern-string(pat, expected: "matching " + repr(pat))
    }
    return str-type
  }
  if t == "number" or t == "integer" { return number-type }
  if t == "array" {
    let items = js.at("items", default: none)
    if items == none {
      _bail("array schema missing \"items\".")
    }
    if type(items) != dictionary {
      _bail("\"items\" must be a schema object, got: " + repr(type(items)) + ".")
    }
    return array-of(_from-json-schema(items, root, seen))
  }
  if t == "object" {
    // Engine is strict by design — can't represent open objects. A
    // missing `properties` would silently invert the schema's intent.
    if "properties" not in js {
      _bail(
        "open object schemas (`type: \"object\"` with no `properties`) " +
          "are out of scope; every field must be declared.",
      )
    }
    let props = js.at("properties")
    if type(props) != dictionary {
      _bail("\"properties\" must be an object, got: " + repr(type(props)) + ".")
    }
    let required = js.at("required", default: ())
    if type(required) != array {
      _bail("\"required\" must be an array of field names, got: " + repr(type(required)) + ".")
    }
    return object(
      props.pairs().map(((k, v)) => (k, _from-json-schema(v, root, seen))).to-dict(),
      required-keys: required,
    )
  }
  if t in ("boolean", "null") {
    _bail("unsupported JSON Schema type: " + repr(t) + ".")
  }
  if type(t) == array {
    // null-as-absent already covers the common `["string", "null"]`
    // nullable case at the validator level, so unions aren't needed.
    _bail("union `type` arrays are unsupported, got: " + repr(t) + ".")
  }
  _bail("unrecognised JSON Schema fragment (no recognised \"type\" or \"$ref\"); keys: " + repr(js.keys()) + ".")
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
    _bail("expected a parsed JSON Schema dict or path(...), got: " + repr(type(js)) + ".")
  }
  _from-json-schema(parsed, parsed, ())
}
