// altacv — a two-column CV template for Typst. Visually descended from
// LianTze Lim's AltaCV LaTeX class (https://github.com/liantze/AltaCV,
// LPPL); forked from George Honeywood's alta-typst
// (https://github.com/GeorgeHoneywood/alta-typst, MIT, © 2023 George
// Honeywood) and rewritten around a JSON Resume-style data dict.
//
// Public entry: `alta(cv, ...)` plus the helpers documented in the
// README. Implementation lives under:
//
//   internal/   — shared infrastructure (presets, state, dates, icons,
//                 primitives, ratings, header, footer, layout catalogue)
//   sections/   — one renderer per CV section (work, education,
//                 certificates, …) — the "component" layer dispatched
//                 from `internal/layout.typ`'s `_sections` table.
//
// Spacing tokens are em-multipliers of `body-size`, so changing one
// knob scales the document proportionally. The few absolute values
// (page margins, column gutter, rule thicknesses) are visual choices
// independent of text size.

#import "internal/presets.typ": palettes, maps-providers
#import "internal/state.typ": _body_size_state, _accent_state, _max_rating_state, _body_colour, _emphasis_colour
#import "internal/defaults.typ": _default_labels
#import "internal/validation.typ": _strict_merge, _validate_preferences, _validate_labels
#import "internal/text.typ": _present, styled-link
#import "internal/icons.typ": icon
#import "internal/primitives.typ": name, term, tag, divider
#import "internal/ratings.typ": rating
#import "internal/dates.typ": _iso_datetime
#import "internal/header.typ": _header, _summary
#import "internal/footer.typ": _resolve_page_footer
#import "internal/layout.typ": _sections, _default_preferences
#import "internal/json-resume.typ": from-json-resume

// Default portrait — a generic head-and-shoulders silhouette baked
// into the package. Exposed so the `typst init` template (and any
// downstream consumer) can render a working `basics.image` without
// shipping its own SVG. Pre-loaded as bytes so the consumer just
// passes it through:
//
//   #import "@preview/altacv:<version>": alta, avatar-placeholder
//   basics: (..., image: avatar-placeholder)
//
// Replace with `read("your-photo.png", encoding: none)` (or `none`
// to drop the portrait entirely).
#let avatar-placeholder = read("assets/avatar-placeholder.svg", encoding: none)

// Every skill group's `keywords`, de-duplicated for the PDF `Keywords`
// field. First occurrences win so the author's ordering survives.
#let _collect_keywords(skills) = (
  skills
    .map(group => group.at("keywords", default: ()))
    .sum(default: ())
    .filter(kw => type(kw) == str and kw != "")
    .dedup()
)

