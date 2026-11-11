// JSON Schema (draft 7 subset) → Typst-schema translator: the entry
// point, `$ref` resolution and the dispatcher, which reads a node's
// keywords and hands it to the builders (build.typ) or the composition
// keywords. Anything not supported panics rather than silently dropping
// the constraint; keyword.typ says which keywords those are.

#import "../core/error.typ": _json-type-name
#import "../core/input.typ": _decode-input
#import "../core/pointer.typ": _percent-decode, _read-pointer, _pointer-get
#import "../kinds/leaf.typ": any-type, enum-of
#import "../kinds/structure.typ": any-of, one-of, not-of
#import "keyword.typ": (
  _bail, _check-keywords, _check-keywords-typed, _has-keyword-for, _role-of,
)
#import "build.typ": _builders, _build, _fold-membership
#import "all-of.typ": _all-of
#import "conditional.typ": _conditional

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
  // The fragment is a URI's, so it is percent-decoded into the pointer
  // (RFC 3986) before the pointer is read (RFC 6901): `%25` is `%`.
  let pointer = _percent-decode(ref.slice(1))
  if pointer == none {
    _bail(
      "$ref "
        + repr(ref)
        + " has a malformed percent escape; `%` must start a `%XX` hex escape of UTF-8 bytes (write `%25` for a literal `%`).",
    )
  }
  let read = _read-pointer(pointer)
  if read.bad != none {
    _bail(
      "$ref "
        + repr(ref)
        + " has an invalid escape; RFC 6901 only allows `~0` (tilde) and `~1` (slash).",
    )
  }
  // RFC 6901: `~1` / `~0` unescape, empty segments are the "" key, and
  // a numeric segment indexes an array (e.g. "#/allOf/0") or names a key.
  let found = _pointer-get(root, read.path)
  if found.missing != none {
    _bail(
      "$ref "
        + repr(ref)
        + " could not be resolved (segment "
        + repr(str(found.missing))
        + " missing).",
    )
  }
  found.value
}

// A composition keyword's members; each is checked as a subschema when
// it is translated.
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
  members
}

// The node's `type` names, checked, or none when it has none. Checked
// before the enum / const fold, which would otherwise report a typo
// like `type: "strng"` as "no value satisfies ...".
#let _type-names-of(js) = {
  let t = js.at("type", default: none)
  if t == none { return none }
  if type(t) == array and (t.len() == 0 or t.any(x => type(x) != str)) {
    _bail(
      "\"type\" array must be a non-empty array of type names, got: "
        + repr(t)
        + ".",
    )
  }
  let names = if type(t) == array { t } else { (t,) }
  for m in names {
    if m not in _builders.keys() {
      _bail(
        "unknown `type` name "
          + repr(m)
          + if type(t) == array { " in " + repr(t) }
          + "; expected one of: "
          + _builders.keys().join(", ")
          + ".",
      )
    }
  }
  names
}

// An untyped node is a union of one member per JSON type (`integer` is
// covered by number), each built as a `type` array's member is, so a
// keyword reaches only its own type. Null comes last, as in a `type`
// array.
#let _untyped-types = ("boolean", "object", "array", "number", "string", "null")

// A `$ref` to its target in `ctx`'s document, for the merges that read
// raw members (all-of.typ).
#let _resolver(ctx) = ref => _resolve-ref(ref, ctx.root, ())

// The composition keywords (#108), each with its member schemas, and
// `if`, which reads its node's other keywords too (conditional.typ).
#let _applicators = (
  allOf: (js, ctx, recur) => _all-of(
    _require-member-array(js, "allOf"),
    ctx,
    recur,
    _resolver(ctx),
  ),
  anyOf: (js, ctx, recur) => any-of(
    _require-member-array(js, "anyOf").map(m => recur(m, ctx)),
  ),
  oneOf: (js, ctx, recur) => one-of(
    _require-member-array(js, "oneOf").map(m => recur(m, ctx)),
  ),
  "not": (js, ctx, recur) => not-of(recur(js.at("not"), ctx)),
  "if": (js, ctx, recur) => _conditional(js, ctx, recur, _resolver(ctx)),
)

// `ctx` is the document `root`, `seen`, the chain of `$ref`s that led
// here, and `open-objects`, set under an `if` (conditional.typ).
#let _translate(js, ctx) = {
  // A `properties` value or `$ref` target reaches here unchecked; a
  // boolean would otherwise fail with a raw Typst error on `in` below.
  if type(js) != dictionary {
    _bail(
      "a subschema must be a schema object, got: "
        + repr(js)
        + if type(js) == bool {
          ". Boolean schemas (true / false) are out of scope."
        } else { "." },
    )
  }
  _check-keywords(js)
  if "$ref" in js {
    let ref = js.at("$ref")
    if type(ref) != str {
      _bail("\"$ref\" must be a string, got: " + repr(type(ref)) + ".")
    }
    return _translate(
      _resolve-ref(ref, ctx.root, ctx.seen),
      (..ctx, seen: ctx.seen + (ref,)),
    )
  }
  let applicator = js.keys().find(k => _role-of(k) == "applicator")
  if applicator != none {
    return _applicators.at(applicator)(js, ctx, _translate)
  }
  let names = _type-names-of(js)
  if names != none { _check-keywords-typed(js, names) }
  if "enum" in js or "const" in js {
    return enum-of(_fold-membership(js, ctx, names, _translate))
  }
  // Each member is built from the whole node, and any-of, not one-of:
  // `["number", "integer"]` overlaps and must still accept 1. "null"
  // keeps the source's nullability: [X, "null"] is nullable(X). By
  // default that judges every value as X does (a null is absent before
  // the union sees it); with strict-null it accepts null.
  let types = if names != none {
    let non-null = names.filter(x => x != "null").dedup()
    non-null + if "null" in names { ("null",) } else { () }
  } else if _untyped-types.any(t => _has-keyword-for(js, t)) {
    _untyped-types
  } else {
    // No type-specific keyword: any value.
    return any-type
  }
  // Untyped, an object with no `properties` or `additionalProperties`
  // is open, where `type: "object"` bails.
  let open = (
    names == none
      and "properties" not in js
      and "additionalProperties" not in js
  )
  let js = if open { (..js, additionalProperties: true) } else { js }
  let members = types.map(t => _build(js, ctx, t, _translate))
  if members.len() == 1 { members.first() } else { any-of(members) }
}

/// Translates a JSON Schema document (a draft 7 subset) into a schema
/// for `parse`, `validate` and `coerce`. Panics on anything it does not
/// support, rather than dropping the constraint.
///
/// - js (dictionary, path, bytes): The JSON Schema, or where to read it.
///   A `path` resolves from your file.
/// -> dictionary
#let schema-from-json-schema(js) = {
  let parsed = _decode-input("schema-from-json-schema", js, null-ok: true)
  // Non-dictionaries are rejected at the boundary so the diagnostic
  // carries the schema-from-json-schema prefix.
  if type(parsed) != dictionary {
    _bail(
      "expected a parsed JSON Schema dict, path(...), or bytes, got: "
        + _json-type-name(parsed)
        + ".",
    )
  }
  _translate(parsed, (root: parsed, seen: (), open-objects: false))
}
