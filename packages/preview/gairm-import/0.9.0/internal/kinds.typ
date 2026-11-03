// Schema-kind constants and constructors. Lives in its own module
// because schema.typ depends on json-schema.typ (for derivation) and
// json-schema.typ depends on these primitives — extracting them here
// breaks the cycle.

#let str-type = (kind: "str")
#let content-type = (kind: "content")
#let number-type = (kind: "number")
#let bool-type = (kind: "bool")

// JSON Schema `integer`: any number with a zero fractional part
// (draft-7 semantics — 1.0 passes, 1.5 fails). Same "number" kind with
// a validation flag rather than a new kind, so coerce / introspect /
// lens need no extra branch.
#let integer-type = (kind: "number", integer: true)

// "Must be null or absent": `none` passes via the engine's global
// early return, non-none hits the kind branch and errors.
#let null-type = (kind: "null")

// Format-specialised string kinds — regex-gated in _validate;
// deliberately permissive (reject obvious malformations, not full RFC).
#let date-string = (kind: "date-string")
#let datetime-string = (kind: "datetime-string")
#let uri-string = (kind: "uri-string")
#let email-string = (kind: "email-string")

// The format-gated kinds above as one list — validate.typ owns their
// regex table (keyed by these names, drift-guarded at load), coerce.typ
// passes them through as plain strings, introspect.typ lists them as
// leaf kinds. One list so adding a format kind is this line plus a
// regex, instead of three hand-synced module-local lists.
#let _format-string-kinds = (
  "date-string",
  "datetime-string",
  "uri-string",
  "email-string",
)

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

// Bad-shape members fail at construction, not as a phantom validation
// error — same contract as object() below.
#let _require-members(fn-name, members) = {
  let ok = (
    type(members) == array
      and members.len() > 0
      and members.all(m => type(m) == dictionary and "kind" in m)
  )
  assert(
    ok,
    message: "gairm-import: "
      + fn-name
      + " members must be a non-empty array of schema dicts (each with a `kind` field); got: "
      + repr(members)
      + ".",
  )
}

// JSON Schema anyOf / oneOf. Both share the union kind; `exclusive`
// distinguishes "at least one member matches" (any-of) from "exactly
// one" (one-of). Match counting lives in _validate; coerce delegates
// to the first matching member.
#let any-of(members) = {
  _require-members("any-of()", members)
  (kind: "union", members: members, exclusive: false)
}
#let one-of(members) = {
  _require-members("one-of()", members)
  (kind: "union", members: members, exclusive: true)
}

// JSON Schema `not` — the value must NOT match the negated schema.
// Named not-of because `not` is a Typst keyword.
#let not-of(member) = {
  assert(
    type(member) == dictionary and "kind" in member,
    message: "gairm-import: not-of member must be a schema dict (with a `kind` field); got: "
      + repr(member)
      + ".",
  )
  (kind: "not", member: member)
}

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
    message: "gairm-import: object() additional must be none, false, true, or a schema dict (with a `kind` field); got: "
      + repr(additional)
      + ".",
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
    message: "gairm-import: object() required-keys references keys not in shape: "
      + unknown.join(", ")
      + ".",
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
