// Canonical JSON Resume schema (https://jsonresume.org/schema).
// Derived from the vendored upstream document; see CONTRIBUTING for
// the bump procedure.
//
// `_content-paths` is the deliberate divergence from the source: the
// canonical schema types these free-text fields as `string`, but the
// package wraps them in Typst `content` during coercion for ergonomic
// inline rendering. Open question tracked in #32 — either the
// override earns its keep or it moves to config / disappears.

#import "kinds.typ": str-type, content-type, number-type, array-of, object
#import "json-schema.typ": schema-from-json-schema
#import "lens.typ": lens, lens-get, lens-put

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

// The pre-condition `lens-get == str-type` turns silent drift into a
// load-time panic: if a future schema bump changes one of these
// fields away from `string`, the override would otherwise mask the
// shape change. The guard fires instead, prompting maintainer review.
#let resume-schema = _content-paths.fold(
  schema-from-json-schema(json("assets/jsonresume-schema.json")),
  (s, p) => {
    let l = lens(p)
    assert(
      lens-get(l, s) == str-type,
      message: "json-resume: _content-paths must target string leaves only — " +
        repr(p) + " is now " + repr(lens-get(l, s).kind) +
        ". Audit upstream schema bump.",
    )
    lens-put(l, s, content-type)
  },
)
