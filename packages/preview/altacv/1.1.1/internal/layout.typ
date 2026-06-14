// Section dispatch catalogue + the default preferences that
// reference it. Adding a section here places it in the default
// layout — still need to write the renderer (under `sections/`)
// and add a `labels` key in `defaults.typ`.
//
// `_default_preferences` lives in this module rather than
// `defaults.typ` because its `leftColumnSections` /
// `rightColumnSections` defaults derive from `_sections` (via
// `_keys_for_column`). Keeping the foundation (`defaults.typ`) free
// of imports from this orchestration layer preserves the dependency
// layering: `defaults.typ` is leaf data; this file is the layout
// kernel.

#import "presets.typ": palettes, maps-providers
#import "../sections/experience.typ": _experience, _volunteer
#import "../sections/focus-areas.typ": _focus_areas
#import "../sections/skills.typ": _skills, _interests
#import "../sections/languages.typ": _languages
#import "../sections/education.typ": _education
#import "../sections/certificates.typ": _certificates
#import "../sections/awards.typ": _awards
#import "../sections/projects.typ": _projects
#import "../sections/publications.typ": _publications

// Defined after the renderers because Typst binds closure identifiers
// eagerly.
#let _sections = (
  work: (
    column: "left",
    render: (cv, labels, prefs) => _experience(cv.at("work", default: ()), labels, prefs),
  ),
  volunteer: (
    column: "left",
    render: (cv, labels, prefs) => _volunteer(cv.at("volunteer", default: ()), labels, prefs),
  ),
  focusAreas: (
    column: "right",
    render: (cv, labels, prefs) => _focus_areas(cv.at("focusAreas", default: ()), labels),
  ),
  skills: (
    column: "right",
    render: (cv, labels, prefs) => _skills(cv.at("skills", default: ()), labels),
  ),
  languages: (
    column: "right",
    render: (cv, labels, prefs) => _languages(cv.at("languages", default: ()), labels),
  ),
  education: (
    column: "right",
    render: (cv, labels, prefs) => _education(cv.at("education", default: ()), labels, prefs),
  ),
  certificates: (
    column: "right",
    render: (cv, labels, prefs) => _certificates(
      cv.at("certificates", default: ()),
      labels,
      prefs,
      group: prefs.groupCertificates,
    ),
  ),
  awards: (
    column: "right",
    render: (cv, labels, prefs) => _awards(cv.at("awards", default: ()), labels, prefs),
  ),
  projects: (
    column: "left",
    render: (cv, labels, prefs) => _projects(cv.at("projects", default: ()), labels, prefs),
  ),
  publications: (
    column: "left",
    render: (cv, labels, prefs) => _publications(cv.at("publications", default: ()), labels, prefs),
  ),
  interests: (
    column: "right",
    render: (cv, labels, prefs) => _interests(cv.at("interests", default: ()), labels),
  ),
)

// Defaults derived from `_sections` so adding a section there
// automatically places it in the default layout for its declared
// column. Insertion order in `_sections` controls render order.
#let _keys_for_column(col) = _sections.keys().filter(k => _sections.at(k).column == col)

// User-facing reference for these prefs lives in the README. Comments
// below capture only what isn't recoverable from the key name + default
// — non-obvious constraints, footguns, and design rationale.
#let _default_preferences = (
  // Must be installed on the build host (CI installs Lato).
  font: "Lato",
  // Every spacing token is an em-multiplier of this, so changing one
  // knob scales the whole document proportionally.
  bodySize: 10pt,
  paper: "a4",
  margin: (x: 0.9cm, y: 1.5cm),
  // `palettes.teal` — see the `palettes` dict for the curated set
  // (`teal`, `navy`, `crimson`, `forest`, `plum`, `charcoal`).
  accent: palettes.teal,
  groupCertificates: true,
  imageSize: 6em,
  linkContactInfo: true,
  // `{q}` is substituted with the URL-encoded location. A string
  // missing that placeholder panics so a typo is caught up front
  // rather than producing a dead link.
  mapsProvider: maps-providers.google,
  imagePosition: "right",
  // Only consulted when `imagePosition` is "center" — chooses whether
  // the centred portrait stacks above or below the header text block.
  imageStackOrder: "above",
  headerTextAlign: "left",
  // PDF metadata (title / author) stays as-supplied regardless of
  // this flag — see the comment above `set document(...)`.
  uppercaseName: true,
  // When true and `cv.meta.lastModified` is set, render a small
  // "Last updated: <value>" line in the page footer. PDF metadata
  // (date / keywords / description) is populated from `meta` and
  // `basics` independently of this flag.
  lastModifiedFooter: false,
  // Controls how ISO 8601 date strings ("2024", "2024-06", "2024-06-15")
  // are rendered wherever the template surfaces a date. Non-ISO strings
  // (e.g. "Jan 2022", "May 2016 – Jul 2017") pass through verbatim
  // regardless of this setting, so pre-formatted data keeps working.
  //   "long"  — "Jun 2024" / "15 Jun 2024" (month names from labels.months)
  //   "short" — "06/2024"  / "15/06/2024"
  //   "iso"   — passthrough of the original string
  //   closure — (parts) -> str, where parts is (year, month?, day?)
  dateFormat: "long",
  // Fraction in (0, 1] (validated in alta()). Use the complement
  // (`1 - r`) and swap the column-section arrays to invert the layout;
  // exactly 1 collapses the grid to a single full-width column.
  columnRatio: 0.65,
  // `none` (default) — no footer. `"auto"` — name + "Page N / M" on
  // multi-page documents only (single-page stays clean). Any content
  // value — rendered verbatim as the footer on every page.
  pageFooter: none,
  // Sections omitted from BOTH arrays don't render even if their data
  // is present; sections listed in both render twice. Defaults derive
  // from `_sections` so adding a section there places it automatically.
  leftColumnSections: _keys_for_column("left"),
  rightColumnSections: _keys_for_column("right"),
  // Number of dots on the language fluency scale. Default 5 matches
  // LinkedIn's scale (and the built-in `fluency` string map). Override
  // to suit other scales — CEFR (6: A1–C2), ILR (5), or custom.
  // Fluency strings remain anchored to LinkedIn's 0–5 scale, so callers
  // using a non-5 maxRating must supply numeric `rating` values.
  maxRating: 5,
)
