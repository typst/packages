// Schema-kind constants and constructors. Lives in its own module
// because schema.typ depends on json-schema.typ (for derivation) and
// json-schema.typ depends on these primitives — extracting them here
// breaks the cycle.

#let str-type     = (kind: "str")
#let content-type = (kind: "content")
#let number-type  = (kind: "number")
#let bool-type    = (kind: "bool")

// "Must be null or absent": `none` passes via the engine's global
// early return, non-none hits the kind branch and errors.
#let null-type    = (kind: "null")

// Format-specialised string kinds — regex-gated in _validate;
// deliberately permissive (reject obvious malformations, not full RFC).
#let date-string     = (kind: "date-string")
#let datetime-string = (kind: "datetime-string")
#let uri-string      = (kind: "uri-string")
#let email-string    = (kind: "email-string")

// Per-instance regex gate — a constructor, not a constant, because
// each schema node carries its own regex and hint.
#let pattern-string(re, expected: "matching pattern") = (
  kind: "pattern-string",
  pattern: regex(re),
  expected: expected,
)

#let array-of(elem) = (kind: "array", elem: elem)

// Mixed-type members allowed — the validator's `in` check gates on
// equality, not type. `const` is a singleton enum.
#let enum-of(values) = (kind: "enum", values: values)
#let const-of(value) = enum-of((value,))

// `additional` controls keys not in `shape` (the engine-side name for
// JSON Schema's `additionalProperties`): `none` / `false` → reject;
// `true` → pass-through; schema dict → validate every extra against
// it. `false` is accepted as a synonym for `none` so callers fluent
// in JSON Schema can pass either. Bad-shape `additional` and
// required-keys-not-covered both fail at construction, not as a
// phantom validation error.
#let object(shape, required-keys: (), additional: none) = {
  // false ≡ none in our model; normalise so the constructor and the
  // translator agree on what they accept.
  let normalized = if additional == false { none } else { additional }
  let additional-ok = (
    normalized == none
      or normalized == true
      or (type(normalized) == dictionary and "kind" in normalized)
  )
  assert(
    additional-ok,
    message: "gairm-import: object() additional must be none, false, true, or a schema dict (with a `kind` field); got: " +
      repr(additional) + ".",
  )
  // With `additional`, undeclared required keys are covered by the
  // additional schema, so the subset check only applies when strict.
  let unknown = if normalized == none {
    required-keys.filter(k => k not in shape)
  } else {
    ()
  }
  assert(
    unknown.len() == 0,
    message: "gairm-import: object() required-keys references keys not in shape: " +
      unknown.join(", ") + ".",
  )
  let base = (
    kind: "object",
    shape: shape,
    required-keys: required-keys,
  )
  // Omitted when `none` so existing strict dicts keep their shape.
  if normalized == none { base } else { (..base, additional: normalized) }
}

// `required-keys` kwarg for symmetry with `object` — required keys
// on a pure map are still meaningful ("the document must contain
// these specific keys, plus any number of others").
#let map(value-schema, required-keys: ()) = object(
  (:),
  required-keys: required-keys,
  additional: value-schema,
)
