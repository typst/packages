// The structural kinds' constructors, arrays, unions, `not`, objects
// and maps, and the walks the engine runs for them. Leaves live in
// leaf.typ and format.typ, and registry.typ holds a descriptor for
// every kind.

#import "../core/ctx.typ": _at, _absent, _has
#import "../core/error.typ": (
  _bail, _error, _type-miss, _type-name-of, _closest-match, _problem, _fail,
  _key-names-problem,
)
#import "constraint.typ": _constraint-errors, _constrain
#import "leaf.typ": null-type
#import "format.typ": _string-problem

// Every kind registry.typ holds a descriptor for. The constructors sit
// below the registry, so they check sub-schemas against this list, and
// the registry asserts at load that the two agree.
#let _schema-kinds = (
  "string",
  "content",
  "number",
  "integer",
  "bool",
  "null",
  "any",
  "enum",
  "array",
  "object",
  "union",
  "not",
)

// Kind names a hand-built node may still carry, deprecated, until 1.0,
// each with the node it stands for: the plain string was "str", a
// patterned one "pattern-string" before it was a string with a
// `pattern`, and each format a kind of its own before it was a
// string's `format`. Every lookup by kind reads the node through
// _node, so an old node reaches the string descriptor and is reported
// as the string it is.
#let _kind-aliases = (
  str: (kind: "string"),
  pattern-string: (kind: "string"),
  date-string: (kind: "string", format: "date"),
  datetime-string: (kind: "string", format: "date-time"),
  uri-string: (kind: "string", format: "uri"),
  email-string: (kind: "string", format: "email"),
  uuid-string: (kind: "string", format: "uuid"),
  hostname-string: (kind: "string", format: "hostname"),
  ipv4-string: (kind: "string", format: "ipv4"),
  ipv6-string: (kind: "string", format: "ipv6"),
  time-string: (kind: "string", format: "time"),
)

// `node` with an old kind name (_kind-aliases) read as the node it
// stands for, its other fields kept. Panics on a string node whose
// `format` the format table doesn't know, which only a hand-built node
// can carry.
#let _node(node) = {
  let kind = node.at("kind", default: none)
  let node = if type(kind) == str and kind in _kind-aliases {
    (:..node, .._kind-aliases.at(kind))
  } else { node }
  if node.at("kind", default: none) == "string" {
    let p = _string-problem(format: node.at("format", default: none))
    if p != none { _fail("string schema", p) }
  }
  node
}

// A schema node: a dictionary whose `kind` is registered. Shallow, as
// its children were checked when they were built.
#let _is-schema(node) = (
  type(node) == dictionary
    and _node(node).at("kind", default: none) in _schema-kinds
)

// A node's kind as messages and describe-schema name it: the kind, then
// a string's format, if it has one, in parentheses (`string (date)`).
#let _kind-label(node) = {
  let node = _node(node)
  if node.kind == "string" and "format" in node {
    "string (" + node.format + ")"
  } else { node.kind }
}

// The one gate for a node entering from user code: a lens-put value, a
// lens-over result, a constructor's sub-schema. A malformed node fails
// here, naming what took it, not later as an unknown kind mid-walk.
#let _require-schema(node, who) = {
  if not _is-schema(node) {
    _bail(
      who,
      "must be a schema; got: "
        + repr(node)
        + ". Build schemas with the constructors.",
    )
  }
}

// The named parameters are the array rows' fields (constraint.typ),
// checked by _constrain as number() and string() check theirs.
/// An array whose every element matches `elem`, with optional length
/// bounds and uniqueness. An argument left at its default sets nothing.
/// Panics if `elem` is not a schema, on a value of the wrong type, or
/// on bounds no array satisfies.
///
/// - elem (dictionary): The schema for each element.
/// - min-items (int, none): The fewest elements allowed.
/// - max-items (int, none): The most elements allowed.
/// - unique-items (bool): Whether every element must differ from the
///   others.
/// -> dictionary
#let array-of(elem, min-items: none, max-items: none, unique-items: false) = {
  _require-schema(elem, "array-of() elem")
  _constrain(
    "array-of()",
    (kind: "array", elem: elem),
    "array",
    (
      min-items: min-items,
      max-items: max-items,
      unique-items: unique-items,
    ),
  )
}

