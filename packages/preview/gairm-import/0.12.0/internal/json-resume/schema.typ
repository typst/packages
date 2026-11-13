// Canonical JSON Resume schema (https://jsonresume.org/schema), vendored
// at 1.7.0. Upstream changelog:
// https://github.com/jsonresume/jsonresume.org/blob/master/packages/schema/CHANGELOG.md
// `resume-schema` is a faithful derivation of the upstream document;
// `resume-schema-strict` layers content + date opinions on it.
// See README "The two resume schemas" for the trade-off.

// Only the kinds this module itself uses — the full combinator surface
// is re-exported to callers by lib.typ directly from kinds/.
#import "../kinds/leaf.typ": str-type, content-type
#import "../kinds/format.typ": string
#import "../kinds/structure.typ": any-of, _is-free-form, _object-with
#import "../json-schema/translate.typ": schema-from-json-schema
#import "../core/error.typ": _internal
#import "../kinds/traverse.typ": _get-at, _set-at, _map-children, _paths-where

/// The JSON Resume schema, translated from the upstream document as it stands.
/// The default for `parse`, `validate` and `coerce`.
#let resume-schema = schema-from-json-schema(json("schema.json"))

// Free-text fields wrapped as Typst `content` in the strict variant.
// Renderer ergonomics, not validation.
#let _content-paths = (
  ("objective",),
  ("basics", "summary"),
  ("work", "items", "summary"),
  ("work", "items", "highlights", "items"),
  ("volunteer", "items", "summary"),
  ("volunteer", "items", "highlights", "items"),
  ("education", "items", "summary"),
  ("awards", "items", "summary"),
  ("certificates", "items", "summary"),
  ("publications", "items", "summary"),
  ("references", "items", "reference"),
  ("projects", "items", "summary"),
  ("projects", "items", "description"),
  ("projects", "items", "highlights", "items"),
)

// iso8601 `$ref` fields. The upstream definition is a string with a
// `pattern`, so the translator emits the iso8601 patterned string for
// these — the strict variant retypes them as date strings
// (`string(format: "date")`), so callers and `paths-of-kind` see them
// as dates.
#let _iso8601-date-paths = (
  ("work", "items", "startDate"),
  ("work", "items", "endDate"),
  ("volunteer", "items", "startDate"),
  ("volunteer", "items", "endDate"),
  ("education", "items", "startDate"),
  ("education", "items", "endDate"),
  ("awards", "items", "date"),
  ("certificates", "items", "date"),
  ("certificates", "items", "expiryDate"),
  ("publications", "items", "releaseDate"),
  ("references", "items", "date"),
  ("projects", "items", "startDate"),
  ("projects", "items", "endDate"),
)

// `meta.lastModified` carries only a description in upstream — no
// machine-readable pattern — so it lands as plain `str-type` in the
// faithful schema. Upstream describes it as `YYYY-MM-DDThh:mm:ss`, so
// strict accepts that datetime, and still a bare date for documents
// that only record the day.
#let _last-modified-paths = (
  ("meta", "lastModified"),
)
#let _last-modified-kind = any-of(
  string(format: "date-time"),
  string(format: "date"),
)

// Source shape the translator emits for iso8601 $ref fields, built
// through the translator from upstream's `definitions/iso8601`. The
// pattern is hand-mirrored so a schema bump that retires or alters it
// surfaces as an override guard panic at load time, not as silent
// semantic drift.
#let _iso8601-source = schema-from-json-schema((
  type: "string",
  pattern: "^([1-2][0-9]{3}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])|[1-2][0-9]{3}-(0[1-9]|1[0-2])|[1-2][0-9]{3})$",
))

