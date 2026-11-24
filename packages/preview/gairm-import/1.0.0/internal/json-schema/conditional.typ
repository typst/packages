// if / then / else: the one applicator that joins its node's other
// keywords. `{A…, if: I, then: T, else: E}` is
// `if-of(I, then: allOf(A, T), otherwise: allOf(A, E))`, each branch
// through the allOf merge (all-of.typ), so it has the merge's limits:
// with sibling keywords, the siblings and each branch must be object
// schemas. With none, the branches are T and E as they are, of any kind.

#import "../kinds/structure.typ": if-of, nullable, _is-object
#import "keyword.typ": _role-of, _lone-hints, _into, _keywords
#import "../kinds/registry.typ": _nullable-member
#import "all-of.typ": _join, _restricts-extras

// A branch read beside its siblings, as draft 7 reads it: a branch
// with no `type` takes the siblings', since only a value of their type
// reaches it; and one that doesn't declare `additionalProperties`
// restricts no keys of its own, so it takes the siblings'
// `additionalProperties` and `properties` (its own properties win, and
// the merge then bails on any that differ). Without them the merge
// would read `then: {required: ["b"]}` as a closed object that has no
// `b`. A borrowed property comes as `{}`, and an `additionalProperties`
// schema as `true`, and each gets the schema the siblings translated
// to (_lend), so a nested `if` translates each level once, not once
// per branch. Returns the branch and what it borrowed: `(keys,
// additional)`. A branch that is a `$ref` or a composition
// is merged as written, and so is one that is no object schema (an
// `enum`, a `type` without `object`, a keyword for another type): the
// merge then names it as it is, rather than by keywords it took from
// its siblings.
#let _types(js) = {
  let t = js.at("type", default: "object")
  if type(t) == array { t } else { (t,) }
}
#let _objectish(b) = {
  (
    "enum" not in b
      and "const" not in b
      and "object" in _types(b)
      and b
        .keys()
        .all(k => (
          "object"
            in _keywords.at(k, default: (:)).at("types", default: ("object",))
        ))
  )
}
#let _beside(branch, siblings) = {
  if (
    type(branch) != dictionary
      or branch.keys().any(k => _role-of(k) in _lone-hints)
      or not _objectish(branch)
  ) { return (branch, (keys: (), additional: false)) }
  let b = branch
  let borrowed = (keys: (), additional: false)
  // Only an object type: the merge names siblings of another type
  // themselves, not a branch that never said it.
  if "type" not in b and "type" in siblings and "object" in _types(siblings) {
    b.insert("type", siblings.type)
  }
  if "additionalProperties" not in b {
    if "additionalProperties" in siblings {
      let ap = siblings.additionalProperties
      if type(ap) == dictionary { (borrowed.additional, ap) = (true, true) }
      b.insert("additionalProperties", ap)
    }
    let own = b.at("properties", default: (:))
    let theirs = siblings.at("properties", default: (:))
    if (
      type(own) == dictionary and type(theirs) == dictionary and theirs != (:)
    ) {
      borrowed.keys = theirs.keys().filter(k => k not in own)
      b.insert("properties", (:
        ..borrowed.keys.map(k => (k, (:))).to-dict(),
        ..own,
      ))
    }
  }
  (b, borrowed)
}

// `node`, a translated branch, with the schemas of its `borrowed` keys
// and additional schema (_beside) taken from `base`, its translated
// siblings. Anything but an object, or a nullable one, is left for the
// merge to name.
#let _lend(node, base, borrowed) = {
  if borrowed.keys == () and not borrowed.additional { return node }
  let from = _nullable-member(base)
  if from == none { from = base }
  let x = _nullable-member(node)
  let obj = if x == none { node } else { x }
  if not (_is-object(obj) and _is-object(from)) { return node }
  if borrowed.additional { obj.additional = from.additional }
  let shape = obj.shape
  for k in borrowed.keys {
    if k in from.shape { shape.insert(k, from.shape.at(k)) }
  }
  obj.shape = shape
  if x == none { obj } else { nullable(obj) }
}

#let _who = "the siblings of \"if\" and its branches"

// The condition is only a test, so it translates as draft 7 reads it:
// every object in it with no `additionalProperties` is open
// (`open-objects`, build.typ), so `{properties: {country: {const:
// "US"}}}` holds for an address with more keys than `country`. An `if`
// with neither branch checks nothing (draft 7), so the node translates
// without it, once its condition has been checked. The siblings
// translate once and join each branch; siblings that are only `type:
// "object"` add nothing a branch doesn't take from _beside, so a branch
// stands alone, as the object its siblings say it is. The branches
// translate in a loop, not a `.map`, to spend no call depth.
#let _conditional(js, ctx, recur) = {
  let siblings = js
    .pairs()
    .filter(((k, _)) => k != "if" and _role-of(k) != "branch")
    .to-dict()
  let cond = recur(js.at("if"), (.._into(ctx, "if"), open-objects: true))
  if "then" not in js and "else" not in js { return recur(siblings, ctx) }
  let plain = siblings.keys().filter(k => _role-of(k) != "annotation")
  let lone = plain == ()
  let types = _types(siblings)
  // Siblings that are only an object type, null allowed beside it.
  let typed = (
    plain == ("type",) and types.filter(t => t != "null").dedup() == ("object",)
  )
  let base = if not lone and not typed { recur(siblings, ctx) }
  let base-restricts = if base != none { _restricts-extras(siblings, ctx) }
  let parts = (:)
  for (arg, k) in (("then", "then"), ("otherwise", "else")) {
    if k not in js {
      // With no branch, the siblings alone: `{type: "object"}` bails
      // as an open object, as it does anywhere.
      if base != none { parts.insert(arg, base) } else if typed {
        parts.insert(arg, recur(siblings, ctx))
      }
      continue
    }
    let at = _into(ctx, k)
    if lone {
      parts.insert(arg, recur(js.at(k), at))
      continue
    }
    let (b, borrowed) = _beside(js.at(k), siblings)
    let node = _lend(recur(b, at), base, borrowed)
    if base == none {
      // Only an object reaches the branch, unless the siblings take
      // null too, so a nullable one is its object; the merge of one
      // member checks it is an object.
      let x = _nullable-member(node)
      if x != none and "null" not in types { node = x }
      node = _join((node,), (false,), (b,), (at,), ctx, who: _who)
    } else {
      node = _join(
        (base, node),
        (base-restricts, _restricts-extras(b, at)),
        (siblings, b),
        (ctx, at),
        ctx,
        who: _who,
      )
    }
    parts.insert(arg, node)
  }
  if-of(cond, ..parts)
}
