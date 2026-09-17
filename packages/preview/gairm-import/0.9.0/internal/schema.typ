// Canonical JSON Resume schema (https://jsonresume.org/schema).
// `resume-schema` is a faithful derivation of the upstream document;
// `resume-schema-strict` layers content + date opinions via lens.
// See README "Two schemas" for the trade-off.

// Only the kinds this module itself uses — the full combinator surface
// is re-exported to callers by lib.typ directly from kinds.typ.
#import "kinds.typ": str-type, content-type, date-string, pattern-string, object
#import "json-schema.typ": schema-from-json-schema
#import "lens.typ": lens, lens-get, lens-put

#let resume-schema = schema-from-json-schema(
  json("assets/jsonresume-schema.json"),
)

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

// iso8601 `$ref` fields. The upstream definition is a string with a
// `pattern`, so the translator emits the iso8601 pattern-string for
// these — the strict variant tightens that to date-string (rejects
// month 00 / 13+, day 00 / 32+).
#let _iso8601-date-paths = (
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
)

// `meta.lastModified` carries only a description in upstream — no
// machine-readable pattern — so it lands as plain `str-type` in the
// faithful schema. Strict still lifts it to date-string.
#let _plain-date-paths = (
  ("meta", "lastModified"),
)

// Source shape the translator emits for iso8601 $ref fields. The
// pattern is hand-mirrored from upstream's `definitions/iso8601` so a
// schema bump that retires or alters it surfaces as an override-fold
// guard panic at load time, not as silent semantic drift.
#let _iso8601-pattern = "^([1-2][0-9]{3}-[0-1][0-9]-[0-3][0-9]|[1-2][0-9]{3}-[0-1][0-9]|[1-2][0-9]{3})$"
#let _iso8601-source = pattern-string(
  _iso8601-pattern,
  expected: "matching " + repr(_iso8601-pattern),
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
      message: "gairm-import: "
        + list-name
        + " must target "
        + repr(expected-source.kind)
        + " leaves only — "
        + repr(p)
        + " is now "
        + repr(current.kind)
        + ". Audit upstream schema bump.",
    )
    lens-put(l, s, replacement)
  })
}

// Strip `additional: true` (the JSON Resume upstream's permissive
// "extras allowed" on every section's items) recursively. Typed
// extras (`additional: <schema>`) are kept and recursed into; only
// the unchecked-pass-through form is removed. Used by the strict
// variant to restore the "rejected unknown keys" promise.
#let _strip-permissive-additional(schema) = {
  if schema.kind == "object" {
    let new-shape = (:)
    for (k, v) in schema.shape.pairs() {
      new-shape.insert(k, _strip-permissive-additional(v))
    }
    let ap = schema.at("additional", default: none)
    let new-additional = if type(ap) == dictionary {
      _strip-permissive-additional(ap)
    } else {
      none
    }
    // Route through the public constructor so any future invariant
    // added to `object()` applies here too.
    object(
      new-shape,
      required-keys: schema.required-keys,
      additional: new-additional,
    )
  } else if schema.kind == "array" {
    (..schema, elem: _strip-permissive-additional(schema.elem))
  } else if schema.kind == "union" {
    // Union members are positive matchers for the document, so
    // stripping tightens them — same promise as everywhere else.
    (..schema, members: schema.members.map(_strip-permissive-additional))
  } else {
    // Leaves — and, deliberately, `not`: its member is a NEGATED
    // matcher, so stripping there would make the negation accept more
    // documents, loosening the strict variant instead of tightening it.
    schema
  }
}

#let resume-schema-strict = {
  // Strip first so the override-folds run against a schema that
  // doesn't carry the `additional: true` markers — paths and
  // expectations stay simple.
  let strict-base = _strip-permissive-additional(resume-schema)
  let with-content = _override-fold(
    strict-base,
    _content-paths,
    str-type,
    content-type,
    "_content-paths",
  )
  let with-iso = _override-fold(
    with-content,
    _iso8601-date-paths,
    _iso8601-source,
    date-string,
    "_iso8601-date-paths",
  )
  _override-fold(
    with-iso,
    _plain-date-paths,
    str-type,
    date-string,
    "_plain-date-paths",
  )
}
