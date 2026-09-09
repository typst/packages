// All available config keys with their default values.
// Copy sections you want to change into your project's config.typ.

#let defaults = (
  page: (
    paper: "iso-b5",
    margin: (x: 2cm, top: 2.5cm, bottom: 2.5cm),
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
  colors: (
    bg-paper: rgb("#FFFFFF"),
    bg-subtle: rgb("#F5F5F5"),
    brand-primary: rgb("#111110"),
    brand-accent: rgb("#2f2f2c"),
    text-main: rgb("#242422"),
    text-muted: rgb("#5e5e5a"),
  ),
)

// Shallow merge: user overrides win
#let merge(base, overrides) = {
  let result = (: ..base)
  for (k, v) in overrides {
    result.insert(k, v)
  }
  result
}
