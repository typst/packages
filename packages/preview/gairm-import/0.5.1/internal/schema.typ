// Canonical JSON Resume schema (https://jsonresume.org/schema).
// `resume-schema` is a faithful derivation of the upstream document;
// `resume-schema-strict` layers content + date opinions via lens.
// See README "Two schemas" for the trade-off.

#import "kinds.typ": (
  str-type, content-type, number-type, array-of, object,
  date-string, uri-string, email-string,
  enum-of, const-of,
)
#import "json-schema.typ": schema-from-json-schema
#import "lens.typ": lens, lens-get, lens-put

#let resume-schema = schema-from-json-schema(json("assets/jsonresume-schema.json"))

// Free-text fields wrapped as Typst `content` in the strict variant.
// Renderer ergonomics, not validation.
#let _content-paths = (
  ("basics", "summary"),
  ("work", "items", "summary"),
  ("work", "items", "highlights", "items"),
  ("volunteer", "items", "summary"),
  ("volunteer", "items", "highlights", "items"),
  ("awards", "items", "summary"),
  ("publications", "items", "summary"),
  ("references", "items", "reference"),
  ("projects", "items", "description"),
  ("projects", "items", "highlights", "items"),
)

// iso8601 `$ref` fields (translator can't pick formats up from a $ref
// alone) plus meta.lastModified (no format annotation in upstream).
#let _date-paths = (
  ("work", "items", "startDate"),
  ("work", "items", "endDate"),
  ("volunteer", "items", "startDate"),
  ("volunteer", "items", "endDate"),
  ("education", "items", "startDate"),
  ("education", "items", "endDate"),
  ("awards", "items", "date"),
  ("publications", "items", "releaseDate"),
  ("projects", "items", "startDate"),
  ("projects", "items", "endDate"),
  ("meta", "lastModified"),
)

// Pre-condition guard turns silent upstream drift into a load-time
// panic — an override that ran unconditionally would mask the shape
// change instead of surfacing it.
#let _override-fold(schema, paths, expected-source, replacement, list-name) = {
  paths.fold(schema, (s, p) => {
    let l = lens(p)
    let current = lens-get(l, s)
    assert(
      current == expected-source,
      message: "gairm-import: " + list-name + " must target " +
        repr(expected-source.kind) + " leaves only — " + repr(p) +
        " is now " + repr(current.kind) + ". Audit upstream schema bump.",
    )
    lens-put(l, s, replacement)
  })
}

#let resume-schema-strict = {
  let with-content = _override-fold(
    resume-schema, _content-paths, str-type, content-type, "_content-paths",
  )
  _override-fold(
    with-content, _date-paths, str-type, date-string, "_date-paths",
  )
}
