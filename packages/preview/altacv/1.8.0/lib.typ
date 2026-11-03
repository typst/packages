// altacv — a two-column CV template for Typst. Visually descended from
// LianTze Lim's AltaCV LaTeX class (https://github.com/liantze/AltaCV,
// LPPL); forked from George Honeywood's alta-typst
// (https://github.com/GeorgeHoneywood/alta-typst, MIT, © 2023 George
// Honeywood) and rewritten around a JSON Resume-style data dict.
//
// Public entry: `alta(cv, ...)` plus the helpers in the README.
// `internal/` holds shared infrastructure; `sections/` one renderer per
// CV section, dispatched from `internal/layout.typ`'s `_sections`.
//
// Sizes scale with `body-size`. Anything exported here reads it from
// state, since it may sit outside `alta()`'s text; internal helpers
// may use `em`, which is relative to the enclosing text, where that's
// the intent. The few absolute values (margins, gutter, rule
// thicknesses) deliberately don't scale.

#import "internal/presets.typ": maps-providers, palettes
#import "internal/state.typ": (
  _accent_state, _body_colour, _body_size_state, _emphasis_colour,
  _max_rating_state,
)
#import "internal/defaults.typ": _default_labels
#import "internal/canonical.typ": _canonical_cv, _canonical_labels
#import "internal/validation.typ": (
  _check_unknown_keys, _strict_merge, _validate_labels, _validate_preferences,
)
#import "internal/text.typ": _field, _fill_template, _string_at, styled-link
#import "internal/icons.typ": icon
#import "internal/primitives.typ": divider, name, tag, term
#import "internal/ratings.typ": rating
#import "internal/dates.typ": _iso_datetime
#import "internal/header.typ": _header, _intro
#import "internal/footer.typ": _resolve_page_footer
#import "internal/layout.typ": (
  _cv_keys, _default_preferences, _read_sections, _sections,
)
#import "internal/json-resume.typ": from-json-resume

// Generic silhouette, exposed as bytes so the `typst init` template
// (and any consumer) gets a working `basics.image` without its own SVG.
#let avatar-placeholder = read("assets/avatar-placeholder.svg", encoding: none)

// Skill keywords for the PDF `Keywords` field, first occurrence first.
#let _collect_keywords(skills) = (
  skills
    .map(group => group.at("keywords", default: ()))
    .sum(default: ())
    .filter(kw => type(kw) == str and kw != "")
    .dedup()
)

