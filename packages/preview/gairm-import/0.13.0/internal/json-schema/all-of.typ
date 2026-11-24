// allOf: the object-merge subset. Each member translates on its own and
// the objects merge into one; what the merge can't express bails here.

#import "../kinds/structure.typ": object, nullable, _is-object
#import "keyword.typ": _bail

// Whether a raw allOf member declares `additionalProperties` false or a
// schema, through `$ref` and nested allOf. Read from the JSON because
// the translated kind can't tell an explicit `false` from an undeclared
// one: object() stores both as no `additional`, and the translator
// reads an undeclared one as closed, where draft 7 reads it as open.
// Runs after the member translated, so `resolve` (a `$ref` to its
// target) is known to succeed without cycles.
#let _restricts-extras(js, resolve) = {
  if "$ref" in js {
    return _restricts-extras(resolve(js.at("$ref")), resolve)
  }
  if "allOf" in js {
    return js.at("allOf").any(m => _restricts-extras(m, resolve))
  }
  js.at("additionalProperties", default: true) != true
}

// Every member must translate to an object schema; shapes union (a
// duplicate key must carry an EQUAL sub-schema), required-keys and
// dependent-required union, additionalProperties must agree across all
// members (undeclared counts as closed), and members that restrict
// extras (`restricts`, see _restricts-extras) need identical property
// sets. Non-object composition (e.g. string + extra constraints) stays
// out of scope; deep-merging conflicting sub-schemas is a rabbit hole
// the engine's flat kinds can't express. `who` names the members in
// the messages, so a conditional's branches (conditional.typ) bail in
// their own words.
#let _merge-all-of(members, restricts, who) = {
  for m in members {
    if not _is-object(m) {
      _bail(
        who
          + " must all be object schemas; got kind "
          + repr(m.kind)
          + ". Non-object composition is out of scope.",
      )
    }
  }
  let shape = (:)
  let required = ()
  let dependent = (:)
  for m in members {
    for (key, sub) in m.shape {
      if key in shape and shape.at(key) != sub {
        _bail(
          who + " declare conflicting schemas for key " + repr(key) + ".",
        )
      }
      shape.insert(key, sub)
    }
    required += m
      .at("required-keys", default: ())
      .filter(k => k not in required)
    // Same-trigger dependency lists union, like required-keys.
    for (trigger, dependents) in m.at("dependent-required", default: (:)) {
      let merged = dependent.at(trigger, default: ())
      dependent.insert(
        trigger,
        merged + dependents.filter(d => d not in merged),
      )
    }
  }
  // additionalProperties must agree across ALL members, with an
  // undeclared member counting as closed (`none`) — silently taking
  // the open (or typed) member's value would accept keys another
  // member rejects.
  let additionals = members.map(m => m.at("additional", default: none))
  for a in additionals {
    if a != additionals.at(0) {
      _bail(
        who
          + " declare conflicting additionalProperties (open, closed, and typed members must all agree).",
      )
    }
  }
  // Draft 7 applies each member's additionalProperties to that member's
  // own properties only: a closed member rejects, and a typed one
  // checks, keys only another member declares, which the union would
  // accept unchecked.
  let keys = members.map(m => m.shape.keys().sorted())
  if restricts.any(r => r) and keys.any(k => k != keys.at(0)) {
    _bail(
      who
        + " with `additionalProperties: false` or a schema must all declare the same properties: draft 7 applies each member's additionalProperties to its own properties only, so a merged schema would accept keys that member rejects. Declare the properties in every member, or drop the restriction.",
    )
  }
  object(
    shape,
    required-keys: required,
    dependent-required: dependent,
    additional: additionals.at(0),
  )
}

// X when `node` is nullable(X), else none.
#let _nullable-of(node) = {
  let members = node.at("members", default: ())
  if members != () and node == nullable(members.first()) {
    members.first()
  }
}

// The merge of already translated `members`, each with its raw
// member's `restricts`. A member translated from `type: ["object",
// "null"]` is nullable(object): its object merges. A null meets allOf
// only when every member takes it, so the merge is nullable only then.
#let _join(members, restricts, who: "allOf members") = {
  let inner = members.map(m => _nullable-of(m))
  let merged = _merge-all-of(
    members.zip(inner).map(((m, x)) => if x == none { m } else { x }),
    restricts,
    who,
  )
  if inner.all(x => x != none) { nullable(merged) } else { merged }
}

// The allOf of the schema objects `raw`, each translated by `recur`.
#let _all-of(raw, ctx, recur, resolve) = _join(
  raw.map(m => recur(m, ctx)),
  raw.map(m => _restricts-extras(m, resolve)),
)