// The strict variant's retypings, applied in order: every listed path
// must hold `from` (named by `name` when it doesn't) and becomes `to`.
#let _overrides = (
  (
    name: "_content-paths",
    paths: _content-paths,
    from: str-type,
    to: content-type,
  ),
  (
    name: "_iso8601-date-paths",
    paths: _iso8601-date-paths,
    from: _iso8601-source,
    to: string(format: "date"),
  ),
  (
    name: "_last-modified-paths",
    paths: _last-modified-paths,
    from: str-type,
    to: _last-modified-kind,
  ),
)

// Pre-condition guard turns silent upstream drift into a load-time
// panic — an override that ran unconditionally would mask the shape
// change instead of surfacing it.
#let _apply-overrides(schema, overrides) = {
  for o in overrides {
    for p in o.paths {
      let current = _get-at(schema, p)
      _internal(
        current == o.from,
        o.name
          + " must target "
          + repr(o.from)
          + " leaves only — "
          + repr(p)
          + " is now "
          + repr(current)
          + ". Audit upstream schema bump.",
      )
      schema = _set-at(schema, p, o.to)
    }
  }
  schema
}

// Completeness guard for the iso8601 override: `_apply-overrides` only
// checks the listed paths, so an upstream bump that ADDS an iso8601 field
// would otherwise stay a patterned string in the strict schema unnoticed.
// Run on the folded schema, no leaf may still be `_iso8601-source`.
#let _assert-no-iso8601-leaves(schema, list-name) = {
  let left = _paths-where(schema, n => n == _iso8601-source)
  _internal(
    left.len() == 0,
    list-name
      + " is missing iso8601 leaves — "
      + left.map(repr).join(", ")
      + " still match the iso8601 patterned string. Add the path(s) to "
      + list-name
      + " (or audit the upstream schema bump).",
  )
  schema
}

// Strip `additional: true` (the JSON Resume upstream's permissive
// "extras allowed" on every section's items) recursively. Typed
// extras (`additional: <schema>`) are kept and recursed into; only
// the unchecked-pass-through form is removed. Used by the strict
// variant to restore the "rejected unknown keys" promise.
//
// A free-form bag (`_is-free-form`, upstream's `custom`) keeps its
// `additional: true` — stripping it would accept only `{}`.
//
// Union members are positive matchers, so stripping them tightens
// them, as everywhere else. That assumes no one-of has two members
// that differ only by `additional: true`: stripping one can turn a
// value that matched both (rejected) into one that matches one
// (accepted). JSON Resume's one-ofs (`location`: a string or an
// object) can't match twice, so it holds there.
//
// A `not` member is left alone: it is a NEGATED matcher, so stripping
// there would make the negation accept more documents, loosening the
// strict variant instead of tightening it. So is a conditional's
// condition, which only picks the branch; its branches are stripped.
#let _strip-permissive-additional(schema) = {
  // kind-check: deprecated with this module, #200
  if _is-free-form(schema) or schema.kind == "not" { return schema }
  // kind-check: deprecated with this module, #200
  let s = if schema.kind == "if" {
    let branches = ("then", "otherwise").filter(k => k in schema)
    (:
      ..schema,
      ..branches
        .map(k => (k, _strip-permissive-additional(schema.at(k))))
        .to-dict(),
    )
  } else { _map-children(schema, _strip-permissive-additional) }
  // Only objects carry `additional`. Rebuilt through object(), so
  // closing it re-checks the constructor's invariants.
  if s.at("additional", default: none) == true {
    _object-with(s, additional: none)
  } else { s }
}

/// `resume-schema` with four changes: free-text fields are Typst `content`,
/// the iso8601 date fields are checked as dates, `meta.lastModified` is
/// checked as a date or date-time, and undeclared keys are rejected
/// everywhere.
#let resume-schema-strict = {
  // Strip first so the overrides run against a schema that doesn't
  // carry the `additional: true` markers — paths and expectations stay
  // simple.
  let strict = _apply-overrides(
    _strip-permissive-additional(resume-schema),
    _overrides,
  )
  _assert-no-iso8601-leaves(strict, "_iso8601-date-paths")
}
