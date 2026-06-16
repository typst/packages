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

#let _expect(expected, value) = (
  "gairm-import: coerce expected " + expected + ", got " +
    _type-name-of(value) + ". Run validate(data) first."
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
  if kind in ("str", "date-string", "uri-string", "email-string") {
    assert(type(value) == str, message: _expect("a string", value))
    return value
  }
  if kind == "number" {
    assert(type(value) in (int, float), message: _expect("a number", value))
    return value
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
    let coerced = value.pairs()
      .filter(((key, _)) => key in schema.shape)
      .map(((key, sub-value)) => (key, _coerce(schema.shape.at(key), sub-value)))
      .filter(((_, coerced)) => coerced != none)
      .to-dict()
    if coerced.len() == 0 { return none }
    return coerced
  }
  panic("gairm-import: internal — unknown schema kind " + repr(kind))
}
