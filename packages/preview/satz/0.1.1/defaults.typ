// Unified defaults for the satz document class.
// All config keys with their default values.
// Copy sections you want to change into your project's config.typ.

/// All the knobs for your document.
///
/// Pass only what you want to change — the rest stays.
/// Nested dicts merge deep, so `config: (colors: (brand-primary: blue))` just changes that one color.
///
/// - page (dictionary): paper, margins, binding
/// - typography (dictionary): font, size, leading, hyphenation, justification
/// - headings (dictionary): numbering, sizes, spacing per level
/// - decorative (dictionary): header, footer, date, keyword, and list sizes
/// - page-footer (dictionary): how page numbers look
/// - links (dictionary): link color
/// - tables (dictionary): stroke, inset, font size
/// - captions (dictionary): caption size and weight
/// - toc / lof / lot (dictionary): table of contents, figures, and tables
/// - bibliography (dictionary): cite style
/// - colors (dictionary): your palette (bg-paper, brand-primary, text-main ...)
#let defaults = (
  page: (
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
    binding: none,
    headers: false,
  ),
  typography: (
    font: "Libertinus Serif",
    size: 11pt,
    leading: 0.65em,
    hyphenate: false,
    justify: true,
  ),
  headings: (
    numbering: "1.1",
    h1-size: 14pt,  h1-below: 0.65em,
    h2-size: 12pt,  h2-below: 0.65em,
    h3-size: 11pt,  h3-below: 0.65em,
    h4-size: 11pt,  h4-below: 0.4em,
  ),
  decorative: (
    header-size: 9pt,
    footer-size: 10pt,
    date-size: 10pt,
    keywords-size: 9pt,
    list-spacing: 0.65em,
  ),
  page-footer: (
    format: "1",
    size: 10pt,
    weight: "bold",
  ),
  links: (
    color: rgb("#B4313F"),
    url-color: rgb("#45556c"),
  ),
  tables: (
    stroke: 0.5pt,
    inset: (x: 8pt, y: 4pt),
    font-size: 10pt,
  ),
  captions: (
    size: 10pt,
    weight: "regular",
  ),
  toc: (
    // Set depth: 0 to disable. none = auto (uses heading numbering depth).
    depth: none,
    // Title shown above the table of contents. Set to none to omit.
    title: [Table of Contents],
    // Indent per heading level (e.g. 1em for sub-sections)
    indent: 1em,
    // Spacing below the ToC before body content begins
    below: 2em,
  ),
  lof: (
    // Set depth: 0 to disable. none = auto.
    depth: none,
    // Title shown above the list of figures. Set to none to omit.
    title: [List of Figures],
    // Indent per level
    indent: 1em,
    // Spacing below the list
    below: 2em,
    // When true, LoF shows only "Figure N .... page", no caption text.
    // Set to true for long captions where the full text clutters the list.
    compact: false,
  ),
  lot: (
    depth: none,
    title: [List of Tables],
    indent: 1em,
    below: 2em,
    // Same as lof.compact, but for tables.
    compact: false,
  ),
  bibliography: (
    style: "apa",
  ),
  // === Slate palette (dark → light) ===
  // #020618 #0f172b #1d293d #314158 #45556c #90a1b9 #cad5e2 #e2e8f0 #f1f5f9 #f8fafc
  //
  // === Gray palette (dark → light) ===
  // #030712 #101828 #1e2939 #364153 #4a5565 #6a7282 #99a1af #d1d5dc #e5e7eb #f3f4f6 #f9fafb

  colors: (
    bg-paper: rgb("#f8fafc"),
    bg-subtle: rgb("#f1f5f9"),
    brand-primary: rgb("#1d293d"),
    brand-accent: rgb("#0f172b"),
    text-main: rgb("#020618"),
    text-muted: rgb("#90a1b9"),
  ),
)

/// Merge two dicts — your overrides win.
///
/// It runs deep: nested dicts keep keys you didn't touch.
/// So `config: (colors: (brand-primary: blue))` only swaps that color.
///
/// - base (dictionary): the full defaults
/// - overrides (dictionary): what you pass in
/// -> dictionary
#let merge(base, overrides) = {
  let result = (:)
  for (k, v) in base {
    result.insert(k, v)
  }
  for (k, v) in overrides {
    if type(v) == dictionary and k in result and type(result.at(k)) == dictionary {
      result.insert(k, merge(result.at(k), v))
    } else {
      result.insert(k, v)
    }
  }
  result
}
