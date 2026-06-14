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
#import "internal/validation.typ": _strict_merge, _check_bool
#import "internal/text.typ": _present, styled-link
#import "internal/icons.typ": icon
#import "internal/primitives.typ": name, term, tag, divider
#import "internal/ratings.typ": rating
#import "internal/dates.typ": _date_format_aliases, _iso_datetime
#import "internal/header.typ": _header, _summary
#import "internal/footer.typ": _auto_page_footer
#import "internal/layout.typ": _sections, _default_preferences

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
#let avatar-placeholder = read("icons/avatar-placeholder.svg", encoding: none)

// Flatten every skill group's `keywords` into a de-duplicated array
// for the PDF `Keywords` field. Insertion order is preserved so the
// metadata reflects the author's curated ordering.
#let _collect_keywords(skills) = {
  let seen = ()
  for group in skills {
    for kw in group.at("keywords", default: ()) {
      if type(kw) == str and kw != "" and kw not in seen { seen.push(kw) }
    }
  }
  seen
}

// `cv` follows the JSON Resume schema (see `examples/example_full.typ`
// for a fully-populated demo, or `template/cv.typ` for the starter
// `typst init` produces). `labels` and `preferences` are partial
// dicts merged over the defaults; unknown keys panic.
#let alta(
  cv,
  labels: (:),
  preferences: (:),
) = {
  let labels = _strict_merge(_default_labels, labels, "labels")
  let preferences = _strict_merge(_default_preferences, preferences, "preferences")
  let column-ratio = preferences.columnRatio
  if type(column-ratio) not in (int, float) or column-ratio <= 0 or column-ratio > 1 {
    panic("columnRatio must be a number in (0, 1], got: " + repr(column-ratio))
  }
  let mp = preferences.mapsProvider
  if mp != none {
    if type(mp) != str {
      panic(
        "mapsProvider must be a URL template string (containing `{q}`) or `none`, got: "
          + repr(mp),
      )
    }
    if "{q}" not in mp {
      panic(
        "mapsProvider URL template must contain the `{q}` placeholder, got: "
          + repr(mp),
      )
    }
  }
  _check_bool("uppercaseName", preferences.uppercaseName)
  _check_bool("lastModifiedFooter", preferences.lastModifiedFooter)
  let max-rating = preferences.maxRating
  if type(max-rating) != int or max-rating < 1 {
    panic("maxRating must be a positive integer, got: " + repr(max-rating))
  }
  // `pageFooter` accepts `none`, the string `"auto"`, or any content
  // value. Any other type — bools, dicts, numbers — panics so a typo
  // like `pageFooter: true` surfaces at the call site rather than
  // falling through to a render-time failure inside `set page(...)`.
  let page-footer = preferences.pageFooter
  let footer-ok = (
    page-footer == none
      or page-footer == "auto"
      or type(page-footer) == content
  )
  if not footer-ok {
    panic(
      "pageFooter must be `none`, the string \"auto\", or a content value, got: "
        + repr(page-footer),
    )
  }
  let df = preferences.dateFormat
  if type(df) == str {
    // Bracketed templates (`[year]`, `[month repr:long]`, …) defer to
    // `_apply_date_template`; bare strings must be one of the named
    // formatters or the literal `"iso"` passthrough.
    if "[" not in df and df != "iso" and df not in _date_format_aliases {
      panic(
        "dateFormat must be \"long\", \"short\", \"iso\", a bracketed template "
          + "(e.g. \"[day]/[month]/[year]\"), or a closure; got: "
          + repr(df),
      )
    }
  } else if type(df) != function {
    panic(
      "dateFormat must be a string (named formatter or bracketed template) "
        + "or a closure, got: " + repr(df),
    )
  }
  // `labels.months` is consumed by the "long" formatter and by the
  // bracketed-template `[month repr:long]` / `[month repr:short]`
  // tokens; validate shape and element types up front so a malformed
  // override panics with a clear message rather than failing inside
  // `array.at()` or string slicing at render time.
  let months = labels.months
  if type(months) != array or months.len() != 12 or months.any(m => type(m) != str) {
    panic(
      "labels.months must be an array of 12 strings, got: " + repr(months),
    )
  }
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
  let doc-date = _iso_datetime(last-modified-raw)
  let doc-keywords = _collect_keywords(cv.at("skills", default: ()))
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
  // Resolve the page footer. `pageFooter` is the general mechanism and
  // takes precedence when set; `lastModifiedFooter` is sugar for one
  // specific use case and only applies when `pageFooter` is `none`
  // (its default). Resulting value passed to `set page(...)`:
  //   `none`             — no footer
  //   auto renderer      — name + "Page N / M", multi-page only
  //   verbatim content   — rendered on every page
  let resolved-footer = if page-footer != none {
    if page-footer == "auto" {
      _auto_page_footer(cv.basics.name)
    } else {
      page-footer
    }
  } else if preferences.lastModifiedFooter and _present(last-modified-raw) {
    align(right, text(0.8 * body-size, fill: _body_colour, {
      labels.lastModified
      ": "
      last-modified-raw
    }))
  } else {
    none
  }
  set page(
    paper: preferences.paper,
    margin: preferences.margin,
    footer: resolved-footer,
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
  )
  _summary(cv.basics)

  // The same `_sections` dict that derives the column defaults also
  // gates the overrides, so adding a section stays a single-touch
  // change.
  let validate-column(arr, pref-name) = {
    let unknown = arr.filter(k => k not in _sections)
    if unknown.len() > 0 {
      let quote(k) = "\"" + k + "\""
      panic(
        "Unknown " + pref-name + " key(s): " + unknown.map(quote).join(", ")
          + ". Supported: " + _sections.keys().map(quote).join(", "),
      )
    }
  }
  validate-column(preferences.leftColumnSections, "leftColumnSections")
  validate-column(preferences.rightColumnSections, "rightColumnSections")

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