// A member's kind as union and `not` errors name it. An integer member
// reads `number`, as it did before integer was a kind of its own, so
// the messages and `expected` values validate returns stay as they were.
#let _reported-kind(member) = if member.kind == "integer" { "number" } else {
  _kind-label(member)
}

// Bad-shape members fail at construction, not as a phantom validation
// error — same contract as object() below. The members come as
// separate arguments or as one array; an array is never a schema, so
// a lone array argument is the array form and anything else (a lone
// schema included) is the member list.
#let _members(fn-name, args) = {
  if args.named() != (:) {
    _bail(
      fn-name,
      "takes no named arguments; got: " + repr(args.named()) + ".",
    )
  }
  let pos = args.pos()
  let members = if pos.len() == 1 and type(pos.first()) == array {
    pos.first()
  } else { pos }
  if members.len() == 0 or not members.all(_is-schema) {
    _bail(
      fn-name,
      "members must be a non-empty array of schema dicts (each built with the constructors); got: "
        + repr(members)
        + ".",
    )
  }
  members
}

// JSON Schema anyOf / oneOf. Both share the union kind; `exclusive`
// distinguishes "at least one member matches" (any-of) from "exactly
// one" (one-of). Match counting lives in _union-walk below, and the
// model is the first matching member's output.
/// A value that matches at least one of the member schemas (JSON Schema
/// `anyOf`). `any-of(a, b)` and `any-of((a, b))` build the same node.
/// Panics if there are no members or one is not a schema.
///
/// - ..members (dictionary, array): The schemas to try, as separate
///   arguments or as one array.
/// -> dictionary
#let any-of(..members) = (
  kind: "union",
  members: _members("any-of()", members),
  exclusive: false,
)
/// A value that matches exactly one of the member schemas (JSON Schema
/// `oneOf`). `one-of(a, b)` and `one-of((a, b))` build the same node.
/// Panics if there are no members or one is not a schema.
///
/// - ..members (dictionary, array): The schemas to try, as separate
///   arguments or as one array.
/// -> dictionary
#let one-of(..members) = (
  kind: "union",
  members: _members("one-of()", members),
  exclusive: true,
)

// JSON Schema `[X, "null"]`. An any-of, not a kind of its own: in
// strict-null mode the union walk hands a null to null-type, and in
// default mode a null is absent before any kind sees it, so this is X.
/// A value that matches `member` or is `null`. Without `strict-null`
/// every field already treats `null` as absent, so this is `member`;
/// with it, this is how a field accepts `null`. Panics if `member` is
/// not a schema.
///
/// - member (dictionary): The schema for a non-null value.
/// -> dictionary
#let nullable(member) = {
  if not _is-schema(member) {
    _bail(
      "nullable",
      "member must be a schema dict (built with the constructors); got: "
        + repr(member)
        + ".",
    )
  }
  any-of((member, null-type))
}

// JSON Schema `not` — the value must NOT match the negated schema.
// Named not-of because `not` is a Typst keyword.
/// A value that must not match `member` (JSON Schema `not`). Panics if
/// `member` is not a schema.
///
/// - member (dictionary): The schema the value must fail.
/// -> dictionary
#let not-of(member) = {
  if not _is-schema(member) {
    _bail(
      "not-of",
      "member must be a schema dict (built with the constructors); got: "
        + repr(member)
        + ".",
    )
  }
  (kind: "not", member: member)
}

// `additional` controls keys not in `shape` (the engine-side name for
// JSON Schema's `additionalProperties`): `none` / `false` → reject;
// `true` → pass-through; schema dict → validate every extra against
// it. `false` is accepted as a synonym for `none` so callers fluent
// in JSON Schema can pass either. Bad-shape `additional` and
// required-keys-not-covered both fail at construction, not as a
// phantom validation error. `dependent-required` follows the same
// rule: a malformed map always panics, and trigger / dependent keys
// outside `shape` panic only when strict.
//
// The argument shapes are checked by _object-problem, which the
// translator words for its own keywords; whether the names are in
// `shape` is object()'s alone.
#let _object-problem(required-keys, dependent-required, additional) = {
  let additional-ok = (
    additional in (none, false, true) or _is-schema(additional)
  )
  if not additional-ok {
    return _problem(
      "additional",
      "none, false, true, or a schema dict (built with the constructors)",
      repr(additional),
    )
  }
  // Checked whatever `additional` is: an open object reads the names as
  // keys too, so a non-string one would pass here and fail at validation.
  let p = _key-names-problem(required-keys, "required-keys")
  if p != none { return p }
  if type(dependent-required) != dictionary {
    return _problem(
      "dependent-required",
      "a dictionary of key to array of keys",
      repr(dependent-required),
    )
  }
  for (trigger, dependents) in dependent-required {
    let p = _key-names-problem(
      dependents,
      "dependent-required",
      entry: trigger,
    )
    if p != none { return p }
  }
}

