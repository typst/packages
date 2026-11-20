// allOf: the object-merge subset. Each member translates on its own and
// the objects merge into one; what the merge can't express bails here.

#import "../kinds/registry.typ": _nullable-member
#import "../kinds/structure.typ": object, nullable, _is-object
#import "../kinds/walk.typ": _kind-label
#import "../core/error.typ": _a
#import "keyword.typ": (
  _bail, _json, _into, _require-member-array, _role-of, _lone-hints,
)
#import "ref.typ": _follow-refs

// Whether a raw allOf member declares `additionalProperties` false or a
// schema, through `$ref`, nested allOf, and the members of an anyOf (a
// nullable object is `anyOf: [{…}, {type: "null"}]`). Read from the
// JSON because the translated kind can't tell an explicit `false` from
// an undeclared one: object() stores both as no `additional`, and the
// translator reads an undeclared one as closed, where draft 7 reads it
// as open. A schema that takes any value (`{}`) restricts nothing.
// Runs after the member translated, so its `$ref`s resolve without
// cycles.
#let _restricts-extras(js, ctx) = {
  let js = _follow-refs(js, ctx)
  for keyword in ("allOf", "anyOf") {
    if keyword in js {
      return js.at(keyword).any(m => _restricts-extras(m, ctx))
    }
  }
  let ap = _follow-refs(js.at("additionalProperties", default: true), ctx)
  (
    ap != true
      and not (
        type(ap) == dictionary
          and ap.keys().all(k => _role-of(k) == "annotation")
      )
  )
}

// What a member that is not an object schema is, for the message. A
// composition or a `type` list is named as written (`"anyOf"`, `"type":
// ["object", "string"]`), not by the internal kind it became; a node
// with no `type` (`{required: ["a"]}`) translates to any JSON type, so
// it is named by what it lacks and the keywords it has; any other by
// its kind (`a string schema`, an enum with its values).
#let _not-object(node, raw, ctx) = {
  let raw = _follow-refs(raw, ctx)
  if type(raw) != dictionary {
    return "got: " + _a(_kind-label(node)) + " schema"
  }
  let applicator = raw.keys().find(k => _role-of(k) in _lone-hints)
  if applicator != none { return "got one with " + _json(applicator) }
  if type(raw.at("type", default: none)) == array {
    return "got one with \"type\": " + _json(raw.type)
  }
  if "type" in raw or raw.keys().any(k => _role-of(k) == "membership") {
    return "got: " + _a(_kind-label(node)) + " schema"
  }
  let keys = raw.keys().filter(k => _role-of(k) != "annotation")
  (
    "got one with no "
      + if "properties" in raw { "\"type\": \"object\"" } else {
        "\"type\": \"object\" or \"properties\""
      }
      + if keys == () { " and no keywords" } else {
        ", only " + keys.map(_json).join(", ")
      }
  )
}

// Every member must translate to an object schema; shapes union (a
// duplicate key must carry an EQUAL sub-schema), required-keys and
// dependent-required union, additionalProperties must agree across all
// members (undeclared counts as closed), and members that restrict
// extras (`restricts`, see _restricts-extras) need identical property
// sets. Non-object composition (e.g. string + extra constraints) stays
// out of scope; deep-merging conflicting sub-schemas is a rabbit hole
// the engine's flat kinds can't express. `raws` are the members as
// written and `ctxs` where each is, for the messages; `ctx` is the
// node the merge is for, and `who` names the members, so a
// conditional's branches (conditional.typ) bail in their own words.
#let _merge-all-of(members, restricts, raws, ctxs, ctx, who) = {
  for (i, m) in members.enumerate() {
    if not _is-object(m) {
      _bail(
        ctxs.at(i),
        who
          + " must all be object schemas, "
          + _not-object(m, raws.at(i), ctxs.at(i))
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
          ctx,
          who + " declare conflicting schemas for key " + _json(key) + ".",
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
        ctx,
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
      ctx,
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

// The merge of already translated `members` (see _merge-all-of). A
// member translated from `type: ["object", "null"]`, or an anyOf of an
// object and a null in either order, is nullable: its object merges. A null meets allOf only when
// every member takes it, so the merge is nullable only then.
#let _join(members, restricts, raws, ctxs, ctx, who: "allOf members") = {
  let inner = members.map(m => _nullable-member(m))
  let merged = _merge-all-of(
    members.zip(inner).map(((m, x)) => if x == none { m } else { x }),
    restricts,
    raws,
    ctxs,
    ctx,
    who,
  )
  if inner.all(x => x != none) { nullable(merged) } else { merged }
}

// The allOf applicator: the node's member schemas, each translated by
// `recur`, merged.
#let _all-of(js, ctx, recur) = {
  let raws = _require-member-array(js, "allOf", ctx)
  let (members, restricts, ctxs) = ((), (), ())
  for (i, m) in raws.enumerate() {
    let at = _into(ctx, "allOf", i)
    members.push(recur(m, at))
    restricts.push(_restricts-extras(m, at))
    ctxs.push(at)
  }
  _join(members, restricts, raws, ctxs, ctx)
}
