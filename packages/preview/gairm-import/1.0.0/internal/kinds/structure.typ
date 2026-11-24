// The structural kinds' constructors, arrays, unions, `not`,
// conditionals, objects and maps, and the schema check every
// sub-schema passes. Leaves live in leaf.typ and format.typ, the walks
// the engine runs for these kinds in walk.typ, and registry.typ holds a
// descriptor for every kind. This module sits above the registry, so
// the schema check reads the registered kinds from it.

#import "../core/error.typ": _a, _bail, _problem, _fail
#import "constraint.typ": _constrain, _value-problem, _bounds-problems
#import "leaf.typ": null
#import "registry.typ": _kinds, _object-problem, _if-problem, _foreign-fields

// Whether `node` is a dictionary of a registered kind. Never panics, so
// a search can ask it of any node it meets.
#let _has-kind(node) = (
  type(node) == dictionary
    and type(node.at("kind", default: none)) == str
    and node.kind in _kinds
)

// What a schema check suggests to a caller who passed something else.
#let _schema-hint = " Build schemas with the constructors."

// What to add when a node carries a field its kind would ignore
// (registry.typ's _foreign-fields), for the slips that have a fix.
#let _foreign-hints = (
  integer: " Drop it: integer() builds a whole number.",
  "else": " The else branch is the field otherwise.",
  pattern: " Use string() for one.",
  format: " Use string() for one.",
)

// What a field set to none gets: a node has no null value for a field
// it may leave out (object()'s `additional: none` is its own value).
#let _none-hint(v) = if v == none { " Leave the field out to unset it." }

// Keys that mark a dictionary as a JSON Schema document, which the
// translator, not the schema check, takes.
#let _json-schema-keys = (
  "$schema",
  "$ref",
  "type",
  "properties",
  "items",
  "enum",
  "const",
  "allOf",
  "anyOf",
  "oneOf",
)

// The first malformed node in `node`, pre-order, as (path, problem), or
// none: a node that is not a dictionary of a registered kind, or one
// whose own fields its descriptor rejects (registry.typ). `path` is the
// schema path to it from `node`. Never panics, so a search can ask it of
// any value.
//
// Typst memoizes a call by hashing its arguments, which visits the whole
// subtree, so this passes the node to nothing but the descriptor's own
// checks: the fields and rows are checked inline. It takes the node
// alone and builds the path on the way back up, so a subtree's verdict
// can be memoized: a wide subtree checked again (one a union repeats,
// or a constructor already checked) costs little. The memo does not
// bound the recursion, which still descends the whole depth: a schema
// nested past about 70 levels exceeds Typst's call depth here.
#let _schema-problem(node) = {
  let kind = if type(node) == dictionary { node.at("kind", default: none) }
  if type(kind) != str or kind not in _kinds {
    // A JSON Schema document, or a file, is named rather than shown: its
    // repr runs to pages. A constructor left uncalled gets the call.
    let (got, hint) = if (
      type(node) == dictionary
        and kind == none
        and _json-schema-keys.any(k => k in node)
    ) {
      (
        "a JSON Schema document",
        " Translate it with schema-from-json-schema(..) first.",
      )
    } else if type(node) in (path, bytes) {
      (
        // Uncountable: "bytes", not "a bytes".
        if type(node) == bytes { "bytes" } else { _a(str(type(node))) },
        " Read a JSON Schema file with schema-from-json-schema(..).",
      )
    } else if type(node) == function {
      (repr(node), " Call it: " + repr(node) + "().")
    } else { (repr(node), _schema-hint) }
    return (path: (), problem: _problem(none, "a schema", got, hint: hint))
  }
  let d = _kinds.at(kind)
  let p = none
  for (field, required, ok, must) in d.fields {
    if field not in node {
      if required { p = _problem("field " + repr(field), must, "missing") }
    } else if ok != none and not ok(node.at(field)) {
      let v = node.at(field)
      // A field the kind requires can't be left out instead.
      let hint = if not required { _none-hint(v) }
      p = _problem("field " + repr(field), must, repr(v), hint: hint)
    }
    if p != none { break }
  }
  if p == none and d.problem != none { p = (d.problem)(node) }
  // A field another kind reads would be ignored here; any other field is
  // an annotation and rides along.
  if p == none {
    let foreign = _foreign-fields.at(kind)
    for k in node.keys() {
      if k in foreign {
        p = (
          message: "field "
            + repr(k)
            + " does nothing on "
            + _a(kind)
            + " schema."
            + _foreign-hints.at(k, default: ""),
        )
        break
      }
    }
  }
  for row in d.rows {
    if p != none { break }
    if row.field in node {
      let v = node.at(row.field)
      let must = _value-problem(row, v)
      if must != none {
        p = _problem(
          "field " + repr(row.field),
          must,
          repr(v),
          hint: _none-hint(
            v,
          ),
        )
      }
    }
  }
  // Bounds no value meets, as the constructors refuse them: read off the
  // kind and the bounds alone, not the node, whose hash is its subtree.
  if p == none and d.rows != () {
    let bounds = d
      .rows
      .filter(row => row.field in node)
      .map(row => (row.field, node.at(row.field)))
      .to-dict()
    let b = _bounds-problems((kind: kind, ..bounds), row => (
      "field " + repr(row.field)
    ))
    p = if b.problem != none { b.problem } else { b.gap }
  }
  if p != none { return (path: (), problem: p) }
  for (seg, sub, _) in (d.children)(node) {
    let found = _schema-problem(sub)
    if found != none {
      // A shadowed additional schema has no path segment of its own.
      let seg = if seg == none { "additionalProperties" } else { seg }
      return (path: (seg,) + found.path, problem: found.problem)
    }
  }
}

