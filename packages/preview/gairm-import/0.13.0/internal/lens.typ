// Lens-style schema editing.
//
// Top-level lens-* functions rather than methods on a lens record:
// Typst parses `dict.field(args)` as a type-method lookup, not a call
// of the closure stored under that key, so methods would force
// `(lens.put)(args)` at every call site.
//
// The schema comes first everywhere, so edits pipe through `.fold`.
// A location is a lens `(lens: path)` or the bare path array, and
// every function here takes either.
//
// Path segments borrow JSON Schema keyword names (not the engine field
// names), but a lens path is not a JSON Schema location: a field is
// entered by its bare name, with no `properties` segment. Segments:
//   - object   : string key into `.shape`
//   - object   : literal "additionalProperties" to enter `.additional`
//                (only when set to a schema dict, not `true`)
//   - array    : literal "items" to enter `.elem`
//   - union    : int index into `.members` (any-of and one-of alike)
//   - not      : literal "not" to enter `.member`
//   - if       : literal "if", "then" or "else" to enter `.cond`, `.then`
//                or `.otherwise` (a branch only when it is set)
//   - empty `()` : identity lens
//
// Shape-first precedence for objects: if `"additionalProperties"` is
// both a literal property in `shape` and the additionalProperties
// keyword name, the literal property wins (meta-schemas are the
// realistic case where this collision arises). Reach the
// additional-schema in that rare collision case via lens-over on the
// parent — `p => p.additional` to read, `p => (..p, additional: new)`
// to write.
//
// Every edit keeps the constructors' invariants. The node `lens-put`
// writes, or `lens-over`'s function returns, must be a schema (checked
// shallowly: its children were checked when it was built), and an
// edited object, the written node or any object above it, is rebuilt
// through object(). Build replacements with the constructors.
//
// Deprecated until 1.0: the lens-first order of lens-get / lens-put /
// lens-over, and the `(kind: "lens", path: …)` lens shape (accepted by
// _location-path in traverse.typ).

#import "kinds/traverse.typ": _get-at, _set-at, _is-location, _location-path
#import "kinds/structure.typ": (
  _require-schema, _is-schema, _is-object, _object-with,
)
#import "core/error.typ": _bail, _not-in, _require-key-names

// A node entering from user code: a schema, and an object one rebuilt
// through object() so it can't break the constructor's invariants.
#let _checked(node, who) = {
  _require-schema(node, who)
  if _is-object(node) { _object-with(node) } else { node }
}

/// Deprecated: use the path array itself, or `(lens: path)`, instead;
/// every function that takes a location takes either. Kept until 1.0.
///
/// A lens: a path to one node in a schema, as `(lens: path)`. A path is
/// an array of segments: a field name to enter an object, `"items"` to
/// enter an array's elements, `"additionalProperties"` to enter an
/// object's additional schema, an int index to enter a union member,
/// `"not"` to enter a `not` member, or `"if"`, `"then"` or `"else"` to
/// enter a conditional's condition or branch. `()` is the identity
/// lens. Every function that takes a location takes a lens or the bare
/// path array.
///
/// - path (array): The segments.
/// -> dictionary
#let lens(path) = {
  if type(path) != array {
    _bail("lens", "path must be an array of segments; got: " + repr(path) + ".")
  }
  (lens: path)
}

// What an argument is, for the order panic below.
#let _what(x) = if _is-schema(x) { "a schema" } else if _is-location(x) {
  "a location"
} else { "a " + str(type(x)) }

// The schema and the path of a lens-get / lens-put / lens-over call.
// Schema first. The lens-first order of earlier releases is deprecated,
// accepted until 1.0, and told apart by type: a schema is never a
// location, so at most one order fits, and a call that fits neither
// panics rather than guess.
#let _subject(a, b, op) = {
  if _is-schema(a) and _is-location(b) {
    return (a, _location-path(b, op))
  }
  if _is-location(a) and _is-schema(b) {
    return (b, _location-path(a, op))
  }
  _bail(
    op,
    "takes a schema, then a location (a lens or a path array); got "
      + _what(a)
      + " and "
      + _what(b)
      + ".",
  )
}

