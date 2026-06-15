// JSON Schema (draft 7 subset) → Typst-schema translator. Anything
// not supported panics rather than silently dropping the constraint.

#import "kinds.typ": (
  str-type, content-type, number-type, array-of, object,
  date-string, uri-string, email-string,
)

// `date-time` is intentionally absent: the date-string regex is
// date-only, so labelling a datetime field then rejecting its values
// is worse than the up-front "unsupported format" panic.
#let _format-kinds = (
  "uri": uri-string,
  "email": email-string,
  "date": date-string,
)

// One panic prefix so every diagnostic from this module is grep-able
// by "schema-from-json-schema —".
#let _bail(msg) = panic("json-resume: schema-from-json-schema — " + msg)

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
  "enum", "const",
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
          ". Composition keywords (allOf/anyOf/oneOf), enum, and conditional schemas are out of scope.",
      )
    }
  }
  let t = js.at("type", default: none)
  if t == "string" {
    let fmt = js.at("format", default: none)
    if fmt == none { return str-type }
    if fmt not in _format-kinds {
      _bail("unsupported string format: " + repr(fmt) + ".")
    }
    return _format-kinds.at(fmt)
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

#let schema-from-json-schema(js) = _from-json-schema(js, js, ())
