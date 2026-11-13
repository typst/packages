// The column sections' specs: the CV field each reads (its key, unless
// `read` overrides it), its default column and the entry types it
// accepts, plus the recognised top-level CV keys. Renderers are bound
// to these keys in `registry.typ`, so reading and checking the CV
// doesn't depend on them.

#import "../util/checks.typ": _check-rules
#import "../util/fields.typ": _field
#import "canonical.typ": _legacy-root-fields
#import "cv.typ": _altacv, _reference-usable
#import "cv-checks.typ": (
  _check-award, _check-entry-location, _check-language, _check-section-entries,
  _check-skill, _string-rule, _text-rule, _texts-rule,
)

// What a renderer needs to draw an entry (its title, name, a keyword).
#let _has(field) = entry => _field(entry, field) != none

#let _period-fields = (startDate: _text-rule, endDate: _text-rule)
#let _role = (
  _period-fields
    + (
      position: _text-rule,
      url: _string-rule,
      summary: _text-rule,
      highlights: _texts-rule,
    )
)
#let _keyword-group = (
  fields: (name: _text-rule, keywords: _texts-rule),
  // A group without keywords would leave a bare category tag.
  keep: g => g.at("keywords", default: ()).len() > 0,
)

// Each section's spec, in default render order:
// - `column`: its default column.
// - `read`: how to find its entries, when not at its own key
//   (`focusAreas` lives in `custom.altacv`).
// - `root: false`: its key isn't a top-level CV key (`_cv-keys`).
// - `items`: the accepted entry types (default: dictionaries).
// - `fields`: a rule per field its renderer draws as given, checked on
//   every entry (see `cv-checks.typ`). The fields 1.8.0 read
//   leniently (a project's `type`, a reference's attribution, a
//   publication's citation parts, `authors` and `identifiers`, work's
//   `keywords`) treat a value of the wrong type as absent, as the
//   README documents, so they have no rule: `_canonical-cv` drops it
//   (`_lenient-fields`).
// - `keep`: which entries render; the rest are dropped before
//   `check` and the renderer, so neither sees them.
// - `check(key, entry, prefs)`: checks that need more than a field's
//   type, on the kept entries.
#let _section-specs = (
  work: (
    column: "left",
    fields: _role + (name: _text-rule),
    check: _check-entry-location,
  ),
  volunteer: (
    column: "left",
    fields: _role + (organization: _text-rule),
    check: _check-entry-location,
  ),
  focus-areas: (
    column: "right",
    read: cv => _altacv(cv, "focusAreas", default: ()),
    root: false,
    items: (str, content),
  ),
  skills: _keyword-group
    + (
      column: "right",
      fields: _keyword-group.fields + (level: _text-rule),
      check: _check-skill,
    ),
  languages: (
    column: "right",
    fields: (language: _text-rule),
    keep: _has("language"),
    check: _check-language,
  ),
  education: (
    column: "right",
    fields: _period-fields
      + (
        institution: _text-rule,
        url: _string-rule,
        area: _text-rule,
        studyType: _text-rule,
        score: _text-rule,
        summary: _text-rule,
        courses: _texts-rule,
      ),
    check: _check-entry-location,
  ),
  certificates: (
    column: "right",
    fields: (
      name: _text-rule,
      date: _text-rule,
      expiryDate: _text-rule,
      url: _string-rule,
      issuer: _text-rule,
      credentialId: _text-rule,
      summary: _text-rule,
    ),
    keep: _has("name"),
  ),
  awards: (
    column: "right",
    fields: (
      title: _text-rule,
      date: _text-rule,
      awarder: _text-rule,
      summary: _text-rule,
    ),
    keep: _has("title"),
    check: _check-award,
  ),
  projects: (
    column: "left",
    fields: _period-fields
      + (
        name: _text-rule,
        url: _string-rule,
        entity: _text-rule,
        roles: _texts-rule,
        summary: _text-rule,
        highlights: _texts-rule,
        keywords: _texts-rule,
      ),
    keep: _has("name"),
  ),
  publications: (
    column: "left",
    fields: (
      name: _text-rule,
      url: _string-rule,
      publisher: _text-rule,
      releaseDate: _text-rule,
      summary: _text-rule,
    ),
    keep: _has("name"),
  ),
  interests: (column: "right") + _keyword-group,
  references: (
    column: "right",
    fields: (
      name: _text-rule,
      reference: _text-rule,
    ),
    // A quote, or the on-request flag.
    keep: _reference-usable,
  ),
)

// Section `key`'s spec, with the defaults its keys leave out.
#let _spec(key) = (
  (
    read: cv => cv.at(key, default: ()),
    items: (dictionary,),
    fields: (:),
    keep: _ => true,
    check: (..) => none,
  )
    + _section-specs.at(key)
)

// Section `key`'s entries in `cv`, the ones that render: read and
// kept per its spec, unchecked (`adapter.entries`).
#let _section-entries(cv, key) = {
  let (read, keep, ..) = _spec(key)
  read(cv).filter(keep)
}

// Every section's entries, checked and filtered to the ones that
// render, before any renderer (or the PDF-keyword pass) reads them.
#let _read-sections(cv, prefs) = (
  _section-specs
    .keys()
    .map(key => {
      let (read, items, fields, keep, check, ..) = _spec(key)
      let entries = _check-section-entries(key, read(cv), items)
      for entry in entries {
        _check-rules(entry, fields, prefix: key + "[].", optional: true)
      }
      let kept = entries.filter(keep)
      for entry in kept { check(key, entry, prefs) }
      (key, kept)
    })
    .to-dict()
)

// Every recognised top-level CV key: the sections that read their own
// key, the root keys that aren't sections (`custom` and `$schema` are
// accepted but not rendered), and the deprecated root forms
// `_canonical-cv` still lifts, so dropping one there (#239) rejects it
// here too.
#let _cv-keys = (
  ("$schema", "basics", "objective", "custom", "meta")
    + _section-specs
      .keys()
      .filter(k => _section-specs.at(k).at("root", default: true))
    + _legacy-root-fields
)

#let _keys-for-column(col) = (
  _section-specs.keys().filter(k => _section-specs.at(k).column == col)
)
