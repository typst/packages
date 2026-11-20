// JSON Schema (draft 7 subset) → Typst-schema translator: the entry
// point and the dispatcher, which follows a node's `$ref` (ref.typ),
// reads its keywords and hands it to the builders (build.typ) or the
// composition keywords. Anything not supported panics rather than
// silently dropping the constraint; keyword.typ says which keywords
// those are, and every panic names the node's JSON Pointer.
//
// The recursion through these files (and build.typ, all-of.typ,
// conditional.typ) runs in `for` and `while` loops, not `.map`
// closures, and calls each applicator and builder directly: each
// closure or wrapper is a call frame, and Typst caps how deeply calls
// nest, so a frame per level costs depth.

#import "../core/error.typ": _json-type-name, _problem
#import "../core/input.typ": _decode-input
#import "../kinds/leaf.typ": unknown, enum-of
#import "../kinds/structure.typ": any-of, one-of, not-of
#import "keyword.typ": (
  _bail, _bail-problem, _check-keywords, _check-keywords-typed, _json, _into,
  _has-keyword-for, _require-member-array, _role-of,
)
#import "ref.typ": _resolve-ref
#import "build.typ": _builders, _with-constraints, _fold-membership
#import "all-of.typ": _all-of
#import "conditional.typ": _conditional

// The node's `type` names, checked, or none when it has none. Checked
// before the enum / const fold, which would otherwise report a typo
// like `type: "strng"` as "no value satisfies ...".
#let _type-names-of(js, ctx) = {
  let t = js.at("type", default: none)
  if t == none { return none }
  if type(t) == array and (t.len() == 0 or t.any(x => type(x) != str)) {
    _bail(
      ctx,
      "\"type\" array must be a non-empty array of type names, got: "
        + _json(t)
        + ".",
    )
  }
  let names = if type(t) == array { t } else { (t,) }
  for m in names {
    if m not in _builders.keys() {
      _bail(
        ctx,
        "unknown `type` name "
          + _json(m)
          + if type(t) == array { " in " + _json(t) }
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

// A union keyword's applicator: its members translated, then `build`.
#let _union-of(keyword, build) = (js, ctx, recur) => {
  let members = ()
  for (i, m) in _require-member-array(js, keyword, ctx).enumerate() {
    members.push(recur(m, _into(ctx, keyword, i)))
  }
  build(members)
}

// `not`'s member translates as draft 7 reads it, like `if`'s condition
// (conditional.typ): every object in it with no `additionalProperties`
// is open. A closed one would match fewer values, so `not` would
// accept more.
#let _not(js, ctx, recur) = not-of(recur(
  js.at("not"),
  (.._into(ctx, "not"), open-objects: true),
))

// The composition keywords (#108), each with its member schemas, and
// `if`, which reads its node's other keywords too (conditional.typ).
// Each takes `(js, ctx, recur)` and is stored as it is, not wrapped, so
// a level of nesting costs no extra call.
#let _applicators = (
  allOf: _all-of,
  anyOf: _union-of("anyOf", any-of),
  oneOf: _union-of("oneOf", one-of),
  "not": _not,
  "if": _conditional,
)

// `ctx` is the document `root`; `seen`, the chain of `$ref`s that led
// here, each with its target's path (ref.typ); `at`, the JSON Pointer of the node being translated, which
// every panic names; and `open-objects`, set under an `if` or a `not`.
#let _translate(js, ctx) = {
  let (js, ctx) = (js, ctx)
  // A `$ref` is followed in this loop, so a chain of them costs no call
  // depth, and its target translates at its own place in the document.
  while true {
    // A `properties` value or `$ref` target reaches here unchecked; a
    // boolean would otherwise fail with a raw Typst error on `in` below.
    if type(js) != dictionary {
      _bail(
        ctx,
        "a subschema must be a schema object, got: "
          + _json(js)
          + if type(js) == bool {
            ". Boolean schemas (true / false) are out of scope."
          } else { "." },
      )
    }
    _check-keywords(js, ctx)
    if "$ref" not in js { break }
    let ref = js.at("$ref")
    if type(ref) != str {
      _bail-problem(ctx, _problem("$ref", "a string", _json-type-name(ref)))
    }
    let target = _resolve-ref(ref, ctx)
    js = target.value
    ctx = (..ctx, seen: ctx.seen + ((ref, target.path),), at: target.at)
  }
  let applicator = js.keys().find(k => _role-of(k) == "applicator")
  if applicator != none {
    return _applicators.at(applicator)(js, ctx, _translate)
  }
  let names = _type-names-of(js, ctx)
  if names != none { _check-keywords-typed(js, names, ctx) }
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
    return unknown()
  }
  // Untyped, an object with no `properties` or `additionalProperties`
  // is open, where `type: "object"` bails.
  let open = (
    names == none
      and "properties" not in js
      and "additionalProperties" not in js
  )
  let js = if open { (..js, additionalProperties: true) } else { js }
  // An integer member whose bounds hold no integer takes no value, so a
  // `type` list drops it; with no other member the schema is
  // unsatisfiable and bails.
  let built = ()
  for t in types {
    built.push(_with-constraints(
      _builders.at(t)(js, ctx, _translate),
      js,
      t,
      ctx,
    ))
  }
  let members = built.filter(b => b.gap == none).map(b => b.node)
  if members == () { _bail-problem(ctx, built.first().gap) }
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
  // A file or bytes had the right type: its content is the problem, so
  // a scalar is quoted as JSON (an array, which may be long, is named).
  if type(parsed) != dictionary {
    let what = if type(js) in (path, bytes) {
      (
        "the document must be a JSON object (a schema), got: "
          + if type(parsed) == array { "an array" } else { _json(parsed) }
      )
    } else {
      (
        "expected a parsed JSON Schema dict, path(...), or bytes, got: "
          + _json-type-name(parsed)
      )
    }
    _bail(
      none,
      what
        + if type(parsed) == bool {
          ". Boolean schemas (true / false) are out of scope."
        } else { "." },
    )
  }
  _translate(parsed, (root: parsed, seen: (), at: "", open-objects: false))
}
