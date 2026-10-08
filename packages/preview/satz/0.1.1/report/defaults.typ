// All available config keys with their default values.
// Copy sections you want to change into your project's config.typ.

#let defaults = (
  page: (
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
    binding: none,
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
  links: (
    color: rgb("#B4313F"),
    url-color: rgb("#45556c"),
  ),
  bibliography: (
    style: "apa",
  ),
  colors: (
    bg-paper: rgb("#FFFFFF"),
    bg-subtle: rgb("#F5F5F5"),
    text-main: rgb("#242422"),
    text-muted: rgb("#5e5e5a"),
    brand-primary: rgb("#111110"),
    brand-accent: rgb("#2f2f2c"),
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
