// The translator's keywords, one entry each: `role` says where the
// translator consumes it, and `types` which JSON types it applies to
// (a keyword without `types` applies to every node). The allow-list,
// the sibling rule beside a composition keyword or `$ref`, the
// unsupported-keyword bails, the keyword-for-another-type bail and the
// enum/const structural list all read this table, so a new keyword is
// one entry here plus the code that consumes it.

#import "../core/error.typ": (
  _bail as _core-bail, _worded, _json, _type-name-of, _json-type-name,
)
#import "../core/pointer.typ": _escape-token
#import "../kinds/constraint.typ": _constraint-rows

// `ctx` one node further in: its JSON Pointer `at` with `segments`
// (keys, or member indices) appended.
#let _into(ctx, ..segments) = (
  ..ctx,
  at: ctx.at
    + segments
      .pos()
      .map(s => "/" + _escape-token(str(s)))
      .join("", default: ""),
)

// One panic prefix so every diagnostic from the translator is grep-able
// by "schema-from-json-schema —", then where in the document the node
// it was translating is (`ctx.at`), as a JSON Pointer. A `ctx` of none
// is the document itself, before there is a node.
#let _bail(ctx, msg) = _core-bail(
  "schema-from-json-schema —",
  if ctx != none {
    "at " + if ctx.at == "" { "the root" } else { ctx.at } + ": "
  }
    + msg,
)

// Bails with a constructor's problem (error.typ), its argument named by
// the JSON keyword `keywords` maps it to, or by itself. A constructor
// renders the value it `got` in Typst's terms, as a repr or a type name
// (`integer`); given the `node` the keyword is on, the same value is
// rendered in JSON's instead.
#let _bail-problem(ctx, p, keywords: (:), node: (:)) = {
  if "message" in p { _bail(ctx, p.message) }
  let keyword = keywords.at(p.arg, default: p.arg)
  let raw = node.at(keyword, default: (:))
  if p.entry != none and type(raw) == dictionary {
    raw = raw.at(p.entry, default: (:))
  }
  let p = if keyword not in node { p } else if p.got == repr(raw) {
    (..p, got: _json(raw))
  } else if p.got == _type-name-of(raw) {
    (..p, got: _json-type-name(raw))
  } else { p }
  _bail(ctx, _worded(p, _json(keyword)))
}

// A composition keyword's members; each is checked as a subschema when
// it is translated.
#let _require-member-array(js, keyword, ctx) = {
  let members = js.at(keyword)
  if type(members) != array or members.len() == 0 {
    _bail(
      ctx,
      _json(keyword)
        + " must be a non-empty array of schemas, got: "
        + _json(members)
        + ".",
    )
  }
  members
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
  "not": (
    role: "applicator",
    hint: ". Moving them into \"not\" would negate them; write {\"if\": <the \"not\" schema>, \"then\": {\"not\": {}}, \"else\": <the other keywords>} instead.",
  ),
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

// What to do with siblings, per role that must stand alone, unless the
// keyword's entry has a `hint` of its own: a sibling `type` /
// `properties` / constraint would be silently ignored, and the
// translator bails rather than drops.
#let _lone-hints = (
  applicator: ". Move them into the composition members.",
  ref: ". Draft 7 ignores them; to apply them too, write {\"allOf\": [{\"$ref\": …}, {<the other keywords>}]} (an object schema), or move them into the referenced definition.",
)

// The `$id` on `js` that sets the base its `$ref`s resolve against, or
// none. The translator resolves every `$ref` against the root
// document, so below the root one would quietly pick another schema. A
// fragment-only or empty one changes no base.
#let _base-id(js) = {
  let id = if type(js) == dictionary { js.at("$id", default: none) }
  if type(id) == str and id != "" and not id.starts-with("#") { id }
}

// Bails on an embedded `$id`, `id`, found at JSON Pointer `where`.
#let _bail-embedded-id(ctx, id, where) = _bail(
  ctx,
  "an embedded \"$id\" ("
    + _json(id)
    + if where != ctx.at { ", at " + where }
    + ") is not supported: it changes the base of the $refs below it, which resolve against the root document here. Move the schema under the root's \"$defs\" without its \"$id\".",
)

// Bails on a keyword the translator cannot honour: a sibling beside a
// composition keyword or `$ref` (checked before the `$ref` is resolved,
// which would drop it), an unsupported keyword with a reason of its
// own, a `then` / `else` with no `if` (draft 7 ignores them), an
// embedded `$id`, then every unknown or outside-the-subset key at once
// (a typo like `minLenght` included: draft 7 would ignore it), then a
// null value.
#let _check-keywords(js, ctx) = {
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
        ctx,
        "sibling keywords beside "
          + _json(keyword)
          + " are not supported: "
          + extras.map(_json).join(", ")
          + entry.at("hint", default: _lone-hints.at(entry.role)),
      )
    }
  }
  for (keyword, entry) in _keywords {
    if keyword in js and "reason" in entry {
      _bail(
        ctx,
        "unsupported JSON Schema keyword: "
          + _json(keyword)
          + ". "
          + entry.reason,
      )
    }
  }
  for (keyword, entry) in _keywords {
    if keyword in js and entry.role == "branch" and entry.of not in js {
      _bail(
        ctx,
        _json(keyword)
          + " has no effect without "
          + _json(entry.of)
          + " (draft 7 ignores it), so translating would silently drop its constraints.",
      )
    }
  }
  // The root's `$id` is the document's own; one below it is embedded.
  if ctx.at != "" and _base-id(js) != none {
    _bail-embedded-id(ctx, _base-id(js), ctx.at)
  }
  let unknown = js.keys().filter(k => _role-of(k) == "unsupported")
  if unknown.len() > 0 {
    _bail(
      ctx,
      "unsupported JSON Schema keyword(s): "
        + unknown.map(_json).join(", ")
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
  if null-key != none { _bail(ctx, _json(null-key) + " must not be null.") }
}

// Bails on a keyword that applies to none of a typed node's `type`
// names: every builder the node runs ignores it, so it would be
// silently dropped. Draft 7's "a keyword ignores the other types" is
// for an untyped node or a `type` array, where some member reads it;
// `{type: "string", minItems: 2}` is a mistake. Keywords are grouped
// by the types they apply to, in table order.
#let _check-keywords-typed(js, names, ctx) = {
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
      + stray.filter(k => types-of(k) == types).map(_json).join(", ")
      + " are only supported on "
      + types.map(t => "`type: \"" + t + "\"`").join(" or ")
      + " schemas"
  ))
  _bail(
    ctx,
    lines.join("; ")
      + ", but this node's `type` is "
      + _json(js.at("type"))
      + ": translating would silently drop them.",
  )
}