/// Reads the schema node at `at`. Panics if the path does not exist.
/// The lens-first order `lens-get(at, schema)` is deprecated, and
/// accepted until 1.0.
///
/// - schema (dictionary): The schema to read from.
/// - at (dictionary, array): Where: a lens or a path array.
/// -> dictionary
#let lens-get(schema, at) = {
  let (schema, path) = _subject(schema, at, "lens-get")
  _get-at(schema, path)
}

// `put` because `set` is a Typst keyword.
/// Returns a new schema with the node at `at` replaced by `value`. The
/// input schema is not changed. Panics if `value` is not a schema, or
/// if the edit breaks an object's invariants (as `object` would). The
/// lens-first order `lens-put(at, schema, value)` is deprecated, and
/// accepted until 1.0.
///
/// - schema (dictionary): The schema to edit.
/// - at (dictionary, array): Where: a lens or a path array.
/// - value (dictionary): The replacement node.
/// -> dictionary
#let lens-put(schema, at, value) = {
  let (schema, path) = _subject(schema, at, "lens-put")
  _set-at(schema, path, _checked(value, "lens-put value"))
}

/// Returns a new schema with the node at `at` replaced by `fn` applied
/// to it. Panics if `fn` returns anything but a schema, or if the edit
/// breaks an object's invariants (as `object` would). The lens-first
/// order `lens-over(at, schema, fn)` is deprecated, and accepted until
/// 1.0.
///
/// - schema (dictionary): The schema to edit.
/// - at (dictionary, array): Where: a lens or a path array.
/// - fn (function): Takes the current node, returns the new one.
/// -> dictionary
#let lens-over(schema, at, fn) = {
  let (schema, path) = _subject(schema, at, "lens-over")
  _set-at(schema, path, _checked(
    fn(_get-at(schema, path)),
    "lens-over result",
  ))
}

// `lens-then(a, b)` applies a then b — paths concatenate in that order.
/// Deprecated: use `a + b` on the path arrays instead. Kept until 1.0.
///
/// Joins two locations into one lens: follows `a`, then `b` from there.
///
/// - a (dictionary, array): The first lens or path.
/// - b (dictionary, array): The lens or path to follow after `a`.
/// -> dictionary
#let lens-then(a, b) = lens(
  _location-path(a, "lens-then") + _location-path(b, "lens-then"),
)

// The skeleton the object edits share: check the schema and the
// location once, find the object at `at`, let `edit` check it and
// return the fields to change (as object() names them), and write it
// back rebuilt through object().
#let _edit-object(schema, at, op, edit) = {
  _require-schema(schema, op + "'s first argument")
  let path = _location-path(at, op)
  let parent = _get-at(schema, path)
  if not _is-object(parent) {
    _bail(
      op,
      "expects an object schema at the lens target, got kind="
        + repr(parent.kind)
        + ".",
    )
  }
  _set-at(schema, path, _object-with(parent, ..edit(parent)))
}

// Collisions panic instead of overwriting silently — for the
// overwrite-an-existing-key case, callers can reach for lens-put / lens-over.
// `required: true` adds the key to required-keys in the same edit, so
// the object is rebuilt, and checked, once.
/// Returns a new schema with `key` added to the object at `at`. Panics
/// if the target is not an object or already has that key; use
/// `lens-put` to replace a field.
///
/// - schema (dictionary): The schema to edit.
/// - at (dictionary, array): The object that gets the field: a lens or
///   a path array.
/// - key (str): The new field's name.
/// - sub-schema (dictionary): The schema for the field.
/// - required (bool): Whether the object also requires the field.
/// -> dictionary
#let add-field(schema, at, key, sub-schema, required: false) = {
  if type(required) != bool {
    _bail(
      "add-field",
      "required must be true or false, got: " + repr(required) + ".",
    )
  }
  _edit-object(schema, at, "add-field", parent => {
    if key in parent.shape {
      _bail(
        "add-field",
        "key "
          + repr(key)
          + " already in object shape. "
          + "Use lens-put / lens-over to replace an existing field.",
      )
    }
    let edit = (shape: (..parent.shape, (key): sub-schema))
    if required and key not in parent.required-keys {
      edit.required-keys = parent.required-keys + (key,)
    }
    edit
  })
}

