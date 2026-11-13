// JSON Resume import: the strict JSON Resume 1.7.0 schema, whose
// `custom` objects carry altacv's extensions (`custom.altacv`), plus
// the deprecated forms of three of them as optional fields, so a
// `resume.json` still using them validates (`_canonical-cv` lifts them
// into `custom.altacv`) until #239 removes them. `alta-from-json`
// lives in `render.typ`, as it composes `alta`.

#import "@preview/gairm-import:0.10.1": (
  add-field, array-of, content-type, lens, number-type, parse as _parse,
  resume-schema-strict, str-type,
)

#let _altacv-schema = {
  let s = resume-schema-strict
  s = add-field(s, lens(()), "focusAreas", array-of(content-type))
  s = add-field(s, lens(("languages", "items")), "rating", number-type)
  s = add-field(s, lens(("awards", "items")), "url", str-type)
  s
}

/// Validates a `resume.json` against the JSON Resume schema (plus
/// altacv's extensions) and returns the CV dictionary `alta` takes.
/// Panics on an invalid document, naming the field. Deprecated (#239):
/// gairm-import's `parse`, `#import "@preview/gairm-import:0.10.1": parse`.
///
/// - data (path, dictionary): The `resume.json`, as
///   `path("resume.json")`, or an already-decoded dictionary.
/// -> dictionary
#let from-json-resume(data) = _parse(data, schema: _altacv-schema)