// Whether `node` is an object schema: for the operations only an
// object supports (the field edits, the allOf merge).
#let _is-object(node) = node.kind == "object"

// The one gate for a node entering from user code: a run function's
// schema, a schema-put value, a schema-update result, a constructor's
// sub-schema. A malformed node fails here, naming what took it and
// where in it the problem is, not later as a raw error mid-walk.
#let _require-schema(node, who) = {
  let found = _schema-problem(node)
  if found == none { return }
  let at = if found.path != () { " at " + repr(found.path) }
  _fail(who + at, found.problem)
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
  if members.len() == 0 {
    _fail(fn-name, _problem("members", "a non-empty array of schemas", "()"))
  }
  for (i, m) in members.enumerate() {
    _require-schema(m, fn-name + " member " + str(i))
  }
  members
}

// JSON Schema anyOf / oneOf. Both share the union kind; `exclusive`
// distinguishes "at least one member matches" (any-of) from "exactly
// one" (one-of). Match counting lives in walk.typ's _union-walk, and the
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
// strict-null mode the union walk hands a null to null(), and in
// default mode a null is absent before any kind sees it, so this is X.
/// A value that matches `member` or is `null`. Without `strict-null`
/// every field already treats `null` as absent, so this is `member`;
/// with it, this is how a field accepts `null`. Panics if `member` is
/// not a schema.
///
/// - member (dictionary): The schema for a non-null value.
/// -> dictionary
#let nullable(member) = {
  _require-schema(member, "nullable() member")
  any-of((member, null()))
}

// JSON Schema `not` — the value must NOT match the negated schema.
// Named not-of because `not` is a Typst keyword.
/// A value that must not match `member` (JSON Schema `not`). Panics if
/// `member` is not a schema.
///
/// - member (dictionary): The schema the value must fail.
/// -> dictionary
#let not-of(member) = {
  _require-schema(member, "not-of() member")
  (kind: "not", member: member)
}

// JSON Schema `if` / `then` / `else`. Named if-of because `if` is a
// Typst keyword, and the else branch `otherwise` because `else` is one
// too. A branch left out is not stored, as object() leaves out its
// optional fields.
/// A value that must match `then` if it matches `cond`, and `otherwise`
/// if it does not (JSON Schema `if` / `then` / `else`). A branch left
/// out accepts the value as given. Panics if an argument is not a
/// schema, or if both branches are left out.
///
/// - cond (dictionary): The schema that picks the branch. Only whether
///   the value matches it counts; its errors are never reported.
/// - then (none, dictionary): The schema for a value that matches
///   `cond`.
/// - otherwise (none, dictionary): The schema for a value that does not.
/// -> dictionary
#let if-of(cond, then: none, otherwise: none) = {
  _require-schema(cond, "if-of() cond")
  let node = (kind: "if", cond: cond)
  for (name, branch) in (then: then, otherwise: otherwise) {
    if branch != none {
      _require-schema(branch, "if-of() " + name)
      node.insert(name, branch)
    }
  }
  let p = _if-problem(node)
  if p != none { _fail("if-of()", p) }
  node
}