// `cv` follows the JSON Resume schema (see `examples/example_full.typ`
// for a fully-populated demo, or `template/cv.typ` for the starter
// `typst init` produces). `labels` and `preferences` are partial
// dicts merged over the defaults; unknown keys panic.
#let alta(
  cv,
  labels: (:),
  preferences: (:),
) = {
  // `basics.name` is the only required field — checked up front so
  // the panic is guided rather than a bare missing-key error.
  if type(cv) != dictionary {
    panic("alta() expects a CV data dictionary, got: " + repr(cv))
  }
  let basics = cv.at("basics", default: none)
  if type(basics) != dictionary or not _present(basics.at("name", default: none)) {
    panic(
      "cv.basics.name is required (a non-empty string) — every other "
        + "field is optional. Got basics: " + repr(basics),
    )
  }
  let labels = _strict_merge(_default_labels, labels, "labels")
  let preferences = _strict_merge(_default_preferences, preferences, "preferences")
  _validate_preferences(preferences, _sections.keys())
  _validate_labels(labels)
  let column-ratio = preferences.columnRatio
  let max-rating = preferences.maxRating
  let accent = preferences.accent
  let body-size = preferences.bodySize
  _accent_state.update(accent)
  _body_size_state.update(body-size)
  _max_rating_state.update(max-rating)

  // PDF metadata is sourced from `basics` (title, author, description)
  // and the JSON Resume `meta` block (date, keywords). Each optional
  // field is only set when its source is non-empty — `set document(...)`
  // rejects `none` for `date`, and emitting empty strings for
  // `description` / `keywords` would still write a present-but-empty
  // entry.
  let meta = cv.at("meta", default: (:))
  let last-modified-raw = meta.at("lastModified", default: none)
  let canonical = meta.at("canonical", default: none)
  let version = meta.at("version", default: none)
  let doc-date = _iso_datetime(last-modified-raw)
  // Typst 0.15's `set document(...)` exposes no dedicated field for a
  // document URL or version, so `meta.canonical` and `meta.version`
  // ride the Keywords array — the only machine-readable home — appended
  // verbatim after the skill keywords. Guard on `str` so a malformed
  // dict passed to `alta()` directly can't smuggle a non-string into a
  // field `set document(...)` requires be strings.
  let doc-keywords = _collect_keywords(cv.at("skills", default: ()))
  if type(canonical) == str and canonical != "" { doc-keywords.push(canonical) }
  if type(version) == str and version != "" { doc-keywords.push(version) }
  let doc-description = cv.basics.at("summary", default: none)
  set document(
    // `uppercaseName` is purely visual — PDF metadata stays canonical.
    title: cv.basics.name + " --- CV",
    author: cv.basics.name,
    ..(if doc-keywords.len() > 0 { (keywords: doc-keywords) } else { (:) }),
    ..(if _present(doc-description) { (description: doc-description) } else { (:) }),
    ..(if doc-date != none { (date: doc-date) } else { (:) }),
  )
  set text(body-size, font: preferences.font, fill: _body_colour)
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

  // Heading levels map to semantic CV roles:
  //   ==   section title (e.g. Experience)
  //   ===  role / qualification line
  //   ==== sub-grouping (publication type)
  show heading.where(level: 2): it => block(sticky: true)[
    #v(0.6 * body-size)
    #text(1.7 * body-size, fill: accent, weight: "bold", upper(it.body))
    #v(-0.7 * body-size)
    #line(length: 100%, stroke: 2pt + accent)
    #v(0.2 * body-size)
  ]
  show heading.where(level: 3): it => block(
    above: 1.0 * body-size,
    below: 0.8 * body-size,
    sticky: true,
    text(1.2 * body-size, fill: _emphasis_colour, weight: "regular", it.body),
  )
  show heading.where(level: 4): it => block(
    above: 0.6 * body-size,
    below: 0.6 * body-size,
    sticky: true,
    text(1.2 * body-size, fill: _emphasis_colour, weight: "bold", it.body),
  )

  _header(
    cv.basics,
    image-size: preferences.imageSize,
    image-position: preferences.imagePosition,
    image-stack-order: preferences.imageStackOrder,
    header-text-align: preferences.headerTextAlign,
    link-contact-info: preferences.linkContactInfo,
    maps-provider: preferences.mapsProvider,
    uppercase-name: preferences.uppercaseName,
    qr-code: preferences.qrCode,
  )
  _summary(cv.basics)

  // Section renderers are width-agnostic — they fill their container,
  // so the same renderer works whether dropped into the wide or the
  // narrow column.
  let render-column(keys) = {
    for key in keys {
      let entry = _sections.at(key)
      (entry.render)(cv, labels, preferences)
    }
  }

  // Three layout shapes: full-width merge when columnRatio is 1,
  // left-only when the right side is empty, otherwise the canonical
  // two-column grid.
  //
  // Swapping the column-section arrays and inverting `columnRatio`
  // gives a mirrored layout.
  if column-ratio == 1 {
    render-column(preferences.leftColumnSections + preferences.rightColumnSections)
  } else if preferences.rightColumnSections.len() == 0 {
    render-column(preferences.leftColumnSections)
  } else {
    let gutter = 12pt
    let left-width = column-ratio * 100%
    let right-width = (1 - column-ratio) * 100% - gutter
    grid(
      columns: (left-width, right-width),
      column-gutter: gutter,
      render-column(preferences.leftColumnSections),
      render-column(preferences.rightColumnSections),
    )
  }
}

// `..rest` forwards every kwarg added to `alta` in a future release
// without an adapter edit. Extra positionals are rejected up front so
// `alta-from-json(p, my-prefs)` (drift from the kwarg form) panics
// with a wrapper-aware diagnostic instead of an alta-level one.
#let alta-from-json(data, ..rest) = {
  if rest.pos().len() > 0 {
    panic("alta-from-json takes one positional (`data`); pass labels/preferences as named arguments. Got extra positionals: " + repr(rest.pos()))
  }
  alta(from-json-resume(data), ..rest)
}
