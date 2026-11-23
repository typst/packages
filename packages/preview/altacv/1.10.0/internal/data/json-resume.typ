// JSON Resume import: gairm-import's `parse` with the vendored JSON
// Resume 1.7.0 schema. `alta()` checks altacv's extensions.

/// Validates a `resume.json` against the JSON Resume schema and returns
/// the CV dictionary `alta` takes. Deprecated (#239): gairm-import's
/// `parse`, as the README's "A `resume.json`" shows.
///
/// - data (path, dictionary): The `resume.json`, as
///   `path("resume.json")`, or an already-decoded dictionary.
/// -> dictionary
#let from-json-resume(data) = {
  // Here, so only a JSON import loads gairm-import.
  import "@preview/gairm-import:1.0.0": parse, schema-from-json-schema
  parse(schema-from-json-schema(json("/template/resume.schema.json")), data)
}