// object()'s body, its panics naming `who`: object() itself, or the
// public function that builds or edits an object through it (map(),
// a schema edit), so a bad argument is named as the caller's call spells
// it. `additional` controls keys not in `shape` (the engine-side name
// for JSON Schema's `additionalProperties`): `none` / `false` → reject;
// `true` → pass-through; schema dict → validate every extra against
// it. `false` is accepted as a synonym for `none` so callers fluent in
// JSON Schema can pass either. Bad-shape `additional` and
// required-keys-not-covered both fail at construction, not as a
// phantom validation error. `dependent-required` follows the same
// rule: a malformed map always panics, and trigger / dependent keys
// outside `shape` panic only when the object is closed. The arguments
// are checked by the registry's _object-problem, which the translator
// words for its own keywords.
#let _object(who, shape, required-keys, dependent-required, additional) = {
  if type(shape) != dictionary {
    _fail(who, _problem(
      "shape",
      "a dictionary of field name to schema",
      repr(shape),
    ))
  }
  let p = _object-problem(
    required-keys,
    dependent-required,
    additional,
    keys: shape.keys(),
  )
  if p != none { _fail(who, p) }
  if type(additional) == dictionary {
    _require-schema(additional, who + " additional")
  }
  // A key listed twice is required once, so it is missing once.
  let required-keys = required-keys.dedup()
  // A trigger with no dependents requires nothing, so it is dropped.
  let dependent-required = dependent-required
    .pairs()
    .filter(((_, dependents)) => dependents != ())
    .map(((trigger, dependents)) => (trigger, dependents.dedup()))
    .to-dict()
  // false ≡ none in our model; normalise so the constructor and the
  // translator agree on what they accept.
  let normalized = if additional == false { none } else { additional }
  for (key, sub) in shape {
    _require-schema(sub, who + " field " + repr(key))
  }
  // Every field but `shape` is omitted when empty / `none`, so an
  // argument left out adds nothing and a hand-built object equals the
  // built one.
  let result = (kind: "object", shape: shape)
  if required-keys != () { result.insert("required-keys", required-keys) }
  if dependent-required.len() > 0 {
    result.insert("dependent-required", dependent-required)
  }
  if normalized != none { result.insert("additional", normalized) }
  result
}

/// A dictionary with the fields in `shape`. A key listed twice in
/// `required-keys` or a `dependent-required` entry counts once. Panics if
/// `shape` is not a dictionary, if a field is not a schema, if
/// `additional` is the wrong shape, if `required-keys` or a
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
) = _object("object()", shape, required-keys, dependent-required, additional)

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
// edit keeps the constructor's invariants; a panic names `who`. A
// change to `additional: none` or `dependent-required: (:)` drops that
// field, as object() does.
#let _object-with(node, who: "object()", ..changes) = {
  let s = (:..node, ..changes.named())
  let out = _object(
    who,
    s.shape,
    s.at("required-keys", default: ()),
    s.at("dependent-required", default: (:)),
    s.at("additional", default: none),
  )
  for (k, v) in s {
    if k not in _object-args { out.insert(k, v) }
  }
  out
}

// `node` as a write leaves it: an object rebuilt through object(), so
// it keeps the constructor's invariants (a panic naming `who`), and any
// other node as it is.
#let _rebuilt(node, who) = if _is-object(node) {
  _object-with(node, who: who)
} else { node }

// `required-keys` kwarg for symmetry with `object` — required keys
// on a pure map are still meaningful ("the document must contain
// these specific keys, plus any number of others").
/// A dictionary with any keys, whose values all match `value-schema`.
/// Panics if `value-schema` is not a schema, or `required-keys` is not
/// an array of key names.
///
/// - value-schema (dictionary): The schema for every value.
/// - required-keys (array): Keys that must be present.
/// -> dictionary
#let map(value-schema, required-keys: ()) = {
  // Checked here, so it is named value-schema, not the `additional`
  // object() takes it as.
  _require-schema(value-schema, "map() value-schema")
  _object("map()", (:), required-keys, (:), value-schema)
}
