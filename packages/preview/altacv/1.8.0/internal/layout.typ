// Section dispatch catalogue and the default preferences. A new section
// also needs a renderer under `sections/` and a heading in
// `labels-en.toml`.
//
// `_default_preferences` lives here, not in `defaults.typ`, because the
// column defaults derive from `_sections`; `defaults.typ` stays leaf
// data with no imports.

#import "presets.typ": maps-providers, palettes
#import "text.typ": _altacv
#import "validation.typ": _check_section_entries
#import "canonical.typ": _legacy_root_fields
#import "../sections/experience.typ": _experience, _volunteer
#import "../sections/focus-areas.typ": _focus_areas
#import "../sections/skills.typ": _interests, _skills
#import "../sections/languages.typ": _languages
#import "../sections/education.typ": _education
#import "../sections/certificates.typ": _certificates
#import "../sections/awards.typ": _awards
#import "../sections/projects.typ": _projects
#import "../sections/publications.typ": _publications
#import "../sections/references.typ": _references

// Renderers take `(entries, ctx)`, `ctx` being `(labels, prefs,
// owner)`. Each key doubles as the CV field read, unless `read`
// overrides it (`focusAreas` lives in `custom.altacv`); `items` lists
// the accepted entry types (default: dictionaries). Insertion order is
// the default render order. Must follow the renderer imports: Typst
// binds identifiers eagerly.
#let _sections = (
  work: (column: "left", render: _experience),
  volunteer: (column: "left", render: _volunteer),
  focusAreas: (
    column: "right",
    render: _focus_areas,
    read: cv => _altacv(cv, "focusAreas", default: ()),
    items: (str, content),
  ),
  skills: (column: "right", render: _skills),
  languages: (column: "right", render: _languages),
  education: (column: "right", render: _education),
  certificates: (column: "right", render: _certificates),
  awards: (column: "right", render: _awards),
  projects: (column: "left", render: _projects),
  publications: (column: "left", render: _publications),
  interests: (column: "right", render: _interests),
  references: (column: "right", render: _references),
)

// Every section's entries, shape-checked before any renderer (or the
// PDF-keyword pass) reads them.
#let _read_sections(cv) = (
  _sections
    .pairs()
    .map(((key, entry)) => {
      let read = entry.at("read", default: cv => cv.at(key, default: ()))
      let items = entry.at("items", default: (dictionary,))
      (key, _check_section_entries(key, read(cv), items))
    })
    .to-dict()
)

// Every recognised top-level CV key: the sections that read their own
// key, the root keys that aren't sections (`custom` and `$schema` are
// accepted but not rendered), and the deprecated root forms
// `_canonical_cv` still lifts, so dropping one there (#239) rejects it
// here too.
#let _cv_keys = (
  ("$schema", "basics", "objective", "custom", "meta")
    + _sections.keys().filter(k => "read" not in _sections.at(k))
    + _legacy_root_fields
)

#let _keys_for_column(col) = (
  _sections.keys().filter(k => _sections.at(k).column == col)
)

// Documented in the README's preferences table; comments here note
// only constraints the README doesn't need.
#let _default_preferences = (
  // Must be installed on the build host (CI installs it: apt in
  // setup-typst, apk in the pinned image).
  font: "Lato",
  bodySize: 10pt,
  paper: "a4",
  margin: (x: 0.9cm, y: 1.5cm),
  accent: palettes.teal,
  // Deprecated and ignored; removed in the next major (#239).
  groupCertificates: true,
  imageSize: 6em,
  linkContactInfo: true,
  mapsProvider: maps-providers.google,
  imagePosition: "right",
  imageStackOrder: "above",
  headerTextAlign: "left",
  qrCode: none,
  // Visual only: PDF title / author metadata keep the name as given.
  uppercaseName: true,
  showPronouns: false,
  lastModifiedFooter: false,
  // Rides the `lastModifiedFooter` line; no-op without it.
  footerVersion: false,
  dateFormat: "long",
  columnRatio: 0.65,
  pageFooter: none,
  leftColumnSections: _keys_for_column("left"),
  rightColumnSections: _keys_for_column("right"),
  // Deprecated (#239): `_canonical_cv` turns it into a
  // `references[].availableOnRequest` entry.
  referencesAvailableOnRequest: false,
  maxRating: 5,
)