/// A dictionary with the fields in `shape`. Panics if a field is not a
/// schema, if `additional` is the wrong shape, if `required-keys` or a
/// `dependent-required` entry is not an array of key names, or, when
/// `additional` is `none` or `false`, if `required-keys` or
/// `dependent-required` names a field not in `shape`.
///
/// - shape (dictionary): Field name to schema.
/// - required-keys (array): Fields that must be present.
/// - dependent-required (dictionary): Field name to the fields that must
///   also be present whenever it is.
/// - additional (none, bool, dictionary): What to do with keys not in
///   `shape`. `none` or `false` rejects them, `true` lets them through
///   unchecked, and a schema validates each one against it.
/// -> dictionary
#let object(
  shape,
  required-keys: (),
  dependent-required: (:),
  additional: none,
) = {
  let p = _object-problem(required-keys, dependent-required, additional)
  if p != none { _fail("object()", p) }
  // false ≡ none in our model; normalise so the constructor and the
  // translator agree on what they accept.
  let normalized = if additional == false { none } else { additional }
  for (key, sub) in shape {
    _require-schema(sub, "object() field " + repr(key))
  }
  // With `additional`, undeclared required keys are covered by the
  // additional schema, so the subset check only applies when strict.
  let unknown = if normalized == none {
    required-keys.filter(k => k not in shape)
  } else {
    ()
  }
  if unknown.len() > 0 {
    _bail(
      "object()",
      "required-keys references keys not in shape: " + unknown.join(", ") + ".",
    )
  }
  let unknown-dependent = if normalized == none {
    dependent-required
      .pairs()
      .map(((trigger, dependents)) => (trigger,) + dependents)
      .flatten()
      .filter(k => k not in shape)
  } else {
    ()
  }
  if unknown-dependent.len() > 0 {
    _bail(
      "object()",
      "dependent-required references keys not in shape: "
        + unknown-dependent.dedup().join(", ")
        + ".",
    )
  }
  let result = (
    kind: "object",
    shape: shape,
    required-keys: required-keys,
  )
  // Optional fields are omitted when empty / `none` so existing dicts
  // keep their shape.
  if dependent-required.len() > 0 {
    result.insert("dependent-required", dependent-required)
  }
  if normalized != none { result.insert("additional", normalized) }
  result
}

// The fields object() takes as arguments; any other field on a node
// (a hand-added annotation) rides along unchanged.
#let _object-args = (
  "kind",
  "shape",
  "required-keys",
  "dependent-required",
  "additional",
)

// `node` with `changes` applied, rebuilt through object() so every
// edit keeps the constructor's invariants. A change to `additional:
// none` or `dependent-required: (:)` drops that field, as object()
// does.
#let _object-with(node, ..changes) = {
  let s = (:..node, ..changes.named())
  let out = object(
    s.shape,
    required-keys: s.at("required-keys", default: ()),
    dependent-required: s.at("dependent-required", default: (:)),
    additional: s.at("additional", default: none),
  )
  for (k, v) in s {
    if k not in _object-args { out.insert(k, v) }
  }
  out
}

// An object that declares no fields and lets anything through is a
// free-form bag (JSON Resume's `custom`): opaque data, not a section
// with extras tacked on. Strict keeps it open, and coerce passes it
// through unchanged.
#let _is-free-form(schema) = (
  schema.kind == "object"
    and schema.shape.len() == 0
    and schema.at("additional", default: none) == true
)

// `required-keys` kwarg for symmetry with `object` — required keys
// on a pure map are still meaningful ("the document must contain
// these specific keys, plus any number of others").
/// A dictionary with any keys, whose values all match `value-schema`.
///
/// - value-schema (dictionary): The schema for every value.
/// - required-keys (array): Keys that must be present.
/// -> dictionary
#let map(value-schema, required-keys: ()) = object(
  (:),
  required-keys: required-keys,
  additional: value-schema,
)

