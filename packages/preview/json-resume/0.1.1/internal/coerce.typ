// Assumes input has passed _validate. Unknown keys are dropped
// silently rather than panicking; top-of-branch type checks catch
// shape mismatches from direct callers who skipped validation.
// assert(false, ...) over panic(...) for newline-preserving
// diagnostics if these messages ever go multi-line.

#import "errors.typ": _type-name-of

#let _expect(expected, value) = (
  "json-resume: coerce-resume expected " + expected + ", got " +
    _type-name-of(value) + ". Run validate-resume first."
)

#let _coerce(schema, value) = {
  let kind = schema.kind
  if kind == "content" {
    assert(type(value) == str, message: _expect("a string", value))
    return [#value]
  }
  if kind == "str" {
    assert(type(value) == str, message: _expect("a string", value))
    return value
  }
  if kind == "number" {
    assert(type(value) in (int, float), message: _expect("a number", value))
    return value
  }
  if kind == "array" {
    assert(type(value) == array, message: _expect("an array", value))
    return value.map(elem => _coerce(schema.elem, elem))
  }
  if kind == "object" {
    assert(type(value) == dictionary, message: _expect("an object", value))
    return value.pairs()
      .filter(((key, _)) => key in schema.shape)
      .map(((key, sub-value)) => (key, _coerce(schema.shape.at(key), sub-value)))
      .to-dict()
  }
  panic("json-resume: internal — unknown schema kind " + repr(kind))
}