// Replace, not merge — mirrors lens-put. On a closed object keys must
// exist in shape so a typo fails at edit time, not as a phantom
// "missing X" error; an open one allows what object() allows.
/// Returns a new schema where the object at `at` requires exactly
/// `keys`, replacing its earlier list. Panics if `keys` is not an array
/// of key names, or if a key is not in the shape of an object that
/// rejects other keys.
///
/// - schema (dictionary): The schema to edit.
/// - at (dictionary, array): The object: a lens or a path array.
/// - keys (array): The fields to require.
/// -> dictionary
#let set-required(schema, at, keys) = {
  _require-key-names(keys, "set-required", "keys")
  _edit-object(schema, at, "set-required", parent => {
    let closed = parent.at("additional", default: none) == none
    let unknown = keys.filter(k => closed and k not in parent.shape)
    if unknown.len() > 0 {
      _bail("set-required", _not-in(
        "keys",
        "object shape",
        "Valid keys",
        parent.shape.keys(),
        names: unknown,
      ))
    }
    (required-keys: keys)
  })
}

// Symmetric to set-required — relax specific keys without re-listing.
// Absent-key panics so a stale "still required" assumption surfaces.
/// Returns a new schema where the object at `at` no longer requires
/// `keys`. Panics if `keys` is not an array of key names, or if a key
/// was not required.
///
/// - schema (dictionary): The schema to edit.
/// - at (dictionary, array): The object: a lens or a path array.
/// - keys (array): The fields to stop requiring.
/// -> dictionary
#let unset-required(schema, at, keys) = {
  _require-key-names(keys, "unset-required", "keys")
  _edit-object(schema, at, "unset-required", parent => {
    let absent = keys.filter(k => k not in parent.required-keys)
    if absent.len() > 0 {
      _bail("unset-required", _not-in(
        "keys",
        "required-keys",
        "Current required",
        parent.required-keys,
        names: absent,
      ))
    }
    (required-keys: parent.required-keys.filter(k => k not in keys))
  })
}

// Absent-key panics rather than being a silent no-op so caller typos surface.
/// Returns a new schema with `key` removed from the object at `at`, and
/// from its required keys and dependent-required entries. Panics if the
/// target is not an object or has no such key.
///
/// - schema (dictionary): The schema to edit.
/// - at (dictionary, array): The object: a lens or a path array.
/// - key (str): The field to remove.
/// -> dictionary
#let remove-field(schema, at, key) = _edit-object(
  schema,
  at,
  "remove-field",
  parent => {
    if key not in parent.shape {
      _bail("remove-field", _not-in(
        "key " + repr(key),
        "object shape",
        "Valid keys",
        parent.shape.keys(),
      ))
    }
    let shape = parent.shape
    let _ = shape.remove(key)
    // Like required-keys, drop `key` from every dependency: its own
    // trigger entry and its place in other triggers' lists. A trigger
    // left with no dependents goes too, and object() drops an empty map.
    let dependent = (:)
    for (trigger, dependents) in parent.at("dependent-required", default: (:)) {
      let kept = dependents.filter(d => d != key)
      if trigger != key and kept.len() > 0 {
        dependent.insert(trigger, kept)
      }
    }
    (
      shape: shape,
      required-keys: parent.required-keys.filter(k => k != key),
      dependent-required: dependent,
    )
  },
)
