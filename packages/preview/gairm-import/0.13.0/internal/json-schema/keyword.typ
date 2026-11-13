// The translator's keywords, one entry each: `role` says where the
// translator consumes it, and `types` which JSON types it applies to
// (a keyword without `types` applies to every node). The allow-list,
// the sibling rule beside a composition keyword or `$ref`, the
// unsupported-keyword bails, the keyword-for-another-type bail and the
// enum/const structural list all read this table, so a new keyword is one entry here plus the code
// that consumes it.

#import "../core/error.typ": _bail as _core-bail, _worded
#import "../kinds/constraint.typ": _constraint-rows

// One panic prefix so every diagnostic from the translator is grep-able
// by "schema-from-json-schema —".
#let _bail = _core-bail.with("schema-from-json-schema —")

// Bails with a constructor's problem (error.typ), its argument named by
// the JSON keyword `keywords` maps it to, or by itself.
#let _bail-problem(p, keywords: (:)) = {
  if "message" in p { _bail(p.message) }
  _bail(_worded(p, repr(keywords.at(p.arg, default: p.arg))))
}

// The constraint family each JSON type reads its rows from: `integer`
// is a number. Types not listed take no constraint keyword.
#let _constraint-family = (
  string: "string",
  number: "number",
  integer: "number",
  array: "array",
)

// Annotation-only: no validation semantics the engine could drop, so
// tolerated anywhere, beside a composition keyword or `$ref` too.
#let _annotation = (role: "annotation")
#let _base(t) = (role: "base", types: (t,))
// Draft 7 keywords outside the subset, with no reason of their own:
// they bail with any unknown key, as translating would drop them.
#let _outside = (role: "unsupported")

// Order is diagnostic order: the composition keywords before `$ref` for
// the sibling rule, and the structural keywords for enum/const as listed.
#let _keywords = (
  "$schema": _annotation,
  "$id": _annotation,
  "$comment": _annotation,
  title: _annotation,
  description: _annotation,
  default: _annotation,
  examples: _annotation,
  readOnly: _annotation,
  writeOnly: _annotation,
  deprecated: _annotation,
  definitions: _annotation,
  "$defs": _annotation,
  // Composition keywords (#108) and `$ref` stand alone on their node.
  allOf: (role: "applicator"),
  anyOf: (role: "applicator"),
  oneOf: (role: "applicator"),
  "not": (role: "applicator"),
  // `if` is the one applicator that `joins` its node's other keywords
  // rather than standing alone (conditional.typ); `then` and `else` are
  // branches `of` it, read with it.
  "if": (role: "applicator", joins: true),
  then: (role: "branch", of: "if"),
  "else": (role: "branch", of: "if"),
  "$ref": (role: "ref"),
  enum: (role: "membership"),
  // `const: null` means the value must be null.
  const: (role: "membership", null-ok: true),
  type: (role: "type"),
  format: _base("string"),
  pattern: _base("string"),
  properties: _base("object"),
  required: _base("object"),
  additionalProperties: _base("object"),
  items: _base("array"),
  // `dependentRequired` (2019-09) and draft 7's array-form
  // `dependencies` are the same constraint.
  dependentRequired: _base("object"),
  dependencies: _base("object"),
  .._constraint-rows
    .map(row => (
      row.json,
      (
        role: "constraint",
        types: _constraint-family
          .keys()
          .filter(t => _constraint-family.at(t) == row.family),
      ),
    ))
    .to-dict(),
  dependentSchemas: (
    role: "unsupported",
    reason: "dependentSchemas and the schema form of dependencies are out of scope.",
  ),
  additionalItems: _outside,
  contains: _outside,
  maxProperties: _outside,
  minProperties: _outside,
  patternProperties: _outside,
  propertyNames: _outside,
  contentMediaType: _outside,
  contentEncoding: _outside,
)

#let _role-of(keyword) = _keywords.at(keyword, default: _outside).role

// Whether `js` carries a keyword that applies to JSON type `t` alone.
#let _has-keyword-for(js, t) = (
  js
    .keys()
    .any(k => t in _keywords.at(k, default: (:)).at("types", default: ()))
)

