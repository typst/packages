// Strict loader for canonical JSON Resume data
// (https://jsonresume.org/schema). The engines under internal/ are
// pure functions of (schema, value); see
// tests/engine-schema-agnostic.typ for the BYO-schema contract.

#import "internal/kinds.typ": (
  str-type, content-type, number-type, integer-type, bool-type, null-type,
  array-of, object, map, date-string, datetime-string, uri-string, email-string,
  pattern-string, enum-of, const-of, any-of, one-of, not-of,
)
#import "internal/schema.typ": resume-schema, resume-schema-strict
#import "internal/validate.typ": _validate
#import "internal/coerce.typ": _coerce
#import "internal/errors.typ": _format-report
#import "internal/json-schema.typ": schema-from-json-schema
#import "internal/lens.typ": (
  lens, lens-get, lens-put, lens-over, lens-then, add-field, remove-field,
  set-required, unset-required,
)
#import "internal/introspect.typ": describe-schema, paths-of-kind, kind-at
#import "internal/json-pointer.typ": path-to-pointer, pointer-to-path

// Engines treat `none` at any value position as "key absent" — right
// for leaves inside a document, but a null root is always invalid
// (no schema can validate "missing document"). One source of truth
// for the message so docs and tests have something stable to pin.
#let _reject-none-root(data) = {
  if data == none { panic("gairm-import: input must be a dict, got null.") }
}

// Combined-report formatter, for callers handling errors themselves
// instead of letting `parse` abort.
#let format-errors(errors) = _format-report(errors)

#let validate(data, schema: resume-schema) = {
  _reject-none-root(data)
  _validate(schema, data, ())
}

// Unknown keys are dropped silently rather than panicking, so direct
// callers who skip validation don't get a Typst dictionary-access
// panic.
#let coerce(data, schema: resume-schema) = {
  _reject-none-root(data)
  _coerce(schema, data)
}

// `path("…")` resolves against the caller's .typ rather than the
// @preview cache where this file lives — that's the headline form.
// The "/…" string and pre-parsed dict are also accepted.
#let parse(data, schema: resume-schema) = {
  _reject-none-root(data)
  let dict-data = if type(data) == path {
    json(data)
  } else if type(data) == str {
    if not data.starts-with("/") {
      panic(
        "gairm-import: parse with a string path requires the path "
          + "to start with \"/\" (resolved from the typst root). Got: "
          + repr(data)
          + ". "
          + "For paths relative to your own .typ file, pass "
          + "path("
          + repr(data)
          + ") (or json("
          + repr(data)
          + ")) in place of the path string.",
      )
    }
    json(data)
  } else if type(data) == dictionary {
    data
  } else {
    panic(
      "gairm-import: parse expected a dict, a path, or a string path, got "
        + repr(type(data))
        + ".",
    )
  }
  let errors = _validate(schema, dict-data, ())
  // assert preserves newlines in the diagnostic; panic repr-escapes
  // them and collapses the bullet list onto one line.
  assert(errors.len() == 0, message: format-errors(errors))
  _coerce(schema, dict-data)
}
