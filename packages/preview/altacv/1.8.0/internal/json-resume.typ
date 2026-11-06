// JSON Resume import: the strict schema plus altacv's extensions,
// added as optional fields so a canonical `resume.json` still
// validates. `alta-from-json` lives in `lib.typ` as it composes `alta`.

#import "@preview/gairm-import:0.9.0": (
  add-field, array-of, content-type, lens, number-type, parse as _parse,
  resume-schema-strict, str-type,
)

#let altacv-schema = {
  let s = resume-schema-strict
  s = add-field(s, lens(()), "focusAreas", array-of(content-type))
  s = add-field(s, lens(("languages", "items")), "rating", number-type)
  s = add-field(s, lens(("publications", "items")), "type", str-type)
  s
}

#let from-json-resume(data) = _parse(data, schema: altacv-schema)
