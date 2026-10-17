# Layouts and existing components

Import `layouts` from Lineal, then call its functions by name:

```typst
#import "@preview/lineal:0.2.0": layouts, quote, repository

#layouts.columns(widths: (2fr, 1fr), gutter: 1em,
  layouts.panel[The main argument.],
  layouts.panel[Supporting material.],
)
```

## Layout primitives

- `layouts.columns(..bodies, widths: auto, gutter: 1em, align: top)` gives each
  body an equal share, or accepts one native Typst grid track per body.
- `layouts.panel(body, fill: colour.neutral-light, ink: colour.neutral-dark,
  stroke: none, inset: 1em, radius: .35em, width: 100%, height: auto,
  breakable: false)` provides a surface with natural content height.
- `layouts.frame(body, width: 100%, height: 200pt, inset: 0pt, fill: none,
  stroke: none, radius: 0pt)` measures the content before drawing a fixed frame.
  It reports vertical overflow instead of clipping or shrinking text. Use native
  wrapping or width constraints for wide images, tables and unbreakable tokens.
  `width` accepts
  absolute, percentage and mixed lengths such as `100% - 12pt`; `height` must
  be a positive absolute length.
- `layouts.page-center(body)` centres a content block on the page.

Existing `two-boxes`, `contained`, `four-columns` and `matrix` layouts remain
available. Use the primitives above when you need different counts, widths or
colours. Native Typst `grid` and `stack` also work with all Lineal components.

## Quotes

```typst
#quote(author: [A speaker], source: [Conference talk])[
  A short quotation belongs here.
]
```

`quote(body, author: none, source: none, fill: colour.neutral-light,
ink: colour.neutral-dark, accent: colour.primary, inset: 1em, radius: .35em,
size: 1em, gap: .6em)` accepts rich content for the body and attribution.
Omit both attribution fields for an anonymous quotation. Fonts inherit from the
document.

## Repositories

```typst
#repository(
  name: "ellsphillips/lineal",
  languages: (Typst: 2, Python: 1),
)
```

`repository(name: none, languages: (:), url: auto, colors: colour.tech,
ink: colour.neutral-dark, fallback: rgb("8a9599"), size: 1em,
bar-height: .5em, gap: .5em)` accepts non-negative weights with a positive total.
Weights can be byte counts or percentages. Both the bar and its labels use the
normalised shares, so `2, 1` displays `66.7%, 33.3%`. Zero-weight entries are
omitted. Unknown language names use `fallback`.

Omit `name` to show only the language bar and legend. The default URL is
`https://github.com/` plus `name`. Override `url` for a
repository hosted elsewhere. `colors` maps lowercase language names to colours.

## Theme configuration

The public entrypoint exports `lineal-theme`, `title-slide`, `brand`, `colour`,
`config-info`, `config-colors`, `config-common` and `config-page`. These last four
functions come from the pinned Touying dependency and let you configure metadata,
colours, slide behaviour and page layout without a second import.

```typst
#show: lineal-theme.with(
  aspect-ratio: "16-9", align: top,
  footer-progress: true,
  config-info(title: [Quarterly review], author: [Your name]),
  config-colors(primary: rgb("6b3fa0"), primary-light: rgb("c8b3df")),
)
```

Theme options include `header`, `header-right`, `footer-left`, `footer-right`,
`footer-progress` and `logo`. `logo: auto` keeps the logo in `config-info`;
explicit content overrides it for the title and footer. Set a running header or
footer field to `none` to omit it. Theme colours configure the slide frame.
Individual content components accept local colours so they can also work in
ordinary Typst documents or mixed-colour slides.

`lineal-progress-bar(variant: "exact", height: 2pt, ratios: none,
accent: colour.primary, remaining: colour.primary-light)` works with or without
section headings. `broad` shows completed and remaining slides, `near` groups
previous/current/future sections, and `exact` splits the current section into
completed and remaining slides. Optional explicit non-negative `ratios` must
match the variant's two, three or four segments and have a positive total.
