// All available config keys with their default values.
// Copy sections you want to change into your project's config.typ.

/// Journal-specific overrides for the shared Satz defaults.
///
/// `journal-entry` and `journal-index` merge these values over the shared
/// `defaults` dictionary, then apply the selected palette and explicit config
/// overrides. The effective defaults are therefore the values in this record
/// for listed keys and the shared Satz defaults for all other keys.
///
/// - `page.paper`: `"iso-b5"`; journal page format.
/// - `page.margin`: 2cm left/right and 2.5cm top/bottom.
/// - `typography.font`: `"Libertinus Serif"`; body text face.
/// - `typography.size`: `11pt`; body text size.
/// - `typography.leading`: `0.65em`; gap between line boxes.
/// - `typography.hyphenate`: `false`; disable automatic body hyphenation.
/// - `typography.justify`: `true`; justify body paragraphs.
/// - `headings.h1-size` through `headings.h4-size`: `16pt`, `12pt`, `11pt`,
///   and `11pt`.
/// - `headings.h1-below` through `headings.h4-below`: `0.65em`, `0.65em`,
///   `0.65em`, and `0.4em`.
/// - `journal.running-header-size`: `9pt`; running-header text size.
/// - `journal.date-size`: `10pt`; date text size.
/// - `journal.keywords-size`: `9pt`; keyword text size.
/// - `colors.bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///   `text-main`, `text-muted`: white, `#F5F5F5`, `#111110`, `#2f2f2c`,
///   `#242422`, and `#5e5e5a`. A selected theme replaces these color values.
#let defaults = (
  page: (
    paper: "iso-b5",
    margin: (left: 2cm, right: 2cm, top: 2.5cm, bottom: 2.5cm),
  ),
  typography: (
    font: "Libertinus Serif",
    size: 11pt,
    leading: 0.65em,
    hyphenate: false,
    justify: true,
  ),
  headings: (
    h1-size: 16pt, h1-below: 0.65em,
    h2-size: 12pt, h2-below: 0.65em,
    h3-size: 11pt, h3-below: 0.65em,
    h4-size: 11pt, h4-below: 0.4em,
  ),
  journal: (
    running-header-size: 9pt,
    date-size: 10pt,
    keywords-size: 9pt,
  ),
  page-footer: (
    format: "1",
    size: 10pt,
    weight: "bold",
  ),
  colors: (
    bg-paper: rgb("#FFFFFF"),
    bg-subtle: rgb("#F5F5F5"),
    brand-primary: rgb("#111110"),
    brand-accent: rgb("#2f2f2c"),
    text-main: rgb("#242422"),
    text-muted: rgb("#5e5e5a"),
  ),
)

/// Shallowly merge a journal defaults record with caller overrides.
///
/// Each top-level key from `overrides` replaces the corresponding value in
/// `base` as a whole. Nested dictionaries are not recursively merged. The
/// current journal templates use the shared recursive `merge` helper instead;
/// this local helper remains available to modules importing this file.
///
/// - base (dictionary): starting values
/// - overrides (dictionary): values that replace matching top-level keys
/// -> dictionary: a new record; neither input is mutated
#let merge(base, overrides) = {
  let result = (: ..base)
  for (k, v) in overrides {
    result.insert(k, v)
  }
  result
}