// ---- engine behaviour ------------------------------------------------
//
// A structural walk is (schema, value, ctx, recur) -> (errors, value,
// fatal). `recur` is the engine's walk, passed in so kinds/ never
// imports the engine. `value` is the model; `fatal` is none, or the
// first place in walk order where the value leaves no sound model, as
// (path, expected, got) for coerce's panic text. Every fatal walk also has
// errors, so a walk with no errors has no fatal.
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

// An object that declares no fields and lets anything through is a
// free-form bag (JSON Resume's `custom`): opaque data, so its model is
// the value as given, nulls included.
//
// Keys not in the shape: with `additional: true` they pass through
// unchecked (absent ones dropped), with an `additional` schema each is
// walked against it, and otherwise each is an `unknown-key` error and
// left out of the model. Absent fields are left out too. Only an absent
// value is dropped: an object whose keys were all null stays an empty
// dictionary, since validate counts it as present.
#let _object-walk(schema, value, ctx, recur) = {
  if type(value) != dictionary {
    return _type-miss(ctx.path, "object", value)
  }
  let additional = schema.at("additional", default: none)
  let errors = ()
  let fatal = none
  let out = (:)
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
      let suggestion = _closest-match(key, schema.shape.keys(), 2)
      let tail = if suggestion != none {
        "Did you mean " + repr(suggestion) + "?"
      } else {
        "Valid keys: " + schema.shape.keys().join(", ") + "."
      }
      errors += _error(
        ctx.path + (key,),
        "unknown-key",
        "unknown key " + repr(key) + ". " + tail,
        expected: schema.shape.keys(),
        got: key,
      )
    }
  }
  // A required key holding null counts as missing.
  for key in schema.at("required-keys", default: ()) {
    if not _has(value, key, ctx) {
      errors += _error(
        ctx.path + (key,),
        "required",
        "missing required key " + repr(key) + ".",
      )
    }
  }
  // A null trigger does not fire, and a null dependent is missing.
  for (trigger, dependents) in schema.at("dependent-required", default: (:)) {
    if not _has(value, trigger, ctx) { continue }
    for dependent in dependents {
      if not _has(value, dependent, ctx) {
        errors += _error(
          ctx.path,
          "dependent",
          repr(dependent)
            + " is required when "
            + repr(trigger)
            + " is present.",
          expected: dependent,
          got: trigger,
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
// A null-type member never competes for a non-null value: the union
// walks only its other members then, so `nullable(X)` judges a
// non-null value exactly as X does, and several types plus null report
// what the union of the types alone would.
#let _union-walk(schema, value, ctx, recur) = {
  let others = schema.members.filter(m => m != null-type)
  if value != none and others != () and others != schema.members {
    if others.len() == 1 { return recur(others.first(), value, ctx) }
    return _union-walk((..schema, members: others), value, ctx, recur)
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
  let fatal = (
    path: ctx.path,
    expected: "a value matching one of the union alternatives",
    got: value,
  )
  // A member claims the value when it has no `type` error at the
  // union's own path. When exactly one claims, its own errors say what
  // is wrong; the generic summary would read like a type error for a
  // right-typed value that merely broke a constraint.
  let claimed = results.filter(r => {
    not r.errors.any(e => (
      e.code == "type" and e.path == ctx.path
    ))
  })
  if claimed.len() == 1 {
    // A claimant that can't be modelled says where itself (e.g. a nested
    // field); one that only broke a constraint gets the union's message.
    let own = claimed.first().fatal
    return (
      errors: claimed.first().errors,
      value: value,
      fatal: if own != none { own } else { fatal },
    )
  }
  let alternatives = kinds.join(" | ")
  let quantifier = if schema.exclusive { "exactly one" } else { "one" }
  let message = (
    "expected a value matching "
      + quantifier
      + " of: "
      + alternatives
      + "; none matched."
  )
  // No member takes the value's type at all: a type error, so an
  // enclosing union doesn't count this one as claiming it either.
  let errors = if claimed.len() == 0 {
    _error(
      ctx.path,
      "type",
      message,
      expected: alternatives,
      got: _type-name-of(value),
    )
  } else {
    _error(ctx.path, "union", message, expected: kinds)
  }
  (errors: errors, value: value, fatal: fatal)
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
