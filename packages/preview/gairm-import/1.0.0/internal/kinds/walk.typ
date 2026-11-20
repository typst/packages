// The walks the engine runs for the structural kinds: arrays, objects,
// unions, `not` and conditionals, and how messages name a node's kind.
// They sit below registry.typ, whose descriptors hold them; the
// constructors that build these kinds are in structure.typ, above it.

#import "../core/ctx.typ": _at, _absent, _has
#import "../core/error.typ": (
  _error, _type-miss, _type-name-of, _closest-match, _shown, _json, _key-label,
)
#import "constraint.typ": _constraint-errors

// A node's kind as messages and describe-schema name it: the kind, then
// a string's format, if it has one, in parentheses (`string (date)`),
// or an enum's values, as JSON writes them (`enum ("a", "b")`).
#let _kind-label(node) = {
  if node.kind == "string" and "format" in node {
    "string (" + node.format + ")"
  } else if node.kind == "enum" {
    "enum (" + node.values.map(_json).join(", ") + ")"
  } else { node.kind }
}

// A member's kind as union and `not` errors name it. A conditional
// reads as its branches when both are set and agree (the translated
// `{type: "object", if: …, then: …, else: …}` is an object either way),
// and as `conditional` otherwise. A nested union reads as its members,
// `(number | boolean)`.
#let _reported-kind(member) = if member.kind == "union" {
  "(" + member.members.map(_reported-kind).join(" | ") + ")"
} else if member.kind == "if" {
  let kinds = ("then", "otherwise").map(b => if b in member {
    _reported-kind(member.at(b))
  })
  if none not in kinds and kinds.dedup().len() == 1 { kinds.first() } else {
    "conditional"
  }
} else {
  _kind-label(member)
}

// An object that declares no fields and lets anything through is a
// free-form bag: opaque data, not an object with extras tacked on.
#let _is-free-form(schema) = (
  schema.kind == "object"
    and schema.shape.len() == 0
    and schema.at("additional", default: none) == true
)

// A structural walk is (schema, value, ctx, recur) -> (errors, value,
// fatal). `recur` is the engine's walk, passed in so kinds/ never
// imports the engine. `value` is the model; `fatal` is none, or the
// first place in walk order where the value leaves no sound model, as
// (path, expected, got) for coerce's panic text. Every fatal walk also has
// errors, so a walk with no errors has no fatal. A walk whose result is
// one sub-schema's over the same value returns `(tail: sub-schema)`
// instead of calling `recur`, and the engine walks it in its own frame.
//
// Hot recursive paths use `for` loops, not `.map(x => …)`: each closure
// is a stack frame, and Typst caps the call depth.

#let _array-walk(schema, value, ctx, recur) = {
  if type(value) != array {
    return _type-miss(ctx.path, "array", value)
  }
  let errors = ()
  let fatal = none
  // The walked items the model keeps, as (source index, item), so
  // constraints judge what the model holds while uniqueness still cites
  // source indices. Absent items are dropped: a null in an array of
  // strings would otherwise reach renderers as a stray `none`.
  let kept = ()
  let model = ()
  for (i, elem) in value.enumerate() {
    let r = recur(schema.elem, elem, _at(ctx, i))
    errors += r.errors
    if fatal == none { fatal = r.fatal }
    if not _absent(r.value, ctx) {
      kept.push((i, r.value))
      model.push(r.value)
    }
  }
  errors += _constraint-errors(schema, "array", kept, ctx.path)
  (errors: errors, value: model, fatal: fatal)
}

#let _suggest-limit = 10

