// Adds altacv's three extensions via `add-field` (not `set-required`),
// so a canonical `resume.json` without them still validates. Re-exported
// from `lib.typ`; the one-call `alta-from-json` lives there since it
// composes `alta`.

#import "@preview/gairm-import:0.8.1": (
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
