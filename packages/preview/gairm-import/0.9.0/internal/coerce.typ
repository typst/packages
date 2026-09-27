// Assumes input has passed _validate. Unknown keys are dropped
// silently rather than panicking; top-of-branch type checks catch
// shape mismatches from direct callers who skipped validation.
// assert(false, ...) over panic(...) for newline-preserving
// diagnostics if these messages ever go multi-line.
//
// JSON `null` (Typst's `none`) at a value position is treated as if
// the key were absent: it returns `none` from the per-value call so
// the parent's object-pair filter or array-element filter drops it.
// Downstream renderers see "key not in dict" instead of a stray
// `none` value to special-case.
//
// An object whose every key coerced to none is itself coerced to
// `none` (rather than an empty dict). That propagates "every key was
// null" upward so the parent filter drops the object too — symmetric
// with the leaf-null policy. Applied recursively, a resume whose only
// section is itself all-null collapses all the way to `none` — the
// consistent extension of the policy. Public callers go through the
// lib.typ wrappers, which reject a null root explicitly so this
// collapse never surprises a direct user of the engine.

#import "errors.typ": _type-name-of
#import "kinds.typ": _format-string-kinds
// Union coercion must pick a member, and Typst has no try/catch to
// probe with — so coerce leans on the validator's verdict. Acyclic:
// validate.typ does not import coerce.
#import "validate.typ": _validate

#let _expect(expected, value) = (
  "gairm-import: coerce expected "
    + expected
    + ", got "
    + _type-name-of(value)
    + ". Run validate(data) first."
)

#let _coerce(schema, value) = {
  // Null at any value position is "key absent". The parent (object
  // or array branch below) is responsible for filtering this out.
  if value == none { return none }
  let kind = schema.kind
  if kind == "content" {
    assert(type(value) == str, message: _expect("a string", value))
    return [#value]
  }
  // Format-specialised string kinds pass through identically to `str`
  // — the regex gate fires in _validate, not here.
  if kind == "str" or kind == "pattern-string" or kind in _format-string-kinds {
    assert(type(value) == str, message: _expect("a string", value))
    return value
  }
  if kind == "number" {
    assert(type(value) in (int, float), message: _expect("a number", value))
    return value
  }
  if kind == "bool" {
    assert(type(value) == bool, message: _expect("a boolean", value))
    return value
  }
  // Unreachable on validated input — top early return handles `none`,
  // the only legal value.
  if kind == "null" {
    assert(false, message: _expect("null", value))
  }
  // Members are polymorphic — no single type to assert. Mirror the
  // validator's membership check so direct-coerce callers fail loud.
  if kind == "enum" {
    assert(
      value in schema.values,
      message: _expect(
        "one of " + schema.values.map(repr).join(", "),
        value,
      ),
    )
    return value
  }
  if kind == "array" {
    assert(type(value) == array, message: _expect("an array", value))
    // Drop null elements: a null in an array of strings would
    // otherwise surface as a stray `none` to downstream renderers.
    return value.map(elem => _coerce(schema.elem, elem)).filter(e => e != none)
  }
  if kind == "object" {
    assert(type(value) == dictionary, message: _expect("an object", value))
    let additional = schema.at("additional", default: none)
    let coerced = value
      .pairs()
      .filter(((key, _)) => key in schema.shape or additional != none)
      .map(((key, sub-value)) => {
        let sub = if key in schema.shape {
          _coerce(schema.shape.at(key), sub-value)
        } else if additional == true {
          // `additionalProperties: true` — pass through; validate.typ
          // mirrors this by returning `()` (no validation).
          sub-value
        } else {
          _coerce(additional, sub-value)
        }
        (key, sub)
      })
      .filter(((_, coerced)) => coerced != none)
      .to-dict()
    if coerced.len() == 0 { return none }
    return coerced
  }
  // Union: delegate to the first member the value validates against.
  // For one-of, validation already guaranteed exactly one; direct
  // callers who skipped validation fail the assert like every other
  // branch.
  if kind == "union" {
    let matching = schema.members.find(m => _validate(m, value, ()).len() == 0)
    assert(
      matching != none,
      message: _expect("a value matching one of the union alternatives", value),
    )
    return _coerce(matching, value)
  }
  // `not` constrains what a value may NOT be — there is no shape to
  // coerce toward, so pass through verbatim (same contract as
  // `additional: true` extras).
  if kind == "not" { return value }
  panic("gairm-import: internal — unknown schema kind " + repr(kind))
}
