// The run functions: validate, coerce and parse, which walk a value
// against a schema once (engine.typ) and differ only in what they make
// of the result, and format-errors, which words validate's records as
// parse's report. lib.typ re-exports them by name, so it holds no
// definitions and leaks no internal module into a `*` import.
//
// Each takes the schema, then the data: both required, so both
// positional, with the options named, as in Typst's own functions.

#import "core/ctx.typ": _ctx
#import "core/error.typ": _bail, _fail, _problem, _require-bool, _format-report
#import "core/input.typ": _decode-input, _refuse-path
#import "kinds/structure.typ": _has-kind, _require-schema
#import "engine.typ": _walk, _coerce-result, _parse-result

// A run function's checked arguments, as the (value, ctx) its walk
// takes. It returns before the walk, and each run function calls _walk
// itself, so this helper adds no frame under the walk: Typst caps the
// call depth, and every frame costs a level of document nesting.
#let _prepare(fn-name, schema, data, strict-null) = {
  if not _has-kind(schema) and _has-kind(data) {
    _bail(
      fn-name,
      "takes the schema first, then the data: " + fn-name + "(schema, data).",
    )
  }
  _require-schema(schema, fn-name + " schema")
  _require-bool(strict-null, fn-name, "strict-null")
  (
    value: _decode-input(fn-name, data, str-is-data: true),
    ctx: _ctx(strict-null: strict-null),
  )
}

/// Checks `data` against `schema` and returns every problem found, as
/// `(path, code, message, expected, got)` records; REFERENCE.md lists
/// the codes. An empty array means the data is valid.
///
/// - schema (dictionary): The schema to check against.
/// - data (any): The document, or where to read it: a `path` or bytes
///   is read as JSON, and a `path` resolves from your file. Any other
///   value is the document itself, whatever root the schema takes. Null
///   panics, and so does a `.json` filename or JSON text the schema's
///   root does not take: use `path(..)` to read a file.
/// - strict-null (bool): Off, JSON `null` counts as an absent key. On,
///   `null` is a value its schema judges: `null()`, `nullable(..)`,
///   `unknown()` and an `enum-of(..)` or `const-of(..)` that lists
///   `none` accept it, as can a `not-of(..)`, or an `if-of(..)` without
///   the branch it picks; the rest reject it. A `null` document panics
///   either way.
/// -> array
#let validate(schema, data, strict-null: false) = {
  let (value, ctx) = _prepare("validate", schema, data, strict-null)
  let r = _walk(schema, value, ctx)
  _refuse-path("validate", data, r)
  r.errors
}

/// Turns `data` into the typed model without checking it first, so run
/// `validate` before it. Keys the schema does not declare are dropped,
/// unless the object allows extras. Null values are dropped as absent
/// keys (unless `strict-null`); an object left with no keys stays an
/// empty dictionary. Panics only where the data leaves no model at all.
///
/// - schema (dictionary): The schema that says what each field becomes.
/// - data (any): The document, or where to read it, as for `validate`.
/// - strict-null (bool): Off, JSON `null` counts as an absent key. On,
///   `null` is a value its schema judges: `null()`, `nullable(..)`,
///   `unknown()` and an `enum-of(..)` or `const-of(..)` that lists
///   `none` accept it, as can a `not-of(..)`, or an `if-of(..)` without
///   the branch it picks; the rest reject it. A `null` document panics
///   either way.
/// -> any
#let coerce(schema, data, strict-null: false) = {
  let (value, ctx) = _prepare("coerce", schema, data, strict-null)
  let r = _walk(schema, value, ctx)
  _refuse-path("coerce", data, r)
  _coerce-result(r)
}

/// Validates `data` against `schema`, then coerces it into the typed
/// model. Panics with every problem found, so one compile shows them
/// all. `parse.with(schema)` is a parser for one schema.
///
/// - schema (dictionary): The schema to check against.
/// - data (any): The document, or where to read it, as for `validate`:
///   the root may be anything the schema takes, an array or a scalar
///   included.
/// - strict-null (bool): Off, JSON `null` counts as an absent key. On,
///   `null` is a value its schema judges: `null()`, `nullable(..)`,
///   `unknown()` and an `enum-of(..)` or `const-of(..)` that lists
///   `none` accept it, as can a `not-of(..)`, or an `if-of(..)` without
///   the branch it picks; the rest reject it. A `null` document panics
///   either way.
/// -> any
#let parse(schema, data, strict-null: false) = {
  let (value, ctx) = _prepare("parse", schema, data, strict-null)
  let r = _walk(schema, value, ctx)
  _refuse-path("parse", data, r)
  _parse-result(r)
}

/// Turns a list of validation errors, as `validate` returns them, into
/// the combined report `parse` panics with. Use it when you handle the
/// errors yourself. Reads only each record's `path` and `message`.
///
/// - errors (array): Records with at least `path` and `message`.
/// -> str
#let format-errors(errors) = {
  let ok = (
    type(errors) == array
      and errors.all(e => (
        type(e) == dictionary
          and type(e.at("path", default: none)) == array
          and e.path.all(seg => type(seg) in (str, int))
          and type(e.at("message", default: none)) == str
      ))
  )
  if not ok {
    _fail("format-errors", _problem(
      "errors",
      "an array of error records, as validate returns them",
      repr(errors),
    ))
  }
  _format-report(errors)
}