// Object / array structure, which an enum / const value list cannot be
// filtered by: these bail beside enum / const rather than being dropped.
#let _membership-structural = (
  _keywords
    .keys()
    .filter(k => (
      _role-of(k) == "base"
        and _keywords.at(k).types.any(t => t in ("array", "object"))
    ))
)

// What to do with siblings, per role that must stand alone: a sibling
// `type` / `properties` / constraint would be silently ignored, and the
// translator bails rather than drops.
#let _lone-hints = (
  applicator: ". Move them into the composition members.",
  ref: ". Draft 7 ignores them; move them into the referenced definition.",
)

// Bails on a keyword the translator cannot honour: a sibling beside a
// composition keyword or `$ref` (checked before the `$ref` is resolved,
// which would drop it), an unsupported keyword with a reason of its
// own, a `then` / `else` with no `if` (draft 7 ignores them), then
// every unknown or outside-the-subset key at once (a typo like
// `minLenght` included: draft 7 would ignore it), then a null value.
#let _check-keywords(js) = {
  for (keyword, entry) in _keywords {
    if (
      keyword not in js
        or entry.role not in _lone-hints
        or entry.at("joins", default: false)
    ) { continue }
    let extras = js
      .keys()
      .filter(k => k != keyword and _role-of(k) != "annotation")
    if extras.len() > 0 {
      _bail(
        "sibling keywords beside "
          + repr(keyword)
          + " are not supported: "
          + extras.map(repr).join(", ")
          + _lone-hints.at(entry.role),
      )
    }
  }
  for (keyword, entry) in _keywords {
    if keyword in js and "reason" in entry {
      _bail(
        "unsupported JSON Schema keyword: "
          + repr(keyword)
          + ". "
          + entry.reason,
      )
    }
  }
  for (keyword, entry) in _keywords {
    if keyword in js and entry.role == "branch" and entry.of not in js {
      _bail(
        repr(keyword)
          + " has no effect without "
          + repr(entry.of)
          + " (draft 7 ignores it), so translating would silently drop its constraints.",
      )
    }
  }
  let unknown = js.keys().filter(k => _role-of(k) == "unsupported")
  if unknown.len() > 0 {
    _bail(
      "unsupported JSON Schema keyword(s): "
        + unknown.map(repr).join(", ")
        + ". They are outside the supported subset (see REFERENCE.md); translating would silently drop their constraints.",
    )
  }
  // A null value would otherwise read as an absent keyword, dropping it.
  // Only an annotation or a keyword that gives null a meaning takes one.
  let null-key = js
    .keys()
    .find(k => (
      js.at(k) == none
        and _role-of(k) != "annotation"
        and not _keywords.at(k).at("null-ok", default: false)
    ))
  if null-key != none { _bail(repr(null-key) + " must not be null.") }
}

// Bails on a keyword that applies to none of a typed node's `type`
// names: every builder the node runs ignores it, so it would be
// silently dropped. Draft 7's "a keyword ignores the other types" is
// for an untyped node or a `type` array, where some member reads it;
// `{type: "string", minItems: 2}` is a mistake. Keywords are grouped
// by the types they apply to, in table order.
#let _check-keywords-typed(js, names) = {
  let types-of(k) = _keywords.at(k).at("types", default: ())
  let stray = _keywords
    .keys()
    .filter(k => (
      k in js and types-of(k) != () and not types-of(k).any(t => t in names)
    ))
  if stray == () { return }
  let groups = stray.map(types-of).dedup()
  let lines = groups.map(types => (
    "keyword(s) "
      + stray.filter(k => types-of(k) == types).map(repr).join(", ")
      + " are only supported on "
      + types.map(t => "`type: \"" + t + "\"`").join(" or ")
      + " schemas"
  ))
  _bail(
    lines.join("; ")
      + ", but this node's `type` is "
      + repr(js.at("type"))
      + ": translating would silently drop them.",
  )
}
