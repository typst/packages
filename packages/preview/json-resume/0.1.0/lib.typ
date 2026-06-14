// Strict loader for canonical JSON Resume data
// (https://jsonresume.org/schema). The engines under internal/ are
// pure (schema, value) functions; the public symbols below pre-bind
// resume-schema. See tests/engine_schema_agnostic.typ.

#import "internal/schema.typ": resume-schema
#import "internal/validate.typ": _validate
#import "internal/coerce.typ": _coerce
#import "internal/errors.typ": _format-report

// Returns a list of {path, message} records; empty = valid.
#let validate-resume(data) = _validate(resume-schema, data, ())

// Assumes data has passed validate-resume. Unknown keys are dropped
// silently rather than panicking on direct callers.
#let coerce-resume(data) = _coerce(resume-schema, data)

// String paths must start with "/" because Typst resolves relative
// paths against the file containing the call — for this package
// that's the @preview cache, which is not what callers want.
#let parse-resume(data) = {
  let dict-data = if type(data) == str {
    if not data.starts-with("/") {
      panic(
        "json-resume: parse-resume with a string path requires the path " +
          "to start with \"/\" (resolved from the typst root). Got: " + repr(data) + ". " +
          "To use a path relative to your own .typ file, call json() " +
          "directly: parse-resume(json(" + repr(data) + ")).",
      )
    }
    json(data)
  } else if type(data) == dictionary {
    data
  } else {
    panic(
      "json-resume: parse-resume expected a dict or a string path, got " +
        repr(type(data)) + ".",
    )
  }
  let errors = validate-resume(dict-data)
  // assert preserves newlines in the diagnostic; panic repr-escapes
  // them and collapses the bullet list onto one line.
  assert(errors.len() == 0, message: _format-report(errors))
  coerce-resume(dict-data)
}
