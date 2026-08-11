// Lens-style schema editing.
//
// Top-level lens-* functions rather than methods on a lens record:
// Typst parses `dict.field(args)` as a type-method lookup, not a call
// of the closure stored under that key, so methods would force
// `(lens.put)(args)` at every call site.
//
// Path segments match the JSON Schema keyword name (not the engine
// field name) so a lens path reads as a JSON Schema location:
//   - object   : string key into `.shape`
//   - object   : literal "additionalProperties" to enter `.additional`
//                (only when set to a schema dict, not `true`)
//   - array    : literal "items" to enter `.elem`
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
// `lens-put` writes the replacement value verbatim — it doesn't
// validate that the value is a well-formed schema dict at any
// segment. Use the public `object` / `array-of` / kind constructors
// to build the replacement.

#let _bail(msg) = panic("gairm-import: " + msg)

#let _require-object(parent, op) = {
  if parent.kind != "object" {
    _bail(
      op + " expects an object schema at the lens target, got kind=" +
        repr(parent.kind) + ".",
    )
  }
}

// Typst dicts are value types — `let new-shape = parent.shape` copies,
// and `.insert` mutates the local without touching parent.
#let _with-shape-set(parent, key, value) = {
  let new-shape = parent.shape
  new-shape.insert(key, value)
  (..parent, shape: new-shape)
}

#let _descend(schema, segment) = {
  if schema.kind == "object" {
    // Shape lookup wins so a literal property named
    // "additionalProperties" stays addressable.
    if segment in schema.shape {
      return schema.shape.at(segment)
    }
    if segment == "additionalProperties" {
      let additional = schema.at("additional", default: none)
      if type(additional) != dictionary {
        _bail(
          "lens segment \"additionalProperties\" requires the object's " +
            "`additional` field to be a schema dict, got: " + repr(additional) + ".",
        )
      }
      return additional
    }
    _bail(
      "lens path segment " + repr(segment) + " not in object shape. " +
        "Valid keys: " + schema.shape.keys().join(", ") + ".",
    )
  }
  if schema.kind == "array" {
    if segment != "items" {
      _bail(
        "lens segment for an array schema must be \"items\", got " +
          repr(segment) + ".",
      )
    }
    return schema.elem
  }
  _bail(
    "lens cannot descend into a leaf schema (kind=" + repr(schema.kind) +
      ") with segment " + repr(segment) + ".",
  )
}

#let _get-at(schema, path) = {
  let cursor = schema
  for segment in path { cursor = _descend(cursor, segment) }
  cursor
}

// _descend runs in both branches so an invalid segment surfaces the
// same diagnostic from get and from put.
#let _set-at(schema, path, value) = {
  if path.len() == 0 { return value }
  let (head, ..rest) = path
  let new-sub = _set-at(_descend(schema, head), rest, value)
  // Mirror _descend's shape-first precedence so a literal property
  // named "additionalProperties" rewrites the shape entry, not the
  // additional schema. _descend already bailed on any other invalid
  // object segment, so the additionalProperties branch is the only
  // remaining object case.
  if schema.kind == "object" and head in schema.shape {
    _with-shape-set(schema, head, new-sub)
  } else if schema.kind == "object" {
    (..schema, additional: new-sub)
  } else {
    (..schema, elem: new-sub)
  }
}

#let lens(path) = (kind: "lens", path: path)

#let lens-get(l, schema) = _get-at(schema, l.path)

// `put` because `set` is a Typst keyword.
#let lens-put(l, schema, value) = _set-at(schema, l.path, value)

#let lens-over(l, schema, fn) = _set-at(schema, l.path, fn(_get-at(schema, l.path)))

// `lens-then(a, b)` applies a then b — paths concatenate in that order.
#let lens-then(a, b) = lens(a.path + b.path)

// Collisions panic instead of overwriting silently — for the
// overwrite-an-existing-key case, callers can reach for lens-put / lens-over.
#let add-field(schema, parent-lens, key, sub-schema) = lens-over(
  parent-lens,
  schema,
  parent => {
    _require-object(parent, "add-field")
    if key in parent.shape {
      _bail(
        "add-field key " + repr(key) + " already in object shape. " +
          "Use lens-put / lens-over to replace an existing field.",
      )
    }
    _with-shape-set(parent, key, sub-schema)
  },
)

// Replace, not merge — mirrors lens-put. Keys must exist in shape
// so a typo fails at edit time, not as a phantom "missing X" error.
#let set-required(schema, parent-lens, keys) = lens-over(
  parent-lens,
  schema,
  parent => {
    _require-object(parent, "set-required")
    let unknown = keys.filter(k => k not in parent.shape)
    if unknown.len() > 0 {
      _bail(
        "set-required keys not in object shape: " + unknown.join(", ") +
          ". Valid keys: " + parent.shape.keys().join(", ") + ".",
      )
    }
    (..parent, required-keys: keys)
  },
)

// Symmetric to set-required — relax specific keys without re-listing.
// Absent-key panics so a stale "still required" assumption surfaces.
#let unset-required(schema, parent-lens, keys) = lens-over(
  parent-lens,
  schema,
  parent => {
    _require-object(parent, "unset-required")
    let absent = keys.filter(k => k not in parent.required-keys)
    if absent.len() > 0 {
      _bail(
        "unset-required keys not in required-keys: " + absent.join(", ") +
          ". Current required: " + parent.required-keys.join(", ") + ".",
      )
    }
    (..parent, required-keys: parent.required-keys.filter(k => k not in keys))
  },
)

// Absent-key panics rather than being a silent no-op so caller typos surface.
#let remove-field(schema, parent-lens, key) = lens-over(
  parent-lens,
  schema,
  parent => {
    _require-object(parent, "remove-field")
    if key not in parent.shape {
      _bail(
        "remove-field key " + repr(key) + " not in object shape. " +
          "Valid keys: " + parent.shape.keys().join(", ") + ".",
      )
    }
    let new-shape = parent.shape
    let _ = new-shape.remove(key)
    let new-required = parent.required-keys.filter(k => k != key)
    (..parent, shape: new-shape, required-keys: new-required)
  },
)