// A free-form bag's model is the value as given, nulls included.
//
// Keys not in the shape: with `additional: true` they pass through
// unchecked (absent ones dropped), with an `additional` schema each is
// walked against it, and otherwise each is an `unknown-key` error and
// left out of the model, with a "Did you mean …?" for a near miss
// unless the object holds more than _suggest-limit of them. Absent
// fields are left out too. Only an absent value is dropped: an object
// whose keys were all null stays an empty dictionary, since validate
// counts it as present.
#let _object-walk(schema, value, ctx, recur) = {
  if type(value) != dictionary {
    return _type-miss(ctx.path, "object", value)
  }
  let additional = schema.at("additional", default: none)
  let errors = ()
  let fatal = none
  let out = (:)
  // Set at the first unknown key: whether to suggest, and the key list.
  let (suggest, valid) = (auto, none)
  for (key, sub-value) in value {
    if key in schema.shape or (additional != none and additional != true) {
      let sub-schema = schema.shape.at(key, default: additional)
      let r = recur(sub-schema, sub-value, _at(ctx, key))
      errors += r.errors
      if fatal == none { fatal = r.fatal }
      if not _absent(r.value, ctx) { out.insert(key, r.value) }
    } else if additional == true {
      if not _absent(sub-value, ctx) { out.insert(key, sub-value) }
    } else {
      // Strict: a fuzzy suggestion if the typo is within edit distance
      // 2 of a valid key, otherwise the full key list. An unknown key
      // holding null is still flagged: silently swallowing typos
      // defeats the point of strict validation.
      if suggest == auto {
        // Many unknown keys mean the wrong shape, not a typo: past a
        // few, a suggestion helps no one, and each costs an edit
        // distance per field.
        suggest = (
          value.keys().filter(k => k not in schema.shape).len()
            <= _suggest-limit
        )
        valid = if schema.shape.len() == 0 {
          "The object takes no keys."
        } else {
          "Valid keys: " + schema.shape.keys().map(_key-label).join(", ") + "."
        }
      }
      let suggestion = if suggest { _closest-match(key, schema.shape.keys()) }
      let tail = if suggestion != none {
        "Did you mean " + repr(suggestion) + "?"
      } else { valid }
      errors += _error(
        ctx.path + (key,),
        "unknown-key",
        "unknown key " + repr(key) + ". " + tail,
        expected: schema.shape.keys(),
        got: key,
      )
    }
  }
  // A required key holding null counts as missing. A hand-built node
  // may list a key twice, which object() keeps once: so does the walk.
  let required = schema.at("required-keys", default: ()).dedup()
  for key in required {
    if not _has(value, key, ctx) {
      errors += _error(
        ctx.path + (key,),
        "required",
        "missing required key " + repr(key) + ".",
      )
    }
  }
  // A null trigger does not fire, and a null dependent is missing. The
  // error sits at the missing key, as `required`'s does; `expected` is
  // the rule broken, the trigger's entry as the node holds it, as a
  // constraint miss gives its bound, and `got` is none: nothing is there.
  for (trigger, dependents) in schema.at("dependent-required", default: (:)) {
    if not _has(value, trigger, ctx) { continue }
    // A required key that is missing is already reported, once.
    for dependent in dependents.dedup() {
      if not _has(value, dependent, ctx) and dependent not in required {
        errors += _error(
          ctx.path + (dependent,),
          "dependent",
          repr(dependent)
            + " is required when "
            + repr(trigger)
            + " is present.",
          expected: (dependent-required: ((trigger): dependents)),
        )
      }
    }
  }
  let model = if _is-free-form(schema) { value } else { out }
  (errors: errors, value: model, fatal: fatal)
}

