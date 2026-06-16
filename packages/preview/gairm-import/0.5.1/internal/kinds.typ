// Schema-kind constants and constructors. Lives in its own module
// because schema.typ depends on json-schema.typ (for derivation) and
// json-schema.typ depends on these primitives — extracting them here
// breaks the cycle.

#let str-type     = (kind: "str")
#let content-type = (kind: "content")
#let number-type  = (kind: "number")

// Format-specialised string kinds — regex-gated in _validate;
// deliberately permissive (reject obvious malformations, not full RFC).
#let date-string  = (kind: "date-string")
#let uri-string   = (kind: "uri-string")
#let email-string = (kind: "email-string")

#let array-of(elem) = (kind: "array", elem: elem)

// Mixed-type members allowed — the validator's `in` check gates on
// equality, not type. `const` is a singleton enum.
#let enum-of(values) = (kind: "enum", values: values)
#let const-of(value) = enum-of((value,))

// Reject required-keys that don't appear in shape so a schema typo
// fails at construction time, not as a phantom validation error.
#let object(shape, required-keys: ()) = {
  let unknown = required-keys.filter(k => k not in shape)
  assert(
    unknown.len() == 0,
    message: "gairm-import: object() required-keys references keys not in shape: " +
      unknown.join(", ") + ".",
  )
  (
    kind: "object",
    shape: shape,
    required-keys: required-keys,
  )
}