// `cv` follows the JSON Resume schema; `labels` and `preferences` are
// partial dicts merged over the defaults (unknown keys panic).
#let alta(
  cv,
  labels: (:),
  preferences: (:),
) = {
  // `basics.name` is the only required field; a guided panic beats a
  // bare missing-key error.
  if type(cv) != dictionary {
    panic("alta() expects a CV data dictionary, got: " + repr(cv))
  }
  let basics = cv.at("basics", default: none)
  if (
    type(basics) != dictionary or _field(basics, "name") == none
  ) {
    panic(
      "cv.basics.name is required (a non-empty string) — every other "
        + "field is optional. Got basics: "
        + repr(basics),
    )
  }
  // A misspelt section (`publication:`) would otherwise vanish silently.
  _check_unknown_keys(cv.keys(), _cv_keys, "CV top-level")
  let labels = _strict_merge(
    _default_labels,
    _canonical_labels(labels),
    "labels",
    nested: true,
  )
  let preferences = _strict_merge(
    _default_preferences,
    preferences,
    "preferences",
  )
  _validate_preferences(preferences, _sections.keys())
  _validate_labels(labels)
  let cv = _canonical_cv(cv, preferences)
  // Before the PDF keywords below walk `skills`.
  let section-data = _read_sections(cv)
  let column-ratio = preferences.columnRatio
  let max-rating = preferences.maxRating
  let accent = preferences.accent
  let body-size = preferences.bodySize
  _accent_state.update(accent)
  _body_size_state.update(body-size)
  _max_rating_state.update(max-rating)

  // Optional metadata is set only when non-empty: `set document(...)`
  // rejects a `none` date, and empty strings would still write an entry.
  let meta = cv.at("meta", default: (:))
  let last-modified-raw = meta.at("lastModified", default: none)
  let canonical = _string_at(meta, "canonical")
  let version = _string_at(meta, "version")
  let doc-date = _iso_datetime(last-modified-raw)
  // `set document(...)` has no URL or version field, so
  // `meta.canonical` / `meta.version` ride the Keywords — the only
  // machine-readable home. `_string_at` because Keywords must be
  // strings and a dict passed to `alta()` directly is unvalidated.
  let doc-keywords = _collect_keywords(section-data.skills)
  if canonical != none { doc-keywords.push(canonical) }
  if version != none { doc-keywords.push(version) }
  let doc-description = _field(cv.basics, "summary")
  set document(
    // `uppercaseName` is purely visual — PDF metadata stays canonical.
    title: _fill_template(labels.documentTitle, (name: cv.basics.name)),
    author: cv.basics.name,
    ..(if doc-keywords.len() > 0 { (keywords: doc-keywords) }),
    ..(if doc-description != none { (description: doc-description) }),
    ..(if doc-date != none { (date: doc-date) }),
  )
  set text(
    body-size,
    font: preferences.font,
    fill: _body_colour,
    lang: labels.lang,
  )
  set page(
    paper: preferences.paper,
    margin: preferences.margin,
    footer: _resolve_page_footer(preferences, labels, meta, cv.basics.name),
  )
  set par(leading: 0.55em, spacing: 0.7em)
  set list(
    marker: text(0.85em, "•"),
    indent: 0pt,
    body-indent: 0.4 * body-size,
    spacing: 0.55em,
  )

  // Levels: 2 section title, 3 role / qualification, 4 sub-grouping
  // (e.g. publication type).
  show heading.where(level: 2): it => block(sticky: true)[
    #v(0.6 * body-size)
    #text(1.7 * body-size, fill: accent, weight: "bold", upper(it.body))
    #v(-0.7 * body-size)
    #line(length: 100%, stroke: 2pt + accent)
    #v(0.2 * body-size)
  ]
  let sub-heading(above, below, weight) = it => block(
    above: above * body-size,
    below: below * body-size,
    sticky: true,
    text(1.2 * body-size, fill: _emphasis_colour, weight: weight, it.body),
  )
  show heading.where(level: 3): sub-heading(1.0, 0.8, "regular")
  show heading.where(level: 4): sub-heading(0.6, 0.6, "bold")

  _header(cv.basics, preferences)
  _intro(cv)

  // Renderers are width-agnostic, so any section fits either column.
  // `owner` bolds the CV owner among publication authors.
  let ctx = (labels: labels, prefs: preferences, owner: cv.basics.name)
  let render-column(keys) = {
    for key in keys {
      (_sections.at(key).render)(section-data.at(key), ctx)
    }
  }

  // The fr columns split what the gutter leaves, so both sides give up
  // a proportional share of it.
  if column-ratio == 1 {
    render-column(
      preferences.leftColumnSections + preferences.rightColumnSections,
    )
  } else if preferences.rightColumnSections.len() == 0 {
    render-column(preferences.leftColumnSections)
  } else {
    grid(
      columns: (column-ratio * 1fr, (1 - column-ratio) * 1fr),
      column-gutter: 12pt,
      render-column(preferences.leftColumnSections),
      render-column(preferences.rightColumnSections),
    )
  }
}

// `..rest` forwards future `alta` kwargs without an edit here. Extra
// positionals (`alta-from-json(p, my-prefs)`) panic with a
// wrapper-aware message rather than an `alta`-level one.
#let alta-from-json(data, ..rest) = {
  if rest.pos().len() > 0 {
    panic(
      "alta-from-json takes one positional (`data`); pass labels/preferences as named arguments. Got extra positionals: "
        + repr(rest.pos()),
    )
  }
  alta(from-json-resume(data), ..rest)
}