// anyOf / oneOf. Each member is walked at most once, and the model is
// the first member that walks clean, so nothing is walked a second time
// to build it. any-of stops at that member; one-of walks them all to
// count matches.
//
// With no clean member, one summary error at the union's own path
// rather than every member's failure list: member errors describe
// branches the value never claimed to match, so replaying them all is
// noise. Coerce has no member to build the model from, so it is fatal
// whatever the errors' codes.
//
// A null member never competes for a non-null value: the union walks
// only its other members then, so `nullable(X)` judges a non-null value
// exactly as X does, and several types plus null report what the union
// of the types alone would. A member is null by its kind, so an
// annotated one counts too.
#let _union-walk(schema, value, ctx, recur) = {
  let others = ()
  for m in schema.members {
    if m.kind != "null" { others.push(m) }
  }
  if value != none and others != () and others != schema.members {
    if others.len() == 1 { return (tail: others.first()) }
    return (tail: (..schema, members: others))
  }
  let results = ()
  for member in schema.members {
    let r = recur(member, value, ctx)
    if r.errors == () and not schema.exclusive { return r }
    results.push(r)
  }
  let clean = results.filter(r => r.errors == ())
  if clean.len() == 1 { return clean.first() }
  let kinds = schema.members.map(_reported-kind)
  if clean.len() > 1 {
    // The first match still models the value, as for any-of.
    let errors = _error(
      ctx.path,
      "union",
      "expected exactly one alternative to match, but "
        + str(clean.len())
        + " matched.",
      expected: kinds,
    )
    return (errors: errors, value: clean.first().value, fatal: none)
  }
  // A member claims the value when it has no `type` error at the
  // union's own path. When exactly one claims, its result is the
  // union's: its own errors say what is wrong (the generic summary would
  // read like a type error for a right-typed value that merely broke a
  // constraint), and coerce models the value as that member would alone.
  // When several claim it, the summary below reports it, and coerce
  // models it as the first claimant that leaves a model, as for a match.
  let type-misses(r) = r.errors.filter(e => (
    e.code == "type" and e.path == ctx.path
  ))
  let claimed = results.filter(r => type-misses(r) == ())
  if claimed.len() == 1 { return claimed.first() }
  let modelled = claimed.find(r => r.fatal == none)
  // When members take the value's type, coerce names the value, not it.
  let (model, fatal) = if modelled != none { (modelled.value, none) } else {
    (
      value,
      (
        path: ctx.path,
        expected: "a value matching one of the union alternatives",
        got: value,
        shown: if claimed != () { _shown(value) },
      ),
    )
  }
  let quantifier = if schema.exclusive { "exactly one" } else { "one" }
  let message = (
    "expected a value matching "
      + quantifier
      + " of: "
      + kinds.join(" | ")
      + "; none matched."
  )
  // No member takes the value's type at all: a type error, so an
  // enclosing union doesn't count this one as claiming it either. Its
  // `expected` gathers the type names the members' own type errors give
  // (an enum's or a nested union's already joined by " or ").
  let errors = if claimed.len() == 0 {
    let names = results
      .map(r => type-misses(r).map(e => e.expected.split(" or ")))
      .flatten()
      .dedup()
    _error(
      ctx.path,
      "type",
      message,
      expected: names.join(" or "),
      got: _type-name-of(value),
    )
  } else {
    _error(ctx.path, "union", message, expected: kinds)
  }
  (errors: errors, value: model, fatal: fatal)
}

// `not` inverts the member verdict; the member's own errors are
// discarded (they describe why the value is ACCEPTABLE here). There is
// no shape to model toward, so the value passes through as given, like
// an `additional: true` extra.
#let _not-walk(schema, value, ctx, recur) = {
  let r = recur(schema.member, value, ctx)
  let errors = if r.errors == () {
    _error(
      ctx.path,
      "not",
      "expected a value not matching the negated "
        + _reported-kind(schema.member)
        + " schema.",
    )
  } else { () }
  (errors: errors, value: value, fatal: none)
}

// `if` / `then` / `else`. The condition is walked in the same ctx, so
// the same null mode, and only its verdict counts: its errors and model
// are discarded, as `not` discards its member's. The branch it picks is
// the result, errors, model and fatal alike, so coerce follows the
// branch validate judged by. A missing branch accepts the value as
// given, like an `additional: true` extra.
//
// So in a union a conditional member claims a value as its chosen
// branch does (_union-walk reads only that branch's errors), and a
// missing branch, having no errors, matches it outright.
#let _if-walk(schema, value, ctx, recur) = {
  let matched = recur(schema.cond, value, ctx).errors == ()
  let branch = schema.at(
    if matched { "then" } else { "otherwise" },
    default: none,
  )
  if branch == none { return (errors: (), value: value, fatal: none) }
  (tail: branch)
}
